// ==============================================================================
// WORDCLOCK ESP32 - OPCION 1: VISTA GENERAL DE ENSAMBLAJE & EXPLOSIONADA (EXPLODED VIEW)
// Modelo concentrado para auditoría 3D de ajuste entre piezas (Marco 3.0 mm + Tapa 188x240 mm)
// ==============================================================================

/* [Controles de Vista e Inspección / View Controls] */
// Desplazamiento de explosión en mm (0 = 100% Ensamblado Real, >0 = Vista Despiezada/Explosionada)
explode_distance = 0; // [0:1:120]

// Modo Transparencia para inspeccionar interferencias internas y alineación de tornillos
transparent_view = 0; // [0:Sólido, 1:Transparente]

// Visibilidad de Piezas Individuales
show_main_frame       = 1; // [0:Ocultar, 1:Mostrar]
show_led_plate        = 1; // [0:Ocultar, 1:Mostrar]
show_electronics_mount= 1; // [0:Ocultar, 1:Mostrar]
show_back_lid         = 1; // [0:Ocultar, 1:Mostrar]

// Incluir definidores de módulos de las 4 piezas
include <wordclock_main_frame.scad>
include <wordclock_back_lid.scad>

// --- Definición abreviada de la Placa de LEDs (Pieza 2) ---
module led_plate_component() {
    grid_w      = (11 - 1) * 13.5135;
    grid_h      = (14 - 1) * 13.5135;
    margin_x    = (188.0 - grid_w) / 2;
    margin_top  = (240.0 - grid_h - 13.5135) / 2;
    dots_y      = 240.0 - margin_top - (14 * 13.5135);
    
    plate_left  = margin_x - (13.5135 / 2) - 0.5;
    plate_right = margin_x + grid_w + (13.5135 / 2) + 0.5;
    plate_top   = 240.0 - margin_top + (13.5135 / 2) + 0.5;
    plate_bot   = 240.0 - margin_top - grid_h - (13.5135 / 2) - 0.5;
    plate_w     = plate_right - plate_left;
    plate_h     = plate_top - plate_bot;
    
    baffle_left  = margin_x - (13.5135 / 2) - 2.0;
    baffle_right = margin_x + grid_w + (13.5135 / 2) + 2.0;
    baffle_top   = 240.0 - margin_top + (13.5135 / 2) + 2.0;
    baffle_bot   = 240.0 - margin_top - grid_h - (13.5135 / 2) - 2.0;
    
    difference() {
        union() {
            translate([plate_left, plate_bot, 0]) cube([plate_w, plate_h, 2.0]);
            dots_plate_w = (4 * 13.5135) + 0.8;
            dots_plate_x = margin_x + (3.0 * 13.5135) - 0.4;
            dots_plate_y = dots_y - (13.5135 / 2) - 0.5;
            dots_plate_h = (plate_bot - dots_plate_y) + 1.0;
            translate([dots_plate_x, dots_plate_y, 0]) cube([dots_plate_w, dots_plate_h, 2.0]);
            
            // 4 Orejas de fijación
            translate([baffle_left, baffle_top, 0])   cylinder(r = 5.0, h = 2.4, $fn = 32);
            translate([baffle_right, baffle_top, 0])  cylinder(r = 5.0, h = 2.4, $fn = 32);
            translate([baffle_left, baffle_bot, 0])   cylinder(r = 5.0, h = 2.4, $fn = 32);
            translate([baffle_right, baffle_bot, 0])  cylinder(r = 5.0, h = 2.4, $fn = 32);
        }
        // Pasantes M3 en las 4 orejas
        translate([baffle_left, baffle_top, -0.1])   cylinder(r = 1.6, h = 3.0, $fn = 32);
        translate([baffle_right, baffle_top, -0.1])  cylinder(r = 1.6, h = 3.0, $fn = 32);
        translate([baffle_left, baffle_bot, -0.1])   cylinder(r = 1.6, h = 3.0, $fn = 32);
        translate([baffle_right, baffle_bot, -0.1])  cylinder(r = 1.6, h = 3.0, $fn = 32);
    }
}

// --- Definición abreviada del Soporte de Electrónica (Pieza 4) ---
module electronics_mount_component() {
    difference() {
        cube([90.0, 65.0, 2.0]);
        translate([10, 10, -0.1]) cube([70.0, 45.0, 2.2]);
        translate([5, 5, -0.1])           cylinder(r = 1.6, h = 2.2, $fn = 24);
        translate([85, 5, -0.1])          cylinder(r = 1.6, h = 2.2, $fn = 24);
        translate([5, 60, -0.1])          cylinder(r = 1.6, h = 2.2, $fn = 24);
        translate([85, 60, -0.1])         cylinder(r = 1.6, h = 2.2, $fn = 24);
    }
    // Torretas M3 para ESP32
    translate([8, 7, 2.0]) {
        cylinder(r = 3.5, h = 5.0, $fn = 24);
        translate([28, 0, 0])  cylinder(r = 3.5, h = 5.0, $fn = 24);
        translate([0, 51, 0])  cylinder(r = 3.5, h = 5.0, $fn = 24);
        translate([28, 51, 0]) cylinder(r = 3.5, h = 5.0, $fn = 24);
    }
}

// --- RENDERING DEL ENSAMBLAJE TOTAL ---
alpha_val = (transparent_view == 1) ? 0.45 : 1.0;

module full_wordclock_assembly() {
    // 1. Pieza 1: Marco Principal (Z = 0)
    if (show_main_frame == 1) {
        color([0.22, 0.22, 0.22, alpha_val]) {
            wordclock_main_frame();
        }
    }

    // 2. Pieza 2: Placa Porta-LEDs (Apoyada a Z = face_thick + baffle_h = 14.4 mm)
    if (show_led_plate == 1) {
        translate([0, 0, 14.4 + (explode_distance * 0.5)]) {
            color([0.9, 0.9, 0.9, alpha_val]) {
                led_plate_component();
            }
        }
    }

    // 3. Pieza 4: Soporte de Electrónica (Centrado a Z = 22.0 mm)
    if (show_electronics_mount == 1) {
        translate([49.0, 87.5, 20.0 + (explode_distance * 1.1)]) {
            color([0.1, 0.6, 0.8, alpha_val]) {
                electronics_mount_component();
            }
        }
    }

    // 4. Pieza 3: Tapa Trasera (Montada a Z = 35.0 mm por fuera)
    if (show_back_lid == 1) {
        translate([0, 0, 35.0 + (explode_distance * 1.8)]) {
            color([0.85, 0.55, 0.2, alpha_val]) {
                wordclock_back_lid();
            }
        }
    }
}

// Renderizar ensamblaje completo con la distancia de explosión seleccionada
full_wordclock_assembly();
