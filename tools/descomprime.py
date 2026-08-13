#!/usr/bin/env python3
"""El descompresor de graficos del juego, reimplementado tal como esta en la ROM.

Los graficos del cartucho no estan en crudo: van comprimidos, y la unica forma
de verlos es hacer lo mismo que hace el juego. La rutina vive en 0x4560 y tiene
CUATRO puntos de entrada, que es lo que la hace util de mas de una manera:

    0x4560  lee del propio flujo los dos bytes del destino de VRAM, y sigue
    0x4564  el destino ya viene dado en DE
    0x4568  el destino ya viene en DE, y ademas ESPEJA cada byte
    0x456D  el bucle pelado: no toca el puntero de VRAM, sigue escribiendo
            donde lo dejo la llamada anterior. Se usa para encadenar trozos

Las cinco se usan de verdad: 15 llamadas a 0x4560, 7 a 0x4564, 2 a 0x4568 y
5 a 0x456D.

El espejo (0x4598) invierte los bits del byte cuando C lleva el bit 0 puesto:
asi el juego guarda una sola vez los dibujos que miran a los dos lados.

El formato del flujo, leido instruccion a instruccion:

    0x00           fin de todo
    0x80           cierra este bloque y vuelve a leer OTRO destino
    n con bit7=0   repite n veces el byte que viene detras     (una racha)
    n con bit7=1   copia n & 0x7F bytes tal cual               (una tirada)

OJO, que es facil leerlo justo al reves: lo que lo decide son los dos DJNZ. El
de 0x4584 vuelve a 0x457E, o sea DESPUES de haber leido el byte, asi que lo
repite; el de 0x4592 vuelve a 0x458B, ANTES de leerlo, asi que lee uno nuevo
cada vuelta. Leerlo al reves da destinos de VRAM imposibles, que es la senal.

Y otra: dos llamadas seguidas sin `ld hl` en medio NO empiezan de cero, siguen
con el HL que dejo la anterior, o sea con el flujo siguiente.

Uso: descomprime.py <rom> [directorio_salida]

Sin directorio solo informa. Con el, escribe la VRAM reconstruida (16 KB) y un
listado de que trozo de ROM ha ido a que sitio.
"""
import os
import sys

ORG = 0x4000
FIN = 0x8000

# Los cinco puntos de entrada: (lee el destino del flujo, espeja)
# 0x456D es el bucle pelado: ni lee destino ni lo espera en DE, sigue donde
# quedo el puntero de VRAM de la llamada anterior.
ENTRADAS = {
    0x4560: (True, False),
    0x4564: (False, False),
    0x4568: (False, True),
    0x456D: (False, False),
}
SIGUE = 0x456D

# Un sitio tiene el destino en la pila y no en un `ld de,nn`, asi que no se lee
# mirando las instrucciones de al lado. Sale de seguir el codigo:
#
#   588A  ld de,0000h / call 589Ch      la rutina de 0x589C se llama TRES veces
#   5890  ld de,0800h / call 589Ch      con los tres desplazamientos de banco
#   5896  ld de,1000h / jp   589Ch
#   589C  push de                       se lo guarda...
#   58C6  pop de / ld hl,6000h / add hl,de / ex de,hl    ...y aqui lo usa
#   58CC  ld hl,58DBh / call 4564h
#
# 0x6000+0x0000, +0x0800 y +0x1000, que enmascarados con 0x3FFF son 0x2000,
# 0x2800 y 0x3000: los PATRONES de los bancos 0, 1 y 2. Escribe lo mismo en los
# tres tercios de la pantalla, que es lo que hay que hacer en SCREEN 2 para que
# el marcador se vea de arriba abajo.
DESDE_LA_PILA = {0x58CF: (0x6000, 0x6800, 0x7000)}

# Y otro sitio donde el flujo tampoco esta en un `ld hl,nn`: la BANDERA de la
# base. 0x559A la elige de una tabla de diez punteros (0x565C) indexada con la
# fase, y luego 0x55AD la descomprime a la VRAM 0x1F40. Mirando las
# instrucciones de al lado solo se ve el destino, asi que sin esto el
# reconstructor se cree que sigue con el flujo de la llamada anterior y llena
# los sprites 58 a 61 de basura. Las diez descomprimen 64 bytes exactos -los
# sprites 58 y 59-; aqui se pone la de la primera fase, y las diez se ven con
# render_banderas.py.
INDEXADAS = {0x55AD: (0x565C, 0x5F40)}

# LA FUENTE NO SE PUEDE RECONSTRUIR MIRANDO LAS LLAMADAS UNA A UNA, y este es
# el sitio donde recorrer la ROM en orden se equivoca. Por que:
#
# La entrada de 0x456D es el BUCLE PELADO: no fija la direccion de escritura,
# sigue donde quedo el puntero del VDP. Asi que a donde va lo que escribe no
# depende de la llamada anterior EN LA ROM, sino de la anterior EN EL TIEMPO. Y
# aqui las dos no coinciden: la de la ROM es la bandera de 0x55AD, que no tiene
# nada que ver, y la de verdad es el relleno de color que hace la propia rutina
# unas instrucciones antes.
#
# 0x589C, entera, se ejecuta TRES veces (0x588A, 0x5890 y 0x5896) con la base
# del banco en DE, y hace esto:
#
#   589C  16 colores lisos y 0x270 bytes de 0xF0     -> base+0x000 .. base+0x2F0
#   58B7  ld hl,5DB0h / call 456Dh   (encadenada)    -> base+0x2F0, 688 B
#   58BC  ld b,016h / ld hl,5DE6h / call 456Dh x22   -> 22 x 16 B
#   58CF  ld hl,58DBh / call 4564h   con DE=0x6000+base -> patrones, 1312 B
#   58D5  ld hl,5C5Bh / call 456Dh   (encadenada)    -> 104 B
#   58D8  jp 456Dh                   (sigue con el HL que quedo: 0x5C7D) -> 376 B
#
# Y LA CUENTA CIERRA POR PARTIDA DOBLE, que es lo que dice que la lectura es la
# buena: 0x80 + 0x270 + 688 + 352 = 1792 bytes de COLOR, y 1312 + 104 + 376 =
# 1792 bytes de PATRONES. Los mismos 1792 en las dos tablas, o sea las casillas
# 0 a 223 de cada banco, y los tres bancos identicos.
SECUENCIA_FUENTE = [
    # (origen en ROM, destino, lee_destino, espejo) con destino relativo al banco
    (0x5DB0, 0x2F0, False, False),
] + [(0x5DE6, None, False, False)] * 22 + [
    (0x58DB, 0x6000, False, False),
    (0x5C5B, None, False, False),
    (0x5C7D, None, False, False),
]
# Los sitios que llaman al descompresor desde dentro de esa rutina: se atienden
# con la secuencia de arriba y NO por el recorrido general.
LLAMADAS_DE_LA_FUENTE = {0x58B7, 0x58C0, 0x58CF, 0x58D5, 0x58D8}

# No todo lo que llega a la VRAM va comprimido: la misma rutina de 0x589C monta
# a mano la tabla de COLOR de los tres bancos, antes de descomprimir nada.
#
#   589C  push de / xor a / ld c,010h
#   58A0  ld b,008h / call 48D0h / inc de / djnz   ocho bytes del mismo valor
#   58A8  inc a / dec c / jr nz                    dieciseis valores: 0x00..0x0F
#   58AC  ld bc,0270h / ld a,0F0h / call 44FDh     y 624 bytes de 0xF0
#
# 0x48D0 escribe A en la VRAM y 0x44FD rellena. Los dieciseis primeros valores
# dan tinta 0 sobre fondo N, y como los patrones de esos tiles son todo ceros,
# LOS TILES 0 A 15 SON CUADRADOS DE COLOR LISO, uno por color de la paleta: asi
# se pintan las bandas de cielo y de hielo sin gastar dibujos. Los 624 bytes de
# 0xF0 que vienen detras son tinta 15 sobre fondo transparente, que es la fuente.
RELLENOS = [
    (0x0000, bytes(v for n in range(16) for v in [n] * 8) + b"\xF0" * 0x270),
    (0x0800, bytes(v for n in range(16) for v in [n] * 8) + b"\xF0" * 0x270),
    (0x1000, bytes(v for n in range(16) for v in [n] * 8) + b"\xF0" * 0x270),
]

# Los registros del VDP que el juego escribe en 0x44C3, copiados de 0x44DF.
# No es la disposicion de la BIOS: aqui los COLORES van abajo y los PATRONES
# arriba, justo al reves de lo habitual en SCREEN 2.
VDP = [0x02, 0xE2, 0x0E, 0x7F, 0x07, 0x76, 0x03, 0xE4]
TABLAS = [
    ("colores",           (VDP[3] & 0x80) * 0x40, 0x1800),
    ("patrones de sprite", VDP[6] * 0x800,        0x0800),
    ("patrones",          (VDP[4] & 0x04) * 0x800, 0x1800),
    ("nombres",            VDP[2] * 0x400,        0x0300),
    ("atributos de sprite", VDP[5] * 0x80,        0x0080),
]


def espeja(v):
    """0x4598: invierte los bits, que es un espejo horizontal de la fila."""
    return int(format(v, "08b")[::-1], 2)


def donde(v):
    """En que tabla del VDP cae una direccion de VRAM."""
    v &= 0x3FFF
    for nombre, base, tam in TABLAS:
        if base <= v < base + tam:
            if nombre in ("patrones", "colores"):
                return "%s banco %d" % (nombre, (v - base) // 0x800)
            if nombre == "nombres":
                o = v - base
                return "nombres fila %d columna %d" % (o // 32, o % 32)
            return nombre
    return "fuera de las tablas"


def descomprime(rom, p, lee_destino, destino=None, espejo=False):
    """Devuelve [(destino, bytes)] y donde se quedo el puntero."""
    bloques = []
    while True:
        if lee_destino:
            if p + 1 >= FIN:
                raise ValueError("el flujo se sale de la ROM")
            destino = rom[p - ORG] | (rom[p + 1 - ORG] << 8)
            p += 2
        if destino is None:
            raise ValueError("no hay destino: el llamante tenia que dar DE")
        salida = bytearray()
        while True:
            if p >= FIN:
                raise ValueError("el flujo se acaba sin cerrar")
            n = rom[p - ORG]
            p += 1
            if n == 0x00:
                bloques.append((destino, bytes(salida)))
                return bloques, p
            if n == 0x80:
                break
            if n & 0x80:                                  # tirada literal
                m = n & 0x7F
                trozo = rom[p - ORG:p - ORG + m]
                salida += bytes(espeja(x) for x in trozo) if espejo else trozo
                p += m
            else:                                         # racha
                v = rom[p - ORG]
                salida += bytes([espeja(v) if espejo else v]) * n
                p += 1
        bloques.append((destino, bytes(salida)))
        lee_destino = True          # tras un 0x80 siempre viene otro destino


def llamadas(rom):
    """Cada CALL/JP al descompresor, con el HL y el DE que trae delante."""
    out = []
    for i in range(len(rom) - 2):
        if rom[i] not in (0xCD, 0xC3):
            continue
        dst = rom[i + 1] | (rom[i + 2] << 8)
        if dst not in ENTRADAS:
            continue
        hl = de = None
        if i >= 3 and rom[i - 3] == 0x21:
            hl = rom[i - 2] | (rom[i - 1] << 8)
        elif i >= 3 and rom[i - 3] == 0x11:
            de = rom[i - 2] | (rom[i - 1] << 8)
            if i >= 6 and rom[i - 6] == 0x21:
                hl = rom[i - 5] | (rom[i - 4] << 8)
        out.append((ORG + i, dst, hl, de))
    return sorted(out)


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 2
    with open(argv[1], "rb") as f:
        rom = f.read()
    salida = argv[2] if len(argv) > 2 else None

    vram = bytearray(0x4000)
    escrito = bytearray(0x4000)
    rangos = []
    cursor = None
    pendientes = []
    produced = 0

    for base, datos in RELLENOS:
        vram[base:base + len(datos)] = datos
        for j in range(base, min(base + len(datos), 0x4000)):
            escrito[j] = 1
    print("  la tabla de color de los tres bancos se monta a mano en 0x589C,")
    print("  sin comprimir: %d bytes por banco. Lo demas va comprimido:\n"
          % len(RELLENOS[0][1]))
    print("  sitio  origen ROM      comprimido    sale    a VRAM   que es")
    print("  " + "-" * 72)
    puntero = None          # donde quedo el puntero de escritura de la VRAM

    def anota(sitio, hl, fin, bloques, primero=True):
        nonlocal produced
        for k, (v, s) in enumerate(bloques):
            produced += len(s)
            v &= 0x3FFF
            vram[v:v + len(s)] = s
            for j in range(v, min(v + len(s), 0x4000)):
                escrito[j] = 1
            print("  %s %s %s %6dB  %04X  %s"
                  % ("%04X" % sitio if k == 0 and primero else "    ",
                     "%04X-%04X" % (hl, fin - 1) if k == 0 and primero else "         ",
                     "%5dB" % (fin - hl) if k == 0 and primero else "      ",
                     len(s), v, donde(v)))
        return (bloques[-1][0] & 0x3FFF) + len(bloques[-1][1])

    # La fuente, los tres bancos, siguiendo el flujo de verdad (ver arriba).
    for banco, base in enumerate((0x0000, 0x0800, 0x1000)):
        p = base + 0x2F0                      # donde lo deja el relleno de color
        for org, dst_rel, lee, esp in SECUENCIA_FUENTE:
            destino = p if dst_rel is None else (dst_rel + base if dst_rel != 0x2F0
                                                 else base + 0x2F0)
            bloques, fin = descomprime(rom, org, lee, destino, esp)
            rangos.append((org, fin))
            p = anota(0x589C, org, fin, bloques, primero=(banco == 0))
    print("  " + "-" * 72)

    for a, dst, hl, de in llamadas(rom):
        if a in LLAMADAS_DE_LA_FUENTE:
            continue                          # ya atendidas por la secuencia
        lee, esp = ENTRADAS[dst]
        if a in INDEXADAS:                   # flujo elegido de una tabla
            tabla, de = INDEXADAS[a]
            hl = rom[tabla - ORG] | (rom[tabla + 1 - ORG] << 8)
        if hl is None:
            hl = cursor                      # llamada encadenada
        if dst == SIGUE and de is None:
            de = puntero                     # el bucle pelado no toca el puntero
        if a in DESDE_LA_PILA:               # destino que sale de la pila
            for banco, dd in enumerate(DESDE_LA_PILA[a]):
                bl, fin = descomprime(rom, hl, lee, dd, esp)
                cursor = fin
                rangos.append((hl, fin))
                for v, s in bl:
                    produced += len(s)
                    v &= 0x3FFF
                    puntero = v + len(s)
                    vram[v:v + len(s)] = s
                    for j in range(v, min(v + len(s), 0x4000)):
                        escrito[j] = 1
                    print("  %s %s %s %6dB  %04X  %s"
                          % ("%04X" % a if banco == 0 else "    ",
                             "%04X-%04X" % (hl, fin - 1) if banco == 0 else "         ",
                             "%5dB" % (fin - hl) if banco == 0 else "      ",
                             len(s), v, donde(v)))
            continue
        if hl is None or (not lee and de is None):
            pendientes.append(a)
            cursor = None
            continue
        try:
            bloques, fin = descomprime(rom, hl, lee, de, esp)
        except ValueError as e:
            print("  %04X  origen %04X: %s" % (a, hl, e))
            cursor = None
            continue
        cursor = fin
        rangos.append((hl, fin))
        for k, (v, s) in enumerate(bloques):
            produced += len(s)
            v &= 0x3FFF
            puntero = v + len(s)              # por donde seguiria el bucle pelado
            vram[v:v + len(s)] = s
            for j in range(v, min(v + len(s), 0x4000)):
                escrito[j] = 1
            print("  %s %s %s %6dB  %04X  %s"
                  % ("%04X" % a if k == 0 else "    ",
                     "%04X-%04X" % (hl, fin - 1) if k == 0 else "         ",
                     "%5dB" % (fin - hl) if k == 0 else "      ",
                     len(s), v, donde(v)))

    unidos = []
    for a, b in sorted(set(rangos)):
        if unidos and a <= unidos[-1][1]:
            unidos[-1] = (unidos[-1][0], max(unidos[-1][1], b))
        else:
            unidos.append((a, b))
    comp = sum(b - a for a, b in unidos)
    print()
    print("  %d rangos de ROM, %d bytes -> %d bytes de VRAM (x%.2f)"
          % (len(unidos), comp, produced, produced / comp if comp else 0))
    for a, b in unidos:
        print("     %04X-%04X  %5d B" % (a, b - 1, b - a))
    if pendientes:
        print("  llamadas con el origen sin resolver: %s"
              % " ".join("%04X" % x for x in pendientes))

    print()
    print("  VRAM que queda escrita, por tabla:")
    for nombre, base, tam in TABLAS:
        n = sum(escrito[base:base + tam])
        print("     %-20s 0x%04X-0x%04X  %5d de %5d bytes  (%.0f%%)"
              % (nombre, base, base + tam - 1, n, tam, 100.0 * n / tam))

    if salida:
        os.makedirs(salida, exist_ok=True)
        with open(os.path.join(salida, "vram.bin"), "wb") as f:
            f.write(vram)
        with open(os.path.join(salida, "vram.escrito"), "wb") as f:
            f.write(escrito)
        print("\n  escritos %s/vram.bin y vram.escrito" % salida)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
