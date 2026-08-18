# The versions

> **Which build is which is not settled.** There are several different builds of
> this cartridge, and what this page says about **versions and regions** may
> change. The listing and the numbers come from the binary either way, and `make`
> reproduces them.

There are three different builds of this cartridge, and what changes between
them goes well beyond translating a label: the background colour changes, the
route changes, and so does every single conversation the code has with the
hardware.

## Which ROM this is

All three are disassembled here, each in its own folder under `src/`, and all
three reassemble byte for byte into their own ROM with not a byte left
unaccounted for. The one commented from top to bottom is the **second Japanese
version**, which is worth saying up front because it isn't the one you'd
expect.

    first Japanese     087378ddad1379a6e378f0810e9cf1dbb64ee03c36e630bb78020b754b7dfebd
    second Japanese    a33f9298bf6f740ebe8d88bdc8ed75c855404d804e07679d6c2f2ad00dc3c452
    European           9b13aaa66661b69a8a9a19656d2d9fd052ddae11aba752e84ebb38b03137739a

All three files are 16384 bytes on the nose, and none of them is distributed
here. If you have them, `make compara` prints everything this page claims in
one go.

A warning, because dirty dumps of this game go around: some are 32 KB with the
same 16 KB repeated twice, and some are the same file under another name. Start
with the sha256, always.

## The three at a glance

|  | first Japanese | European | second Japanese |
|---|---|---|---|
| background and border | black | black | **dark blue** |
| hardware ports written directly | 31 | 31 | **0** |
| BIOS calls | 0 | 0 | **14** |
| system hooks neutralised at boot | no | no | **yes** |
| three-byte copy at boot | no | no | **yes** |
| title screen label | `VIDEO CARTRIDGE` | `VIDEO CARTRIDGE` | **`KONAMI`** |
| NEW ZEALAND | **you go there** | sits unused | sits unused |
| the demo starts on its own | yes | **no** | yes |
| the `KEYBOABD` typo | **yes** | no | no |
| the South Pole | **four graphics of its own** | `THE SOUTH POLE` | `THE SOUTH POLE` |

None of the three resembles another in the binary: 14869 bytes differ between
the first and the European, 15350 between the European and the second, and
15443 between the first and the second. These are separate builds with the code
moved around, not variants with a patch on top.

What's interesting is how they group. On the game's map the European goes with
the second Japanese; on how it treats the machine it goes with the first. The
changes arrive in two batches, and the European sits in the middle.

## First batch: the map changes

All three carry the same eight base-name strings inside, plus a table of ten
pointers handing them out across the ten stages. The first version hands them
out like this:

    JAPAN, AUSTRALIA, AUSTRALIA, FRANCE, NEW ZEALAND, the Pole,
    USA, USA, ARGENTINA, UNITED KINGDOM

and the other two like this:

    FRANCE, USA, the Pole, USA, USA, ARGENTINA,
    UNITED KINGDOM, JAPAN, AUSTRALIA, AUSTRALIA

It's the same trip round the world rotated by three, with one real change:
where the first sends you to New Zealand, the others repeat the United States.
The NEW ZEALAND string stays in the cartridge, whole, with nothing pointing at
it. That index, by the way, is the base you **arrive at**: index 0 is where you
set off from and also where the lap closes, on the tenth stage.

Two more text changes come in the same batch. The label for the Pole base,
which on the first version isn't letters at all but four graphics of its own —
patterns 0xCE to 0xD1, which turn up in no other word in the game — gets
spelled out as `THE SOUTH POLE`. And each string starts carrying two bytes in
front giving the exact spot on screen where it goes, which is what centres it:
0x3AC8 for the fourteen-letter ones, 0x3ACE for the three letters of USA.

## Second batch: the whole machine layer changes

This is where the second Japanese version parts company with the other two, and
it isn't a video-chip detail: it's the entire hardware layer, counted
instruction by instruction across the three listings.

|  | BIOS calls | ports written directly |
|---|---|---|
| first Japanese | 0 | 31 |
| European | 0 | 31 |
| second Japanese | **14** | **0** |

The first two never call the BIOS at all and talk to the chips directly: nine
accesses to video data, four to its registers, thirteen to the sound chip and
five to the circuit that reads the keyboard. And both do it identically, down
to the number of times, so the European changed none of this.

The second Japanese version doesn't write a single port. The same work goes
through fourteen BIOS calls: `WRTVDP` for the video registers, `SETRD` and
`SETWRT` to point at video memory, `RDVDP` to read its status, `WRTPSG` and
`RDPSG` for sound and the controls, and `SNSMAT` for the keyboard.

The difference matters because on an MSX there's no guarantee where the chips
are. The standard says the video port should be read from the BIOS work area,
and that's exactly what it does:

    ld a,(00006h)   ; the VDP data port, which the BIOS keeps there
    ld c,a

where the other two carry the number inside the instruction itself, in routines
like this one, which is their entire routine for writing a video register:

    di / ld a,e / out (099h),a / ld a,d / out (099h),a / ret

And the boot code does something the other two don't: before hooking its
interrupt routine, it **fills the system's 512 bytes of reserved hooks with
RETs**, disabling whatever any attached extension had put there.

The background comes along for the ride. Background and border colour come from
register 7 of the chip, and all three set it at boot and never touch it again
for the rest of the game: 0xE1 on the first two, which is black, and 0xE4 on
the second Japanese, which is dark blue.

## What only the European has: no demo

Leave the first or second Japanese version sitting there and after a while a
demonstration game starts on its own. On the European one it never does, and
the reason is a single instruction.

The game runs off a sixteen-slot state machine, and all sixteen destinations
line up one to one across the three versions. All but one: state 5, the one
that waits on the title screen.

    second Japanese   ld hl,0E004h / dec (hl) / ret nz / jp <next state>
    European          ret

On the other two, that state counts a frame timer down and, when it reaches
zero, moves to the next state — the wipe, and from there the demo. On the
European, state 5 is **a bare `ret`**: it counts nothing and goes nowhere, so
the title screen sits there until somebody presses a key.

The nice part is that the countdown is still in the cartridge **one byte
further along**, whole, with nothing pointing at it. It turns up as orphaned
code while checking that not a byte is left unaccounted for, long before you
know why it's there.

## Another sign that the first one is the first

On the first Japanese version the menu label reads `KEYBOABD` instead of
`KEYBOARD`. It's at 0x57B9, with a B where the R goes. The other two have it
fixed.

## The three-byte copy at boot

Which brings us to the thing only the second Japanese version has. Its INIT
copies three bytes from 0x411F — which are `C3 00 00`, that is, `jp 0000h` —
over the top of 0x0000, the BIOS entry point and the machine's boot vector:

    ld hl,411Fh / ld de,0000h / ld bc,0003h / ldir

That's ROM, so the write is lost and nothing happens.

Neither the first Japanese version nor the European carries any of this: the
copy doesn't exist anywhere in those two, not even the three loose bytes at
0x411F.

What it does is settled by reading the bytes; **what it's for can't be proved
from the binary**. The reading that fits is a guard against running the
cartridge from RAM, since the write only lands anywhere if what's there isn't
ROM, and on a real cartridge it's an instruction you never notice: it checks
nothing and warns about nothing. But that's a reading, not a measurement.

## What we don't know

The four graphics the first version writes the South Pole with still haven't
been read. They're compressed like the rest of the artwork, and getting them
out would need that version's own addresses.
