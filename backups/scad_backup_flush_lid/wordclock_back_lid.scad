// ==============================================================================
// WORDCLOCK ESP32 - PIEZA 3: TAPA TRASERA CON VENTILACIONES (REAR COVER LID)
// Parametric OpenSCAD Model for Bambu Lab (256x256 mm build plate)
// Matching wall_thick = 1.6 mm
// ==============================================================================

// --- Parameters ---
box_w       = 188.0;
box_h       = 240.0;
wall_thick  = 1.6;     // Coincide con las paredes del marco
lid_thick   = 2.5;     // Grosor de la tapa trasera (mm)

// --- Module: Tapa Trasera Completa ---
module wordclock_back_lid() {
    difference() {
        // 1. Placa Base de la Tapa (188 x 240 mm)
        cube([box_w, box_h, lid_thick]);

        // 2. Orificios avellanados (Countersunk) en las 4 esquinas para tornillos M3
        screw_off = wall_thick + 4.0;
        
        // Esquina Inferior Izquierda
        translate([screw_off, screw_off, -0.1]) {
            cylinder(r = 1.6, h = lid_thick + 0.2, $fn = 24);
            translate([0, 0, 1.0]) cylinder(r1 = 1.6, r2 = 3.2, h = 1.6, $fn = 24);
        }
        // Esquina Inferior Derecha
        translate([box_w - screw_off, screw_off, -0.1]) {
            cylinder(r = 1.6, h = lid_thick + 0.2, $fn = 24);
            translate([0, 0, 1.0]) cylinder(r1 = 1.6, r2 = 3.2, h = 1.6, $fn = 24);
        }
        // Esquina Superior Izquierda
        translate([screw_off, box_h - screw_off, -0.1]) {
            cylinder(r = 1.6, h = lid_thick + 0.2, $fn = 24);
            translate([0, 0, 1.0]) cylinder(r1 = 1.6, r2 = 3.2, h = 1.6, $fn = 24);
        }
        // Esquina Superior Derecha
        translate([box_w - screw_off, box_h - screw_off, -0.1]) {
            cylinder(r = 1.6, h = lid_thick + 0.2, $fn = 24);
            translate([0, 0, 1.0]) cylinder(r1 = 1.6, r2 = 3.2, h = 1.6, $fn = 24);
        }

        // 3. Ranuras de Ventilación Superior
        for (i = [0 : 4]) {
            y_slot = box_h - 25 - (i * 6);
            translate([20, y_slot, -0.1])         cube([50, 3.0, lid_thick + 0.2]);
            translate([box_w - 70, y_slot, -0.1]) cube([50, 3.0, lid_thick + 0.2]);
        }

        // 4. Ranuras de Ventilación Inferior
        for (i = [0 : 4]) {
            y_slot = 25 + (i * 6);
            translate([20, y_slot, -0.1])         cube([50, 3.0, lid_thick + 0.2]);
            translate([box_w - 70, y_slot, -0.1]) cube([50, 3.0, lid_thick + 0.2]);
        }

        // 5. Orificio para Conector de Alimentación (Jack DC / Cable USB-C)
        translate([box_w / 2, 12, -0.1]) {
            cylinder(r = 5.0, h = lid_thick + 0.2, $fn = 24);
        }

        // 6. Muesca en forma de cerradura (Keyhole) para colgar en pared
        translate([box_w / 2, box_h - 15, -0.1]) {
            union() {
                cylinder(r = 4.5, h = lid_thick + 0.2, $fn = 24);
                translate([-2.2, 0, 0]) cube([4.4, 9.0, lid_thick + 0.2]);
            }
        }
    }
}

// Generar modelo
wordclock_back_lid();
