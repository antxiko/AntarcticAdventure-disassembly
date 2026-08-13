# Antarctic Adventure (Konami, 1984, MSX) — a commented disassembly

A 16 KB Konami cartridge from 1984, taken apart byte by byte. All 16,384
bytes are bounded and owned, and inside there's a penguin crossing Antarctica
between ten research bases, an attract mode that plays back from a recording
like a pianola roll, and one base you never get to.

📖 **[Full documentation](https://antxiko.github.io/AntarcticAdventure-disassembly/)**
· [En castellano](https://antxiko.github.io/AntarcticAdventure-disassembly/es/)
· [README en castellano](README.es.md)

---

## What this is

*Antarctic Adventure* is a 1984 Konami cartridge for the MSX, reference
RC-701. This repository holds its code, commented, along with the tools to
rebuild it and to check that the result is really the original.

Being a cartridge changes the shape of the job. There's no loader and no
blocks to wait for: the machine maps the 16 KB at 0x4000-0x7FFF and that's the
whole picture, one snapshot of memory with no overlaps. The BIOS reads an "AB"
header, calls the entry point at 0x4010, and from there the code never returns
— the startup drops into an empty two-byte loop and **the entire game runs
inside the interrupt**, fifty or sixty times a second.

There isn't a single variable in the cartridge either, because it's ROM. All
the state lives in the machine's RAM from 0xE000 up, which is why the listing
is full of addresses starting 0xE0 that aren't data at all.

## How you know this is true

`make` traces the flow, generates the listing and demands that assembling it
gives back exactly the original:

```
  ensamblado : 16384 bytes  17f4dd65...8065126
  original   : 16384 bytes  17f4dd65...8065126
OK: reproducible byte a byte
```

That's the test that settles whether a disassembly can be trusted, but it
isn't the only one here, because a listing can reassemble perfectly and still
be lying: if some artwork is read as instructions the bytes don't change, only
what we say about them does. So two more checks run alongside:

- no range declared as data may come out as code;
- and no entry point may fall inside one.

## The numbers

| | |
|---|---|
| bytes of code | 5,947 |
| bytes of data | 10,437 |
| bytes unexplained | **0** |
| named labels | 394 |
| anchored comments | 264 |
| data ranges with an explanation | 62 |

## A few things that turned up

- **The attract mode is a recording.** 64 bytes carrying exactly the joystick's
  own bits, read one every 32 frames. No intelligence behind it at all.
- **The first thing the cartridge does is write over itself**, copying
  `jp 0000h` on top of its own dispatcher. On a cartridge that does nothing;
  from a copy in RAM it would reset the machine on the first frame.
- **There's a research base nobody visits**: NEW ZEALAND is in there, spelled
  out, and not one instruction points at it.
- **The alphabet has no F.** The one word in the game that needs one, FRANCE,
  carries its own, stored well away from the rest of the letters.
- **Up brakes and down accelerates**, and braking takes three times as long as
  accelerating.

There's more, with the evidence, on
[the findings page](https://antxiko.github.io/AntarcticAdventure-disassembly/FINDINGS.html).

## What's still open

The listing is complete and every byte is accounted for, but nothing has been
measured in an emulator yet: what's read explains what the program does, not
what the player sees. Two things wait on that, and they're listed with the
rest on
[the open-questions page](https://antxiko.github.io/AntarcticAdventure-disassembly/OPEN-QUESTIONS.html).

## Getting started

You need `pasmo`, `z80dasm` and Python 3. The cartridge is **not** distributed
here: put your own copy in the project root as `antarctic.rom`, 16384 bytes,
sha256 `17f4dd654c937134c44c1faf68a9f67141d69ccf251853228aa5211dc8065126`.

```sh
make          # trace, build the listing and check everything
make verify   # just the acid test
make web      # rebuild the site under docs/
```

Full instructions are in
[Getting started](https://antxiko.github.io/AntarcticAdventure-disassembly/GETTING-STARTED.html).

## Licence and attribution

The game is not ours: *Antarctic Adventure* is Konami's, and all rights in it
remain with its holders. What is ours — the tools, the comments, the analysis
and the documentation — is published under the licence in `LICENSE`. The
cartridge image is not distributed. See [LEGAL-NOTICE.md](LEGAL-NOTICE.md).
