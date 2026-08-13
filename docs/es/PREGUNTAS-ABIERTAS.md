# Preguntas abiertas

Cada byte del cartucho tiene dueño, el listado vuelve a dar el original byte a
byte y las 394 etiquetas tienen escrito qué hacen. Pero eso no es una lista de
deberes tachados: esta página cuenta qué significan esas cifras exactamente, y
qué queda por saber.

## Qué es cada obstáculo

Los siete están completamente descritos por dentro —su dibujo, su cadena de
quince pasos, sus dos ventanas de choque, qué sonido dan y qué puntos— y de
tres de ellos se sabe además que son agujeros, porque son exactamente los tres
de los que sale el pez.

Lo que no está cerrado es cómo se llama cada uno mirándolo. Que los tipos 5 y 6
se recogen y valen 500 puntos está en el código; si eso es una bandera, una
mata de hielo o cualquier otra cosa, hace falta verlo. Es una tarde de
emulador, no una investigación.

## Lo que no se ha medido en el emulador

Todo lo que dice este repositorio sale de leer el binario, y eso tiene un
límite muy concreto: **lo que se lee explica lo que el programa hace, no lo que
el jugador ve**. Las imágenes de la web son una comprobación fuerte de que los
gráficos están donde decimos —si el reparto de la memoria de vídeo estuviera
mal, saldría ruido en vez de pingüinos—, pero no sustituyen a ver el juego
correr.

Falta esa pasada: arrancar el cartucho en un emulador, contrastar contra el
listado lo que se ve, y usarlo para cerrar la pregunta de arriba.

## Lo que sí está cerrado, y por qué se puede afirmar

Para que quede claro qué respalda cada cifra:

- **Reensambla byte a byte.** El listado publicado se ensambla y el sha256 del
  resultado es el del cartucho. Esto no es una comprobación parcial: si un
  comentario se hubiera comido un byte, esa línea no saldría.
- **Ni un byte sin explicar.** Los 16384 se reparten en 5947 de código que el
  trazador alcanza siguiendo el flujo de verdad, y 10437 dentro de un rango
  declarado, cada uno con la instrucción que lo lee escrita al lado.
- **Ninguna zona de datos se lee como código.** Es una comprobación aparte, y
  hace falta: un desensamblado puede reensamblar perfecto y estar mintiendo, si
  unos dibujos se están leyendo como instrucciones. Los bytes no cambian, solo
  cambia lo que decimos de ellos.
- **Ningún punto de entrada cae dentro de una zona de datos.** Sembrar el
  trazador con una dirección mal deducida hincha la cobertura sin que salte
  ninguna alarma, así que hay una regla para exactamente eso.

## Dos avisos para quien siga por aquí

**Los ejes y los órdenes son fáciles de leer al revés, y equivocarse no da
error.** Un sprite de 16x16 son dos mitades de dieciséis filas, no dieciséis
filas de dos bytes; leído de la otra manera sale una imagen convincente, pero
cortada en tiras. Lo mismo pasa con las bases de la memoria de vídeo: leer una
tabla de colores como si fuera de dibujos da algo que parece un dibujo. La
única defensa es sacar las bases del propio código y mirar el resultado.

**Y una llamada al descompresor sin `ld hl` delante no empieza de cero**: sigue
con el puntero que dejó la anterior. Eso vale para el flujo de origen y también
para el destino en la memoria de vídeo, y significa que el orden en el que se
ejecutan las llamadas importa. Recorrer el cartucho de arriba abajo llamada por
llamada no reconstruye lo mismo que ejecutarlo.
