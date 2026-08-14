# Findings

What turned up when the cartridge came apart, with the evidence alongside.
Everything on this page checks out by reading the binary; what isn't settled yet
is in [Open questions](OPEN-QUESTIONS.html).

## The demo is a recording

Left alone, the game starts a session that plays itself. There's no
intelligence behind it: there are 64 bytes at 0x584A carrying exactly the same
bits the joystick returns, and the input reader takes one every 32 frames. In
between it holds the previous direction, so the recording runs at a very coarse
rate and still does the job.

You can see it in the bytes themselves: `01` is up, `09` up and right, `11` up
and button. Not one value falls outside the controller's bit map.

And the length works out too. The demo runs 0x073C steps, which at one byte
every 32 is 58 of the 64 that are there. The run ends exactly where the next
routine's first instruction begins.

## The first thing the cartridge does is write over the BIOS

Between bringing the machine up and starting the game sit these four
instructions:

```asm
    ld hl,0411fh      ; source: three bytes that read C3 00 00, i.e. jp 0000h
    ld de,00000h      ; destination: 0x0000, the BIOS entry point
    ld bc,00003h
    ldir
```

On an MSX that does absolutely nothing, because 0x0000 is ROM and the write
goes nowhere.

The cartridge's other two builds carry none of this: neither the first Japanese
version nor the European one has these four instructions, not even the three
loose bytes at 0x411F. It belongs to this one.

What it does is settled by reading the bytes; **what it's for can't be proved
from the binary**. The reading that fits is a guard against running the
cartridge from RAM, since the write only lands anywhere if what's there isn't
ROM. But that's a reading, not a measurement.

## There's a base you never reach

The cartridge carries eight base names and the route has ten stops. Seven of
those names cover the ten —the United States turns up three times and Australia
twice— and the eighth, **NEW ZEALAND**, is asked for by nobody.

Checked three separate ways, because one check isn't enough here:

- it isn't among the name table's ten entries;
- no instruction points at it, walking only instruction starts;
- and not one of that string's twenty addresses appears as a word anywhere in
  the cartridge's 16 KB.

The other seven do show up pointed at, so the check works and NEW ZEALAND's
zero means something.

## The seal comes out of the hole in eight steps

Three of the seven obstacles —the holes— have a seal come out of them, and it's
all there in the cartridge: eight frames, one per step from 7 to 14, with the
table at 0x78C1. That table's index is easy to read backwards, and the mistake
is a convincing one: it looks like the obstacle type and it's **the step it's
on**. Read the other way you get pointers that walk off the end of the
cartridge; read right, you get eight in a row, and the last frame ends exactly
on the one that hides the seal, which in turn ends where code starts again.

The first three steps are two sprites and the remaining five are four, and each
frame carries three variants. But all three carry the same picture: the only
thing that changes is the X, because one seal comes up through the centre, one
veers right and one veers left. And from step 10 to 14 the same happens with the
other coordinate —the four pictures are always the same and it's the Y that
drops— so the seal doesn't deform as it approaches: it just moves.

And the colour isn't in there. The routine that assembles it copies three bytes
per sprite —position and picture— and **skips the fourth**, which is precisely
the colour one: that was left in place by the attribute list, which gives the
first sprite black and the other three dark red. Since on an MSX the
lowest-numbered sprite goes in front, the black one ends up on top and what you
see is a brown seal with a dark face.

## The clouds come at you and pass overhead

There are four clouds in the sky, and they aren't part of the scenery: they're
four sprites the game drives separately. They come up at fixed spots, rise up
the screen at a rate set by the penguin's speed —half of it, exactly— spread
outwards with a drift of their own each (-1, +1, -2 and +2) and change picture
along the way, to a bigger one.

All of that together is perspective: the cloud grows and spreads because you're
closing on it, and it rises because it ends up passing over your head. At the
very top it switches off and comes back up from below.

And they only show up in a real game. In the demo the sky is empty.

## The yellow feet aren't a new picture

When the penguin falls down a hole and flails about in there, you can see two
yellow feet moving. There's no new sprite for that: it's **the same sprite that
serves as his shadow**, with two instructions changing its colour from dark
blue to yellow. From then on it's just a matter of feeding it the three
flailing pictures, and on the way out another instruction gives it back its own
picture and its shadow colour.

It's the same idea used all over the cartridge: **a sprite's colour doesn't
live in its picture**, it lives in its entry in the attribute table. So
anything can be recoloured without touching a single byte of artwork, and
that's what's done with the shadow here, with the seal —whose dark face is a
second black sprite laid over the red body— and with the flags, all ten of
which come out of the same pair of sprites with their two colours swapped.

## And one yellow sprite that never shows up

The attribute list has one entry set up completely —number 14, with its picture
and its yellow colour in place— that never appears in play. And the picture is
not just anything: it's **a sun**, a disc of yellow spikes. It's built with its
vertical coordinate at 0xE0, which is off the screen, and nobody ever changes
it: there isn't a single instruction writing to that entry, the chain that
rebuilds the sprites on the way out of the water stops at the one before it,
and the other copies start higher up or end lower down.

So the cartridge loads the picture, reserves its slot, gives it a colour… and
leaves it out of frame.

And this isn't deduced from reading the binary. Over a twenty-five minute
recorded game, a watchpoint on that entry's four bytes says the only things
touching it are sweeps of the whole table —the sprite clear, the list copier—
and none of them is aiming at it; when the game ends it's still got its vertical
coordinate at 0xE0. And changing **just those two position bytes** in a copy of
the cartridge, without touching its picture or its colour, brings it into the
sky where it shows perfectly: a yellow spiked sun against the blue.

## The alphabet has no F

The typeface is laid out so a tile's number is its ASCII minus 0x20, so A is
0x21, B is 0x22 and so on. By that arithmetic, F ought to be at 0x26.

It isn't: that tile holds a different picture, in all three thirds of the
screen. And the one word in the whole game that needs an F —**FRANCE**, the
route's first base— brings its own: its string doesn't use 0x26 but 0xC9, a
lone F kept apart, nowhere near the alphabet.

## Half of talking to the screen was never used

The routines dealing with the graphics chip come in pairs: one to write and its
exact twin to read. Both writers are used constantly, ten and six times
respectively.

Neither reader is called by anyone. And that can be said flatly, because one of
their addresses **never appears in the 16 KB at all**, and the only appearance
of the other is the call its own dead twin makes to it.

This game never reads the screen. It only writes.

## There's a two-player mode left in the wiring

There's a routine that writes a string followed by a `1` or a `2`, taken from
bit 7 of the flag word. Nobody calls it —its address doesn't appear in the
cartridge— and on top of that nobody ever sets that bit, because the only two
values ever written there are 0x40 and 0x50.

Matching that, the panel's label reads **1P**, fixed, written into the label
string as one more constant.

## The tables give themselves away

Working out where a table ends is usually the worst part of a disassembly,
because the size isn't written down anywhere and getting it wrong raises no
error at all.

In this cartridge nearly all of them say so. The table's last word ends exactly
on the byte where its own first destination starts, so only one size is
possible: try N entries and only one N closes. It works for the six jump
tables, the ten stages, the ten flags, the seven horizons, the twenty-four
sounds and the five stretches of the finish.

And there's a second house trick, this one to save instructions: **three tables
are pointed at one byte before they begin**, because their index is never zero
and that saves a `dec a`. The byte-zero of one of them is the last byte of a
`jp`; of another, a stray `ret` that serves as data without ceasing to be a
`ret`.

## The seven obstacles tile their region without a byte left over

Between 0x6BE9 and 0x7241 there are 92 pieces of artwork, and the only clue to
what they're for is that the obstacle table's seven pointers land inside.

Chain the fifteen steps each obstacle lasts and this comes out:

    type 3   6BE9 -> 6D85      type 2   7091 -> 7150
    type 4   6D85 -> 6F19      type 6   7150 -> 71C8
    type 0   6F19 -> 6FD2      type 5   71C8 -> 7241
    type 1   6FD2 -> 7091

Each chain ends precisely where the next begins, and the last ends precisely at
the end of the region. The seven share out all 92 pieces with nothing spare and
nothing missing, and that confirms both the fifteen-step count and that the
chaining is being read correctly.

A nice detail from that: all seven pointers point at an **empty** block. It
isn't a misreading — an obstacle's first step draws nothing because it's still
behind the horizon, and two of the seven carry two empty steps.

## What looks like an inverted throttle is a period

The table governing speed has four destinations, one per combination of up and
down. Pressing nothing does nothing, pressing both does nothing either, and the
other two do the obvious thing: up accelerates and down brakes.

It reads backwards very easily, because **up is the one that SUBTRACTS**. And it
subtracts because 0xE100 doesn't hold the speed but the period: how many frames
go by between two advances. Its three uses say so. Two countdown timers are
reloaded from it —the distance one with half of it, at 0x46DC, and the track one
with a quarter, at 0x5334— and the speedometer has to invert it with a `cpl` to
draw the bar. Less period is more speed, and flat out is 8.

They don't cost the same, either. Each step of acceleration takes twelve frames
and each step of braking only four, so the penguin lets his speed go three
times faster than he picks it up.

The rule that comes out of this is good for any disassembly: **a variable that
gets reloaded into a countdown timer is a period, not a magnitude**. Before
calling something a speed, check whether the game uses it to count frames.

## The two tables of twelve that aren't the same thing

Next to the sound player sit two twelve-byte tables, right up against each
other. The first is a chromatic octave, and it shows: the twelve periods land
0.09 semitones from equal temperament.

The second invites the same reading, and isn't. Measured as a scale it gives
15.8 semitones, which is no scale at all. What it actually is shows in the code
that uses it: each note's high nibble indexes it to get **how long the note
lasts**. They're durations, and they run from 5 to 100 frames.

## Silence is a stream that ends on its first byte

Of the twenty-four sound pointers, the first points outside the cartridge.
That's not a mistake: sound zero is never asked for, so that entry is never
read.

And the last three all point at the same byte, which is an `0xFF`, the end of a
stream. That's the silence, and it's what the startup asks for to leave the
chip quiet before anything starts.
