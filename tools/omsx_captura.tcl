# Capturas de instantes concretos de la partida grabada.
#
# Dos trampas que hacen que el PNG salga NEGRO y que `screenshot` conteste que
# todo ha ido bien (pesa ~1 KB en vez de ~10 KB):
#
#   1. Lanzado con -script, openMSX arranca con el renderer SIN INICIALIZAR.
#   2. Con el acelerador quitado, el renderer se salta todos los cuadros. La
#      captura hay que pedirla con `after realtime`, no con `after time`.
#
# Uso:  openmsx -machine C-BIOS_MSX1_EU -cart antarctic.rom \
#               -script tools/omsx_captura.tcl
#
# Los instantes salen de work/sprites_medidos.txt: son los segundos en que la
# medida vio cada combinacion de sprite y color que interesa mirar.

set renderer SDLGL-PP
set throttle on

set ::destino [file normalize "work/png/replay"]
file mkdir $::destino

# (segundo, nombre) — cada uno es un momento apuntado por la medida de sprites.
set ::momentos {
    122.8 meta-01
    123.6 meta-02
    124.4 meta-03
    125.4 meta-04
    126.6 meta-05
    128.0 meta-06
    130.0 meta-07
    132.0 meta-08
    134.0 meta-09
    136.0 meta-10
    264.6 base-fase2-bandera
    270.2 base-fase2
    439.4 patas-amarillas
    574.6 estado13
    580.8 estado7-a
     23.6 foca
     21.0 pez
}

proc siguiente {} {
    if {[llength $::momentos] == 0} { exit }
    set t [lindex $::momentos 0]
    set n [lindex $::momentos 1]
    set ::momentos [lrange $::momentos 2 end]
    reverse goto $t
    # Un poco de tiempo REAL para que el renderer pinte el cuadro.
    after realtime 1.5 [list captura $t $n]
}

proc captura {t n} {
    set f [file join $::destino [format "%s.png" $n]]
    screenshot -raw $f
    set e [debug read memory 0xE000]
    set fase [debug read memory 0xE0E1]
    puts "captura $n  t=$t  estado=$e  fase=$fase"
    after realtime 0.3 siguiente
}

reverse loadreplay -viewonly [file normalize "work/replays/partida.omr"]
after realtime 2 siguiente
