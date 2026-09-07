// ==============================================================================
// WORDCLOCK ESP32 - PIEZA 2: PLACA DE LEDS INTERMEDIA CON OREJAS DE FIJACIÓN
// Parametric OpenSCAD Model for Bambu Lab (256x256 mm build plate)
// Fixed: Dot strip guide rails perfectly aligned & contained inside bottom extension plate
// ==============================================================================

// --- Parameters ---
led_pitch   = 13.5135; // 74 LEDs/m
cols        = 11;
rows        = 14;

box_w       = 240.0;
box_h       = 240.0;
wall_thick  = 3.0;
baffle_wall = 1.6;

grid_w      = (cols - 1) * led_pitch; // ~135.14 mm
grid_h      = (rows - 1) * led_pitch; // ~175.68 mm

margin_x    = (box_w - grid_w) / 2;       // ~52.43 mm
margin_top  = (box_h - grid_h - led_pitch) / 2; // ~25.41 mm

dots_block_cols = 4;
dots_y          = box_h - margin_top - (14 * led_pitch);

// Dimensiones de la placa del texto
plate_left  = margin_x - (led_pitch / 2) - 0.5;
plate_right = margin_x + grid_w + (led_pitch / 2) + 0.5;
plate_top   = box_h - margin_top + (led_pitch / 2) + 0.5;
plate_bot   = box_h - margin_top - grid_h - (led_pitch / 2) - 0.5;

plate_w     = plate_right - plate_left; // ~149.65 mm
plate_h     = plate_top - plate_bot;   // ~183.43 mm
plate_thick = 2.5;                     // Grosor de la placa (mm)

strip_w     = 10.2; // Ancho de tira LED WS2812B (mm)

// Coordenadas de las 4 orejas/esquinas del Baffle
baffle_left  = margin_x - (led_pitch / 2) - 2.0;
baffle_right = margin_x + grid_w + (led_pitch / 2) + 2.0;
baffle_top   = box_h - margin_top + (led_pitch / 2) + 2.0;
baffle_bot   = box_h - margin_top - grid_h - (led_pitch / 2) - 2.0;

// --- Module: Torretas M3 para Electrónica (Cara Trasera) ---
module m3_standoff(h = 6) {
    difference() {
        cylinder(r = 3.5, h = h, $fn = 24);
        translate([0, 0, -0.1]) cylinder(r = 1.4, h = h + 0.2, $fn = 24);
    }
}

// --- Module: Oreja de Fijación con Orificio M3 ---
module mounting_ear() {
    difference() {
        cylinder(r = 5.0, h = plate_thick, $fn = 32);
        translate([0, 0, -0.1]) cylinder(r = 1.6, h = plate_thick + 0.2, $fn = 32);
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

                // b) Extensión para el Bloque de 4 Puntos de Minutos (Centrado en X=120mm)
                dots_plate_w = (dots_block_cols * led_pitch) + baffle_wall;
                dots_plate_x = margin_x + (3.0 * led_pitch) - (baffle_wall / 2);
                dots_plate_y = dots_y - (led_pitch / 2) - 0.5;
                dots_plate_h = (plate_bot - dots_plate_y) + 1.0;

                translate([dots_plate_x, dots_plate_y, 0]) {
                    cube([dots_plate_w, dots_plate_h, plate_thick]);
                }
            }

            // Pasacables para conexiones entre filas de LEDs (Muescas laterales en la placa)
            for (r = [0 : rows - 1]) {
                y_row = box_h - margin_top - (r * led_pitch);
                translate([plate_left - 0.1, y_row - 2.5, -0.1])          cube([6.0, 5.0, plate_thick + 0.2]);
                translate([plate_right - 5.9, y_row - 2.5, -0.1])         cube([6.0, 5.0, plate_thick + 0.2]);
            }
        }

        // 3. Las 4 OREJAS DE FIJACIÓN en las esquinas del Baffle (Coinciden 1-a-1 con las torretas)
        translate([baffle_left, baffle_top, 0])   mounting_ear();
        translate([baffle_right, baffle_top, 0])  mounting_ear();
        translate([baffle_left, baffle_bot, 0])   mounting_ear();
        translate([baffle_right, baffle_bot, 0])  mounting_ear();

        // 4. Guías grabadas para pegado preciso de las tiras LED
        // a) 14 Filas de Texto
        for (r = [0 : rows - 1]) {
            y = box_h - margin_top - (r * led_pitch) - (strip_w / 2);
            text_rail_x   = margin_x - (led_pitch / 2);
            text_rail_len = (cols * led_pitch);
            
            translate([text_rail_x, y + strip_w, plate_thick]) cube([text_rail_len, 0.8, 1.2]);
            translate([text_rail_x, y - 0.8, plate_thick])     cube([text_rail_len, 0.8, 1.2]);
        }

        // b) Canaleta de los 4 Puntos de Minutos (100% contenida dentro del bloque inferior)
        dots_rail_x   = margin_x + (3.0 * led_pitch) - (baffle_wall / 2) + 0.5;
        dots_rail_len = (dots_block_cols * led_pitch) + baffle_wall - 1.0;
        y_dots_strip  = dots_y - (strip_w / 2);

        translate([dots_rail_x, y_dots_strip + strip_w, plate_thick]) cube([dots_rail_len, 0.8, 1.2]);
        translate([dots_rail_x, y_dots_strip - 0.8, plate_thick])     cube([dots_rail_len, 0.8, 1.2]);

        // 5. Torretas M3 en la CARA TRASERA para montar ESP32 DevKit (30p: ~28 x 51 mm)
        esp32_x = plate_left + 15;
        esp32_y = plate_bot + 25;
        translate([esp32_x, esp32_y, -6.0]) {
            m3_standoff(6);
            translate([28, 0, 0])  m3_standoff(6);
            translate([0, 51, 0])  m3_standoff(6);
            translate([28, 51, 0]) m3_standoff(6);
        }

        // 6. Torretas M3 en la CARA TRASERA para montar Módulo RTC DS3231 (~38 x 22 mm)
        rtc_x = plate_right - 55;
        rtc_y = plate_bot + 25;
        translate([rtc_x, rtc_y, -6.0]) {
            m3_standoff(6);
            translate([38, 0, 0])  m3_standoff(6);
            translate([0, 22, 0])  m3_standoff(6);
            translate([38, 22, 0]) m3_standoff(6);
        }
    }
}

// Generar modelo
wordclock_led_plate();
