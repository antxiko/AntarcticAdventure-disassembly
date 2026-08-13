# Legal notice and attribution

*(También disponible [en castellano](AVISO-LEGAL.md).)*

## Who owns what

**The game is not ours.** *Antarctic Adventure* (1984) was published by
**Konami**, reference RC-701. All rights in the game remain with its holders.

**What is ours** are this repository's tools, the listing's comments, the
analysis and the documentation. Those are published under the licence in
`LICENSE`.

## What this repository contains

The file `src/antarctic.asm` is the commented disassembly of the cartridge. It
is published for the **preservation, study and documentation** of a 1984 title
that is part of the MSX's software history.

The cartridge image (`.rom`) is **not** distributed here. Anyone wanting to
rebuild the listing has to supply their own, and the `Makefile` checks its
sha256 before doing anything.

The images under `docs/` are not screen captures taken from the game: they're
generated from the binary's own data with this repository's tools,
decompressing what the game decompresses and using the memory bases the game
itself writes into the graphics chip's registers. They are part of the proof
that the format is properly understood.

## What it leans on

Nothing of anyone else's. Everything claimed here comes from reading this
binary, and each claim carries its evidence alongside: the instruction that
reads a piece of data, the table that closes exactly where it must, or the
arithmetic that adds up on its own. What isn't settled is stated as such on the
open-questions page.

## If you're one of the authors

If you worked on *Antarctic Adventure* or hold rights in the game, and you'd
rather this material weren't published, **say so and it comes down, no
argument**. The intent of this work is the exact opposite of harming you: it's
to put on record how it was made.
