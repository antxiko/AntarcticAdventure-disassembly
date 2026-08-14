# The versions

There are three different builds of this cartridge, and what changes between
them goes well beyond translating a label: the background colour changes, the
route changes, and so does the way the code talks to the video chip.

## Which ROM this is

This disassembly is of the **second Japanese version**, which is worth saying
up front because it isn't the one you'd expect. Specifically, of a dump of that
version with two bytes altered: the ones at 0x4050-0x4051, which are the
destination of the boot-time copy discussed at the end of this page.

    the dump used here   17f4dd654c937134c44c1faf68a9f67141d69ccf251853228aa5211dc8065126
    second Japanese      a33f9298bf6f740ebe8d88bdc8ed75c855404d804e07679d6c2f2ad00dc3c452
    first Japanese       087378ddad1379a6e378f0810e9cf1dbb64ee03c36e630bb78020b754b7dfebd
    European             9b13aaa66661b69a8a9a19656d2d9fd052ddae11aba752e84ebb38b03137739a

All four files are 16384 bytes on the nose, and none of them is distributed
here. If you have them, `tools/compara_versiones.py` prints everything this
page claims in one go.

A warning, because a lot of dirty dumps of this game go around: some are 32 KB
with the same 16 KB repeated twice, some are the same file under another name,
and several have a couple of bytes changed. Start with the sha256, always, and
don't trust the filename.

## The three at a glance

|  | first Japanese | European | second Japanese |
|---|---|---|---|
| background and border | black | black | **dark blue** |
| VDP accesses with the port in the opcode | 14 | 14 | **0** |
| accesses with the port read from the BIOS | 0 | 0 | **8** |
| system hooks neutralised at boot | no | no | **yes** |
| three-byte copy at boot | no | no | **yes** |
| title screen label | `VIDEO CARTRIDGE` | `VIDEO CARTRIDGE` | **`KONAMI`** |
| NEW ZEALAND | **you go there** | sits unused | sits unused |
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

## Second batch: the machine changes

This is where the second Japanese version parts company with the other two, and
everything that changes points the same way: it stops assuming what the MSX
underneath looks like.

The first two have the video chip's ports written into the instructions
themselves. Their routine for writing one register is this, in full:

    di / ld a,e / out (099h),a / ld a,d / out (099h),a / ret

and there are fourteen more accesses in the same style alongside it. The second
Japanese version doesn't have a single one. All eight video-data accesses
become `out (c),a`, with the port number in C, and that number isn't written
anywhere: it's read from the BIOS work area, where the machine records which
port is actually its own.

    ld a,(00006h)   ; the VDP data port, which the BIOS keeps there
    ld c,a

The registers go through the standard BIOS call instead, and so does pointing
at video memory. And the boot code does something the other two don't: before
hooking its interrupt routine, it **fills the system's 512 bytes of reserved
hooks with RETs**, disabling whatever any attached extension had put there.

The background comes along for the ride. Background and border colour come from
register 7 of the chip, and all three set it at boot and never touch it again
for the rest of the game: 0xE1 on the first two, which is black, and 0xE4 on
the second Japanese, which is dark blue.

## The three-byte copy at boot

Which brings us to the thing only the second Japanese version has. Its INIT
copies three bytes from 0x411F — which are `C3 00 00`, that is, `jp 0000h` —
over the top of another address. In the dump this disassembly uses, that
address is 0x40B2, the game's dispatcher, the routine every table-driven jump
goes through and which gets called on the very first frame:

    ld hl,411Fh / ld de,40B2h / ld bc,0003h / ldir

In a cartridge nothing happens, because the page the cartridge lives in is ROM
and the write is lost. But running from RAM, the dispatcher would turn into a
jump to zero and the machine would reset before showing anything. It's copy
protection, and a good one: it checks nothing and warns about nothing, because
on the real cartridge it's an instruction you never notice.

The two bytes separating this dump from the other one of the same version are
exactly that copy's destination, which over there is 0x0000. And a third dump
of this same version goes around with the whole `ldir` turned into two `nop`s.
Three variants of the same binary differing only in that one instruction give a
fairly clear idea of what it's for.

Neither the first Japanese version nor the European carries any of this: the
copy doesn't exist anywhere in those two, not even the three loose bytes.

## What we don't know

The four graphics the first version writes the South Pole with still haven't
been read. They're compressed like the rest of the artwork, and getting them
out would need that version's own addresses.
