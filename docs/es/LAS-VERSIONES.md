# Las versiones

De este cartucho hay tres compilaciones distintas, y entre ellas cambian cosas
que van bastante más allá de traducir un rótulo: cambia el color del fondo,
cambia el recorrido, y cambia hasta la manera de hablarle al chip gráfico.

## Cuál es la ROM de aquí

Este desensamblado está hecho sobre la **segunda versión japonesa**, y conviene
decirlo de entrada porque no es la que uno esperaría. En concreto, sobre un
volcado de esa versión que lleva dos bytes tocados: los de 0x4050-0x4051, que
son el destino de la copia del arranque de la que se habla al final.

    volcado de aquí     17f4dd654c937134c44c1faf68a9f67141d69ccf251853228aa5211dc8065126
    segunda japonesa    a33f9298bf6f740ebe8d88bdc8ed75c855404d804e07679d6c2f2ad00dc3c452
    primera japonesa    087378ddad1379a6e378f0810e9cf1dbb64ee03c36e630bb78020b754b7dfebd
    europea             9b13aaa66661b69a8a9a19656d2d9fd052ddae11aba752e84ebb38b03137739a

Los cuatro ficheros son de 16384 bytes clavados, y aquí no se distribuye
ninguno. Si los tienes, `tools/compara_versiones.py` saca de una pasada todo lo
que cuenta esta página.

Un aviso, porque de este juego circulan muchos volcados sucios: los hay de
32 KB con los mismos 16 KB repetidos dos veces, copias del mismo fichero con
otro nombre, y varios con un par de bytes cambiados. Lo primero es siempre el
sha256, y no fiarse del nombre.

## Las tres, de un vistazo

|  | primera japonesa | europea | segunda japonesa |
|---|---|---|---|
| fondo y borde | negro | negro | **azul oscuro** |
| accesos al VDP con el puerto en el opcode | 14 | 14 | **0** |
| accesos con el puerto leído de la BIOS | 0 | 0 | **8** |
| ganchos del sistema neutralizados al arrancar | no | no | **sí** |
| copia de tres bytes en el arranque | no | no | **sí** |
| rótulo de portada | `VIDEO CARTRIDGE` | `VIDEO CARTRIDGE` | **`KONAMI`** |
| NEW ZEALAND | **se visita** | está sin usar | está sin usar |
| el Polo Sur | **cuatro dibujos propios** | `THE SOUTH POLE` | `THE SOUTH POLE` |

Ninguna de las tres se parece a otra en el binario: entre la primera y la
europea hay 14869 bytes distintos, entre la europea y la segunda 15350, y entre
la primera y la segunda 15443. Son compilaciones separadas, con el código
movido de sitio, no variantes con un parche.

Lo interesante es cómo se agrupan. En el mapa del juego, la europea va con la
segunda japonesa; en la manera de tratar la máquina, va con la primera. O sea
que los cambios llegan en dos tandas, y la europea está en medio.

## Primera tanda: cambia el mapa

Las tres llevan dentro las mismas ocho cadenas con los nombres de las bases y
una tabla de diez punteros que las reparte entre las diez fases. La primera
versión reparte así:

    JAPÓN, AUSTRALIA, AUSTRALIA, FRANCIA, NUEVA ZELANDA, el Polo,
    EE. UU., EE. UU., ARGENTINA, REINO UNIDO

y las otras dos así:

    FRANCIA, EE. UU., el Polo, EE. UU., EE. UU., ARGENTINA,
    REINO UNIDO, JAPÓN, AUSTRALIA, AUSTRALIA

Es la misma vuelta al mundo girada tres puestos, con un solo cambio de verdad:
donde la primera manda a Nueva Zelanda, las otras repiten Estados Unidos. La
cadena de NEW ZEALAND se queda en el cartucho, entera y sin que nadie la
apunte. Ese índice, por cierto, es la base **a la que se llega**: el 0 es de
donde sales y también donde se cierra la vuelta, en la décima fase.

En la misma tanda cambian otras dos cosas del texto. El rótulo de la base del
Polo, que en la primera no son letras sino cuatro dibujos propios —los patrones
0xCE a 0xD1, que no salen en ninguna otra palabra del juego—, pasa a estar
deletreado como `THE SOUTH POLE`. Y cada cadena empieza a llevar delante dos
bytes con el sitio exacto de la pantalla donde va escrita, que es lo que la
centra: 0x3AC8 para las de catorce letras, 0x3ACE para las tres de EE. UU.

## Segunda tanda: cambia la máquina

Aquí es donde la segunda japonesa se separa de las otras dos, y todo lo que
cambia va en la misma dirección: dejar de dar por hecho cómo es el MSX que hay
debajo.

Las dos primeras llevan los puertos del chip gráfico escritos dentro de las
propias instrucciones. Su rutina de escribir un registro es esta entera:

    di / ld a,e / out (099h),a / ld a,d / out (099h),a / ret

y con ella hay catorce accesos más del mismo estilo. La segunda japonesa no
tiene ni uno. Los ocho accesos a los datos del vídeo pasan a `out (c),a`, con
el número de puerto en C, y ese número no está escrito en ninguna parte: se lee
de la zona de trabajo de la BIOS, que es donde la máquina apunta cuál es el
suyo.

    ld a,(00006h)   ; el puerto de datos del VDP, que la BIOS guarda ahí
    ld c,a

Los registros pasan a mandarse con la llamada estándar de la BIOS y el apuntado
de la memoria de vídeo también. Y el arranque hace algo más que las otras dos
no hacen: antes de enganchar su rutina de interrupción, **rellena de RET los
512 bytes de ganchos que el sistema tiene reservados**, o sea que desactiva lo
que hubiera puesto ahí cualquier extensión conectada.

De paso, el fondo. El color de fondo y de borde sale del registro 7 del chip, y
las tres lo dejan puesto en el arranque y no lo vuelven a tocar en toda la
partida: 0xE1 en las dos primeras, que es negro, y 0xE4 en la segunda japonesa,
que es azul oscuro.

## La copia de tres bytes del arranque

Y llegamos a lo que solo tiene la segunda japonesa. Su INIT copia tres bytes de
0x411F —que son `C3 00 00`, o sea `jp 0000h`— encima de otra dirección. En el
volcado de este desensamblado esa dirección es 0x40B2, que es el despachador
del juego, la rutina por la que pasan todos los saltos por tabla y a la que se
llama en el primer fotograma:

    ld hl,411Fh / ld de,40B2h / ld bc,0003h / ldir

En un cartucho no pasa nada, porque la página donde vive el cartucho es ROM y
la escritura se pierde. Pero corriendo desde RAM, el despachador se convertiría
en un salto a cero y la máquina se reiniciaría antes de enseñar nada. Es una
protección contra copias, y de las buenas: no comprueba nada ni avisa de nada,
porque en el cartucho de verdad es una instrucción que no se nota.

Los dos bytes que separan este volcado del otro de la misma versión son
justamente el destino de esa copia, que allí es 0x0000. Y por ahí circula
además un tercer volcado, otra vez de esta misma versión, con el `ldir` entero
convertido en dos `nop`. Tres variantes del mismo binario que solo se
diferencian en esa instrucción dan una idea bastante clara de para qué está.

Ni la primera japonesa ni la europea llevan nada de esto: la copia no existe en
ninguna parte de esas dos, ni siquiera los tres bytes sueltos.

## Lo que no sabemos

Los cuatro dibujos con los que la primera versión escribe el Polo Sur siguen
sin leerse. Están comprimidos como el resto de los gráficos y harían falta las
direcciones de esa versión para sacarlos.
