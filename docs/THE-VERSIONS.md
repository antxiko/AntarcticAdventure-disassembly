# The versions

There are three different builds of this cartridge: two that sell in Japan and
the one that leaves the country. This disassembly is of the last one, the
European release, and it turns out to cover one of the Japanese ones too,
because there are exactly two bytes between them.

All three files are 16384 bytes on the nose:

    first Japanese    087378ddad1379a6e378f0810e9cf1dbb64ee03c36e630bb78020b754b7dfebd
    second Japanese   a33f9298bf6f740ebe8d88bdc8ed75c855404d804e07679d6c2f2ad00dc3c452
    European          17f4dd654c937134c44c1faf68a9f67141d69ccf251853228aa5211dc8065126

None of them is distributed here. If you have all three,
`tools/compara_versiones.py` prints everything this page claims in one go,
which is what it's for.

One warning first: there are a lot of dirty dumps of this game going around.
Some are 32 KB with the same 16 KB repeated twice, some are the same file under
another name, and at least one is the European build with a couple of bytes
changed by somebody who wanted to run it from RAM. Start with the sha256, always.

## The second Japanese build and the European one are the same binary

They differ in **two bytes** and nothing else. The bytes are at 0x4050 and
0x4051, inside the boot code, and what they change is where a three-byte copy
lands:

    second Japanese   ld hl,411Fh / ld de,0000h / ld bc,0003h / ldir
    European          ld hl,411Fh / ld de,40B2h / ld bc,0003h / ldir

Everything else — the code, the compressed artwork, the text, the music, the
recorded attract game — is byte for byte the same. So this disassembly
describes both equally well, and all you need to read it as the Japanese one is
to swap that `40B2h` for `0000h`. We'll come back to that LDIR at the end,
because it has a story.

## The first one is another cartridge altogether

No small edits here: 15443 of the 16384 bytes are different, 94 % of the
cartridge, and the code has moved around from top to bottom. It's a separate
build. What's interesting is that nearly everything that changed points the
same way.

### It assumes where the video chip lives

The first version has the VDP ports written into the instructions themselves:
fourteen accesses with the port number baked into the opcode, like

    di / ld a,e / out (099h),a / ld a,d / out (099h),a / ret

which is its entire routine for writing one of the chip's registers. On a 1984
Japanese MSX that works and that's that.

In the other two there isn't a single one left. All eight video-data accesses
become `out (c),a`, with the port number in C, and that number isn't written
anywhere: it's read from the BIOS work area, where the machine records which
port is actually its own.

    ld a,(00006h)   ; the VDP data port, which the BIOS keeps there
    ld c,a

The registers go through the standard BIOS call instead, and so does pointing
at video memory. This isn't one stray tweak: somebody went through site by site
removing the assumption that the chip sits where it usually sits.

### And it assumes nothing else is plugged in

The boot code has two more differences of the same kind. The first version
hooks its interrupt routine and gets going; the other two, before hooking it,
**fill the system's 512 bytes of reserved hooks with RETs**, disabling whatever
any attached extension had put there. And to clear the interrupt left pending
at power-on, the first one reads the video port directly while the other two
call the BIOS.

### The background is black

Background and border colour come from register 7 of the video chip, and all
three set it at boot and never touch it again for the rest of the game.

    first Japanese   0xE1  -> grey ink, black background and border
    the other two    0xE4  -> grey ink, dark blue background and border

So the Konami screen on the first one comes up over black, and on the other two
over blue.

### New Zealand exists, and you go there

All three carry the same eight strings with the base names inside, plus a table
of ten pointers handing those eight out across the ten stages of the route. The
hand-out isn't the same:

    first Japanese   JAPAN, AUSTRALIA, AUSTRALIA, FRANCE, NEW ZEALAND,
                     the Pole, USA, USA, ARGENTINA, UNITED KINGDOM
    the other two    FRANCE, USA, the Pole, USA, USA, ARGENTINA,
                     UNITED KINGDOM, JAPAN, AUSTRALIA, AUSTRALIA

It's the same trip round the world rotated by three — the first one starts in
Japan and the others in France — with a single real change: where the first
sends you to New Zealand, the others repeat the United States. The NEW ZEALAND
string is still sitting in the cartridge, at 0x5610, with nothing pointing at
it. Whole and unused, taking up its sixteen bytes.

### The South Pole is written in Japanese

On the first version the label for the Pole base isn't letters at all: it's
four graphics of its own, patterns 0xCE to 0xD1, which don't turn up in any
other word in the game. On the other two that slot holds `THE SOUTH POLE`,
spelled out with the same alphabet as everything else.

Along the way the title screen label changes too — `VIDEO CARTRIDGE` on the
first, `KONAMI` on the others — and so does the way the names are stored: on
the last two each string is preceded by two bytes giving the exact spot on
screen where it goes, which is what centres it (0x3AC8 for the fourteen-letter
ones, 0x3ACE for the three letters of USA), and on the first those two bytes
aren't there.

## The LDIR that does nothing

Back to those two bytes. What that LDIR does is copy three bytes from 0x411F —
which are `C3 00 00`, that is, `jp 0000h` — over the top of 0x40B2. And 0x40B2
is the game's dispatcher, the routine every table-driven jump goes through, and
it gets called on the very first frame.

In a cartridge nothing happens, because the page the cartridge lives in is ROM
and the write is simply lost. But if the game were running from RAM, the
dispatcher would turn into a jump to zero and the machine would reset before
showing anything.

Lining the three versions up says a fair bit:

    first Japanese    doesn't carry that LDIR anywhere
    second Japanese   carries it, aimed at 0x0000
    European          carries it, aimed at 0x40B2

So it appears later, and between one version and the next somebody re-aims it.
**What it does is verified by reading the bytes; what it's for can't be proven
from the binary.** The obvious reading is that it's protection against RAM
copies, and it helps that a dump goes around which is exactly the European
build with those two bytes turned into `nop`s — precisely what you'd do to get
rid of it. But that's a reading, not a measurement.

## What we don't know

The four graphics the first version writes the South Pole with still haven't
been read. They're in the cartridge compressed like the rest of the artwork,
and getting them out would need that version's own addresses.
