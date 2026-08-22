# Antarctic Adventure (Konami, 1984, MSX) — a commented disassembly

> **Which build is which is not settled.** There are several different builds
> of this cartridge, and what this repository says about **versions and
> regions** may change. The listing and the numbers come from the binary either
> way, and `make` reproduces them.

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
  ensamblado : 16384 bytes  a33f9298...dc3c452
  original   : 16384 bytes  a33f9298...dc3c452
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
| anchored comments | 713 |
| data ranges with an explanation | 63 |

## A few things that turned up

- **The attract mode is a recording.** 64 bytes carrying exactly the joystick's
  own bits, read one every 32 frames. No intelligence behind it at all.
- **The first thing the cartridge does is write over the BIOS**, copying
  `jp 0000h` on top of 0x0000. That's ROM, so nothing happens; and that
  instruction is the only thing telling apart the dumps of this version that go
  around.
- **There's a research base nobody visits**: NEW ZEALAND is in there, spelled
  out, and not one instruction points at it. On the first Japanese version of
  the cartridge you do go there, and it's the fifth stop on the route.
- **The alphabet has no F.** The one word in the game that needs one, FRANCE,
  carries its own, stored well away from the rest of the letters.
- **0xE100 doesn't hold the speed but its period**: the more frames it waits,
  the slower he goes, so accelerating means subtracting from it. And braking
  takes a third of the time accelerating does.

There's more, with the evidence, on
[the findings page](https://antxiko.github.io/AntarcticAdventure-disassembly/FINDINGS.html).

There are three different builds of this cartridge, and the one taken apart
here is the **second Japanese version**. What changes between them — the
background colour, the route, even how they talk to the video chip — is on
[the versions page](https://antxiko.github.io/AntarcticAdventure-disassembly/THE-VERSIONS.html).

## What's still open

The listing is complete and every byte is accounted for, but nothing has been
measured in an emulator yet: what's read explains what the program does, not
what the player sees. One thing waits on that, and they're listed with the
rest on
[the open-questions page](https://antxiko.github.io/AntarcticAdventure-disassembly/OPEN-QUESTIONS.html).

## Getting started

You need `pasmo`, `z80dasm` and Python 3. The cartridge is **not** distributed
here: put your own copy in the project root as `antarctic.rom`, 16384 bytes,
sha256 `a33f9298bf6f740ebe8d88bdc8ed75c855404d804e07679d6c2f2ad00dc3c452`.

```sh
make          # trace, build the listing and check everything
make verify   # just the acid test
make graficos # decompress the artwork and dump it to PNG
```

Full instructions are in
[Getting started](https://antxiko.github.io/AntarcticAdventure-disassembly/GETTING-STARTED.html).

## Licence and attribution

The game is not ours: *Antarctic Adventure* is Konami's, and all rights in it
remain with its holders. What is ours — the tools, the comments, the analysis
and the documentation — is published under the licence in `LICENSE`. The
cartridge image is not distributed. See [LEGAL-NOTICE.md](LEGAL-NOTICE.md).
