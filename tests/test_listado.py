#!/usr/bin/env python3
"""Comprobaciones sobre el listado generado.

Ninguna de estas necesita el cartucho: se hacen sobre src/jap2/antarctic.asm y
src/jap2/antarctic.notes, que van en el repositorio. Lo que vigilan es que el
listado no se degrade sin que nadie se entere -que no vuelvan a aparecer
etiquetas sin nombre, ni bloques de datos sin identificar, ni comentarios que
se queden por el camino-.
"""
import os
import re
import unittest

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASM = os.path.join(RAIZ, "src", "jap2", "antarctic.asm")
NOTES = os.path.join(RAIZ, "src", "jap2", "antarctic.notes")


def asm():
    with open(ASM, encoding="utf-8") as f:
        return f.read()


def notas():
    with open(NOTES, encoding="utf-8") as f:
        return f.read().splitlines()


class TestListado(unittest.TestCase):

    def test_ninguna_etiqueta_sin_nombre(self):
        """Una L_XXXX es una etiqueta que nadie ha bautizado todavia."""
        sueltas = sorted(set(re.findall(r"\bL_[0-9A-F]{4}\b", asm())))
        self.assertEqual(sueltas, [], "quedan etiquetas sin nombre: %s"
                         % " ".join(sueltas[:12]))

    def test_ningun_bloque_de_datos_sin_identificar(self):
        """Cada zona de datos tiene que tener nombre y explicacion."""
        n = asm().count("DATOS sin identificar")
        self.assertEqual(n, 0, "hay %d bloques de datos sin identificar" % n)

    def test_ninguna_etiqueta_declarada_con_equ(self):
        """Un `equ` suelto senala una direccion que el listado no ha colocado.

        Cuando aparece, casi siempre es una tabla apuntada un byte antes de
        donde empieza, o codigo al que el trazador no llega. En los dos casos
        hay algo que mirar, asi que no debe pasar desapercibido.
        """
        sueltas = re.findall(r"(?m)^(\w+):\tequ", asm())
        self.assertEqual(sueltas, [], "hay etiquetas sin colocar: %s"
                         % " ".join(sueltas))

    def test_todos_los_comentarios_llegan_al_listado(self):
        """Una C anclada a una direccion que no es inicio de instruccion se cae.

        mkasm no avisa de eso: sencillamente no la emite. Como el comentario
        sigue en el .notes, es facil creer que esta puesto cuando no lo esta.
        """
        cuerpo = asm()
        perdidos = []
        for ln in notas():
            ln = ln.strip()
            if ln.startswith("C "):
                p = ln.split(None, 2)
                if len(p) > 2 and p[2] not in cuerpo:
                    perdidos.append(p[1])
        self.assertEqual(perdidos, [], "comentarios que no salen: %s"
                         % " ".join(perdidos[:12]))

    def test_todas_las_cabeceras_llegan_al_listado(self):
        cuerpo = asm()
        perdidas = []
        for ln in notas():
            ln = ln.rstrip()
            if ln.startswith("B "):
                p = ln.split(None, 2)
                if len(p) > 2 and p[2].strip() and p[2] not in cuerpo:
                    perdidas.append(p[1])
        self.assertEqual(perdidas, [], "cabeceras que no salen: %s"
                         % " ".join(perdidas[:12]))

    def test_el_listado_lo_genera_la_herramienta(self):
        """Si alguien edita el .asm a mano, el siguiente `make` se lo come."""
        self.assertIn("Generado por tools/mkasm.py", asm())


class TestRangosDeDatos(unittest.TestCase):

    def test_los_rangos_no_se_solapan(self):
        """Dos rangos D que se pisen quieren decir que uno de los dos miente."""
        rangos = []
        for ln in notas():
            if ln.startswith("D "):
                p = ln.split(None, 3)
                rangos.append((int(p[1], 0), int(p[2], 0), p[2]))
        rangos.sort()
        for (a1, b1, _), (a2, b2, _) in zip(rangos, rangos[1:]):
            self.assertLessEqual(b1, a2,
                                 "se solapan 0x%04X-0x%04X y 0x%04X-0x%04X"
                                 % (a1, b1, a2, b2))

    def test_todos_los_rangos_van_al_derecho(self):
        for ln in notas():
            if ln.startswith("D "):
                p = ln.split(None, 3)
                a, b = int(p[1], 0), int(p[2], 0)
                self.assertLess(a, b, "rango del reves: %s" % ln)

    def test_todos_los_rangos_estan_explicados(self):
        """Un rango con nombre pero sin descripcion no explica nada."""
        mudos = []
        for ln in notas():
            if ln.startswith("D "):
                p = ln.split(None, 4)
                if len(p) < 5 or not p[4].strip():
                    mudos.append(p[1])
        self.assertEqual(mudos, [], "rangos sin explicacion: %s"
                         % " ".join(mudos))



class TestNadaDeOtroJuego(unittest.TestCase):
    """Que no se cuele material de otro proyecto.

    Las herramientas de este repositorio vienen de un tronco comun, y con ellas
    viajan textos que hablan de OTRO juego: un pie de pagina, un enlace al
    repositorio equivocado, el titulo que se le pone a cada pagina. Eso no lo
    caza ninguna otra comprobacion -la web se genera igual de bien y los
    enlaces internos siguen sin romperse- y acaba publicado.

    Este test barre las fuentes y lo que se publica buscando el nombre de los
    demas juegos y de sus editoras.
    """

    AJENOS = ("stardust", "temptations", "ale hop", "alehop", "colt 36",
              "colt36", "topo soft")

    def _barre(self, ficheros):
        malos = []
        for ruta in ficheros:
            with open(ruta, encoding="utf-8", errors="ignore") as f:
                texto = f.read().lower()
            for nombre in self.AJENOS:
                if nombre in texto:
                    malos.append("%s: %s" % (os.path.relpath(ruta, RAIZ), nombre))
        return malos

    def _todos(self, carpeta, exts):
        out = []
        for base, _, ficheros in os.walk(os.path.join(RAIZ, carpeta)):
            if ".forja" in base or "__pycache__" in base:
                continue
            out += [os.path.join(base, f) for f in ficheros
                    if f.endswith(exts)]
        return out

    def test_las_herramientas_no_hablan_de_otro_juego(self):
        malos = self._barre(self._todos("tools", (".py",)))
        self.assertEqual(malos, [], "material de otro proyecto: %s"
                         % "; ".join(malos))

    def test_la_web_no_habla_de_otro_juego(self):
        malos = self._barre(self._todos("docs", (".md", ".html")))
        self.assertEqual(malos, [], "material de otro proyecto: %s"
                         % "; ".join(malos))

    def test_la_raiz_no_habla_de_otro_juego(self):
        raiz = [os.path.join(RAIZ, f) for f in
                ("README.md", "README.es.md", "AVISO-LEGAL.md",
                 "LEGAL-NOTICE.md", "LICENSE", "Makefile")]
        malos = self._barre(raiz)
        self.assertEqual(malos, [], "material de otro proyecto: %s"
                         % "; ".join(malos))

    def test_el_listado_no_habla_de_otro_juego(self):
        malos = self._barre([ASM, NOTES,
                             os.path.join(RAIZ, "src", "jap2", "antarctic.entries"),
                             os.path.join(RAIZ, "src", "jap2", "antarctic.nocode")])
        self.assertEqual(malos, [], "material de otro proyecto: %s"
                         % "; ".join(malos))


if __name__ == "__main__":
    unittest.main()


class TestLasTresVersiones(unittest.TestCase):
    """Los tests de arriba miran la version por defecto. Estos, las tres.

    Hacen falta porque asi es como se colaron dos rangos AL REVES en la primera
    japonesa -punteros_de_banderas y color_por_fase, con el fin antes que el
    principio- que nadie vio: su explicacion no se publicaba y el listado
    reensamblaba igual, porque los bytes no cambian.
    """

    def rangos(self, version):
        ruta = os.path.join(RAIZ, "src", version, "antarctic.notes")
        with open(ruta, encoding="utf-8") as f:
            return [(int(l.split()[1], 16), int(l.split()[2], 16), l.split()[3])
                    for l in f if l.startswith("D ")]

    def test_ningun_rango_va_del_reves(self):
        for v in ("jap1", "jap2", "eu"):
            for a, b, nombre in self.rangos(v):
                self.assertLess(a, b, "%s: %s va del reves (%#06x..%#06x)"
                                % (v, nombre, a, b))

    # Dos rangos que se pisan quieren decir que uno de los dos tiene mal un
    # limite, y eso el reensamblado no lo caza: los bytes no cambian.
    def test_ningun_rango_se_solapa_con_otro(self):
        for v in ("jap1", "jap2", "eu"):
            ordenados = sorted(self.rangos(v))
            for (a1, b1, n1), (a2, b2, n2) in zip(ordenados, ordenados[1:]):
                self.assertLessEqual(b1, a2, "%s: %s (%#06x..%#06x) se mete en "
                                     "%s (%#06x..%#06x)" % (v, n1, a1, b1, n2, a2, b2))

    def test_todos_los_rangos_caben_en_el_cartucho(self):
        for v in ("jap1", "jap2", "eu"):
            for a, b, nombre in self.rangos(v):
                self.assertTrue(0x4000 <= a < b <= 0x8000,
                                "%s: %s se sale del cartucho" % (v, nombre))
