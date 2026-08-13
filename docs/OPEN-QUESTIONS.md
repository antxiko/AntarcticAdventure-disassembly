# Open questions

Every byte of the cartridge has an owner, the listing gives the original back
byte for byte, and all 394 labels have it written down what they do. But that
isn't a list of ticked-off homework: this page says exactly what those numbers
mean, and what's left to find out.

## What each obstacle actually is

All seven are fully described from the inside —their artwork, their fifteen-step
chain, their two collision windows, what sound they make and what they score—
and three of them are known to be holes as well, because they're exactly the
three the fish comes out of.

What isn't settled is what you'd call each one looking at it. That types 5 and
6 get collected and pay 500 points is in the code; whether that's a flag, a
clump of ice or something else needs eyes on it. That's an afternoon with an
emulator, not an investigation.

## What hasn't been measured in an emulator

Everything this repository says comes from reading the binary, and that has a
very specific limit: **what you read explains what the program does, not what
the player sees**. The site's images are a strong check that the graphics are
where we say they are —get the video memory layout wrong and you'd get noise
instead of penguins— but they're no substitute for watching the game run.

That pass is still missing: boot the cartridge in an emulator, check what's on
screen against the listing, and use it to close the question above.

## What is settled, and why it can be said

So it's clear what backs each figure:

- **It reassembles byte for byte.** The published listing assembles and the
  sha256 of the result is the cartridge's. This isn't a partial check: if a
  comment had eaten a byte, that line wouldn't appear.
- **Not one byte unexplained.** All 16384 split into 5947 of code the tracer
  reaches by genuinely following the flow, and 10437 inside a declared range,
  each with the instruction that reads it written alongside.
- **No data range is read as code.** That's a separate check, and it's needed:
  a disassembly can reassemble perfectly and still be lying, if some artwork is
  being read as instructions. The bytes don't change, only what we say about
  them does.
- **No entry point falls inside a data range.** Seed the tracer with one badly
  deduced address and coverage inflates without any alarm going off, so there's
  a rule for exactly that.

## Two warnings for whoever comes next

**Axes and orderings are easy to read backwards, and getting them wrong raises
no error.** A 16x16 sprite is two halves of sixteen rows, not sixteen rows of
two bytes; read the other way it gives a convincing picture, but sliced into
strips. The same goes for the video memory bases: reading a colour table as if
it were artwork gives you something that looks like artwork. The only defence
is taking the bases from the code itself and looking at the result.

**And a call to the decompressor with no `ld hl` in front doesn't start from
scratch**: it carries on with the pointer the previous one left. That holds for
the source stream and for the destination in video memory too, which means the
order the calls run in matters. Walking the cartridge top to bottom call by
call does not reconstruct the same thing as executing it.
