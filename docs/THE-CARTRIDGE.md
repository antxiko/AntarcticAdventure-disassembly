# The cartridge

It's 16384 bytes, and that's it. No loader, no blocks, nothing to wait for: the
MSX maps the cartridge at 0x4000-0x7FFF and what's there is what's there,
permanently. That makes the byte budget far cleaner than it usually is, because
there aren't two different things living at the same address at different
moments: one single snapshot of memory, no overlaps.

## Where it comes in

The first sixteen bytes are the header the BIOS reads:

    41 42 10 40 00 00 00 00 00 00 00 00 00 00 00 00
    'A' 'B'  \_ INIT = 0x4010

The two letters are the signature telling the machine there's an executable
cartridge here, followed by four two-byte vectors. Only the first is filled in:
the other three —the ones that would add statements to BASIC or declare a
device— are zero. This cartridge is a game and nothing else.

So the BIOS finishes bringing the machine up and calls 0x4010. And from there
it never comes back.

## What the startup does

Not much, and all of it deliberate:

- turns interrupts off and fills the BIOS's 512 bytes of hooks with `ret`, so
  none of them does anything;
- installs its own on the timer hook, the one the BIOS calls on every screen
  refresh;
- puts the stack at 0xE400 and clears the 2 KB just above it, which is where
  the whole game state is going to live;
- writes the graphics chip's registers, silences the sound chip and zeroes
  video memory;
- and drops into an empty two-byte loop.

That empty loop is the main program. **From then on the entire game runs inside
the interrupt**, fifty or sixty times a second, and the thread that started the
machine never does anything again.

## Where the state lives

There isn't a single variable in the cartridge, because it's ROM. Everything
the game keeps track of lives in the MSX's RAM from 0xE000 upwards, which is
why the listing is full of addresses starting 0xE0: they aren't cartridge data,
they're variables.

The ones read most:

| | |
|---|---|
| 0xE000 | the game state, 0 to 15 |
| 0xE001 | the step within that state |
| 0xE003 | the frame counter, which serves as a clock for everything |
| 0xE005 | the latch stopping the interrupt from treading on itself |
| 0xE009 | what's being pressed, with the previous frame's at 0xE008 |
| 0xE040 | the high score, with the score at 0xE043 |
| 0xE078 | the penguin's four sprites |
| 0xE100 | the speed |
| 0xE112 | the obstacle slots |

## The screen, laid out backwards

The game doesn't settle for what the BIOS leaves behind: it writes the graphics
chip's eight registers itself, from an eight-byte table it carries. And the
layout it ends up with is the opposite of the usual one.

| | |
|---|---|
| 0x0000 | the colours |
| 0x1800 | the sprite patterns |
| 0x2000 | the patterns |
| 0x3800 | the name table |
| 0x3B00 | the sprite attributes |

The normal arrangement has patterns low and colours high; here it's the other
way round, and that matters more than it sounds, because drawing the cartridge
with the bases swapped **doesn't produce an error**: it produces a picture, and
a convincing one at that, since a colour table read as artwork looks a lot like
artwork. That's why this repository's tools take the bases from the registers
the game writes, and not from a constant typed in by hand.

The mode is the 256x192 graphics one with unmagnified 16x16 sprites, and the
border ends up dark blue.

## Three banks, and sixteen flat-colour tiles

In this mode the screen splits into three thirds, each with its own set of 256
tiles. The cartridge sets all three up identically to begin with: the same
typeface and the same graphics written three times over, 1792 bytes of pattern
and another 1792 of colour in each third.

And there's one detail that pays for itself: **the first sixteen tiles of each
third are flat colour squares**, one per palette entry. They're built by hand,
uncompressed, by writing the colour number eight times over. With those,
painting the sky or the ice costs no artwork at all: you fill the row with the
tile of whatever colour you want.

## And everything else is compressed

Not a single graphic sits there raw. There's a 61-byte decompressor reading a
format you can follow at a glance —one byte says whether what follows repeats
so many times or is so many bytes taken as they come— and four separate doors
into it depending on where the destination has to come from, or on whether the
picture needs mirroring on the way in.

Of the cartridge's 16 KB, 10437 bytes are data and 5947 are code.

## The full layout

Not one byte without an owner. Here's what's there, top to bottom:

| | |
|---|---|
| 0x4000-0x4010 | the header |
| 0x4010-0x44DF | startup, interrupt, controls and the state machine |
| 0x44DF-0x4787 | video, strings, decompressor and the panel |
| 0x4787-0x4843 | the per-stage scenery tables |
| 0x4843-0x4A01 | the title banner, video memory access and the map |
| 0x4A01-0x4B01 | the map artwork, the route and the ten stages |
| 0x4B01-0x53E1 | the penguin, collisions, the track and the obstacles |
| 0x53E1-0x55D9 | the bends and the seven horizons |
| 0x55D9-0x5839 | the base names, the flags and the on-screen labels |
| 0x5839-0x588A | the title screen and the demo recording |
| 0x588A-0x6BE9 | the typeface and all the artwork, compressed |
| 0x6BE9-0x7241 | the 92 pieces the obstacles are built from |
| 0x7241-0x7519 | the scenery tree |
| 0x7519-0x78C1 | the finish, the fish, the speed and the background sprites |
| 0x78C1-0x79C9 | the frames of the creature from the holes |
| 0x79C9-0x7B37 | the sound player |
| 0x7B37-0x7EB7 | the notes, the durations and the sound streams |
| 0x7EB7-0x8000 | the padding up to 16 KB |
