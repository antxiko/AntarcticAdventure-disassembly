# Getting started

## What you need

`pasmo` and `z80dasm` to assemble and disassemble, and Python 3 for the tools.
That's all: nothing to install, no environment to set up.

The cartridge isn't distributed with this repository, only the documentation
work, so you'll need your own copy named `antarctic.rom` in the project root.
It's exactly 16384 bytes and has to give this sha256:

    17f4dd654c937134c44c1faf68a9f67141d69ccf251853228aa5211dc8065126

If yours doesn't, it's a different version and the listing won't reassemble.
`make comprueba` tells you in one line.

## The commands

```sh
make          # trace, build the listing and check everything
make verify   # just the acid test: does the cartridge come back out?
make graficos # decompress the artwork and dump it to PNG
```

Plain `make` runs the whole cycle and fails if anything doesn't add up: if the
listing stops reproducing the cartridge byte for byte, if the tracer has walked
into a range declared as data, or if an entry point falls inside one.

## The test that settles it

The only thing that makes a disassembly trustworthy is that it gives the
original back. Here that's `make verify`, which assembles the published listing
and compares the sha256 against the cartridge:

    ensamblado : 16384 bytes  17f4dd65...8065126
    original   : 16384 bytes  17f4dd65...8065126
    OK: reproducible byte a byte

As long as that line shows up, no comment in this repository can have eaten a
byte along the way.

## Without the cartridge

You can still read `src/antarctic.asm` and the notes, which is where the work
actually lives: 394 named routines, 269 comments anchored to their address, and
63 data ranges with an explanation beside each one.

## How it's laid out

The listing is **never edited by hand**. It's generated, and three files govern
it:

| | |
|---|---|
| `src/antarctic.entries` | the entry points: where tracing starts |
| `src/antarctic.nocode` | the ranges that are NOT code, and how we know |
| `src/antarctic.notes` | the names, the comments and the data ranges |

Out of those comes `src/antarctic.asm`. If you want to change a comment or name
a routine, it goes in the `.notes`, anchored to its address; that way the
comment survives a re-trace and never drifts away from the instruction it
explains.

That separation is exactly what stops the listing and its verification from
diverging over time, because the file that gets published is the same one that
gets checked.

## The tools

Everything you need is in `tools/`, and each one carries in its header what it
does and why it was built that way:

| | |
|---|---|
| `z80trace.py` | follows the flow from the entry points |
| `mkasm.py` | assembles the listing with the anchored notes |
| `descomprime.py` | the game's decompressor, reimplemented |
| `refs.py` | what instructions point into a range, without inventing pointers |
| `render_tiles.py` | draws the tiles and sprites from video memory |
| `render_banderas.py` | the flags of the ten stops |
| `render_decorados.py` | the scenery, using the game's own interpreter |
| `render_pista.py` | the seven obstacles, built up step by step |
| `render_foca.py` | the seal that comes out of the holes, frame by frame |
| `render_pinguino.py` | the penguin's ten poses, in its own colour |
