# Las versiones

Del cartucho hay tres compilaciones distintas: dos que se venden en Japón y la
que sale de allí. Este desensamblado está hecho sobre la última, la europea, y
resulta que también sirve para una de las japonesas, porque entre las dos hay
exactamente dos bytes de diferencia.

Los tres ficheros son de 16384 bytes clavados:

    primera japonesa   087378ddad1379a6e378f0810e9cf1dbb64ee03c36e630bb78020b754b7dfebd
    segunda japonesa   a33f9298bf6f740ebe8d88bdc8ed75c855404d804e07679d6c2f2ad00dc3c452
    europea            17f4dd654c937134c44c1faf68a9f67141d69ccf251853228aa5211dc8065126

Aquí no se distribuye ninguno. Si los tienes los tres,
`tools/compara_versiones.py` saca de una pasada todo lo que cuenta esta página,
que para eso está.

Y un aviso antes de nada: de este juego circulan muchos volcados sucios.
Los hay de 32 KB con los mismos 16 KB repetidos dos veces, copias del mismo
fichero con otro nombre, y alguno que es la europea con un par de bytes tocados
por alguien que quería correrla desde RAM. Lo primero es siempre el sha256.

## La segunda japonesa y la europea son el mismo binario

Difieren en **dos bytes** y en nada más. Están en 0x4050 y 0x4051, dentro del
arranque, y lo que cambian es el destino de una copia de tres bytes:

    segunda japonesa   ld hl,411Fh / ld de,0000h / ld bc,0003h / ldir
    europea            ld hl,411Fh / ld de,40B2h / ld bc,0003h / ldir

Todo lo demás —el código, los gráficos comprimidos, los textos, la música, la
partida de demostración— es byte por byte lo mismo. Así que este desensamblado
describe las dos igual de bien, y lo único que hay que saber para leerlo como
la japonesa es cambiar ese `40B2h` por un `0000h`. De ese LDIR hablamos al
final, porque tiene su gracia.

## La primera es otro cartucho

Aquí ya no hay retoques: 15443 de los 16384 bytes son distintos, un 94 % del
cartucho, y el código está movido de sitio de arriba abajo. Es otra
compilación. Lo interesante es que casi todo lo que cambia va en la misma
dirección.

### Da por hecho dónde está el chip gráfico

La primera versión lleva los puertos del VDP escritos dentro de las propias
instrucciones: catorce accesos con el número de puerto metido en el opcode,
del estilo de

    di / ld a,e / out (099h),a / ld a,d / out (099h),a / ret

que es su rutina entera de escribir un registro del chip. En un MSX japonés de
1984 eso funciona y ya está.

En las otras dos no queda ni uno. Los ocho accesos a los datos del vídeo pasan
a `out (c),a`, con el número de puerto en C, y ese número no está escrito en
ninguna parte: se lee de la zona de trabajo de la BIOS, que es donde la máquina
apunta cuál es el suyo.

    ld a,(00006h)   ; el puerto de datos del VDP, que la BIOS guarda ahí
    ld c,a

Los registros pasan a mandarse con la llamada estándar de la BIOS, y el
apuntado de la memoria de vídeo también. No es un retoque suelto: alguien fue
sitio por sitio quitando la suposición de que el chip está donde suele estar.

### Y da por hecho que no hay nada más enchufado

El mismo arranque tiene otras dos diferencias del mismo estilo. La primera
versión engancha su rutina de interrupción y a correr; las otras dos, antes de
engancharla, **rellenan de RET los 512 bytes de ganchos que el sistema tiene
reservados**, o sea que desactivan lo que hubiera puesto ahí cualquier
extensión conectada. Y para descartar la interrupción que queda pendiente al
arrancar, la primera lee el puerto del vídeo a pelo y las otras llaman a la
BIOS.

### El fondo es negro

El color de fondo y de borde sale del registro 7 del chip gráfico, y las tres
lo dejan puesto en el arranque y no lo vuelven a tocar en toda la partida.

    primera japonesa   0xE1  -> tinta gris, fondo y borde negros
    las otras dos      0xE4  -> tinta gris, fondo y borde azul oscuro

Así que la pantalla de Konami de la primera sale sobre negro y la de las otras
dos sobre azul.

### Nueva Zelanda existe y se visita

Las tres llevan dentro las mismas ocho cadenas con los nombres de las bases, y
una tabla de diez punteros que reparte esas ocho entre las diez fases del
recorrido. El reparto no es el mismo:

    primera japonesa   JAPÓN, AUSTRALIA, AUSTRALIA, FRANCIA, NUEVA ZELANDA,
                       el Polo, EE. UU., EE. UU., ARGENTINA, REINO UNIDO
    las otras dos      FRANCIA, EE. UU., el Polo, EE. UU., EE. UU., ARGENTINA,
                       REINO UNIDO, JAPÓN, AUSTRALIA, AUSTRALIA

Es la misma vuelta al mundo girada tres puestos —la primera empieza en Japón y
las otras en Francia— con un solo cambio de verdad: donde la primera manda a
Nueva Zelanda, las otras repiten Estados Unidos. La cadena de NEW ZEALAND sigue
guardada en el cartucho, en 0x5610, y no la apunta nadie. Ahí sigue, entera y
sin estrenar, ocupando sus dieciséis bytes.

### El Polo Sur está escrito en japonés

En la primera, el rótulo de la base del Polo no son letras: son cuatro dibujos
propios, los patrones 0xCE a 0xD1, que no salen en ninguna otra palabra del
juego. En las otras dos ese hueco lo ocupa `THE SOUTH POLE`, deletreado con el
mismo alfabeto que el resto.

Por el camino cambia también el rótulo de la portada, que en la primera dice
`VIDEO CARTRIDGE` y en las otras `KONAMI`, y la manera de guardar los nombres:
en las dos últimas cada cadena lleva delante dos bytes con el sitio exacto de
la pantalla donde va escrita, que es lo que la centra —0x3AC8 para las de
catorce letras, 0x3ACE para las tres de EE. UU.—, y en la primera esos dos
bytes no están.

## El LDIR que no hace nada

Volvamos a los dos bytes del principio. Lo que hace ese LDIR es copiar tres
bytes de 0x411F —que son `C3 00 00`, o sea `jp 0000h`— encima de 0x40B2. Y
0x40B2 es el despachador del juego, la rutina por la que pasan todos los saltos
por tabla, a la que se llama en el primer fotograma.

En un cartucho no pasa nada, porque la página donde vive el cartucho es ROM y
la escritura se pierde por el camino. Pero si el juego estuviera corriendo
desde RAM, el despachador se convertiría en un salto a cero y la máquina se
reiniciaría antes de enseñar nada.

Las tres versiones puestas en fila dicen bastante:

    primera japonesa   no lleva ese LDIR en ninguna parte
    segunda japonesa   lo lleva, apuntando a 0x0000
    europea            lo lleva, apuntando a 0x40B2

O sea que aparece después, y entre una versión y la siguiente alguien le cambia
la puntería. **Qué hace está comprobado leyendo los bytes; para qué está no se
puede demostrar desde el binario.** La lectura obvia es que sea una protección
contra copias en RAM, y suma que por ahí circule un volcado que es exactamente
la europea con esos dos bytes convertidos en `nop`, que es justo lo que haría
quien quisiera quitársela de encima. Pero eso es una lectura, no una medida.

## Lo que no sabemos

Los cuatro dibujos con los que la primera versión escribe el Polo Sur siguen
sin leerse. Están en el cartucho comprimidos como el resto de los gráficos y
harían falta las direcciones de esa versión para sacarlos.
