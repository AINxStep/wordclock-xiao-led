// ==============================================================================
// WORDCLOCK ESP32 - PIEZA 3: TAPA TRASERA SUPERPUESTA CON RANURA USB-C
// Parametric OpenSCAD Model for Bambu Lab (256x256 mm build plate)
// Versión 1: Tapa exterior de 188.0 x 240.0 mm para el cuerpo impreso originalmente
// ==============================================================================

// --- Parameters ---
box_w       = 188.0;   // Ancho total exterior de la tapa (mm)
box_h       = 240.0;   // Alto total exterior de la tapa (mm)
wall_thick  = 1.6;     // Coincide con las paredes del marco (1.6 mm)
lid_thick   = 2.0;     // Grosor de la tapa trasera (mm) - 10 capas de 0.20 mm

// Distancia del centro de los tornillos desde la esquina exterior (wall_thick + 4.0 = 5.6 mm)
screw_off   = wall_thick + 4.0; 

// --- Module: Tapa Trasera Completa ---
module wordclock_back_lid() {
    difference() {
        // 1. Placa Base Exterior de la Tapa (188.0 x 240.0 x 2.0 mm)
        cube([box_w, box_h, lid_thick]);

        // 2. Orificios avellanados (Countersunk) en las 4 esquinas para tornillos M3
        // Esquina Inferior Izquierda
        translate([screw_off, screw_off, -0.1]) {
            cylinder(r = 1.6, h = lid_thick + 0.2, $fn = 24);
            translate([0, 0, 0.8]) cylinder(r1 = 1.6, r2 = 3.2, h = 1.3, $fn = 24);
        }
        // Esquina Inferior Derecha
        translate([box_w - screw_off, screw_off, -0.1]) {
            cylinder(r = 1.6, h = lid_thick + 0.2, $fn = 24);
            translate([0, 0, 0.8]) cylinder(r1 = 1.6, r2 = 3.2, h = 1.3, $fn = 24);
        }
        // Esquina Superior Izquierda
        translate([screw_off, box_h - screw_off, -0.1]) {
            cylinder(r = 1.6, h = lid_thick + 0.2, $fn = 24);
            translate([0, 0, 0.8]) cylinder(r1 = 1.6, r2 = 3.2, h = 1.3, $fn = 24);
        }
        // Esquina Superior Derecha
        translate([box_w - screw_off, box_h - screw_off, -0.1]) {
            cylinder(r = 1.6, h = lid_thick + 0.2, $fn = 24);
            translate([0, 0, 0.8]) cylinder(r1 = 1.6, r2 = 3.2, h = 1.3, $fn = 24);
        }

        // 3. Ranuras de Ventilación Superior (Cooling Vents Izquierda y Derecha)
        for (i = [0 : 4]) {
            y_slot = box_h - 22 - (i * 6);
            translate([18, y_slot, -0.1])         cube([48, 3.0, lid_thick + 0.2]);
            translate([box_w - 66, y_slot, -0.1]) cube([48, 3.0, lid_thick + 0.2]);
        }

        // 4. Ranuras de Ventilación Inferior (Cooling Vents Izquierda y Derecha)
        for (i = [0 : 4]) {
            y_slot = 22 + (i * 6);
            translate([18, y_slot, -0.1])         cube([48, 3.0, lid_thick + 0.2]);
            translate([box_w - 66, y_slot, -0.1]) cube([48, 3.0, lid_thick + 0.2]);
        }

        // 5. RANURA USB-C OBLONGA / PANELSOCKET (Reemplaza al antiguo orificio circular)
        // Calado de 14.5 x 5.8 mm con bordes redondeados (r = 2.9 mm)
        translate([box_w / 2, 14.0, -0.1]) {
            hull() {
                translate([-4.35, 0, 0]) cylinder(r = 2.9, h = lid_thick + 0.2, $fn = 32);
                translate([ 4.35, 0, 0]) cylinder(r = 2.9, h = lid_thick + 0.2, $fn = 32);
            }
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
