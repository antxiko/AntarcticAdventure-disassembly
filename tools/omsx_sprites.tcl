# Que sprite sale de que color, MEDIDO sobre la partida grabada.
#
# El color de un sprite no vive en su dibujo: vive en el cuarto byte de su
# entrada de la tabla de atributos, y el juego se lo cambia en marcha. Asi que
# leer la ROM no basta para saber de que color sale cada uno: hay que mirar la
# tabla de atributos DE VERDAD, cuadro a cuadro, mientras el juego corre.
#
# Esto recorre work/replays/partida.omr muestreando cada 0,2 s emulados:
#
#   - los 128 bytes de la tabla de atributos (VRAM 0x3B00), y
#   - los 32 bytes del patron de cada sprite que este puesto,
#
# y apunta cada combinacion distinta de (estado del juego, patron, color) con
# su dibujo, la primera vez que se ve y cuantas veces sale. El dibujo va con la
# combinacion porque los patrones de sprite se recargan por escenas: el mismo
# numero de patron es una cosa en la pista y otra en la base.
#
# Uso:  openmsx -machine C-BIOS_MSX1_EU -cart antarctic.rom \
#               -script tools/omsx_sprites.tcl
#
# Deja el resultado en work/sprites_medidos.txt y cierra el emulador solo.

set ::salida [file normalize "work/sprites_medidos.txt"]
set ::visto  [dict create]
set ::muestras 0

set throttle off
set ::fin 598

proc muestra {} {
    set t [machine_info time]
    if {$t >= $::fin} { vuelca ; return }
    incr ::muestras

    set estado [debug read memory 0xE000]
    set fase   [debug read memory 0xE0E1]
    binary scan [debug read_block VRAM 0x3B00 128] cu* a

    for {set i 0} {$i < 32} {incr i} {
        set y [lindex $a [expr {$i*4}]]
        set p [expr {[lindex $a [expr {$i*4+2}]] & 0xFC}]
        set c [expr {[lindex $a [expr {$i*4+3}]] & 0x0F}]
        # Fuera de la pantalla o transparente: no se ve, no cuenta.
        if {$y >= 0xC0 || $c == 0} continue
        set k [format "%02d %02X %02d" $estado $p $c]
        if {[dict exists $::visto $k]} {
            set v [dict get $::visto $k]
            dict set ::visto $k [list [lindex $v 0] [expr {[lindex $v 1]+1}] \
                                     [lindex $v 2] [lindex $v 3] $i]
        } else {
            binary scan [debug read_block VRAM [expr {0x1800 + $p*8}] 32] H* dib
            dict set ::visto $k [list $t 1 $dib $fase $i]
        }
    }
    after time 0.2 muestra
}

proc vuelca {} {
    set f [open $::salida w]
    puts $f "# estado patron color  t_primera  veces  fase  atributo  dibujo"
    foreach k [lsort [dict keys $::visto]] {
        set v [dict get $::visto $k]
        puts $f [format "%s %8.2f %6d %3d %3d %s" $k [lindex $v 0] \
                     [lindex $v 1] [lindex $v 3] [lindex $v 4] [lindex $v 2]]
    }
    puts $f "# muestras: $::muestras"
    close $f
    exit
}

reverse loadreplay -viewonly [file normalize "work/replays/partida.omr"]
reverse goto 12
after time 0.2 muestra
