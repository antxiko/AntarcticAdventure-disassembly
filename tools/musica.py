#!/usr/bin/env python3
"""La musica del cartucho, ejecutando su motor de sonido (ver motor_musica.py).

Version documentada en la web: la segunda japonesa (antarctic-jap2.rom). Pide el
sonido con `PIDE_SONIDO` (0x79C9, A = numero) y corre `ATIENDE_SONIDO` (0x7A30),
que la interrupcion llama cada cuadro (0x406B).
Uso:  musica.py registros 0x8A [cuadros] | mp3 0x8A f.mp3 | todas docs/audio
      musica.py barrido 0x80 0xB0 | emu
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import motor_musica  # noqa: E402

PIEZAS = [
    # (numero, fichero, grupo, titulo es, titulo en, quien es, quien en)
    (0x8A, "musica_8A.mp3", "musica", "La salida de cada fase",
     "The start of every stage", "`ESTADO_10_ENTRA`, solo en la partida",
     "`ESTADO_10_ENTRA`, in the game only (not in the demo)"),
    (0x8C, "musica_8C.mp3", "musica", "Se acabó el tiempo", "Time out",
     "`ESTADO_12_TIME_OUT`", "`ESTADO_12_TIME_OUT`"),
    (0x8F, "musica_8F.mp3", "musica", "La llegada a la base",
     "Arriving at the base", "`META_3_LLEGA`", "`META_3_LLEGA`"),
    (0x92, "musica_92.mp3", "musica", "La pantalla de título",
     "The title screen", "`MENU_0_PINTA`", "`MENU_0_PINTA`"),
]

PAGINA = dict(
    motor_es="`ATIENDE_SONIDO`, 0x7A30, y `PIDE_SONIDO`, 0x79C9, que le reparte "
             "los canales; lo llama la interrupción en 0x406B. Es la versión "
             "japonesa 2, la documentada en esta web",
    motor_en="`ATIENDE_SONIDO`, 0x7A30, and `PIDE_SONIDO`, 0x79C9, which hands "
             "it the channels; the interrupt calls it at 0x406B. This is the "
             "second Japanese version, the one documented on this site",
    maquina="C-BIOS MSX1 japonés",
    cotejo=[("la música de la salida de fase (0x8A): sus primeros 950 cuadros "
             "seguidos y otros nueve tramos más, hasta que el juego la vuelve "
             "a pedir",
             "the stage-start tune (0x8A): its first 950 frames in a row and "
             "nine more stretches, up to where the game asks for it again"),
            ("la llegada a la base (0x8F) entera, 302 cuadros",
             "the arrival at the base (0x8F), whole, 302 frames")],
    notas=[("Cómo se pide una pieza",
            "`PIDE_SONIDO` recibe el número en A. Por debajo de 0x8A es un "
            "efecto y usa un solo canal; 0x8A y 0x8B usan dos canales y de "
            "0x8C en adelante los tres. Cada canal tiene diez bytes en 0xE010, "
            "0xE01A y 0xE024. El motor no escribe nunca el mezclador del PSG "
            "(registro 7): lo deja puesto el arranque, y aquí se parte de ese "
            "mismo valor, 0xB8. Pedir otra vez el mismo número reinicia la "
            "pieza, y por eso el cotejo de la 0x8A se hace por tramos.",
            "How a piece is asked for",
            "`PIDE_SONIDO` takes the number in A. Below 0x8A it is an effect "
            "and uses a single channel; 0x8A and 0x8B use two channels and "
            "from 0x8C up all three. Each channel has ten bytes at 0xE010, "
            "0xE01A and 0xE024. The engine never writes the PSG mixer "
            "(register 7): start-up leaves it set, and here it starts from "
            "that same value, 0xB8. Asking for the same number again restarts "
            "the piece, which is why the 0x8A check is done in stretches.")],
    grupos=[("musica", "Las músicas", "The tunes", "", "")],
)

CFG = dict(rom="antarctic-jap2.rom", org=0x4000, frame=0x7A30, pide=0x79C9,
           ram=(0xE010, 0xE02E), hz=60, psg0={7: 0xB8}, piezas=PIEZAS,
           pagina=PAGINA, cotejado=[(0x8A, 3074, 1), (0x8F, 302, None)])

if __name__ == "__main__":
    sys.exit(motor_musica.main(CFG, sys.argv[1:]))
