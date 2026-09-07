// ==============================================================================
// WORDCLOCK ESP32 - VERSION 2 (AL RAS / INCRUSTADA)
// PIEZA 3: TAPA TRASERA INCRUSTADA DE 184.4 x 236.4 mm CON RANURA USB-C
// ==============================================================================

box_w       = 188.0;
box_h       = 240.0;
wall_thick  = 1.6;
clearance   = 0.2;     // 0.2 mm de holgura por lado
lid_thick   = 2.0;

// Dimensiones reducidas para entrar dentro del perímetro interno
lid_w       = box_w - (2 * wall_thick) - (2 * clearance); // 184.4 mm
lid_h       = box_h - (2 * wall_thick) - (2 * clearance); // 236.4 mm

screw_off_lid = (wall_thick + 4.0) - wall_thick - clearance; // ~3.8 mm

module wordclock_back_lid() {
    difference() {
        // 1. Placa Base Incrustada (184.4 x 236.4 x 2.0 mm)
        cube([lid_w, lid_h, lid_thick]);

        // 2. Orificios avellanados (Countersunk) en las 4 esquinas para tornillos M3
        translate([screw_off_lid, screw_off_lid, -0.1]) {
            cylinder(r = 1.6, h = lid_thick + 0.2, $fn = 24);
            translate([0, 0, 0.8]) cylinder(r1 = 1.6, r2 = 3.2, h = 1.3, $fn = 24);
        }
        translate([lid_w - screw_off_lid, screw_off_lid, -0.1]) {
            cylinder(r = 1.6, h = lid_thick + 0.2, $fn = 24);
            translate([0, 0, 0.8]) cylinder(r1 = 1.6, r2 = 3.2, h = 1.3, $fn = 24);
        }
        translate([screw_off_lid, lid_h - screw_off_lid, -0.1]) {
            cylinder(r = 1.6, h = lid_thick + 0.2, $fn = 24);
            translate([0, 0, 0.8]) cylinder(r1 = 1.6, r2 = 3.2, h = 1.3, $fn = 24);
        }
        translate([lid_w - screw_off_lid, lid_h - screw_off_lid, -0.1]) {
            cylinder(r = 1.6, h = lid_thick + 0.2, $fn = 24);
            translate([0, 0, 0.8]) cylinder(r1 = 1.6, r2 = 3.2, h = 1.3, $fn = 24);
        }

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
        translate([lid_w / 2, 14.0, -0.1]) {
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
