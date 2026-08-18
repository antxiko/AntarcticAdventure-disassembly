#!/usr/bin/env python3
"""Que la web y los README no digan una cifra distinta de la que sale del listado.

Esto es el guardian de la documentacion. Publicar "394 etiquetas" y que sean
380 no lo caza ninguna otra comprobacion: el listado reensambla igual, los
rangos siguen cuadrando y la web se genera sin protestar. La unica forma de que
no se despeguen es contar y comparar.

Cuando uno de estos falla al comentar una rutina nueva, NO es una regresion: es
el guardian haciendo su trabajo. Se arregla actualizando la cifra publicada.
"""
import os
import re
import unittest

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASM = os.path.join(RAIZ, "src", "jap2", "antarctic.asm")
NOTES = os.path.join(RAIZ, "src", "jap2", "antarctic.notes")
MAKEWEB = os.path.join(RAIZ, "tools", "make_web.py")

TOTAL = 16384


def lee(p):
    with open(p, encoding="utf-8") as f:
        return f.read()


def cuenta_etiquetas():
    """Las etiquetas del listado, SIN contar las de los bloques de datos.

    Las DATA_ las pone mkasm.py en cada rango de datos para separarlos y
    etiquetarlos por su uso; se publican como "rangos de datos", no como
    rutinas con nombre, y contarlas aqui inflaba la cifra de la portada."""
    todas = set(re.findall(r"(?m)^([A-Za-z_]\w*):", lee(ASM)))
    return len({e for e in todas if not e.startswith("DATA_")})


def cuenta_rutinas():
    """Las que alguien llama con un CALL, que es lo que se publica como rutina."""
    cuerpo = lee(ASM)
    definidas = set(re.findall(r"(?m)^([A-Za-z_]\w*):", cuerpo))
    llamadas = set(re.findall(
        r"\bcall\s+(?:nz,|z,|nc,|c,|po,|pe,|p,|m,)?([A-Za-z_]\w*)", cuerpo))
    return len(llamadas & definidas)


def cuenta_bytes_de_codigo():
    """Suma el tamano de cada region de codigo declarada en el listado."""
    n = 0
    for a, b in re.findall(r"; CODIGO (0x[0-9a-f]+)\.\.(0x[0-9a-f]+)", lee(ASM)):
        n += int(b, 16) - int(a, 16)
    return n


def cuenta_directiva(letra):
    return sum(1 for ln in lee(NOTES).splitlines() if ln.startswith(letra + " "))


class TestCifras(unittest.TestCase):

    def test_codigo_y_datos_suman_el_cartucho(self):
        """La cuenta que sostiene el '0 bytes sin explicar' de la portada."""
        codigo = cuenta_bytes_de_codigo()
        self.assertEqual(codigo, 5947)
        self.assertEqual(TOTAL - codigo, 10437)

    def test_la_portada_publica_esas_mismas_cifras(self):
        web = lee(MAKEWEB)
        codigo = cuenta_bytes_de_codigo()
        datos = TOTAL - codigo
        for cifra, sep in ((codigo, "."), (codigo, ","), (datos, "."), (datos, ",")):
            texto = "%s%s%03d" % (cifra // 1000, sep, cifra % 1000)
            self.assertIn(texto, web,
                          "la portada no publica %s" % texto)

    def test_la_portada_publica_las_rutinas_que_hay(self):
        self.assertIn('("%d", "rutinas identificadas")' % cuenta_rutinas(),
                      lee(MAKEWEB))
        self.assertIn('("%d", "routines identified")' % cuenta_rutinas(),
                      lee(MAKEWEB))

    def test_la_portada_dice_cero_sin_identificar(self):
        web = lee(MAKEWEB)
        self.assertIn('("0", "bytes sin identificar")', web)
        self.assertIn('("0", "bytes unidentified")', web)

    def test_las_dos_paginas_de_empezar_dicen_las_mismas_etiquetas(self):
        n = cuenta_etiquetas()
        for pagina in ("docs/es/EMPEZAR.md", "docs/GETTING-STARTED.md"):
            texto = lee(os.path.join(RAIZ, pagina))
            self.assertIn(str(n), texto,
                          "%s no publica las %d etiquetas" % (pagina, n))

    def test_los_comentarios_publicados_son_los_que_hay(self):
        n = cuenta_directiva("C")
        for pagina in ("docs/es/EMPEZAR.md", "docs/GETTING-STARTED.md",
                       "README.md", "README.es.md"):
            self.assertIn(str(n), lee(os.path.join(RAIZ, pagina)),
                          "%s no publica los %d comentarios" % (pagina, n))

    def test_los_rangos_publicados_son_los_que_hay(self):
        n = cuenta_directiva("D")
        for pagina in ("docs/es/EMPEZAR.md", "docs/GETTING-STARTED.md",
                       "README.md", "README.es.md"):
            self.assertIn(str(n), lee(os.path.join(RAIZ, pagina)),
                          "%s no publica los %d rangos" % (pagina, n))

    def test_el_sha_del_cartucho_es_el_mismo_por_todas_partes(self):
        SHA = "a33f9298bf6f740ebe8d88bdc8ed75c855404d804e07679d6c2f2ad00dc3c452"
        for fichero in ("Makefile", "README.md", "README.es.md",
                        "docs/es/EMPEZAR.md", "docs/GETTING-STARTED.md"):
            self.assertIn(SHA, lee(os.path.join(RAIZ, fichero)),
                          "%s no lleva el sha256 del cartucho" % fichero)


class TestLasDiezFases(unittest.TestCase):
    """Las dos paginas del juego tienen que contar el mismo recorrido."""

    # OJO CON EL DESPLAZAMIENTO, que es donde se cae todo el mundo: la distancia
    # y el tiempo de la fase k salen de la entrada k-1 de la tabla de 0x4AD9
    # (indexada por 0xE0E8), y el nombre de la base sale de 0xE0E1, que la
    # escena de llegada SUBE ANTES de escribirlo. O sea que la fase k LLEGA a la
    # base de indice k, y por eso FRANCE -el indice 0- es la de la fase 10 y no
    # la de la 1.
    FASES = [("1500", "100", "USA"), ("1700", "120", "THE SOUTH POLE"),
             ("1100", "80", "USA"), ("1200", "80", "USA"),
             ("1200", "80", "ARGENTINA"), ("500", "40", "UNITED KINGDOM"),
             ("2600", "165", "JAPAN"), ("1200", "90", "AUSTRALIA"),
             ("1500", "100", "AUSTRALIA"), ("1200", "90", "FRANCE")]

    def test_las_dos_tablas_dicen_lo_mismo(self):
        for pagina in ("docs/es/EL-JUEGO.md", "docs/THE-GAME.md"):
            texto = lee(os.path.join(RAIZ, pagina))
            for i, (dist, tiempo, base) in enumerate(self.FASES, 1):
                fila = "| %d | %s m | %s s | %s |" % (i, dist, tiempo, base)
                self.assertIn(fila, texto, "%s: falta la fila %s" % (pagina, fila))

    def test_las_distancias_y_los_tiempos_son_los_del_cartucho(self):
        """Y que no salgan de la cabeza de nadie: se leen de la ROM."""
        rom = os.path.join(RAIZ, "antarctic-jap2.rom")
        if not os.path.exists(rom):
            self.skipTest("sin el cartucho no se puede comprobar")
        with open(rom, "rb") as f:
            d = f.read()
        # Cuatro bytes por fase, y todo en decimal empaquetado: centenas de
        # metros, la casilla del mapa donde empieza, y el tiempo en dos bytes.
        def bcd(b):
            return (b >> 4) * 10 + (b & 0x0F)

        for i, (dist, tiempo, _) in enumerate(self.FASES, 1):
            e = 0x4AD9 - 0x4000 + 4 * (i - 1)   # la fase k usa la entrada k-1
            metros = bcd(d[e]) * 100
            segundos = bcd(d[e + 3]) * 100 + bcd(d[e + 2])
            self.assertEqual(int(dist), metros,
                             "fase %d: la distancia publicada no es la del cartucho" % i)
            self.assertEqual(int(tiempo), segundos,
                             "fase %d: el tiempo publicado no es el del cartucho" % i)


if __name__ == "__main__":
    unittest.main()
