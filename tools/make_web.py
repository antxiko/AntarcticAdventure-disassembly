#!/usr/bin/env python3
"""Genera la portada de la web, en los dos idiomas.

El diseno es el compartido por la serie (tools/estilo_web.py) y la pagina sale
autocontenida, con las imagenes embebidas como data URI.

El logotipo de la cabecera no es una imagen dibujada aparte: son las 46
casillas que el propio juego pinta en la pantalla de presentacion, sacadas de
la VRAM reconstruida. Si el reparto de la memoria de video estuviera mal, ahi
no saldria un rotulo legible.

Uso: make_web.py <work/vram.bin> <docs/imagenes> <salida.html> <idioma>
"""
import base64
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from estilo_web import ESTILO                      # noqa: E402
from render_maps import PALETA, png                # noqa: E402

# Los tres numeros que dan las cifras de la portada. Salen de contar sobre el
# listado generado, no de escribirlos aqui a ojo: 16384 = 5947 + 10437.
CODIGO = 5947
DATOS = 10437

TXT = {
    "es": dict(
        titulo="Antarctic Adventure (1984) — desensamblado comentado",
        claim="Un cartucho japonés de 16 KB de 1984, desmontado byte a byte. "
              "Dentro hay un pingüino que cruza la Antártida entre diez bases "
              "de investigación, una partida de demostración que va grabada "
              "como un pianola, y una base a la que no se llega nunca.",
        ficha=["Konami · <b>1984</b>", "Cartucho de <b>16 KB</b>",
               "MSX1 · <b>RC-701</b>", "Sin cinta: <b>ROM fija</b>"],
        nav=[("#numbers", "Las cifras"), ("#findings", "Hallazgos"),
             ("#screens", "Los gráficos")],
        docnav=[("EMPEZAR.html", "Empezar"), ("EL-JUEGO.html", "El juego"),
                ("EL-CARTUCHO.html", "El cartucho"),
                ("EL-CODIGO.html", "El código"),
                ("HALLAZGOS.html", "Hallazgos"),
                ("PREGUNTAS-ABIERTAS.html", "Preguntas abiertas")],
        otro=("../", "In English"),
        h_num="El juego en cifras", h_find="Lo que apareció al desmontarlo",
        h_scr="Los gráficos",
        cifras=[("100%", "del binario explicado"), ("116", "rutinas identificadas"),
                ("10", "fases del recorrido"), ("5.947", "bytes de código"),
                ("10.437", "bytes de datos"), ("0", "bytes sin identificar")],
        nota_scr="Nada de esto es una captura de pantalla. Está dibujado desde "
                 "los propios datos del cartucho, descomprimiéndolos igual que "
                 "hace el juego y con las bases de memoria que él mismo escribe "
                 "en los registros del chip gráfico. Y por eso vale como "
                 "comprobación además de como ilustración: si el reparto "
                 "estuviera mal, lo que saldría es ruido y no unos pingüinos.",
        pie_leg="Esto es trabajo de documentación y preservación sobre un juego "
                "de 1984: el código y los gráficos siguen siendo de sus autores "
                "y de Konami, y la imagen del cartucho no se distribuye.",
    ),
    "en": dict(
        titulo="Antarctic Adventure (1984) — a commented disassembly",
        claim="A 16 KB Japanese cartridge from 1984, taken apart byte by byte. "
              "Inside there's a penguin crossing Antarctica between ten "
              "research bases, an attract-mode game that plays back from a "
              "recording like a pianola roll, and one base you never get to.",
        ficha=["Konami · <b>1984</b>", "A <b>16 KB</b> cartridge",
               "MSX1 · <b>RC-701</b>", "No tape: <b>fixed ROM</b>"],
        nav=[("#numbers", "The numbers"), ("#findings", "What turned up"),
             ("#screens", "The graphics")],
        docnav=[("GETTING-STARTED.html", "Getting started"),
                ("THE-GAME.html", "The game"),
                ("THE-CARTRIDGE.html", "The cartridge"),
                ("THE-CODE.html", "The code"),
                ("FINDINGS.html", "Findings"),
                ("OPEN-QUESTIONS.html", "Open questions")],
        otro=("es/", "En castellano"),
        h_num="The game in numbers", h_find="What turned up when we took it apart",
        h_scr="The graphics",
        cifras=[("100%", "of the binary explained"), ("116", "routines identified"),
                ("10", "stages on the route"), ("5,947", "bytes of code"),
                ("10,437", "bytes of data"), ("0", "bytes unidentified")],
        nota_scr="None of this is a screen capture. It's drawn from the "
                 "cartridge's own data, decompressed exactly the way the game "
                 "does it and using the memory layout the game itself writes "
                 "into the video chip's registers. Which makes it a check as "
                 "much as an illustration: get the layout wrong and what comes "
                 "out is noise, not penguins.",
        pie_leg="This is documentation and preservation work on a 1984 game: the "
                "code and artwork still belong to their authors and to Konami, "
                "and the cartridge image is not distributed.",
    ),
}

HALLAZGOS = {
    "es": [
        ("La partida de demostración va grabada",
         "<p>Lo que se ve cuando el juego se deja solo no lo juega ninguna "
         "inteligencia: son 64 bytes en 0x584A que llevan exactamente los "
         "mismos bits que devuelve el joystick, y el lector de mandos coge uno "
         "cada 32 fotogramas. Entre byte y byte se repite la dirección "
         "anterior.</p>"
         "<p>Y encaja hasta en la duración: la demo dura 1852 pasos, o sea 58 "
         "de esos 64 bytes, y la tira acaba justo donde empieza la primera "
         "instrucción de la rutina siguiente.</p>"),
        ("Lo primero que hace es escribir sobre sí mismo",
         "<p>Entre la inicialización de la máquina y el arranque del juego hay "
         "un <code>ldir</code> que copia tres bytes —<code>C3 00 00</code>, es "
         "decir <code>jp 0000h</code>— encima del despachador que gobierna "
         "todo el juego.</p>"
         "<p>En un cartucho eso no hace nada, porque esa mitad del mapa de "
         "memoria es ROM y la escritura se pierde por el camino. Pero si el "
         "cartucho estuviera copiado en RAM, el despachador quedaría "
         "convertido en un salto a cero y la máquina se reiniciaría en el "
         "primer fotograma, porque el bucle de juego lo llama enseguida. Que "
         "lo hace está comprobado leyendo los bytes; para qué lo hace, cada "
         "cual.</p>"),
        ("Hay una base de investigación a la que nunca se llega",
         "<p>El cartucho lleva ocho nombres de base y el recorrido tiene diez "
         "paradas. Siete nombres se reparten esas diez —tres de ellas son la "
         "misma— y el octavo, <b>NEW ZEALAND</b>, no lo pide nadie.</p>"
         "<p>No es una impresión: no está entre las diez entradas de la tabla, "
         "ninguna instrucción lo apunta, y ninguna de las veinte direcciones "
         "de esa cadena aparece como palabra en los 16 KB del cartucho. Las "
         "otras siete sí aparecen apuntadas.</p>"),
        ("Todo el dibujo va comprimido, y la mitad va espejada",
         "<p>Ni un gráfico está en crudo. Hay un descompresor de 61 bytes con "
         "cuatro puertas de entrada distintas, y el formato es de los que se "
         "leen de un vistazo: un byte dice si lo que viene se repite tantas "
         "veces o si son tantos bytes tal cual.</p>"
         "<p>Lo bonito es la cuarta puerta: invierte los bits de cada byte "
         "según entra, que en una pantalla de mapa de bits es un espejo "
         "horizontal. Así el borde derecho de la pista no ocupa un solo byte "
         "más que el izquierdo: es el mismo, leído al revés.</p>"),
        ("La mitad de leer la memoria de vídeo viene sin estrenar",
         "<p>Las rutinas que hablan con el chip gráfico van por parejas: una "
         "para escribir y su gemela exacta para leer. Las dos de escribir se "
         "usan a todas horas. Las dos de leer no las llama nadie, y se puede "
         "afirmar sin miedo porque la dirección de una de ellas no aparece ni "
         "una sola vez en los 16 KB, y la única aparición de la otra es la "
         "llamada que le hace su propia gemela muerta.</p>"
         "<p>Este juego no lee la pantalla nunca. Solo escribe.</p>"),
        ("Las tablas se delatan solas",
         "<p>Saber dónde acaba una tabla suele ser lo más incómodo de un "
         "desensamblado, porque el tamaño no está escrito en ninguna parte. "
         "Aquí casi todas lo dicen: la última palabra de la tabla acaba "
         "exactamente en el byte donde empieza su primer destino, así que solo "
         "hay un tamaño posible y no hay nada que suponer.</p>"
         "<p>Y hay un segundo truco de la casa, este para ahorrar "
         "instrucciones: tres tablas se apuntan un byte antes de donde "
         "empiezan, porque su índice nunca vale cero y así se evita un "
         "<code>dec a</code>. El byte cero de una de ellas es el último de un "
         "<code>jp</code>; el de otra, un <code>ret</code> suelto.</p>"),
    ],
    "en": [
        ("The attract mode is a recording",
         "<p>What you see when the game is left alone isn't played by any kind "
         "of intelligence: it's 64 bytes at 0x584A carrying exactly the same "
         "bits the joystick returns, and the input reader picks up one of them "
         "every 32 frames. In between, the previous direction is held.</p>"
         "<p>Even the length works out: the demo runs for 1852 steps, that is "
         "58 of those 64 bytes, and the run ends exactly where the next "
         "routine's first instruction begins.</p>"),
        ("The first thing it does is write over itself",
         "<p>Between bringing the machine up and starting the game there's an "
         "<code>ldir</code> copying three bytes —<code>C3 00 00</code>, that "
         "is <code>jp 0000h</code>— straight over the dispatcher that runs the "
         "whole game.</p>"
         "<p>On a cartridge that does nothing, because that half of the memory "
         "map is ROM and the write goes nowhere. But if the cartridge were "
         "running from a copy in RAM, the dispatcher would turn into a jump to "
         "zero and the machine would reset on the very first frame, since the "
         "game loop calls it immediately. That it does this is settled by "
         "reading the bytes; why it does it, make of it what you will.</p>"),
        ("There's a research base you never reach",
         "<p>The cartridge carries eight base names and the route has ten "
         "stops. Seven of the names cover those ten —three of them are the "
         "same one— and the eighth, <b>NEW ZEALAND</b>, is asked for by "
         "nobody.</p>"
         "<p>This isn't an impression: it isn't among the table's ten entries, "
         "no instruction points at it, and not one of that string's twenty "
         "addresses appears as a word anywhere in the 16 KB. The other seven "
         "do show up pointed at.</p>"),
        ("Every picture is compressed, and half of them are mirrored",
         "<p>Not a single graphic sits there in the raw. There's a 61-byte "
         "decompressor with four separate doors into it, and the format is one "
         "of those you can read at a glance: one byte says whether what "
         "follows is repeated so many times or is so many bytes taken as "
         "they come.</p>"
         "<p>The nice part is the fourth door: it flips the bits of each byte "
         "on the way in, which on a bitmapped screen is a horizontal mirror. "
         "So the right-hand edge of the track costs not one byte more than the "
         "left: it's the same one, read backwards.</p>"),
        ("Half of talking to video memory was never used",
         "<p>The routines that deal with the graphics chip come in pairs: one "
         "to write and its exact twin to read. Both writers are used "
         "constantly. Neither reader is called by anyone, and that can be said "
         "without hedging because one of their addresses never appears in the "
         "16 KB at all, and the only appearance of the other is the call its "
         "own dead twin makes to it.</p>"
         "<p>This game never reads the screen. It only writes.</p>"),
        ("The tables give themselves away",
         "<p>Working out where a table ends is usually the awkward part of a "
         "disassembly, because the size isn't written down anywhere. Here "
         "nearly all of them say so: the table's last word ends exactly on the "
         "byte where its own first destination starts, so only one size is "
         "possible and there's nothing left to guess.</p>"
         "<p>And there's a second house trick, this one to save instructions: "
         "three tables are pointed at one byte before they begin, because "
         "their index is never zero and that saves a <code>dec a</code>. The "
         "byte-zero of one of them is the last byte of a <code>jp</code>; of "
         "another, a stray <code>ret</code>.</p>"),
    ],
}

IMAGENES = [
    ("sprites.png",
     "Los 64 sprites de 16x16: los pingüinos, los peces y las focas",
     "The 64 16x16 sprites: the penguins, the fish and the seals"),
    ("tiles-banco0.png",
     "El primero de los tres bancos de casillas: la tipografía, el logotipo de "
     "KONAMI y el rótulo de la presentación",
     "The first of the three tile banks: the typeface, the KONAMI logo and the "
     "title banner"),
    ("decorados-todos.png",
     "Los dieciséis decorados que embaldosan los bordes de la pista",
     "The sixteen scenery blocks that tile the edges of the track"),
    ("banderas.png",
     "Las banderas de las bases, descomprimidas: siete dibujos para diez paradas",
     "The bases' flags, decompressed: seven pictures for ten stops"),
    ("pista.png",
     "Un agujero en el hielo, montado por trozos según se acerca",
     "A hole in the ice, built up piece by piece as it comes closer"),
]

# El rotulo de la presentacion: 23 columnas de dos casillas, empezando en la
# 0xB2 y de dos en dos, que es como las pinta 0x4864.
LOGO_COL, LOGO_BASE, LOGO_ESC = 23, 0xB2, 3


def img64(ruta):
    with open(ruta, "rb") as f:
        return "data:image/png;base64," + base64.b64encode(f.read()).decode()


def logo_png(vrampath, ruta):
    """Dibuja el rotulo ANTARCTIC ADVENTURE desde la VRAM reconstruida.

    Las bases son las que el juego escribe en los registros del VDP: patrones
    en 0x2000 y colores en 0x0000, al reves de lo corriente. El rotulo vive en
    el banco 0, que es el tercio de arriba de la pantalla.
    """
    v = open(vrampath, "rb").read()
    ancho, alto = LOGO_COL * 8, 2 * 8
    px = [[(0, 0, 0)] * ancho * LOGO_ESC for _ in range(alto * LOGO_ESC)]
    for col in range(LOGO_COL):
        for fila, t in enumerate((LOGO_BASE + 2 * col, LOGO_BASE + 2 * col + 1)):
            patron = v[0x2000 + t * 8:0x2000 + t * 8 + 8]
            color = v[0x0000 + t * 8:0x0000 + t * 8 + 8]
            for y in range(8):
                b, c = patron[y], color[y]
                tinta, fondo = PALETA[c >> 4], PALETA[c & 15]
                for bit in range(8):
                    rgb = tinta if b & (0x80 >> bit) else fondo
                    for sy in range(LOGO_ESC):
                        for sx in range(LOGO_ESC):
                            px[(fila * 8 + y) * LOGO_ESC + sy][
                                (col * 8 + bit) * LOGO_ESC + sx] = rgb
    png(ruta, ancho * LOGO_ESC, alto * LOGO_ESC, px)


def main(argv):
    if len(argv) < 5:
        print(__doc__)
        return 2
    vram, imgdir, salida, idioma = argv[1], argv[2], argv[3], argv[4]
    t = TXT[idioma]
    os.makedirs(imgdir, exist_ok=True)
    ruta_logo = os.path.join(imgdir, "logo.png")
    logo_png(vram, ruta_logo)

    nav = "".join(f'<a href="{h}">{x}</a>' for h, x in t["nav"])
    nav += "".join(f'<a href="{h}">{x}</a>' for h, x in t["docnav"])
    nav += (f'<a href="{t["otro"][0]}" style="margin-left:auto;color:var(--oro)">'
            f'{t["otro"][1]}</a>')

    cifras = "".join(f'<div class="cifra"><b>{v}</b><span>{e}</span></div>'
                     for v, e in t["cifras"])
    halls = "".join(f'<div class="hall"><h3>{tit}</h3>{cuerpo}</div>'
                    for tit, cuerpo in HALLAZGOS[idioma])
    imgs = ""
    for fich, es, en in IMAGENES:
        ruta = os.path.join(imgdir, fich)
        if not os.path.exists(ruta):
            continue
        pie = es if idioma == "es" else en
        imgs += (f'<figure><img src="{img64(ruta)}" alt="{pie}">'
                 f'<figcaption>{pie}</figcaption></figure>')

    html = f"""<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>{t['titulo']}</title>
<style>{ESTILO}</style>
<header class="top">
  <img src="{img64(ruta_logo)}" alt="Antarctic Adventure (1984)">
  <p class="claim">{t['claim']}</p>
  <p class="ficha">{' · '.join(t['ficha'])}</p>
</header>
<nav>{nav}</nav>
<section id="numbers">
  <h2>{t['h_num']}</h2>
  <div class="cifras">{cifras}</div>
</section>
<section id="findings"><h2>{t['h_find']}</h2>{halls}</section>
<section id="screens">
  <h2>{t['h_scr']}</h2>
  <p class="n">{t['nota_scr']}</p>
  <div class="galeria">{imgs}</div>
</section>
<footer><p>{t['pie_leg']}</p></footer>
"""
    with open(salida, "w", encoding="utf-8") as f:
        f.write(html)
    print("  %s: %d KB (%s)" % (salida, len(html) // 1024, idioma))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
