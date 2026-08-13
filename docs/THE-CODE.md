# The code

## Everything happens inside the interrupt

This game's main program is two bytes: a jump to itself. The real work happens
in the timer hook, which the BIOS calls on every screen refresh, and which does
three things in this order: services the sound, moves the penguin and the
clock, and takes **one step** of the state machine.

That third step can take longer than a frame, so it's protected by a latch. If
the previous pass is still working, this one skips the step entirely and leaves
by the side door instead of re-entering. The frame is lost and nothing breaks.

## The state machine

One byte says what state the game is in —0 to 15— and another says which step
within that state. Each frame runs whichever step is due and that's that. The
sixteen destinations are:

| | | | |
|---|---|---|---|
| 0 | idle | 8 | the control menu |
| 1 | start the intro | 9 | set up the stage |
| 2 | raise the logo | 10 | enter the stage |
| 3 | wait | 11 | **the game** |
| 4 | draw the banner | 12 | time up |
| 5 | wait | 13 | end of game |
| 6 | wipe | 14 | the finish |
| 7 | the demo | 15 | the map of Antarctica |

And the normal path is: intro, demo, menu, set up, map, enter, play, finish,
and back to setting up the next one. Run out of clock instead and you leave via
12 and 13 and land back in the demo.

What makes this readable are six chained routines that serve as exits. Each
does its bit and **falls into the next**, most to least: the top three move to
the next state and zero the step, the bottom three only move to the next step,
and the ones with a wait leave a counter set before they fall. With those,
nearly every step in the game ends in a three-letter jump.

## The dispatcher, with the table tucked behind the CALL

The heart of all this is ten bytes:

```asm
DESPACHA:
    add a,a           ; the index, doubled
    pop hl            ; ...and this is NOT something off the stack
    call SUMA_A_HL
    ld e,(hl)
    inc hl
    ld d,(hl)
    ex de,hl
    jp (hl)
```

The `pop hl` isn't picking up anything anybody pushed: it picks up **the return
address**, which is precisely the byte after the `call`. And that's where the
table is. So the caller writes the table right behind the call, and the
dispatcher finds it without anyone passing it along.

It's elegant, and it has an awkward side effect: a tracer following the flow
walks straight into the table and reads pointers as if they were instructions.
Which is why this cartridge's six tables are declared by hand.

The good news is they bound themselves. Each table's last word ends **exactly**
on the byte where its own first destination begins, so only one size is
possible: try N entries and only one N closes. All six close, and between them
they give 42 destinations.

There's also a second dispatcher that works differently. Instead of indexing
addresses it indexes **code**: four chunks of exactly four bytes, laid out so
the index lands squarely on one of them. It drives the four moves that trace
the route across the map.

## The controls, and three places they come from

Whatever's being pressed always ends up in the same byte, in the same format:
four directions and two buttons. But it can come from three different places,
and a single flag byte decides which: from the joystick via the sound chip,
from the keyboard by reading two rows of the matrix and shuffling the bits, or
**from a recording carried inside the cartridge**, which is what drives the
demo.

Since all three end up in the same place with the same shape, the rest of the
game has no idea which one it's using.

## The penguin is four sprites

A sprite on this MSX is 16x16, so the penguin is built from four of them in a
square: 32x32 pixels. Only the first one's position is tracked, and the other
three come from adding sixteen across, down, or both.

The poses live in a table of ten, four bytes each, being the four pictures each
sprite gets. Changing pose is copying four bytes at a stride.

Walking is three poses rotating every eight frames. Jumping is eleven steps,
one every four, with a twelve-entry curve that lifts the penguin four pixels
and puts him back down; and if the button was pressed with a direction held,
he also moves sideways at double speed. Falling is twenty-one steps with its
own curve and its own table of rolls.

## Obstacles are six-byte slots

There's room for four obstacles at once, and five from the fifth stage on. Each
takes a slot:

| | |
|---|---|
| +0 | which step it's on, 1 to 15; 0 means the slot is free |
| +1 | the type, 0 to 6 |
| +2 | pointer to the piece of artwork due now |
| +4 | pointer to the four bytes the collision is checked against |

The interesting one is that artwork pointer, because it **advances by itself**.
The 92 pieces between 0x6BE9 and 0x7241 aren't screens: each one places between
one and six tiles, which makes them increments. The slot runs the piece it's
due, saves where it stopped, and carries on from there next step. Accumulated,
what you see is the obstacle coming closer.

That this is the right reading checks itself: chain the fifteen steps of all
seven types and the seven chains **tile the whole region without a single byte
left over**, each one ending exactly where the next begins.

## Drawing is executing

The scenery down the sides and the pieces of track are written in a small
language, and there's a 45-byte interpreter that runs it. One byte says which
column and which third to start in, and then, per row, an offset followed by
the tiles written consecutively; a high byte closes the row and opens the next,
and a zero closes the block.

With that, the side scenery comes out of a two-level tree —four groups of
four— and the sixteen blocks hanging off it tile their region without a gap.

## The track turns without moving a single pixel

The horizon row isn't drawn straight onto the screen. It's composed in memory:
32 tiles, with two bytes in front saying where on screen they go and one byte
behind closing it off. When the track has to bend, what happens is that this
row gets **rotated** with a single block-copy instruction, one way or the
other, and sent again.

Which bend is due at any moment comes out of a table of nibbles, two bends to a
byte, and there are seven different horizon pictures —straight, bending one
way, bending the other, and the four for arriving at a base— picked by index.

## The sound: the number is the priority

Three channels, one per chip voice, with ten bytes of state each. To ask for a
sound you pass a number, and that number does two things at once: it says which
stream plays and **how much authority it has**. If what's already playing has a
higher number, the request dies right there.

The number also says how many channels it takes: below 0x8A just one, up to
0x8C two, and above that all three. Effects take one channel and music takes
three, so an effect never cuts a tune in half.

Each note is **one byte**: the low nibble is the note within a twelve-note
chromatic octave, and the high nibble is the duration, looked up in another
table of twelve sitting right next to the first. Both have twelve entries and
they're side by side, which rather invites reading them as the same thing; they
aren't. Going up an octave is doubling the period as many times as needed, and
there's a control byte to change it, another to repeat a section and another to
finish.

Of the twenty-four stream pointers, one points outside the cartridge —sound
zero, which is never asked for— and three point at the same place: an
end-of-stream byte. That's the silence, and it's what the startup asks for to
leave the chip quiet before it begins.
