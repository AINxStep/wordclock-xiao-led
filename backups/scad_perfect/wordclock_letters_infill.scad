// ==============================================================================
// WORDCLOCK ESP32 - PIEZA AUXILIAR: RELLENO DE LETRAS (LETTERS INFILL STL)
// Parametric OpenSCAD Model for Bambu Lab (256x256 mm build plate)
// High-Density LED Strip: WS2812B 74 LEDs/m (Pitch = 13.5135 mm)
// Reversed matrix_text column order matching main frame
// ==============================================================================

led_pitch   = 13.5135;
cols        = 11;
rows        = 14;

box_w       = 240.0;
box_h       = 240.0;

grid_w      = (cols - 1) * led_pitch;
grid_h      = (rows - 1) * led_pitch;

margin_x    = (box_w - grid_w) / 2;
margin_top  = (box_h - grid_h - led_pitch) / 2;

diff_thick  = 0.4; // 2 capas a 0.20 mm de PLA Blanco Translúcido

font_name   = "Arial:style=Bold";
font_size   = 7.8;
dot_radius  = 2.0;

dots_y      = box_h - margin_top - (14 * led_pitch);

matrix_text = [
    ["A","N","U","S","A","L","X","N","O","S","E"],
    ["O","C","N","I","C","I","T","N","I","E","V"],
    ["G","E","T","N","I","E","V","Z","E","I","D"],
    ["A","R","A","P","K","O","T","R","A","U","C"],
    ["I","F","I","W","Z","A","N","U","S","A","L"],
    ["S","O","D","K","G","B","Z","S","E","R","T"],
    ["O","C","N","I","C","O","T","R","A","U","C"],
    ["E","T","E","I","S","O","S","I","E","S","U"],
    ["V","N","E","V","E","U","N","O","H","C","O"],
    ["A","E","C","N","O","S","D","Z","E","I","D"],
    ["V","K","J","I","E","Y","L","E","C","O","D"],
    ["Z","I","E","D","Z","E","T","N","I","E","V"],
    ["O","C","N","I","C","I","T","N","I","E","V"],
    ["A","I","D","E","M","O","T","R","A","U","C"]
];

module wordclock_letters_infill() {
    union() {
        // Filas 0 a 13 (Texto)
        for (r = [0 : rows - 1]) {
            for (c = [0 : cols - 1]) {
                x = margin_x + (c * led_pitch);
                y = box_h - margin_top - (r * led_pitch);
                
                translate([x, y, 0]) {
                    linear_extrude(height = diff_thick) {
                        mirror([1, 0, 0]) {
                            text(matrix_text[r][c], size = font_size, font = font_name, halign = "center", valign = "center");
                        }
                    }
                }
            }
        }

        // Fila 14 (4 Puntos de Minutos Centrados)
        for (i = [0 : 3]) {
            x_dot = margin_x + ((3.5 + i) * led_pitch);
            translate([x_dot, dots_y, 0]) {
                cylinder(r = dot_radius, h = diff_thick, $fn = 32);
            }
        }
    }
}

wordclock_letters_infill();
