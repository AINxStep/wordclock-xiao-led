// ==============================================================================
// WORDCLOCK ESP32 - VERSION 1 (NO AL RAS / SUPERPUESTA)
// PIEZA 1: CUERPO PRINCIPAL (MARCO + STENCIL + BAFFLE INTEGRADOS)
// Torretas traseras a altura completa 35.0 mm (La tapa se apoya encima de 188x240 mm)
// ==============================================================================

led_pitch   = 13.5135;
cols        = 11;
rows        = 14;

box_w       = 188.0;
box_h       = 240.0;
box_d       = 35.0;
wall_thick  = 1.6;

grid_w      = (cols - 1) * led_pitch;
grid_h      = (rows - 1) * led_pitch;

margin_x    = (box_w - grid_w) / 2;
margin_top  = (box_h - grid_h - led_pitch) / 2;

face_thick  = 1.6;
baffle_h    = 10.0;
baffle_wall = 0.8;

cell_w      = led_pitch - baffle_wall;
cell_h      = led_pitch - baffle_wall;

font_name   = "Arial:style=Bold";
font_size   = 7.8;
dot_radius  = 2.0;

notch_w     = 4.0;
notch_y     = 5.0;
notch_z     = 2.0;

dots_block_cols = 4;
dots_y          = box_h - margin_top - (14 * led_pitch);

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

module screw_boss(h, r_out = 4.0, r_in = 1.4) {
    difference() {
        cylinder(r = r_out, h = h, $fn = 32);
        translate([0, 0, -0.1]) cylinder(r = r_in, h = h + 0.2, $fn = 32);
    }
}

module wordclock_main_frame() {
    union() {
        difference() {
            cube([box_w, box_h, box_d]);

            translate([wall_thick, wall_thick, face_thick]) {
                cube([box_w - (wall_thick * 2), box_h - (wall_thick * 2), box_d]);
            }

            translate([0, 0, -0.5]) {
                for (r = [0 : rows - 1]) {
                    for (c = [0 : cols - 1]) {
                        x = margin_x + (c * led_pitch);
                        y = box_h - margin_top - (r * led_pitch);
                        
                        translate([x, y, 0]) {
                            linear_extrude(height = face_thick + 1.0) {
                                mirror([1, 0, 0]) {
                                    text(matrix_text[r][c], size = font_size, font = font_name, halign = "center", valign = "center");
                                }
                            }
                        }
                    }
                }

                for (i = [0 : 3]) {
                    x_dot = margin_x + ((3.5 + i) * led_pitch);
                    translate([x_dot, dots_y, 0]) {
                        cylinder(r = dot_radius, h = face_thick + 1.0, $fn = 32);
                    }
                }
            }
        }

        translate([0, 0, face_thick]) {
            difference() {
                union() {
                    baffle_text_x = margin_x - (led_pitch / 2) - (baffle_wall / 2);
                    baffle_text_y = box_h - margin_top - grid_h - (led_pitch / 2) - (baffle_wall / 2);
                    baffle_text_w = grid_w + led_pitch + baffle_wall;
                    baffle_text_h = grid_h + led_pitch + baffle_wall;
                    
                    translate([baffle_text_x, baffle_text_y, 0]) {
                        cube([baffle_text_w, baffle_text_h, baffle_h]);
                    }

                    dots_block_w = (dots_block_cols * led_pitch) + baffle_wall;
                    dots_block_x = margin_x + (3.0 * led_pitch) - (baffle_wall / 2);
                    dots_block_y = dots_y - (led_pitch / 2) - (baffle_wall / 2);
                    dots_block_h = led_pitch + baffle_wall;
                    
                    translate([dots_block_x, dots_block_y, 0]) {
                        cube([dots_block_w, dots_block_h, baffle_h]);
                    }
                }

                for (r = [0 : rows - 1]) {
                    for (c = [0 : cols - 1]) {
                        x = margin_x + (c * led_pitch) - (cell_w / 2);
                        y = box_h - margin_top - (r * led_pitch) - (cell_h / 2);
                        
                        translate([x, y, -0.1]) {
                            cube([cell_w, cell_h, baffle_h + 0.2]);
                        }
                    }
                }

                for (i = [0 : 3]) {
                    x_dot_cell = margin_x + ((3.0 + i) * led_pitch) + (baffle_wall / 2);
                    y_dot_cell = dots_y - (cell_h / 2);
                    
                    translate([x_dot_cell, y_dot_cell, -0.1]) {
                        cube([cell_w, cell_h, baffle_h + 0.2]);
                    }
                }

                for (r = [0 : rows - 1]) {
                    y_row = box_h - margin_top - (r * led_pitch);
                    translate([margin_x - (led_pitch / 2) - (baffle_wall / 2) - 1.0, y_row - (notch_y / 2), baffle_h - notch_z]) {
                        cube([baffle_wall + 2.0, notch_y, notch_z + 0.5]);
                    }
                    translate([margin_x + grid_w + (led_pitch / 2) - (baffle_wall / 2) - 1.0, y_row - (notch_y / 2), baffle_h - notch_z]) {
                        cube([baffle_wall + 2.0, notch_y, notch_z + 0.5]);
                    }
                }
            }
        }

        baffle_left  = margin_x - (led_pitch / 2) - 2.0;
        baffle_right = margin_x + grid_w + (led_pitch / 2) + 2.0;
        baffle_top   = box_h - margin_top + (led_pitch / 2) + 2.0;
        baffle_bot   = box_h - margin_top - grid_h - (led_pitch / 2) - 2.0;
        led_plate_z  = face_thick + baffle_h;

        translate([baffle_left, baffle_top, 0])   screw_boss(led_plate_z, 4.5, 1.4);
        translate([baffle_right, baffle_top, 0])  screw_boss(led_plate_z, 4.5, 1.4);
        translate([baffle_left, baffle_bot, 0])   screw_boss(led_plate_z, 4.5, 1.4);
        translate([baffle_right, baffle_bot, 0])  screw_boss(led_plate_z, 4.5, 1.4);

        // Torretas traseras a altura completa (35.0 mm) para tapa superpuesta por fuera
        rear_boss_h = box_d; // 35.0 mm
        screw_off   = wall_thick + 4.0;
        
        translate([screw_off, screw_off, 0])                 screw_boss(rear_boss_h, 4.5, 1.4);
        translate([box_w - screw_off, screw_off, 0])         screw_boss(rear_boss_h, 4.5, 1.4);
        translate([screw_off, box_h - screw_off, 0])         screw_boss(rear_boss_h, 4.5, 1.4);
        translate([box_w - screw_off, box_h - screw_off, 0]) screw_boss(rear_boss_h, 4.5, 1.4);
    }
}

wordclock_main_frame();
