// ==============================================================================
// WORDCLOCK ESP32 - OPCION 1: TAPA TRASERA SUPERPUESTA (PARA MARCO YA IMPRESO)
// PIEZA 3: TAPA SUPERPUESTA DE 188.0 x 240.0 mm
// Offset de tornillos: 7.0 mm (Coincide EXACTAMENTE con la impresión física realizada)
// Avellanado simétrico (doble cara) para que la cabeza del tornillo encaje sin importar el lado
// ==============================================================================

box_w       = 188.0;   // Ancho exterior completo (188 mm)
box_h       = 240.0;   // Alto exterior completo (240 mm)
wall_thick  = 3.0;     // Pared de 3.0 mm coincidente con el marco impreso
lid_thick   = 2.0;     // Grosor de la tapa

// Centro de tornillos a 7.0 mm desde las esquinas exteriores
screw_off   = wall_thick + 4.0; // 3.0 + 4.0 = 7.0 mm

module double_countersunk_hole(h = 2.0) {
    union() {
        // Pasante central M3
        translate([0, 0, -0.1]) cylinder(r = 1.6, h = h + 0.2, $fn = 32);
        
        // Avellanado Cara A (Cono de 1.6 mm a 3.3 mm en los primeros 0.9 mm)
        translate([0, 0, -0.1]) cylinder(r1 = 3.3, r2 = 1.6, h = 0.9, $fn = 32);
        
        // Avellanado Cara B (Cono de 1.6 mm a 3.3 mm en los últimos 0.9 mm)
        translate([0, 0, h - 0.8]) cylinder(r1 = 1.6, r2 = 3.3, h = 0.9, $fn = 32);
    }
}

module wordclock_back_lid() {
    difference() {
        // 1. Placa Base de la Tapa (188.0 x 240.0 x 2.0 mm)
        cube([box_w, box_h, lid_thick]);

        // 2. Orificios M3 con Avellanado Doble Cara (Offset exacto 7.0 mm)
        translate([screw_off, screw_off, 0])                 double_countersunk_hole(lid_thick);
        translate([box_w - screw_off, screw_off, 0])         double_countersunk_hole(lid_thick);
        translate([screw_off, box_h - screw_off, 0])         double_countersunk_hole(lid_thick);
        translate([box_w - screw_off, box_h - screw_off, 0]) double_countersunk_hole(lid_thick);

        // 3. Ranuras de Ventilación Superior
        for (i = [0 : 4]) {
            y_slot = box_h - 22 - (i * 6);
            translate([18, y_slot, -0.1])         cube([48, 3.0, lid_thick + 0.2]);
            translate([box_w - 66, y_slot, -0.1]) cube([48, 3.0, lid_thick + 0.2]);
        }

        // 4. Ranuras de Ventilación Inferior
        for (i = [0 : 4]) {
            y_slot = 22 + (i * 6);
            translate([18, y_slot, -0.1])         cube([48, 3.0, lid_thick + 0.2]);
            translate([box_w - 66, y_slot, -0.1]) cube([48, 3.0, lid_thick + 0.2]);
        }

        // 5. RANURA USB-C OBLONGA / PANELSOCKET (14.5 x 5.8 mm con r = 2.9 mm)
        translate([box_w / 2, 14.0, -0.1]) {
            hull() {
                translate([-4.35, 0, 0]) cylinder(r = 2.9, h = lid_thick + 0.2, $fn = 32);
                translate([ 4.35, 0, 0]) cylinder(r = 2.9, h = lid_thick + 0.2, $fn = 32);
            }
        }

        // 6. Muesca de cerradura (Keyhole) para colgar en pared
        translate([box_w / 2, box_h - 15, -0.1]) {
            union() {
                cylinder(r = 4.5, h = lid_thick + 0.2, $fn = 24);
                translate([-2.2, 0, 0]) cube([4.4, 9.0, lid_thick + 0.2]);
            }
        }
    }
}

wordclock_back_lid();
