# Las versiones

> **Cuál es cuál no está cerrado.** De este cartucho hay varias compilaciones
> distintas, y lo que esta página dice sobre **versiones y regiones** puede
> cambiar. El listado y las cifras salen del binario igualmente, y `make` las
> reproduce.

De este cartucho hay tres compilaciones distintas, y entre ellas cambian cosas
que van bastante más allá de traducir un rótulo: cambia el color del fondo,
cambia el recorrido, y cambia **cada una de las conversaciones que el código
tiene con el hardware**.

## Cuál es la ROM de aquí

Las tres están desensambladas aquí, cada una en su carpeta de `src/`, y las
tres reensamblan byte a byte a su propia ROM sin dejar un byte sin explicar, y
las tres están comentadas: ninguna de sus rutinas se queda sin explicación. La
que sirve de **origen** es la segunda versión japonesa —y conviene decirlo de
entrada porque no es la que uno esperaría—: sus comentarios se llevan a las
otras dos con el mapa de direcciones de `tools/`, que solo empareja
instrucciones idénticas, y lo que en ellas es código distinto (los chips a pelo
donde esta llama a la BIOS) lleva explicación propia.

    primera japonesa    087378ddad1379a6e378f0810e9cf1dbb64ee03c36e630bb78020b754b7dfebd
    segunda japonesa    a33f9298bf6f740ebe8d88bdc8ed75c855404d804e07679d6c2f2ad00dc3c452
    europea             9b13aaa66661b69a8a9a19656d2d9fd052ddae11aba752e84ebb38b03137739a

Los tres ficheros son de 16384 bytes clavados, y aquí no se distribuye ninguno.
Si los tienes, `make compara` saca de una pasada todo lo que cuenta esta
página.

Un aviso, porque de este juego circulan volcados sucios: los hay de 32 KB con
los mismos 16 KB repetidos dos veces, y copias del mismo fichero con otro
nombre. Lo primero es siempre el sha256.

## Las tres, de un vistazo

|  | primera japonesa | europea | segunda japonesa |
|---|---|---|---|
| fondo y borde | negro | negro | **azul oscuro** |
| puertos del hardware escritos a pelo | 31 | 31 | **0** |
| llamadas a la BIOS | 0 | 0 | **14** |
| ganchos del sistema neutralizados al arrancar | no | no | **sí** |
| copia de tres bytes en el arranque | no | no | **sí** |
| rótulo de portada | `VIDEO CARTRIDGE` | `VIDEO CARTRIDGE` | **`KONAMI`** |
| NEW ZEALAND | **se visita** | está sin usar | está sin usar |
| la demo arranca sola | sí | **no** | sí |
| errata `KEYBOABD` | **sí** | no | no |
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

## Segunda tanda: cambia la máquina entera

Aquí es donde la segunda japonesa se separa de las otras dos, y no es un
detalle del chip gráfico: es toda la capa de hardware, contada instrucción a
instrucción sobre los tres listados.

|  | llamadas a la BIOS | puertos escritos a pelo |
|---|---|---|
| primera japonesa | 0 | 31 |
| europea | 0 | 31 |
| segunda japonesa | **14** | **0** |

Las dos primeras no llaman a la BIOS ni una sola vez y hablan con los chips
directamente: nueve accesos a los datos del vídeo, cuatro a sus registros,
trece al chip de sonido y cinco al circuito que lee el teclado. Y lo hacen
exactamente igual las dos, con el mismo reparto hasta en el número de veces,
así que de esto la europea no cambió nada.

La segunda japonesa no escribe ni un puerto. Lo mismo pasa por catorce llamadas
a la BIOS: `WRTVDP` para los registros de vídeo, `SETRD` y `SETWRT` para
apuntar la memoria de vídeo, `RDVDP` para leer su estado, `WRTPSG` y `RDPSG`
para el sonido y el mando, y `SNSMAT` para el teclado.

La diferencia importa porque en un MSX no está garantizado dónde están los
chips. La norma dice que el puerto del vídeo se lea de la zona de trabajo de la
BIOS, y eso es justo lo que hace:

    ld a,(00006h)   ; el puerto de datos del VDP, que la BIOS guarda ahí
    ld c,a

donde las otras dos llevan el número metido dentro de la propia instrucción, en
rutinas como esta, que es la de escribir un registro del chip gráfico entera:

    di / ld a,e / out (099h),a / ld a,d / out (099h),a / ret

Y el arranque hace algo más que las otras dos no hacen: antes de enganchar su
rutina de interrupción, **rellena de RET los 512 bytes de ganchos que el
sistema tiene reservados**, o sea que desactiva lo que hubiera puesto ahí
cualquier extensión conectada.

De paso, el fondo. El color de fondo y de borde sale del registro 7 del chip, y
las tres lo dejan puesto en el arranque y no lo vuelven a tocar en toda la
partida: 0xE1 en las dos primeras, que es negro, y 0xE4 en la segunda japonesa,
que es azul oscuro.

## Lo que solo tiene la europea: no hay demo

Si dejas quieta la primera japonesa o la segunda, al rato arranca sola una
partida de demostración. En la europea no arranca nunca, y la razón es una sola
instrucción.

El juego va por una máquina de estados de dieciséis casillas, y sus dieciséis
destinos coinciden uno a uno en las tres versiones. Menos uno: el estado 5, que
es el que espera en la pantalla de título.

    segunda japonesa   ld hl,0E004h / dec (hl) / ret nz / jp <siguiente estado>
    europea            ret

En las otras dos, ese estado descuenta un contador de fotogramas y, cuando
llega a cero, pasa al estado siguiente, que es la cortinilla, y de ahí a la
demo. En la europea el estado 5 **es un `ret` pelado**: no cuenta nada y no pasa
a ninguna parte, así que la pantalla de título se queda ahí hasta que alguien
pulse.

Y lo bonito es que la cuenta atrás sigue en el cartucho, **un byte más allá**,
entera y sin que nadie la apunte. Aparece como código huérfano al repasar que
no quede un byte sin explicar, mucho antes de saber por qué está ahí.

## Otra pista de que la primera es la primera

En la primera japonesa, el rótulo del menú dice `KEYBOABD` en vez de
`KEYBOARD`. Está en 0x57B9, con la B donde va la R. En las otras dos está
corregido.

## La copia de tres bytes del arranque

Y llegamos a lo que solo tiene la segunda japonesa. Su INIT copia tres bytes de
0x411F —que son `C3 00 00`, o sea `jp 0000h`— encima de 0x0000, que es la
entrada de la BIOS y el vector de arranque de la máquina:

    ld hl,411Fh / ld de,0000h / ld bc,0003h / ldir

Ahí hay ROM, así que la escritura se pierde y no pasa nada.

Ni la primera japonesa ni la europea llevan nada de esto: la copia no existe en
ninguna parte de esas dos, ni siquiera los tres bytes sueltos de 0x411F.

Qué hace está comprobado leyendo los bytes; **para qué no se puede demostrar
desde el binario**. La lectura que encaja es que sea un guardián contra correr
el cartucho desde RAM, porque la escritura solo llega a alguna parte si eso de
ahí no es ROM, y en un cartucho de verdad es una instrucción que no se nota:
no comprueba nada ni avisa de nada. Pero es una lectura, no una medida.

## Lo que no sabemos

Los cuatro dibujos con los que la primera versión escribe el Polo Sur siguen
sin leerse. Están comprimidos como el resto de los gráficos y harían falta las
direcciones de esa versión para sacarlos.
