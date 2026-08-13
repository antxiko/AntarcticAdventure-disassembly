# Quien escribe el atributo 14 -el sprite amarillo que no se ve nunca- y quien
# escribe el 13 -el pinguino-, sobre la partida grabada.
#
# La pregunta es "cuando se pinta la explosion y que rutina la llama". La forma
# de contestarla sin suponer nada es poner un punto de observacion de ESCRITURA
# en los cuatro bytes de su entrada de atributo (0xE088-0xE08B) y dejar correr
# los diez minutos de partida: cada escritura queda apuntada con el PC que la
# hizo y el valor que puso.
#
# Y CON UN CONTROL, porque un "no salto ni una vez" es un hallazgo o es
# instrumentacion rota, y de lejos no se distinguen: el mismo tipo de
# observacion en los cuatro bytes del atributo 13, que es el ultimo sprite del
# pinguino y se reescribe en cada cuadro. Si el control da cero, la medida no
# vale; si da miles, los ceros del otro son datos.
#
# Uso:  openmsx -machine C-BIOS_MSX1_EU -cart antarctic.rom \
#               -script tools/omsx_atributo14.tcl

set ::salida [file normalize "work/atributo14.txt"]
set ::e14 [dict create]
set ::e13 [dict create]
set ::fin 598

# El callback tiene que ser BARATO: solo un `dict incr` con el PC en crudo. El
# formateo, al volcado.
foreach {var base} {e14 0xE088 e13 0xE084} {
    for {set i 0} {$i < 4} {incr i} {
        debug set_watchpoint write_mem [expr {$base + $i}] {} \
            "dict incr ::$var \"\[reg PC\]\""
    }
}

proc vuelca {} {
    set f [open $::salida w]
    puts $f "# Escrituras a los cuatro bytes de cada entrada de atributo,"
    puts $f "# sobre work/replays/partida.omr, de t=12 a t=$::fin."
    puts $f ""
    puts $f "# ATRIBUTO 14 (0xE088-0xE08B), el del patron 0xD4 en amarillo:"
    if {[dict size $::e14] == 0} {
        puts $f "#   NADIE. Ni una escritura en toda la partida."
    }
    foreach k [lsort [dict keys $::e14]] {
        puts $f [format "  PC=%04X  %d escrituras" $k [dict get $::e14 $k]]
    }
    puts $f ""
    puts $f "# CONTROL - ATRIBUTO 13 (0xE084-0xE087), el cuarto sprite del pinguino:"
    if {[dict size $::e13] == 0} {
        puts $f "#   CERO. El control no ha saltado: la medida NO vale."
    }
    foreach k [lsort [dict keys $::e13]] {
        puts $f [format "  PC=%04X  %d escrituras" $k [dict get $::e13 $k]]
    }
    puts $f ""
    puts $f "# Y lo que hay en la VRAM, en la entrada 14 (0x3B38), al final:"
    binary scan [debug read_block VRAM 0x3B38 4] cu* a
    puts $f [format "  Y=%02X X=%02X patron=%02X color=%02X" \
                 [lindex $a 0] [lindex $a 1] [lindex $a 2] [lindex $a 3]]
    close $f
    exit
}

proc late {} {
    if {[machine_info time] >= $::fin} { vuelca ; return }
    after time 5 late
}

set throttle off
reverse loadreplay -viewonly [file normalize "work/replays/partida.omr"]
reverse goto 12
after time 5 late
