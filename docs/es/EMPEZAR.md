# Empezar

## Lo que hace falta

`pasmo` y `z80dasm` para ensamblar y desensamblar, y Python 3 para las
herramientas. Nada más: no hay dependencias que instalar ni entorno que montar.

El cartucho no se distribuye con este repositorio, solo el trabajo de
documentación, así que hace falta tu propia copia con el nombre
`antarctic.rom` en la raíz del proyecto. Son 16384 bytes exactos y tiene que
dar este sha256:

    17f4dd654c937134c44c1faf68a9f67141d69ccf251853228aa5211dc8065126

Si el tuyo no da eso, es otra versión y el listado no reensamblará. `make
comprueba` te lo dice en una línea.

## Las órdenes

```sh
make          # traza, genera el listado y lo comprueba todo
make verify   # solo la prueba de fuego: ¿vuelve a salir el cartucho?
make web      # regenera la web de docs/, imágenes incluidas
make graficos # descomprime los dibujos y los saca a PNG
```

`make` a secas hace el ciclo entero y falla si algo no cuadra: si el listado
deja de reproducir el cartucho byte a byte, si el trazador se ha metido en una
zona declarada como datos, o si un punto de entrada cae dentro de esa zona.

## La prueba que decide

Lo único que convierte un desensamblado en algo fiable es que vuelva a dar el
original. Aquí eso es `make verify`, y lo que hace es ensamblar el listado
publicado y comparar el sha256 con el del cartucho:

    ensamblado : 16384 bytes  17f4dd65...8065126
    original   : 16384 bytes  17f4dd65...8065126
    OK: reproducible byte a byte

Mientras esa línea salga, ni un comentario de este repositorio puede haberse
comido un byte por el camino.

## Sin el cartucho

Se puede leer igualmente el listado de `src/antarctic.asm` y las notas, que es
donde está de verdad el trabajo: 394 rutinas con nombre, 267 comentarios
anclados a su dirección y 62 rangos de datos con su explicación al lado.

## Cómo está organizado

El listado **no se toca a mano**. Se genera, y lo gobiernan tres ficheros:

| | |
|---|---|
| `src/antarctic.entries` | los puntos de entrada: por dónde empieza a trazar |
| `src/antarctic.nocode` | las zonas que NO son código, y por qué se sabe |
| `src/antarctic.notes` | los nombres, los comentarios y los rangos de datos |

De ahí sale `src/antarctic.asm`. Si quieres cambiar un comentario o bautizar
una rutina, va en el `.notes`, anclado a su dirección; así el comentario
sobrevive a un retrazado y nunca se despega de la instrucción que explica.

Esa separación es justo lo que evita que el listado y su comprobación se
distancien con el tiempo, porque el fichero que se publica es el mismo que se
verifica.

## Las herramientas

En `tools/` está todo lo que hace falta, y cada una lleva escrito en su
cabecera qué hace y por qué se hizo así:

| | |
|---|---|
| `z80trace.py` | sigue el flujo desde los puntos de entrada |
| `mkasm.py` | monta el listado con las notas ancladas |
| `descomprime.py` | el descompresor del juego, reimplementado |
| `refs.py` | qué instrucciones apuntan a un rango, sin inventarse punteros |
| `render_tiles.py` | dibuja las casillas y los sprites desde la VRAM |
| `render_banderas.py` | las banderas de las diez paradas |
| `render_decorados.py` | los decorados, con el intérprete del propio juego |
| `render_pista.py` | los siete obstáculos, montados paso a paso |
| `render_foca.py` | la foca que sale de los agujeros, fotograma a fotograma |
| `render_pinguino.py` | las diez posturas del pingüino, en su color |
