// ==============================================================================
// WORDCLOCK ESP32 - OPCION 2: TAPA TRASERA INCRUSTADA AL RAS (MARCO OPTIMIZADO)
// PIEZA 3: TAPA INCRUSTADA DE 184.4 x 236.4 mm
// Offset de tornillos: 3.8 mm desde borde de tapa (Alineado a 5.6 mm desde el exterior del marco)
// Avellanado simétrico (doble cara) para que la cabeza del tornillo encaje sin importar el lado
// ==============================================================================

box_w       = 188.0;
box_h       = 240.0;
wall_thick  = 1.6;     // Pared optimizada de 1.6 mm
clearance   = 0.2;     // 0.2 mm de holgura por lado
lid_thick   = 2.0;

// Dimensiones reducidas para encajar dentro del perímetro interno
lid_w       = box_w - (2 * wall_thick) - (2 * clearance); // 184.4 mm
lid_h       = box_h - (2 * wall_thick) - (2 * clearance); // 236.4 mm

// Offset del centro de tornillo desde el borde de la tapa incrustada
// Frame offset (5.6 mm) - Margen borde (1.8 mm) = 3.8 mm
screw_off_lid = (wall_thick + 4.0) - wall_thick - clearance; // 3.8 mm

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
        // 1. Placa Base Incrustada (184.4 x 236.4 x 2.0 mm)
        cube([lid_w, lid_h, lid_thick]);

        // 2. Orificios M3 con Avellanado Doble Cara (Alineados a 5.6 mm del marco)
        translate([screw_off_lid, screw_off_lid, 0])                 double_countersunk_hole(lid_thick);
        translate([lid_w - screw_off_lid, screw_off_lid, 0])         double_countersunk_hole(lid_thick);
        translate([screw_off_lid, lid_h - screw_off_lid, 0])         double_countersunk_hole(lid_thick);
        translate([lid_w - screw_off_lid, lid_h - screw_off_lid, 0]) double_countersunk_hole(lid_thick);

        // 3. Ranuras de Ventilación Superior
        for (i = [0 : 4]) {
            y_slot = lid_h - 22 - (i * 6);
            translate([18, y_slot, -0.1])         cube([48, 3.0, lid_thick + 0.2]);
            translate([lid_w - 66, y_slot, -0.1]) cube([48, 3.0, lid_thick + 0.2]);
        }

        // 4. Ranuras de Ventilación Inferior
        for (i = [0 : 4]) {
            y_slot = 22 + (i * 6);
            translate([18, y_slot, -0.1])         cube([48, 3.0, lid_thick + 0.2]);
            translate([lid_w - 66, y_slot, -0.1]) cube([48, 3.0, lid_thick + 0.2]);
        }

        // 5. RANURA USB-C OBLONGA / PANELSOCKET (14.5 x 5.8 mm con r = 2.9 mm)
        translate([lid_w / 2, 12.2, -0.1]) {
            hull() {
                translate([-4.35, 0, 0]) cylinder(r = 2.9, h = lid_thick + 0.2, $fn = 32);
                translate([ 4.35, 0, 0]) cylinder(r = 2.9, h = lid_thick + 0.2, $fn = 32);
            }
        }

        // 6. Muesca de cerradura (Keyhole) para colgar en pared
        translate([lid_w / 2, lid_h - 15, -0.1]) {
            union() {
                cylinder(r = 4.5, h = lid_thick + 0.2, $fn = 24);
                translate([-2.2, 0, 0]) cube([4.4, 9.0, lid_thick + 0.2]);
            }
        }
    }
}

wordclock_back_lid();
