// ==============================================================================
// WORDCLOCK ESP32 - PIEZA 2: PLACA DE LEDS INTERMEDIA CON OREJAS DE FIJACIÓN
// Parametric OpenSCAD Model for Bambu Lab (256x256 mm build plate)
// High-Density LED Strip: WS2812B 74 LEDs/m (Pitch = 13.5135 mm)
// Matching wall_thick = 1.6 mm
// ==============================================================================

// --- Parameters ---
led_pitch   = 13.5135; // 74 LEDs/m
cols        = 11;
rows        = 14;

box_w       = 188.0;
box_h       = 240.0;
wall_thick  = 1.6;
baffle_wall = 0.8;

grid_w      = (cols - 1) * led_pitch; // ~135.14 mm
grid_h      = (rows - 1) * led_pitch; // ~175.68 mm

margin_x    = (box_w - grid_w) / 2;       // ~26.43 mm
margin_top  = (box_h - grid_h - led_pitch) / 2; // ~25.41 mm

dots_block_cols = 4;
dots_y          = box_h - margin_top - (14 * led_pitch);

// Dimensiones de la placa del texto
plate_left  = margin_x - (led_pitch / 2) - 0.5;
plate_right = margin_x + grid_w + (led_pitch / 2) + 0.5;
plate_top   = box_h - margin_top + (led_pitch / 2) + 0.5;
plate_bot   = box_h - margin_top - grid_h - (led_pitch / 2) - 0.5;

plate_w     = plate_right - plate_left;
plate_h     = plate_top - plate_bot;

// Espesores optimizados para capa de 0.20 mm
plate_thick = 2.0; // Grosor base de la placa (10 capas de 0.20 mm)
guide_thick = 0.4; // Altura de guías de centrado (2 capas de 0.20 mm)
total_thick = plate_thick + guide_thick; // 2.4 mm (12 capas de 0.20 mm)

strip_w     = 10.2; // Ancho de tira LED WS2812B (mm)
center_x    = box_w / 2; // ~94.0 mm (Centro exacto a lo ancho / 6º LED)

// Coordenadas de las 4 orejas/esquinas del Baffle
baffle_left  = margin_x - (led_pitch / 2) - 2.0;
baffle_right = margin_x + grid_w + (led_pitch / 2) + 2.0;
baffle_top   = box_h - margin_top + (led_pitch / 2) + 2.0;
baffle_bot   = box_h - margin_top - grid_h - (led_pitch / 2) - 2.0;

// --- Module: Oreja de Fijación con Orificio M3 ---
module mounting_ear() {
    difference() {
        cylinder(r = 5.0, h = total_thick, $fn = 32);
        translate([0, 0, -0.1]) cylinder(r = 1.6, h = total_thick + 0.2, $fn = 32);
    }
}

// --- Module: Flecha Indicadora de Sentido de Flujo de Datos (0.2 mm = 1 capa de impresión) ---
module data_flow_arrow(dir_right = true, h = 0.2) {
    linear_extrude(height = h) {
        if (dir_right) {
            polygon(points = [[-3, -1], [1, -1], [1, -2.2], [4, 0], [1, 2.2], [1, 1], [-3, 1]]);
        } else {
            polygon(points = [[3, -1], [-1, -1], [-1, -2.2], [-4, 0], [-1, 2.2], [-1, 1], [3, 1]]);
        }
    }
}

// --- Module: Placa de LEDs Completa ---
module wordclock_led_plate() {
    union() {
        difference() {
            union() {
                // a) Placa del Grid de Texto (11x14)
                translate([plate_left, plate_bot, 0]) {
                    cube([plate_w, plate_h, plate_thick]);
                }

                // b) Extensión para el Bloque de 4 Puntos de Minutos
                dots_plate_w = (dots_block_cols * led_pitch) + baffle_wall;
                dots_plate_x = margin_x + (3.0 * led_pitch) - (baffle_wall / 2);
                dots_plate_y = dots_y - (led_pitch / 2) - 0.5;
                dots_plate_h = (plate_bot - dots_plate_y) + 1.0;

                translate([dots_plate_x, dots_plate_y, 0]) {
                    cube([dots_plate_w, dots_plate_h, plate_thick]);
                }
            }

            // Pasacables para conexiones entre filas de LEDs (Muescas laterales)
            for (r = [0 : rows - 1]) {
                y_row = box_h - margin_top - (r * led_pitch);
                translate([plate_left - 0.1, y_row - 2.5, -0.1])          cube([6.0, 5.0, plate_thick + 0.2]);
                translate([plate_right - 5.9, y_row - 2.5, -0.1])         cube([6.0, 5.0, plate_thick + 0.2]);
            }
        }

        // 3. Las 4 OREJAS DE FIJACIÓN en las esquinas del Baffle
        translate([baffle_left, baffle_top, 0])   mounting_ear();
        translate([baffle_right, baffle_top, 0])  mounting_ear();
        translate([baffle_left, baffle_bot, 0])   mounting_ear();
        translate([baffle_right, baffle_bot, 0])  mounting_ear();

        // 4. Guías grabadas, marcas de centrado horizontal y flechas de flujo de datos para tiras LED
        // a) 14 Filas de Texto
        for (r = [0 : rows - 1]) {
            y = box_h - margin_top - (r * led_pitch) - (strip_w / 2);
            text_rail_x   = margin_x - (led_pitch / 2);
            text_rail_len = (cols * led_pitch);
            
            // Guías laterales de la fila (0.4 mm de alto)
            translate([text_rail_x, y + strip_w, plate_thick]) cube([text_rail_len, 0.8, guide_thick]);
            translate([text_rail_x, y - 0.8, plate_thick])     cube([text_rail_len, 0.8, guide_thick]);

            // Marcas indicadoras del centro horizontal (X = center_x = 94.0 mm, centro del 6º LED)
            mark_w = 0.8;
            translate([center_x - (mark_w / 2), y + strip_w, plate_thick]) cube([mark_w, 1.6, guide_thick]);
            translate([center_x - (mark_w / 2), y - 1.6, plate_thick])     cube([mark_w, 1.6, guide_thick]);

            // Flechas indicadoras de sentido de flujo de datos (Alternadas: par -> Izq a Der, impar -> Der a Izq)
            dir_right = (r % 2 == 0);
            y_center  = y + (strip_w / 2);
            translate([margin_x + (1.5 * led_pitch), y_center, plate_thick])           data_flow_arrow(dir_right);
            translate([margin_x + grid_w - (1.5 * led_pitch), y_center, plate_thick])  data_flow_arrow(dir_right);
        }

        // b) Canaleta de los 4 Puntos de Minutos
        dots_rail_x   = margin_x + (3.0 * led_pitch) - (baffle_wall / 2) + 0.5;
        dots_rail_len = (dots_block_cols * led_pitch) + baffle_wall - 1.0;
        y_dots_strip  = dots_y - (strip_w / 2);

        translate([dots_rail_x, y_dots_strip + strip_w, plate_thick]) cube([dots_rail_len, 0.8, guide_thick]);
        translate([dots_rail_x, y_dots_strip - 0.8, plate_thick])     cube([dots_rail_len, 0.8, guide_thick]);

        // Marca de centrado horizontal para la canaleta de puntos
        dots_center_x = dots_rail_x + (dots_rail_len / 2);
        mark_w = 0.8;
        translate([dots_center_x - (mark_w / 2), y_dots_strip + strip_w, plate_thick]) cube([mark_w, 1.6, guide_thick]);
        translate([dots_center_x - (mark_w / 2), y_dots_strip - 1.6, plate_thick])     cube([mark_w, 1.6, guide_thick]);

        // Flechas indicadoras de sentido de flujo de datos para los puntos (Izquierda a Derecha)
        translate([dots_rail_x + (led_pitch * 0.8), dots_y, plate_thick])             data_flow_arrow(true);
        translate([dots_rail_x + dots_rail_len - (led_pitch * 0.8), dots_y, plate_thick]) data_flow_arrow(true);
    }
}

// Generar modelo
wordclock_led_plate();

