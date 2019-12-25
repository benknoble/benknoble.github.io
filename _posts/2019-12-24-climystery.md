---
title: 'A terminal case of mysteries'
tags: [ awk, mystery, shell ]
category: Blog
---

I play through [clmystery](https://github.com/veltman/clmystery), and log the
journey here.

> Note, I have elided some of the experimentation done between commands, and
> thus substituted `!!` where appropriate---it stands for the last command
> executed.
>
> In the same vein, `G` is an alias for `grep(1)`, `S` for `sed(1)`, and `A` for
> `awk(1)`---these are very real and I use them regularly.

## Instructions

```
.OOOOOOOOOOOOOOO @@                                   @@ OOOOOOOOOOOOOOOO.
OOOOOOOOOOOOOOOO @@                                    @@ OOOOOOOOOOOOOOOO
OOOOOOOOOO'''''' @@                                    @@ ```````OOOOOOOOO
OOOOO'' aaa@@@@@@@@@@@@@@@@@@@@"""                   """""""""@@aaaa `OOOO
OOOOO,""""@@@@@@@@@@@@@@""""                                     a@"" OOOA
OOOOOOOOOoooooo,                                            |OOoooooOOOOOS
OOOOOOOOOOOOOOOOo,                                          |OOOOOOOOOOOOC
OOOOOOOOOOOOOOOOOO                                         ,|OOOOOOOOOOOOI
OOOOOOOOOOOOOOOOOO @          THE                          |OOOOOOOOOOOOOI
OOOOOOOOOOOOOOOOO'@           COMMAND                      OOOOOOOOOOOOOOb
OOOOOOOOOOOOOOO'a'            LINE                         |OOOOOOOOOOOOOy
OOOOOOOOOOOOOO''              MURDERS                      aa`OOOOOOOOOOOP
OOOOOOOOOOOOOOb,..                                          `@aa``OOOOOOOh
OOOOOOOOOOOOOOOOOOo                                           `@@@aa OOOOo
OOOOOOOOOOOOOOOOOOO|                                             @@@ OOOOe
OOOOOOOOOOOOOOOOOOO@                               aaaaaaa       @@',OOOOn
OOOOOOOOOOOOOOOOOOO@                        aaa@@@@@@@@""        @@ OOOOOi
OOOOOOOOOO~~ aaaaaa"a                 aaa@@@@@@@@@@""            @@ OOOOOx
OOOOOO aaaa@"""""""" ""            @@@@@@@@@@@@""               @@@|`OOOO'
OOOOOOOo`@@a                  aa@@  @@@@@@@""         a@        @@@@ OOOO9
OOOOOOO'  `@@a               @@a@@   @@""           a@@   a     |@@@ OOOO3
`OOOO'       `@    aa@@       aaa"""          @a        a@     a@@@',OOOO'


There's been a murder in Terminal City, and TCPD needs your help.

To figure out whodunit, go to the 'mystery' subdirectory and start working from there.

You'll want to start by collecting all the clues at the crime scene (the 'crimescene' file).

The officers on the scene are pretty meticulous, so they've written down EVERYTHING in their officer reports.

Fortunately the sergeant went through and marked the real clues with the word "CLUE" in all caps.

If you get stuck, open one of the hint files (from the CL, type 'cat hint1', 'cat hint2', etc.).

To check your answer or find out the solution, open the file 'solution' (from the CL, type 'cat solution').

To get started on how to use the command line, open cheatsheet.md or cheatsheet.pdf (from the command line, you can type 'nano cheatsheet.md').

Don't use a text editor to view any files except these instructions, the cheatsheet, and hints.
```

All I have to say is, please format your text to 80-columns wide, and eschew
unnecessary line breaks, please.

## Automating checking

The first thing I did is check that `solution` file, and then extract the
command-line for checking into a script that amounts to


```bash
#! /usr/bin/env bash
main() {
  if echo "$1" \
    | "$(command -v md5 || command -v md5sum)" \
    | grep -qi ../encoded
    then
    echo CORRECT\! GREAT WORK, GUMSHOE.
  else
    echo SORRY, TRY AGAIN.
  fi
}

main "$@"
```

## On a hunt

Now it's time to look for clues:

```
λ G CLUE crimescene
CLUE: Footage from an ATM security camera is blurry but shows that the perpetrator is a tall male, at least 6'.
CLUE: Found a wallet believed to belong to the killer: no ID, just loose change, and membership cards for AAA, Delta SkyMiles, the local library, and the Museum of Bash History. The cards are totally untraceable and have no name, for some reason.
CLUE: Questioned the barista at the local coffee shop. He said a woman left right before they heard the shots. The name on her latte was Annabel, she had blond spiky hair and a New Zealand accent.
```

(I understand the necessity of omitting line-breaks here, but ugh.)

Let's look for Annabel, then:

```
λ G Annabel people
Annabel Sun	F	26	Hart Place, line 40
Oluwasegun Annabel	M	37	Mattapan Street, line 173
Annabel Church	F	38	Buckingham Place, line 179
Annabel Fuglsang	M	40	Haley Street, line 176
```

Well, crap, there's more than one. At least the data is tabular.

But, wait, the interviews are organized by *number*! Of course… No matter, we'll
have to find her properly:

```bash
λ !! |
fields {5..9} |
S -e 's/ /_/1' -e 's/, line / /g' -e 's/^/streets\//' |
while read -r f l ; do
  S -n "${l}p" "$f"
done
SEE INTERVIEW #47246024
SEE INTERVIEW #9437737
SEE INTERVIEW #699607
SEE INTERVIEW #871877
```

Hm, let's check those interviews:

```bash
λ !! | fields 3 | cut -c2- | while read -r i ; do cat interviews/*-"$i" ; done
Ms. Sun has brown hair and is not from New Zealand.  Not the witness from the cafe.
Doesn't appear to be the witness from the cafe, who is female.
Interviewed Ms. Church at 2:04 pm.  Witness stated that she did not see anyone she could identify as the shooter, that she ran away as soon as the shots were fired.

However, she reports seeing the car that fled the scene.  Describes it as a blue Honda, with a license plate that starts with "L337" and ends with "9"
Mr. Fuglsang is male and has brown hair.  Not the witness from the cafe.
```

(That [fields script]({% link _posts/2019-09-11-fields.md %}) couldn't be more
sweet now.)

We are now looking for the car, a blue Honda with license plate L337\*9:

```bash
λ G 'L337.*9' vehicles
License Plate L337ZR9
License Plate L337P89
License Plate L337GX9
License Plate L337QE9
License Plate L337GB9
License Plate L337OI9
License Plate L337X19
License Plate L337539
License Plate L3373U9
License Plate L337369
License Plate L337DV9
License Plate L3375A9
License Plate L337WR9
```

Well, crap. That's not helpful. But a quick glance at `head vehicles` shows the
information comes *after* the plate line… who designs these formats, anyway?

```bash
λ !! | G -B2 -A3 'Blue' | G -B1 -A4 'Honda'
License Plate L337QE9
Make: Honda
Color: Blue
Owner: Erika Owens
Height: 6'5"
Weight: 220 lbs
--
--
License Plate L337539
Make: Honda
Color: Blue
Owner: Aron Pilhofer
Height: 5'3"
Weight: 198 lbs
--
--
License Plate L337369
Make: Honda
Color: Blue
Owner: Heather Billings
Height: 5'2"
Weight: 244 lbs
--
--
License Plate L337DV9
Make: Honda
Color: Blue
Owner: Joe Germuska
Height: 6'2"
Weight: 164 lbs
--
--
License Plate L3375A9
Make: Honda
Color: Blue
Owner: Jeremy Bowers
Height: 6'1"
Weight: 204 lbs
--
--
License Plate L337WR9
Make: Honda
Color: Blue
Owner: Jacqui Maher
Height: 6'2"
Weight: 130 lbs
```

I need to limit this suspect list further… what clues do we still have? Oh
right, suspect is male and at least 6' tall. I can limit it to 6' quickly, but
getting only males is harder.

Why don't I grab the males first, then convert that to a grep pattern? No, too
many people; let's try grabbing the males from the 6' list. First, the
owners:

```bash
λ !! | G -B4 -A1 "6'" | G Owner | cut -c8-
Erika Owens
Joe Germuska
Jeremy Bowers
Jacqui Maher
```

Now, joining that with the males list:

```bash
λ join <(!! | sort) <(A '$3 == "M"' people | sort)
Jeremy Bowers Bowers M 34 Dunstable Road, line 284
Joe Germuska Germuska M 65 Plainfield Street, line 275
```

Well, that's a lot smoother.

My only other clue is the wallet, but it has to be one of these two men, so
let's check both. (Spoiler: it's neither of them?)

Drat, do we have interviews?

```bash
λ !! |
fields {6..9} |
S -e 's/ /_/1' -e 's/, line//g' |
while read -r s i ; do
  S -n "${i}p" streets/"$s"
done
SEE INTERVIEW #9620713
SEE INTERVIEW #29741223
```

Yes, yes we do!

```bash
λ !! | fields 3 | cut -c2- | while read -r i ; do cat interviews/*-"$i" ; done
Home appears to be empty, no answer at the door.

After questioning neighbors, appears that the occupant may have left for a trip recently.

Considered a suspect until proven otherwise, but would have to eliminate other suspects to confirm.
Should not be considered a suspect, has no SkyMiles membership and has never been a member of the Museum of Bash History.
```

So looks like Jeremy Bowers needs further investigating? Or maybe I need new
suspects… where could I get those?

The wallet! Suspect is a member of

- AAA
- Delta SkyMiles
- the local library
- and the Museum of Bash History

Fortunately, the memberships files are lists of names. A sort/join should do the
trick---but we need to consider the whole line for the join:

```bash
λ join -t$'\t' <(sort memberships/AAA) <(sort memberships/Delta_SkyMiles) \
| join -t$'\t' - <(sort memberships/Terminal_City_Library) \
| join -t$'\t' - <(sort memberships/Museum_of_Bash_History)
Aldo Nicolas
Andrei Masna
Augustin Lozano
Brian Boyer
Dalibor Vidal
Deron Estanguet
Didier Munoz
Emma Wei
Jacqui Maher
Jamila Rodhe
Jeremy Bowers
Kelly Kulish
Krystian Pen
Liangliang Miller
Marina Murphy
Mary Tomashova
Matt Waite
Mike Bostock
Monika Hwang
Nikolaus Milatz
Sonata Raif
Stephanie Adlington
Tamara Cafaro
```

Interesting… Jacqui Maher, who we eliminated because she was female, is on this
list! Could the ATM footage have actually shown a tall female? Let's find out:

```bash
λ G Jacqui people |
fields {5..9} |
S -e 's/ /_/1' -e 's/, line//g' |
while read -r s i ; do S -n "${i}p" streets/"$s"; done |
fields 3 |
cut -c2- |
while read -r i ; do cat interviews/*-"$i"; done
Maher is not considered a suspect. Video evidence confirms that she was away at a professional soccer game on the morning in question, even though it was a workday.
```

Damn!

Alright, Jeremy Bowers is on the membership list, and I've just about
exhausted my suspect pool… should I track down the remaining vehicle owners? Try
all the membership folks? I'm at a bit of loss… time for dinner!

---

I've returned after a quick lasagna, and reviewed the case files---it turns out,
my checker script was wrong!

I forgot that `grep(1)` reads data to search from standard in, while the
original usage is to read a *pattern* from standard in. Let's clean that up:

```bash
if grep -qi "$( "$(command -v md5 || command -v md5sum)" <<<"$1" )" ../encoded
then
  echo CORRECT\! GREAT WORK, GUMSHOE.
else
  echo SORRY, TRY AGAIN.
fi
```

Now, let's try our friend Jeremy again…

```bash
λ ./check 'jeremy bowers'
CORRECT! GREAT WORK, GUMSHOE.
```

Nailed that perp!

Coming soon: a live, interactive, on-the-web version?
