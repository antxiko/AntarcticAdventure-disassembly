#!/usr/bin/env python3
"""Dibuja las banderas de las bases, descomprimiendolas como hace el juego.

En 0x565C hay diez punteros, uno por parada del recorrido, y la rutina de
0x559A los usa asi:

    ld hl,565Ch / ld a,(0E0E0h) / and 00Fh / add a,a / call 48FEh
    ld e,(hl) / inc hl / ld d,(hl) / ex de,hl
    ld de,05F40h / call 4564h        <- VRAM 0x1F40, patrones de sprite

La tabla cierra clavada en 0x5670, que es donde empieza el primero de los
graficos: con diez entradas la ultima palabra acaba justo ahi, y con otro
numero no cuadra.

LO QUE CONFIRMA QUE SON SPRITES Y NO OTRA COSA: los diez flujos miden entre 11
y 59 bytes, todos distintos, y los diez descomprimen a 64 bytes EXACTOS. 64
bytes son dos patrones de sprite de 16x16. Que diez flujos de tamanos
distintos caigan todos en la misma cifra no es casualidad.

Detras de cada flujo van sus dos bytes de color, que 0x55B0 recoge para las
dos entradas de atributo.

LA BANDERA SON TRES SPRITES, NO DOS, y eso hay que sacarlo de la lista de
atributos de la escena de la base (0x672C), porque el flujo comprimido solo
trae dos. Los tres, tal y como quedan montados:

    atributo 4  patron 0xE8  -> VRAM 0x1F40, los bytes 0-31 del flujo
    atributo 5  patron 0xEC  -> VRAM 0x1F60, los bytes 32-63
    atributo 6  patron 0xE4  -> VRAM 0x1F20, color 0x0F FIJO

El tercero no viene en el flujo: es un rectangulo blanco macizo de 16x12 que
sale de la carga general de sprites, y es el fondo de la bandera. Sin el, los
dibujos se ven en el aire.

Y EL ORDEN IMPORTA: en un MSX el sprite de numero MAS BAJO se dibuja DELANTE,
asi que se pinta de atras hacia adelante -el blanco, luego el segundo color y
por ultimo el primero-. Al reves, el segundo color tapa al primero y los
colores salen mal.

Uso: render_banderas.py <rom> <work/vram.bin> <directorio_salida>
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from descomprime import descomprime                  # noqa: E402
from render_maps import PALETA, png                  # noqa: E402

ORG = 0x4000
TABLA = 0x565C
NOMBRES = 0x55D9       # los diez punteros a los nombres de las bases
FONDO_VRAM = 0x1F20    # patron 0xE4: el rectangulo blanco de fondo
FASES = 10
ESCALA = 3


def w(rom, a):
    return rom[a - ORG] | (rom[a + 1 - ORG] << 8)


def bcd(n):
    """El numero de fase tal y como lo lleva el juego, en BCD."""
    return (n // 10) * 16 + n % 10


def nombre_base(rom, fase):
    """El rotulo de la base de esa fase, descifrado.

    Los textos no estan en ASCII: cada byte es su ASCII menos 0x20, porque la
    fuente empieza en el espacio. Y la cadena lleva delante dos bytes con el
    sitio de la pantalla donde va, que aqui se saltan.
    """
    p = w(rom, NOMBRES + 2 * (fase - 1)) + 2
    out = []
    while True:
        c = rom[p - ORG]
        p += 1
        if c in (0xFF, 0xFE):
            break
        out.append(chr(c + 0x20))
    return "".join(out).strip()


def sprite16(datos, base):
    """Las 16 filas de un sprite de 16x16, que son 32 bytes.

    OJO con el orden, que es facil de leer al reves: NO son ocho filas de dos
    bytes, son dos MITADES de 16 filas. Los bytes 0-15 son la columna
    izquierda y los 16-31 la derecha. Leidos de la otra manera sale una imagen
    -convincente, ademas- pero cortada en tiras.
    """
    filas = []
    for y in range(16):
        izq, der = datos[base + y], datos[base + 16 + y]
        filas.append([(izq >> (7 - i)) & 1 for i in range(8)]
                     + [(der >> (7 - i)) & 1 for i in range(8)])
    return filas


def main():
    if len(sys.argv) != 4:
        sys.exit(__doc__)
    with open(sys.argv[1], "rb") as f:
        rom = f.read()
    with open(sys.argv[2], "rb") as f:
        vram = f.read()
    salida = sys.argv[3]
    os.makedirs(salida, exist_ok=True)

    # El sprite de fondo, el que no viene en el flujo: patron 0xE4.
    fondo = vram[FONDO_VRAM:FONDO_VRAM + 32]

    # OJO CON EL INDICE, que no es la fase: 0x559A indexa esta tabla con
    # (0xE0E0) & 0x0F, y 0xE0E0 es el numero de fase EN BCD, que empieza en 1.
    # O sea que la fase 1 coge la entrada 1... y la fase 10, que en BCD es 0x10,
    # coge la 0. Dibujadas en ese orden, cada bandera cae en su pais.
    banderas, vistos = [], {}
    for fase in range(1, FASES + 1):
        p = w(rom, TABLA + 2 * (bcd(fase) & 0x0F))
        bloques, fin = descomprime(rom, p, False, 0x5F40, False)
        datos = b"".join(s for _, s in bloques)
        colores = (rom[fin - ORG], rom[fin + 1 - ORG])
        banderas.append((fase, p, datos, colores, len(datos), fin - p))
        vistos.setdefault(p, []).append(fase)

    hueco = 4
    ancho = FASES * (16 + hueco) * ESCALA
    alto = 16 * ESCALA
    img = [[PALETA[4]] * ancho for _ in range(alto)]
    # Tres capas, de atras hacia adelante, porque en un MSX el sprite de numero
    # mas bajo va delante: el fondo blanco, el segundo color y el primero.
    for i, (fase, p, datos, colores, n, comprimido) in enumerate(banderas):
        capas = [(fondo, 0, 0x0F),
                 (datos, 32, colores[1]),
                 (datos, 0, colores[0])]
        for bytes_, base, color in capas:
            tinta = PALETA[color & 15]
            for y, fila in enumerate(sprite16(bytes_, base)):
                for x, bit in enumerate(fila):
                    if not bit:
                        continue
                    for sy in range(ESCALA):
                        for sx in range(ESCALA):
                            img[y * ESCALA + sy][
                                (i * (16 + hueco) + x) * ESCALA + sx] = tinta
        print("  fase %2d  %-16s flujo 0x%04X  %2d B -> %d, colores %d y %d"
              % (fase, nombre_base(rom, fase), p, comprimido, n,
                 colores[0] & 15, colores[1] & 15))

    png(os.path.join(salida, "banderas.png"), ancho, alto, img)
    distintas = len(vistos)
    print("  banderas.png            %d dibujos distintos para %d paradas"
          % (distintas, FASES))
    for p, fases in sorted(vistos.items()):
        if len(fases) > 1:
            print("     0x%04X lo comparten las fases %s"
                  % (p, ", ".join(str(f) for f in fases)))
    if any(n != 64 for _, _, _, _, n, _ in banderas):
        sys.exit("  los diez tenian que descomprimir a 64 bytes exactos")
    print("  los diez descomprimen a 64 bytes exactos: dos sprites de 16x16")


if __name__ == "__main__":
    main()
