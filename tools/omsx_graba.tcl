# Arranca el juego grabando la partida, para poder medir sobre ella despues.
#
# Por que grabar en vez de medir en vivo: una partida jugada por una persona
# llega a sitios a los que la demo no llega nunca, y ademas se puede repetir
# tantas veces como haga falta. Con `reverse loadreplay` + `reverse goto` se
# vuelve a cualquier instante y se muestrea alli, sin tener que volver a jugar.
#
# Tres cosas que hay que hacer bien, y que cuestan una tarde si se olvidan:
#
#   1. Lanzado con -script, openMSX arranca con el renderer SIN INICIALIZAR, y
#      entonces `screenshot` contesta que ha ido bien y escribe un PNG NEGRO.
#      Por eso lo primero es encenderlo.
#   2. El acelerador se queda PUESTO. Sin el, la maquina corre a toda pastilla
#      y ademas el renderer se salta cuadros.
#   3. La historia de `reverse` vive en memoria: si openMSX se cierra sin
#      guardar, no queda nada. De ahi el guardado automatico de aqui abajo.
#
# Uso:  openmsx -machine C-BIOS_MSX1_EU -cart antarctic.rom \
#               -script tools/omsx_graba.tcl

set ::destino [file normalize "work/replays"]
file mkdir $::destino

set renderer SDLGL-PP
set throttle on

# La grabacion. `reverse start` empieza a guardar historia; el fichero se
# escribe con savereplay, aqui y cada minuto.
reverse start

# Una senal en disco de que esto esta de verdad en marcha, para no tener que
# fiarse de la salida por pantalla.
proc apunta_estado {} {
    set f [open [file join $::destino "estado.txt"] w]
    puts $f "reverse: [dict get [reverse status] status]"
    puts $f "machine: [machine_info config_name]"
    puts $f "tiempo emulado: [machine_info time]"
    close $f
}
apunta_estado

# El cartel, para que se vea en la ventana que se esta grabando.
osd create rectangle grabando -x 0 -y 0 -w 90 -h 14 -rgba 0xc00000c0 -scaled true
osd create text grabando.txt -x 5 -y 3 -size 7 -rgba 0xffffffff \
    -text "GRABANDO" -scaled true

# Guardado periodico. Cada minuto de tiempo REAL, no emulado: lo que interesa
# es no perder lo que la persona lleva jugado.
proc autoguarda {} {
    reverse savereplay -maxnofextrasnapshots 20 \
        [file join $::destino "partida"]
    apunta_estado
    after realtime 60 autoguarda
}
after realtime 60 autoguarda

# Y una captura de pantalla a los quince segundos reales, que es de sobra para
# que el juego haya pasado del logotipo. Con el renderer encendido y el
# acelerador puesto sale entera; si saliera negra, pesaria ~1 KB.
after realtime 15 {
    screenshot -raw [file join $::destino "pantalla.png"]
}
