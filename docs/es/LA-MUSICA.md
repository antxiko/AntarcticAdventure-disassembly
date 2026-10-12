# La música

Todo lo que suena aquí sale de ejecutar el motor de sonido del cartucho (`ATIENDE_SONIDO`, 0x7A30, y `PIDE_SONIDO`, 0x79C9, que le reparte los canales; lo llama la interrupción en 0x406B. Es la versión japonesa 2, la documentada en esta web) en un Z80 emulado, cuadro a cuadro y a 60 por segundo, igual que lo llama el juego. Lo que el motor escribe en el PSG pasa a sonido con un AY-3-8910 (`tools/musica.py`). Cada MP3 es la pieza entera hasta donde vuelve a empezar, más 8 segundos de la vuelta apagándose; las que no se repiten acaban donde acaba el motor.

## Cotejado con openMSX

Las escrituras al PSG se han comparado cuadro a cuadro con las de openMSX (C-BIOS MSX1 japonés). En todos los cuadros el PSG queda igual:

- la música de la salida de fase (0x8A): sus primeros 950 cuadros seguidos y otros nueve tramos más, hasta que el juego la vuelve a pedir;
- la llegada a la base (0x8F) entera, 302 cuadros.

El timbre no está cotejado: es el de un AY-3-8910 de manual, no una grabación del emulador. Las sondas están en `tools/omsx_psg.tcl` y `tools/coteja_psg.py`.

## Cómo se pide una pieza

`PIDE_SONIDO` recibe el número en A. Por debajo de 0x8A es un efecto y usa un solo canal; 0x8A y 0x8B usan dos canales y de 0x8C en adelante los tres. Cada canal tiene diez bytes en 0xE010, 0xE01A y 0xE024. El motor no escribe nunca el mezclador del PSG (registro 7): lo deja puesto el arranque, y aquí se parte de ese mismo valor, 0xB8. Pedir otra vez el mismo número reinicia la pieza, y por eso el cotejo de la 0x8A se hace por tramos.

## Las músicas

**La salida de cada fase** (0x8A)

Lo pide `ESTADO_10_ENTRA`, solo en la partida; dura 51,2 s y vuelve a empezar en el segundo 0,0.

<audio controls preload="none" src="../audio/musica_8A.mp3?v=7839190e"></audio>

**Se acabó el tiempo** (0x8C)

Lo pide `ESTADO_12_TIME_OUT`; dura 5,4 s.

<audio controls preload="none" src="../audio/musica_8C.mp3?v=bb0bf293"></audio>

**La llegada a la base** (0x8F)

Lo pide `META_3_LLEGA`; dura 5,0 s.

<audio controls preload="none" src="../audio/musica_8F.mp3?v=b5d821f7"></audio>

**La pantalla de título** (0x92)

Lo pide `MENU_0_PINTA`; dura 5,4 s.

<audio controls preload="none" src="../audio/musica_92.mp3?v=80316205"></audio>
