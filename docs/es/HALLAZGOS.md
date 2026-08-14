# Hallazgos

Lo que apareció al desmontar el cartucho, con la evidencia al lado. Todo lo de
esta página se comprueba leyendo el binario; lo que todavía no está cerrado
está en [Preguntas abiertas](PREGUNTAS-ABIERTAS.html).

## La demo va grabada

Cuando el juego se queda solo, arranca una partida que juega sola. No hay
ninguna inteligencia detrás: hay 64 bytes en 0x584A que llevan exactamente los
mismos bits que devuelve el joystick, y el lector de mandos coge uno cada 32
fotogramas. Entre byte y byte se repite la dirección anterior, así que la
grabación va a un ritmo muy lento y aun así basta.

Se ve en los propios bytes: `01` es arriba, `09` arriba y derecha, `11` arriba
y botón. Ni un valor sale del mapa de bits del mando.

Y encaja hasta en la duración. La demo dura 0x073C pasos, que a un byte cada
32 son 58 bytes de los 64 que hay. La tira acaba exactamente donde empieza la
primera instrucción de la rutina siguiente.

## Lo primero que hace el cartucho es escribir encima de la BIOS

Entre inicializar la máquina y arrancar el juego hay estas cuatro
instrucciones:

```asm
    ld hl,0411fh      ; origen: tres bytes que son C3 00 00, o sea jp 0000h
    ld de,00000h      ; destino: 0x0000, la entrada de la BIOS
    ld bc,00003h
    ldir
```

En un MSX eso no hace absolutamente nada, porque en 0x0000 hay ROM y la
escritura se pierde por el camino.

Lo llamativo es que **esa instrucción es lo único que separa entre sí a los
volcados de esta versión que circulan por ahí**. Hay otro con el destino puesto
en 0x40B2, que es el despachador del juego, y ahí sí muerde: corriendo desde
una copia en RAM, el despachador quedaría convertido en un salto a cero y la
máquina se reiniciaría en el primer fotograma, porque el bucle de juego lo llama
nada más empezar. Y hay un tercero con el `ldir` convertido en dos `nop`.

Las otras dos compilaciones del cartucho no llevan nada de esto: ni la primera
japonesa ni la europea tienen estas cuatro instrucciones, ni siquiera los tres
bytes sueltos. Lo que encaja con todo junto es una protección contra copias en
memoria, de las discretas —no comprueba nada ni avisa de nada, porque en el
cartucho de verdad es una instrucción que no se nota—, aunque el para qué no se
demuestra desde el binario.

## Hay una base a la que no se llega nunca

El cartucho lleva ocho nombres de base y el recorrido tiene diez paradas. Siete
de esos nombres cubren las diez —Estados Unidos sale tres veces y Australia
dos— y el octavo, **NEW ZEALAND**, no lo pide nadie.

Comprobado por tres caminos distintos, porque una sola comprobación aquí no
basta:

- no está entre las diez entradas de la tabla de nombres;
- ninguna instrucción lo apunta, recorriendo solo inicios de instrucción;
- y ninguna de las veinte direcciones de esa cadena aparece como palabra en
  los 16 KB del cartucho.

Las otras siete sí aparecen apuntadas, así que el control funciona y el cero de
NEW ZEALAND significa algo.

## La foca sale del agujero en ocho pasos

De tres de los siete obstáculos —los agujeros— sale una foca, y está entera en
el cartucho: ocho fotogramas, uno por cada paso del 7 al 14, con la tabla en
0x78C1. El índice de esa tabla es fácil de leer al revés, y el error es
convincente: parece el tipo de obstáculo y es **el paso en que va**. Leída de
la otra manera salen punteros que se van fuera del cartucho; leída bien salen
ocho seguidos, y el último acaba justo en el fotograma que la esconde, que a su
vez acaba donde vuelve a haber código.

Los tres primeros pasos son de dos sprites y los cinco siguientes de cuatro, y
cada fotograma lleva tres variantes. Pero las tres llevan el mismo dibujo: lo
único que cambia es la X, porque una foca sale por el centro, otra se va hacia
la derecha y otra hacia la izquierda. Y del paso 10 al 14 pasa lo mismo con la
otra coordenada —los cuatro dibujos son siempre los mismos y lo que baja es la
Y—, así que la foca no se deforma al acercarse: solo cambia de sitio.

Y el color no está ahí. La rutina que la monta copia tres bytes de cada sprite
—posición y dibujo— y **se salta el cuarto**, que es justo el del color: ese lo
dejó puesto la lista de atributos, que le da el primer sprite en negro y los
otros tres en rojo oscuro. Como en un MSX el sprite de número más bajo va
delante, el negro queda encima y lo que se ve es una foca marrón con la cara
oscura.

## Las nubes se acercan y te pasan por encima

Hay cuatro nubes en el cielo, y no son un dibujo del decorado: son cuatro
sprites que el juego gobierna aparte. Asoman por sitios fijos, suben por la
pantalla al ritmo que marca la velocidad del pingüino —la mitad, exactamente—,
se van abriendo hacia los lados con un desplazamiento propio cada una (-1, +1,
-2 y +2) y cambian de dibujo por el camino, a uno más grande.

Todo eso junto es la perspectiva: la nube crece y se abre porque te la estás
acercando, y sube porque acaba pasándote por encima. Al llegar arriba del todo
se apaga y vuelve a salir por abajo.

Y solo salen si hay partida de verdad. En la demo, el cielo está vacío.

## Las patas amarillas no son un dibujo nuevo

Cuando el pingüino se cae por un agujero y chapotea ahí dentro, se le ven dos
patas amarillas moviéndose. No hay ningún sprite nuevo para eso: es **el mismo
sprite que le hace de sombra**, al que dos instrucciones le cambian el color de
azul oscuro a amarillo. A partir de ahí solo hay que irle poniendo los tres
dibujos del pataleo, y al salir del agua otra instrucción le devuelve su dibujo
y su color de sombra.

Es la misma idea que está por todo el cartucho: **el color de un sprite no vive
en su dibujo**, vive en su entrada de la tabla de atributos. Así que se puede
recolorear cualquier cosa sin tocar ni un byte de gráfico, y eso es lo que se
hace con la sombra aquí, con la foca —cuya cara oscura es un segundo sprite
negro por encima del cuerpo rojo— y con las banderas, que salen las diez del
mismo par de sprites cambiándoles los dos colores.

## Y un sprite amarillo que no se ve nunca

En la lista de atributos hay una entrada montada del todo —la número 14, con su
dibujo y su color amarillo puesto— que jugando no aparece jamás. Y el dibujo no
es cualquier cosa: es **un sol**, un disco de puntas amarillas. Se monta con
la coordenada vertical a 0xE0, que es fuera de la pantalla, y nadie se la
cambia nunca: no hay una sola instrucción que escriba en esa entrada, la cadena
que rehace los sprites al salir del agua se para justo en la anterior, y las
demás copias empiezan más arriba o acaban más abajo.

O sea que el cartucho carga el dibujo, le reserva su sitio, le da color… y lo
deja fuera del encuadre.

Y no es una deducción de leer el binario. Sobre una partida grabada de
veinticinco minutos, un punto de observación en los cuatro bytes de esa entrada
dice que lo único que la toca son barridos de la tabla entera —el borrado de
sprites, el copiador de las listas— y ninguno va a por ella; al terminar la
partida sigue con la coordenada vertical a 0xE0. Y cambiando **solo esos dos
bytes de posición** en una copia del cartucho, sin tocarle ni el dibujo ni el
color, sale al cielo y se ve perfectamente: un sol amarillo de puntas sobre el
azul.

## El alfabeto no tiene F

La tipografía va colocada de forma que el número de casilla es su ASCII menos
0x20, así que la A es la 0x21, la B la 0x22 y así. Con esa cuenta, la F
tendría que estar en la 0x26.

No está: en esa casilla hay otro dibujo, en los tres tercios de la pantalla. Y
la única palabra de todo el juego que necesita una F —**FRANCE**, la primera
base del recorrido— se la lleva puesta: su cadena no usa la 0x26 sino la 0xC9,
que es una F suelta guardada aparte, lejos del alfabeto.

## La mitad de hablar con la pantalla viene sin estrenar

Las rutinas que tratan con el chip gráfico van por parejas: una para escribir y
su gemela exacta para leer. Las dos de escribir se usan a todas horas, diez y
seis veces respectivamente.

Las dos de leer no las llama nadie. Y se puede decir sin rodeos porque la
dirección de una de ellas **no aparece ni una sola vez en los 16 KB**, y la
única aparición de la otra es la llamada que le hace su propia gemela muerta.

Este juego no lee la pantalla nunca. Solo escribe.

## Queda el rastro de un modo de dos jugadores

Hay una rutina que escribe una cadena y detrás un `1` o un `2`, sacado del bit
7 de la palabra de banderas. Nadie la llama —su dirección no aparece en el
cartucho— y además ese bit no lo enciende nadie, porque los dos únicos valores
que se escriben ahí son 0x40 y 0x50.

A juego con eso, el rótulo del marcador dice **1P** fijo, escrito en la cadena
de los rótulos como una constante más.

## Las tablas se delatan solas

Saber dónde acaba una tabla suele ser lo peor de un desensamblado, porque el
tamaño no está escrito en ninguna parte y equivocarse no da ningún error.

En este cartucho casi todas lo dicen. La última palabra de la tabla acaba
exactamente en el byte donde empieza su primer destino, así que solo hay un
tamaño posible: se prueba con N entradas y solo una N cierra. Funciona con las
seis tablas de salto, con las diez fases, con las diez banderas, con los siete
horizontes, con los veinticuatro sonidos y con los cinco tramos de la meta.

Y hay un segundo truco de la casa, este para ahorrar instrucciones: **tres
tablas se apuntan un byte antes de donde empiezan**, porque su índice nunca
vale cero y así se evitan un `dec a`. El byte cero de una de ellas es el último
byte de un `jp`; el de otra, un `ret` suelto que hace de dato sin dejar de ser
un `ret`.

## Los siete obstáculos embaldosan su zona sin dejar un byte

Entre 0x6BE9 y 0x7241 hay 92 trozos de dibujo, y la única pista de para qué son
es que los siete punteros de la tabla de obstáculos caen ahí dentro.

Encadenando los quince pasos que dura cada obstáculo, sale esto:

    tipo 3   6BE9 -> 6D85      tipo 2   7091 -> 7150
    tipo 4   6D85 -> 6F19      tipo 6   7150 -> 71C8
    tipo 0   6F19 -> 6FD2      tipo 5   71C8 -> 7241
    tipo 1   6FD2 -> 7091

Cada cadena acaba justo donde empieza la siguiente, y la última acaba justo en
el final de la zona. Los siete se reparten los 92 trozos sin que sobre ni falte
nada, y de paso queda confirmado que los pasos son quince y que el
encadenamiento se lee bien.

Un detalle bonito de ahí: los siete punteros apuntan a un bloque **vacío**. No
es un error de lectura, es que el primer paso de un obstáculo no dibuja nada
porque todavía está detrás del horizonte, y dos de los siete llevan dos pasos
vacíos.

## Lo que parece un acelerador invertido es un periodo

La tabla que gobierna la velocidad tiene cuatro destinos, uno por cada
combinación de arriba y abajo. Sin tocar nada no pasa nada, con las dos a la
vez tampoco, y las otras dos hacen lo esperable: arriba acelera y abajo frena.

Se lee al revés con mucha facilidad, porque **arriba es la que RESTA**. Y resta
porque en 0xE100 no está la velocidad, sino el periodo: cada cuántos fotogramas
avanza el juego. Lo dicen sus tres usos. Dos contadores descendentes se recargan
con él —el de la distancia con su mitad, en 0x46DC, y el de la pista con su
cuarta parte, en 0x5334—, y el velocímetro tiene que invertirlo con un `cpl`
para dibujar la barra. Menos periodo es más velocidad, y el tope de carrera es
el 8.

Además no cuestan igual: cada escalón de aceleración tarda doce fotogramas y
cada uno de frenada solo cuatro, así que el pingüino suelta la carrera tres
veces más rápido de lo que la coge.

La regla que sale de aquí sirve para cualquier desensamblado: **una variable
que se recarga en un contador descendente es un periodo, no una magnitud**.
Antes de llamarle velocidad a algo, hay que mirar si el juego la usa para
contar fotogramas.

## Las dos tablas de doce que no son lo mismo

Junto al reproductor de sonido hay dos tablas de doce bytes, pegadas la una a
la otra. La primera es una octava cromática, y se nota: los doce periodos
caen a 0,09 semitonos del temperamento igual.

La segunda invita a leerse igual, y no lo es. Medida como si fuera una escala
da 15,8 semitonos, que no es ninguna escala de nada. Lo que es se ve en el
código que la usa: el nibble alto de cada nota la indexa para sacar **cuánto
dura**. Son duraciones, y van de 5 a 100 fotogramas.

## El silencio es un flujo que se acaba en el primer byte

De los veinticuatro punteros de sonido, el primero apunta fuera del cartucho.
No es un error: el sonido cero no se pide nunca, así que esa entrada no se lee
jamás.

Y los tres últimos apuntan todos al mismo byte, que es un `0xFF`, o sea el
final de un flujo. Ese es el silencio, y es lo que pide el arranque para dejar
el chip callado antes de empezar.
