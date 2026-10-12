# The music

Everything you hear here comes from running the cartridge's own sound engine (`ATIENDE_SONIDO`, 0x7A30, and `PIDE_SONIDO`, 0x79C9, which hands it the channels; the interrupt calls it at 0x406B. This is the second Japanese version, the one documented on this site) on an emulated Z80, frame by frame at 60 per second, just as the game calls it. What the engine writes to the PSG is turned into sound with an AY-3-8910 (`tools/musica.py`). Each MP3 is the whole piece up to where it starts again, plus 8 seconds of the repeat fading out; those that do not repeat end where the engine ends.

## Checked against openMSX

The PSG writes have been compared frame by frame with those of openMSX (C-BIOS MSX1 japonés). In every frame the PSG ends up the same:

- the stage-start tune (0x8A): its first 950 frames in a row and nine more stretches, up to where the game asks for it again;
- the arrival at the base (0x8F), whole, 302 frames.

The timbre is not checked: it is a textbook AY-3-8910, not a recording of the emulator. The probes are `tools/omsx_psg.tcl` and `tools/coteja_psg.py`.

## How a piece is asked for

`PIDE_SONIDO` takes the number in A. Below 0x8A it is an effect and uses a single channel; 0x8A and 0x8B use two channels and from 0x8C up all three. Each channel has ten bytes at 0xE010, 0xE01A and 0xE024. The engine never writes the PSG mixer (register 7): start-up leaves it set, and here it starts from that same value, 0xB8. Asking for the same number again restarts the piece, which is why the 0x8A check is done in stretches.

## The tunes

**The start of every stage** (0x8A)

Asked for by `ESTADO_10_ENTRA`, in the game only (not in the demo); lasts 51.2 s and starts again at second 0.0.

<audio controls preload="none" src="audio/musica_8A.mp3?v=7839190e"></audio>

**Time out** (0x8C)

Asked for by `ESTADO_12_TIME_OUT`; lasts 5.4 s.

<audio controls preload="none" src="audio/musica_8C.mp3?v=bb0bf293"></audio>

**Arriving at the base** (0x8F)

Asked for by `META_3_LLEGA`; lasts 5.0 s.

<audio controls preload="none" src="audio/musica_8F.mp3?v=b5d821f7"></audio>

**The title screen** (0x92)

Asked for by `MENU_0_PINTA`; lasts 5.4 s.

<audio controls preload="none" src="audio/musica_92.mp3?v=80316205"></audio>
