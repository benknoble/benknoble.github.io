#lang scribble/lp2/manual

@(require (for-label
            (except-in racket _)
            racklog
            rackunit racket/generator
            racklog))

@title{Solving Boggle}
@author{D. Ben Knoble}

Having recently read Jay McCarthy's
@hyperlink["http://jeapostrophe.github.io/2012-05-14-boggle-post.html"]{A Boggle
Solver}, and remembering my brother's similar C assignment for an NC State
course, I decided to give it a go.

The part I really remember from working with my brother was the flood-fill "is
the input a word in the grid" algorithm. This relates to McCarthy's solver,
which generates words with a similar flood-fill and tests for their presence in
a trie-like dictionary.

@section[#:style 'non-toc]{Setup}

We'll use McCarthy's board representation, which is a hash mapping
(@italic{x}, @italic{y}) coordinates to letters. @margin-note{Aside: I would like
to find a way to express this without @racket[for*/fold], but I have a feeling
it would still involve computing the cartesian product.}

@chunk[<board>
        (define board-n 4)
        (define board
          (for*/fold ([cell->char (hash)])
            ([row (in-range board-n)]
             [col (in-range board-n)])
            (hash-set cell->char (cons row col) (random-letter))))]

We'll also keep the printer,

@chunk[<printer>
        (for ([row (in-range board-n)])
          (for ([col (in-range board-n)])
            (display (hash-ref board (cons row col))))
          (newline))]

which can be re-written with @racket[for-each].

@chunk[<printer-for-each>
        (for-each (λ (row)
                    (for-each (λ (col)
                                (display (hash-ref board (cons row col))))
                              (range board-n))
                    (newline))
                  (range board-n))]

@section{Racket checker}

Now we need to implement our flood-fill for checking an input. We have to check
every possible starting place, and we cannot re-use blocks.

@chunk[<checker>
        (define (check word board)
          (ormap (curry check-start word board)
                 (hash-keys board)))]

Given a word, a board, and a starting location, how do we know if the word is
there? First, we cannot re-use a block. We handle that with a slight trick:
@racket[hash-ref] takes a default argument, which we can use to build a test
that will always fail when the coordinate is not in the board. If we
(functionally) remove coordinates from the board before recurring, this will do
it.

Then, we have to have the same letter at the starting location and the start of
the word. The default argument to @racket[hash-ref] also takes care of the
out-of-bounds cases.

@chunk[<step-starting-letter>
        (eq? (hash-ref board c #false) (string-ref word 0))]

Then, and only then, can we recur on the other possible directions with a
shortened word. Note that we do re-visit the same location, but that should
immediately bail out as false because it will already have been seen
(@racket[<step-starting-letter>] takes care of it).

@chunk[<step-recur>
        (let ([new-board (hash-remove board c)])
          (for*/or ([dx (in-list '(-1 0 1))]
                    [dy (in-list '(-1 0 1))])
            (check-start (substring word 1)
                         new-board
                         (cons (+ (x c) dx)
                               (+ (y c) dy)))))]

But wait! If we're shortening the word, we need to check for an empty case to
bail out: that's how we know we found the word along a path.

@chunk[<step-found-it>
        (zero? (string-length word))]

Putting it all together gives us the following, which embeds the rules that

@itemlist[@item{we found the word, or}
          @item{@itemlist[@item{the word starts at the current position, and}
                          @item{we found the rest starting in one of the eight adjacent positions.}]}]

@chunk[<checker-start>
        (define (check-start word board c)
          (or <step-found-it>
              (and <step-starting-letter>
                   <step-recur>)))]

Altogether, aside from the gnarly C details, this is not unlike the solution my
brother and I came up with. Of course, the @racket[for*/or] macro hides the
insane code-duplication that our C program exhibited, and for that I am
grateful.

@section{Testing}

Right, now we'd like some tests. We want to make sure our checker works on every
word in the board (up to some maximum length), and on no words in the board.
With the randomization we're doing, and the lack of a dictionary, these "words"
won't necessarily be real words. But they will be (in)valid paths in the Boggle
board.

The general structure will be something like this.

@chunk[<tests>
        (for ([word (find-words board maximum-word-length)])
          (check-in-board word board))]

And @racket[check-in-board] is straightforward.

@chunk[<check-in-board>
        (define (check-in-board word board)
          (check-true (check word board)))]

Similarly, we'll have

@chunk[<check-not-in-board>
        (define (check-not-in-board word board)
          (check-false (check word board)))]

Now, how can we program @racket[find-words]? We're going to use the same idea,
though this time by generating a sequence, since we don't need to materialize
the entire list at once. @racket[find-words] will find all the words on a board
up to length @racket[maximum-word-length] and below length
@racket[minimum-word-length], since Boggle words are at least 3 letters. It does
so by chaining the sequences of words found from each starting position.

@chunk[<find-words>
        (define (find-words board maximum-word-length)
          (code:comment "chain the list of sequences")
          (apply in-sequences
                 (map (curry find-words-at board maximum-word-length)
                      (hash-keys board))))]


To find the words from each starting position, we'll lean on McCarthy's code
some more, though instead of printing words from a dictionary we'll
@racket[yield] all of them. We'll use @racket[in-generator] to produce a
sequence directly, which we then chain with @racket[in-sequences] above.

@chunk[<find-words-at>
        (define (find-words-at board maximum-word-length c)
          (in-generator
            (let loop ([board board]
                       [path empty]
                       [c c])
              (define char (hash-ref board c #f))
              (when char
                <step-get-new-path>
                <step-yield-word>
                <step-loop>))))]

 A quick test on my machine says it takes about 1.5s
to find all the words in a 4x4 grid of length between 3 and 8. Not slow, but not
as fast as I would like. (Without printing, it's about half a second.)
Following McCarthy's approach, we first get the new path.

@chunk[<step-get-new-path>
        (define new-path (cons char path))]

Then, we @racket[yield] the word if we have one.

@chunk[<step-yield-word>
        (when (<= minimum-word-length (length new-path) maximum-word-length)
          (yield (list->string (reverse new-path))))]

Lastly, unless the board is empty or we have reached our maximum path length, we
loop over all the new possibilities.

@chunk[<step-loop>
        (unless (or (zero? (hash-count board))
                    (>= (length new-path) maximum-word-length))
          (define new-board (hash-remove board c))
          (for* ([dx (in-list '(-1 0 1))]
                 [dy (in-list '(-1 0 1))])
            (loop new-board new-path
                  (cons (+ (x c) dx)
                        (+ (y c) dy)))))]

Testing all those words does take some time! Roughly 6s, for me. But there is a
lot of duplicated work, since some words are the same as others in terms of
which paths they take. Also, the work is embarrassingly parallel (@italic{i.e.},
sub-tasks are independent), so parallelization might make a difference here.

At this point, it would be interesting to try to generate words not in the board
to make sure the implementation of @racket[check] isn't just

@chunk[<check-bad>
        (define check (const #t))]

But I think this is enough for now.

@section{Do it again!}

Now that I have that working in Racket, I want to see if I can make a Prolog
version work. Why? Because the same relation can determine if a word is on the
board or produce a set of possible words: bidirectional Prolog relations capture
the backtracking in our solution (from recursion) as well as handling the
duality of the checker and the generator. Let's see it in SWI Prolog first, then
we'll try building it in Racket.

Some example queries, showing the timing as well as the bidirectional use:

@verbatim|{

% load the program
?- ["boggle"].
true.

% make a 3x3 board
?- boggle:make_board([[a,b,c], [d,e,f], [g,h,i]], B).
% I won't show the large board structure defined by the association lists.
% The key is that the mapping is correct.
B = … .

% make a 3x3 board and check the element at (1,2), which is f
?- boggle:make_board([[a,b,c], [d,e,f], [g,h,i]], B), get_assoc(1-2, B, V).
B = … , V = f.

% check a particular word "adhf"
?- boggle:make_board([[a,b,c], [d,e,f], [g,h,i]], B), get_assoc(1-2, B, V),
    boggle:board_has_word(B, [a,d,h,f]).

% find all the words in a 3x3
?- boggle:make_board([[a,b,c], [d,e,f], [g,h,i]], B),
    setof(W, N^(boggle:board_has_word(B, W),length(W, N), N #>= 3), S).
B = … ,
S = [[a, b, c], [a, b, c, e], [a, b, c, e, d], [a, b, c, e, d|...], [a, b, c, e|...], [a, b, c| ...], [a, b|...], [a|...], [...|...]|...].

% timing the solver
?- boggle:make_board([[a,b,c], [d,e,f], [g,h,i]], B),
    time(setof(W, N^(boggle:board_has_word(B, W),length(W, N), N #>= 3), S)).
% 2,502,809 inferences, 0.864 CPU in 0.880 seconds (98% CPU, 2896937 Lips)
B = … ,
S = [[a, b, c], [a, b, c, e], [a, b, c, e, d], [a, b, c, e, d|...], [a, b, c, e|...], [a, b, c| ...], [a, b|...], [a|...], [...|...]|...].

}|

Running the entire solver on a 4x4 with @tt{setof} runs out of memory after
about 40 seconds, even with a 2-gigabyte limit, but can find solutions
one-at-a-time via backtracking more quickly than can be measured, starting with
a depth of only about 30 inferences after the first 500. If we constrain the
maximum length of the word, too, we obtain results with a 2-gigabyte limit:

@verbatim|{
?- boggle:make_board([[a,b,c,d], [e,f,g,h], [h,i,j,k], [l,m,n,o]], B),
    time(setof(W, N^(boggle:board_has_word(B, W),length(W, N), N #>= 3, N #=< 8), S)).
% 2,982,360,271 inferences, 698.309 CPU in 702.722 seconds (99% CPU, 4270830 Lips)
B = … ,
S = [[a, b, c], [a, b, c, d], [a, b, c, d, g], [a, b, c, d, g|...], [a, b, c, d|...], [a, b, c| ...], [a, b|...], [a|...], [...|...]|...].
}|

@(define 4x4-seconds 702)
@(define 4x4-minutes (/ 4x4-seconds 60))

And yes, that's @italic{@(number->string (exact->inexact 4x4-minutes)) minutes}.
Impractical. But it made almost three billion inferences at a rate nearly double
that of the previous queries, so I forgive it.

Interestingly, re-ordering the solver clauses on the 3x3 to do the length check
first slows the query down significantly: I suspect we spend a lot of time
trying to match specific lengths with real words, so we duplicate certain work
again and again, rather than gathering up the possible words upfront and
filtering them down. The number of inferences appears to confirm this.

@(define aborted-seconds 2607)
@(define aborted-minutes (/ aborted-seconds 60))

I did abort this query after @(number->string (exact->inexact aborted-minutes))
minutes; in that time, it worked through eleven billion inferences and wasn't
anywhere near done as best I can tell. Compare that to previous versions that
only needed 2.5 million inferences to run in less than a second.

@verbatim|{
?- boggle:make_board([[a,b,c], [d,e,f], [g,h,i]], B),
    time(setof(W, N^(length(W, N), N #>= 3, boggle:board_has_word(B, W)), S)).
^CAction (h for help) ? abort
% 11,123,831,833 inferences, 2577.157 CPU in 2607.577 seconds (99% CPU, 4316318 Lips)
% Execution Aborted
}|

Here's the full listing. The important pieces are @tt{make_board},
and @tt{board_has_word}.

@filebox["boggle.pl"]{@verbatim|{
% vim: ft=prolog

:- module(boggle, [make_board/2, board_has_word/2]).

:- use_module(library(assoc)). % assoc-list (AVL trees) predicates
:- use_module(library(clpfd)). % #= and related constraints
:- use_module(library(lists)). % member
:- use_module(library(apply)). % maplist, foldl
:- use_module(library(yall)). % [x]>>f(x) lambda syntax

product(As, Bs, Cs) :-
    findall(A-B, (member(A, As), member(B, Bs)), Cs).

range(N, L) :-
    NN #= N-1,
    bagof(X, between(0, NN, X), L).

coords(N, Coords) :-
    range(N, ToN),
    product(ToN, ToN, Coords).

square(Xss, N) :-
    length(Xss, N),
    maplist([Xs]>>length(Xs, N), Xss).

make_board_fold_helper(Chars, X-Y, Acc, New) :-
    nth0(X, Chars, Row),
    nth0(Y, Row, Char),
    put_assoc(X-Y, Acc, Char, New).

make_board(Chars, B) :-
    square(Chars, N),
    coords(N, Coords),
    empty_assoc(B0),
    foldl(make_board_fold_helper(Chars), Coords, B0, B).

% +B, ?W
board_has_word(B, W) :-
    assoc_to_keys(B, Cs),
    member(C, Cs),
    board_has_word(B, W, C).

board_has_word(_, [], _).

board_has_word(B, [First|W], X-Y) :-
    get_assoc(X-Y, B, First),
    member(DX, [-1, 0, 1]),
    member(DY, [-1, 0, 1]),
    NewX #= X + DX,
    NewY #= Y + DY,
    del_assoc(X-Y, B, _, NewB),
    board_has_word(NewB, W, NewX-NewY).
}|}

Let's work through @tt{board_has_word} first, since it's the interesting
core of the solver.

The binary relation @tt{board_has_word/2} relates a word @tt{W} to a
board @tt{B} if-and-only-if there is some @tt{C} (a coordinate) in the
board such that the trinary relation @tt{board_has_word/3} holds. That
trinary relation is like our helper @racket[check-start]: it holds if the word
is in the board starting at that coordinate.

Just like @racket[check-start], @tt{board_has_word/3} has two cases:

@itemlist[
    @item{Either the word is empty, in which case we do indeed have a word in
    the board, or}
    @item{The word is some first character and the rest of the word.}
]

In the latter case, we need that the current position matches
(à la @racket[<step-starting-letter>]), and that the rest of the word starts
from one of the adjacent positions (à la @racket[<step-recur>]).

It's a remarkably concise spec, considering it's able to encompass both the
checker and the generator. It's not quite as fast as the Racket version, but
could possibly be improved. Combine a solver query from above with a clause
asserting the found word is in some dictionary, and you have something like
McCarthy's solver!

Now, @tt{make_board} relates a (necessarily ground) list of characters
(which can be anything; here I use simple atoms), as long as it is a square
list-of-lists, to a board structure. It does so with a list of coordinates
computed from a cartesian product, which it folds over to repeatedly add
characters to the board. This is essentially what @racket[<board>] does, but
without randomness.

The rest is the helper predicates and the boiler-plate of declaring a Prolog
module and importing libraries (some of which is SWI Prolog-specific).

@section{And a third time}

Prolog down, if inefficiently. Can we make this available to Racket?
@racketmodname[racklog] looks promising, but has a very small set of
primitives. If we can implement enough of the required predicates
(with the right modes) using Racket functions, we can build this thing in
@racketmodname[racklog].

Here are some queries similar to those from the Prolog version. This first
version uses association lists with @math{O(n)} access, so the programs are much
slower than the Prolog equivalents (which use AVL trees). So I'm showing 2x2 and
3x3s. Times reported are in milli-seconds.

@verbatim|{
> (time (void (%which (S)
                (%let (B W N)
                  (%set-of W (%and (%make-board '((a b) (d e)) B)
                                   (%board-has-word B W)
                                   (%is N (length W))
                                   (%>= N 3))
                           S)))))
cpu time: 166 real time: 166 gc time: 14
> (time (void (%which (S)
                (%let (B W N)
                  (%set-of W (%and (%make-board '((a b c) (d e f) (g h i)) B)
                                   (%board-has-word B W)
                                   (%is N (length W))
                                   (%>= N 3))
                           S)))))
cpu time: 68845 real time: 68909 gc time: 5595
> (time (void (%which (S)
                (%let (B W N)
                  (%set-of W (%and (%make-board '((a b c) (d e f) (g h i)) B)
                                   (%board-has-word B W)
                                   (%is N (length W))
                                   (%>= N 3)
                                   (%<= N 8))
cpu time: 69356 real time: 69437 gc time: 5868
}|

After switching to hashes, I get the following times. They aren't really any
faster, though I'll still present the hash-based version.

@verbatim|{
> (time (void (%which (S)
                (%let (B W N)
                  (%set-of W (%and (%make-board '((a b) (d e)) B)
                                   (%board-has-word B W)
                                   (%is N (length W))
                                   (%>= N 3))
                           S)))))
cpu time: 191 real time: 191 gc time: 34
> (time (void (%which (S)
                (%let (B W N)
                  (%set-of W (%and (%make-board '((a b c) (d e f) (g h i)) B)
                                   (%board-has-word B W)
                                   (%is N (length W))
                                   (%>= N 3))
                           S)))))
cpu time: 68330 real time: 69054 gc time: 4990
}|

Mutable hashes would probably be faster, but I would have to be more careful to
not mutate logical values that are referred to in other places
(or else to undo the mutation). That's too tricky for this version.

Let's take a look. The core functionality is strikingly similar to the Prolog
code.

@chunk[<racklog-core>
        (define %make-board-fold-helper
          (%rel (Chars X Y Acc New Row Char)
            [(Chars (cons X Y) Acc New) (code:comment "-")
             (%is Row (list-ref Chars X))
             (%is Char (list-ref Row Y))
             (%put-assoc (cons X Y) Acc Char New)]))

        (define %make-board
          (%rel (Chars B N Coords B0)
            [(Chars B) (code:comment "-")
             (%square Chars N)
             (%coords N Coords)
             (%empty-assoc B0)
             (%foldl (curry %make-board-fold-helper Chars)
                     Coords B0 B)]))

        (define %board-has-word
          (%rel (B W Cs C First X Y DX DY NewX NewY NewB)
            [(B W) (code:comment "-")
             (%assoc-to-keys B Cs)
             (%member C Cs)
             (%board-has-word B W C)]
            [((_) empty (_))]
            [(B (cons First W) (cons X Y)) (code:comment "-")
             (%get-assoc (cons X Y) B First)
             (%member DX '(-1 0 1))
             (%member DY '(-1 0 1))
             (%is NewX (+ X DX))
             (%is NewY (+ Y DY))
             (%del-assoc (cons X Y) B (_) NewB)
             (%board-has-word NewB W (cons NewX NewY))]))]

I've gotten into the habit of putting @tt{;-} after my clause heads to remind me
of Prolog. Scribble doesn't render it in the code as well as inline here, where
it looks a lot like Prolog's @tt{:-}.

But we still have to define quite a bit of machinery to make this work. This is
mostly self-explanatory: building (moded) relations out of Racket functions.

@chunk[<racklog-machine>
        (define %product
          (%rel (As Bs Cs A B)
            [(As Bs Cs) (code:comment "-")
             (%set-of (cons A B)
                      (%and (%member A As)
                            (%member B Bs))
                      Cs)]))

        (code:comment "spoofed from https://stackoverflow.com/a/8608389/4400820")
        (define %between
          (%rel (Low High Value NewLow)
            [(Low High Low)]
            [(Low High Value) (code:comment "-")
             (%is NewLow (add1 Low))
             (%<= NewLow High)
             (%between NewLow High Value)]))

        (define %range
          (%rel (N L NN X)
            [(N L) (code:comment "-")
             (%is NN (sub1 N))
             (%bag-of X (%between 0 NN X) L)]))

        (define %coords
          (%rel (N Coords ToN)
            [(N Coords) (code:comment "-")
             (%range N ToN)
             (%product ToN ToN Coords)]))

        (define %square
          (%rel (Xss N)
            [(Xss N) (code:comment "-")
             (%is N (length Xss))
             (%andmap (λ (Xs) (%is N (length Xs))) Xss)]))

        (define %empty-assoc
          (%rel ()
            [((hash))]))

        (define %put-assoc
          (%rel (Key Assoc Val New)
            [(Key Assoc Val New) (code:comment "-")
             (%is New (hash-set Assoc Key Val))]))

        (code:comment "more general than swipl's get_assoc, since we have")
        (code:comment "-Key +Assoc -Val")
        (code:comment "+Key +Assoc ?Val")
        (code:comment "though not")
        (code:comment "-Key +Assoc +Val")
        (define %get-assoc
          (%rel (Key Assoc Val Keys)
            [(Key Assoc Val) (code:comment "-")
             (%assoc-to-keys Assoc Keys)
             (%member Key Keys)
             (%is Val (hash-ref Assoc Key #f))]))

        (define %del-assoc
          (%rel (Key Assoc Val New)
            [(Key Assoc Val New) (code:comment "-")
             (%get-assoc Key Assoc Val)
             (%is New (hash-remove Assoc Key))]))

        (define %assoc-to-keys
          (%rel (Assoc Keys)
            [(Assoc Keys) (code:comment "-")
             (%is Keys (hash-keys Assoc))]))

        (define %foldl
          (%rel (Goal H T V0 V1 V)
            [(Goal empty V V)]
            [(Goal (cons H T) V0 V) (code:comment "-")
             (Goal H V0 V1)
             (%foldl Goal T V1 V)]))]

We only need certain functionality from some relations, so I avoid generalizing
them here (@italic{e.g.}, @racket[%foldl] only has the arity-4 definition).

@section{Outro}

We've built a Boggle checker and generator in increasingly
sophisticated ways, but with increasingly worse performance! Comments on
improvements welcome.

Put the code in this order.

@chunk[<*>
        (require racket/list
                 racket/function
                 racket/set
                 racket/generator
                 racket/sequence
                 racklog
                 rackunit)

        (define letters
          (string->list "abcdefghijklmnopqrstuvwxyz"))
        (define (random-list-ref l)
          (list-ref l (random (length l))))
        (define (random-letter)
          (random-list-ref letters))

        (define x car)
        (define y cdr)

        <board>
        <printer>
        (newline)

        <checker-start>
        <checker>

        <find-words-at>
        <find-words>

        (define minimum-word-length 3)
        (define maximum-word-length 8)

        <check-in-board>
        <check-not-in-board>
        <tests>

        <racklog-machine>
        <racklog-core>
        ]
