---
title: 'Solving a logic puzzle the right way™'
tags: [ breaks, 'capital one', puzzle, prolog, prog-langs, intern ]
category: [ Blog ]
---

I take a break from my internship with Capital One to solve a puzzle they posed:
for a chance to win!

Today, the intern group sent out a logic puzzle---correct submissions are
entered into a raffle to win prizes. What I really want to do, though, is show
how I solved it (and discuss some pitfalls along the way).

Without further ado, the puzzle:

> Valero's 5k Fun Run was held yesterday in the downtown district. Determine the
> shirt color and hometown of each of the top runners, and match each to their
> finishing time.
>
> Clues
>
> 1. Mathew finished 1 minute after Anthony.
> 2. The contestant in the white shirt was either Anthony or the runner who
>    finished in 22 minutes.
> 3. The competitor from Kamrar finished sometime after the runner from Pierson.
> 4. Salvador finished 1 minute after the runner in the maroon shirt.
> 5. Greg finished 1 minute before the competitor in the white shirt.
> 6. The contestant from Corinth didn't wear the pink shirt.
> 7. The contestant who finished in 22 minutes was either the contestant from
>    Kamrar or the contestant in the pink shirt.
> 8. The competitor who finished in 23 minutes wasn't from Corinth.

What's not clear from the description is that there is a fourth color
(aquamarine), that no two runners have the same color shirt, nor are any two
from the same town. (This becomes somewhat more obvious in the grid we were
given as an aid.)

The most egregious ambiguity, however, I will save for later.

## Cracking the puzzle in prolog

Prolog is a logic programming language: source code consists of facts and
predicates (also called functors; not to be confused with category theory).
Predicates are often notated `name/3` to mean that the predicate `name` has 3
parameters. A simple example:

```prolog
man(socrates). % socrates is a man
mortal(X) :- man(X). % X is mortal if X is a man
```

Firing up the interpreter, we can ask questions about the universe, given a set
of facts and queries:

```prolog
?- [socrates]. % This is how you load files (omit the .pl extension)
?- mortal(socrates).
true.
?- man(X).
X = socrates.
?- mortal(X).
X = socrates.
```

Different interpreters give slight different truth/false values.

Note that not only can we ask if a predicate is true for a value, but we can
ask which values satisfy a predicate! With properly coded predicates, this can
be used to generate solutions to a problem. (The process by which this occurs is
called unification, an algorithm that also lies at the heart of the
Hindley-Milner type system and inference algorithm used in Standard ML, the
precursor to OCaml and Haskell.)

A quick example of a built-in functor, `member/2` (in some prologs, this
requires loading a library, but only when used in source-code):

```prolog
?- member(1, [1,2,3]).
true.
?- member(X, [1,2,3]).
X = 1 ;
X = 2 ;
X = 3.
?- member(1, [X,Y]).
X = 1 ;
Y = 1.
```

Note that lower-case words are atoms (along with numbers and strings and such),
while upper-case words are variables for unification. And lists have the
somewhat universal `[]` syntax.

Onto the puzzle. We first decide on a representation of the solution: since we
care about the order the 4 people finished in, we'll use a list to hold the
runners in order of finish time. Each item will be a list of their name, shirt
color, and town:

```prolog
% Sol = [[Name, Color, Town] times 4]
% the list is ordered by finish time, which is then mapped to 21,22,23,24
solve(Sol) :-

    Sol = [[Name1, Color1, Town1],
           [Name2, Color2, Town2],
           [Name3, Color3, Town3],
           [Name4, Color4, Town4]],
```

Then, we add some uniqueness constraints:

```prolog
    % puzzle constraints
    permutation([Name1, Name2, Name3, Name4], [anthony, greg, mathew, salvador]),
    permutation([Color1, Color2, Color3, Color4], [aquamarine, maroon, pink, white]),
    permutation([Town1, Town2, Town3, Town4], [corinth, janesville, kamrar, pierson]),
```

Then we iterate the puzzle constraints:

```prolog
    %1
    nextto([anthony, _, _], [mathew, _, _], Sol),
    %2
    (member([anthony, white, _], Sol) ; nth1(2, Sol, [_, white, _])),
    %3
    (append(Left, Right, Sol),
        member([_, _, pierson], Left),
        member([_, _, kamrar], Right)),
    %4
    nextto([_, maroon, _], [salvador, _, _], Sol),
    %5
    nextto([greg, _, _], [_, white, _], Sol),
    %6
    \+member([_, pink, corinth], Sol),
    %7
    (nth1(2, Sol, [_, _, kamrar]) ; nth1(2, Sol, [_, pink, _])),
    %8
    \+nth1(3, Sol, [_, _, corinth]).
```

Or at least, so we think.

In one early version of this solution, I had the argument order for `nth1/3`
backwards, giving me bogus answers. In another, I had forgotten to encode the
uniqueness of the shirt colors and towns, so my solutions had more than one
person in the same shirt or from the same town!  (Aside: I would love to know if
there's a more elegant way to encode those than completely destructing the
solution.)

But the really, truly, frustrating thing is that the interpreter gives two
solutions to these constraints!

```prolog
?- [race].
?- solve(S).
S = [[greg, pink, pierson], [anthony, white, kamrar], [mathew, maroon, janesville], [salvador, aquamarine, corinth]] ;
S = [[greg, maroon, pierson], [salvador, white, kamrar], [anthony, pink, janesville], [mathew, aquamarine, corinth]] ;
```

Worse, working through the constraints, both are entirely valid---unless you
read *or* as *exclusive or*! Then, Anthony can no longer be wearing the white
shirt, and the second solution is the only valid one. Some claim `;` is supposed
to mean exclusive or, others that is logical or (which isn't exclusive). Alas,
I found no easy way to rectify the final code (below) to account for this
oddity short of mapping `a ; b` to `(a, \+b ; b, \+a)`, which I find ugly.

```prolog
% vim: ft=prolog

:- use_module(library(lists)).

% Sol = [[Name, Color, Town] times 4]
% the list is ordered by finish time, which is then mapped to 21,22,23,24
solve(Sol) :-

    Sol = [[Name1, Color1, Town1],
           [Name2, Color2, Town2],
           [Name3, Color3, Town3],
           [Name4, Color4, Town4]],

    % puzzle constraints
    permutation([Name1, Name2, Name3, Name4], [anthony, greg, mathew, salvador]),
    permutation([Color1, Color2, Color3, Color4], [aquamarine, maroon, pink, white]),
    permutation([Town1, Town2, Town3, Town4], [corinth, janesville, kamrar, pierson]),

    %1
    nextto([anthony, _, _], [mathew, _, _], Sol),
    %2
    (member([anthony, white, _], Sol) ; nth1(2, Sol, [_, white, _])),
    %3
    (append(Left, Right, Sol),
        member([_, _, pierson], Left),
        member([_, _, kamrar], Right)),
    %4
    nextto([_, maroon, _], [salvador, _, _], Sol),
    %5
    nextto([greg, _, _], [_, white, _], Sol),
    %6
    \+member([_, pink, corinth], Sol),
    %7
    (nth1(2, Sol, [_, _, kamrar]) ; nth1(2, Sol, [_, pink, _])),
    %8
    \+nth1(3, Sol, [_, _, corinth]).
```
