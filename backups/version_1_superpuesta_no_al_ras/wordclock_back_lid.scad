// ==============================================================================
// WORDCLOCK ESP32 - VERSION 1 (NO AL RAS / SUPERPUESTA)
// PIEZA 3: TAPA TRASERA SUPERPUESTA DE 188.0 x 240.0 mm CON RANURA USB-C
// ==============================================================================

box_w       = 188.0;   // Ancho exterior completo
box_h       = 240.0;   // Alto exterior completo
wall_thick  = 1.6;
lid_thick   = 2.0;

screw_off   = wall_thick + 4.0; // 5.6 mm desde la esquina exterior

module wordclock_back_lid() {
    difference() {
        // 1. Placa Base de la Tapa (188.0 x 240.0 x 2.0 mm)
        cube([box_w, box_h, lid_thick]);

        // 2. Orificios avellanados (Countersunk) en las 4 esquinas para tornillos M3
        translate([screw_off, screw_off, -0.1]) {
            cylinder(r = 1.6, h = lid_thick + 0.2, $fn = 24);
            translate([0, 0, 0.8]) cylinder(r1 = 1.6, r2 = 3.2, h = 1.3, $fn = 24);
        }
        translate([box_w - screw_off, screw_off, -0.1]) {
            cylinder(r = 1.6, h = lid_thick + 0.2, $fn = 24);
            translate([0, 0, 0.8]) cylinder(r1 = 1.6, r2 = 3.2, h = 1.3, $fn = 24);
        }
        translate([screw_off, box_h - screw_off, -0.1]) {
            cylinder(r = 1.6, h = lid_thick + 0.2, $fn = 24);
            translate([0, 0, 0.8]) cylinder(r1 = 1.6, r2 = 3.2, h = 1.3, $fn = 24);
        }
        translate([box_w - screw_off, box_h - screw_off, -0.1]) {
            cylinder(r = 1.6, h = lid_thick + 0.2, $fn = 24);
            translate([0, 0, 0.8]) cylinder(r1 = 1.6, r2 = 3.2, h = 1.3, $fn = 24);
        }

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
