// ==============================================================================
// WORDCLOCK ESP32 - OPCION 1: PLACA DE LEDS INTERMEDIA (MARCO IMPRESO 3.0 mm)
// PIEZA 2: PLACA DE LEDS CON OREJAS DE FIJACIÓN Y GUÍAS DE TIRA WS2812B (74 LEDs/m)
// ==============================================================================

led_pitch   = 13.5135; // 74 LEDs/m
cols        = 11;
rows        = 14;

box_w       = 188.0;
box_h       = 240.0;
wall_thick  = 3.0;     // Coincide con la pared de 3.0 mm del marco impreso
baffle_wall = 1.2;

grid_w      = (cols - 1) * led_pitch; // ~135.14 mm
grid_h      = (rows - 1) * led_pitch; // ~175.68 mm

margin_x    = (box_w - grid_w) / 2;
margin_top  = (box_h - grid_h - led_pitch) / 2;

dots_block_cols = 4;
dots_y          = box_h - margin_top - (14 * led_pitch);

plate_left  = margin_x - (led_pitch / 2) - 0.5;
plate_right = margin_x + grid_w + (led_pitch / 2) + 0.5;
plate_top   = box_h - margin_top + (led_pitch / 2) + 0.5;
plate_bot   = box_h - margin_top - grid_h - (led_pitch / 2) - 0.5;

plate_w     = plate_right - plate_left;
plate_h     = plate_top - plate_bot;

plate_thick = 2.0; 
guide_thick = 0.4; 
total_thick = plate_thick + guide_thick; 

strip_w     = 10.2; 
center_x    = box_w / 2; 

baffle_left  = margin_x - (led_pitch / 2) - 2.0;
baffle_right = margin_x + grid_w + (led_pitch / 2) + 2.0;
baffle_top   = box_h - margin_top + (led_pitch / 2) + 2.0;
baffle_bot   = box_h - margin_top - grid_h - (led_pitch / 2) - 2.0;

module mounting_ear() {
    difference() {
        cylinder(r = 5.0, h = total_thick, $fn = 32);
        translate([0, 0, -0.1]) cylinder(r = 1.6, h = total_thick + 0.2, $fn = 32);
    }
}

module data_flow_arrow(dir_right = true, h = 0.2) {
    linear_extrude(height = h) {
        if (dir_right) {
            polygon(points = [[-3, -1], [1, -1], [1, -2.2], [4, 0], [1, 2.2], [1, 1], [-3, 1]]);
        } else {
            polygon(points = [[3, -1], [-1, -1], [-1, -2.2], [-4, 0], [-1, 2.2], [-1, 1], [3, 1]]);
        }
    }
}

module wordclock_led_plate() {
    union() {
        difference() {
            union() {
                translate([plate_left, plate_bot, 0]) {
                    cube([plate_w, plate_h, plate_thick]);
                }

                dots_plate_w = (dots_block_cols * led_pitch) + baffle_wall;
                dots_plate_x = margin_x + (3.0 * led_pitch) - (baffle_wall / 2);
                dots_plate_y = dots_y - (led_pitch / 2) - 0.5;
                dots_plate_h = (plate_bot - dots_plate_y) + 1.0;

                translate([dots_plate_x, dots_plate_y, 0]) {
                    cube([dots_plate_w, dots_plate_h, plate_thick]);
                }
            }

            for (r = [0 : rows - 1]) {
                y_row = box_h - margin_top - (r * led_pitch);
                translate([plate_left - 0.1, y_row - 2.5, -0.1])          cube([6.0, 5.0, plate_thick + 0.2]);
                translate([plate_right - 5.9, y_row - 2.5, -0.1])         cube([6.0, 5.0, plate_thick + 0.2]);
            }
        }

        translate([baffle_left, baffle_top, 0])   mounting_ear();
        translate([baffle_right, baffle_top, 0])  mounting_ear();
        translate([baffle_left, baffle_bot, 0])   mounting_ear();
        translate([baffle_right, baffle_bot, 0])  mounting_ear();

        for (r = [0 : rows - 1]) {
            y = box_h - margin_top - (r * led_pitch) - (strip_w / 2);
            text_rail_x   = margin_x - (led_pitch / 2);
            text_rail_len = (cols * led_pitch);
            
            translate([text_rail_x, y + strip_w, plate_thick]) cube([text_rail_len, 0.8, guide_thick]);
            translate([text_rail_x, y - 0.8, plate_thick])     cube([text_rail_len, 0.8, guide_thick]);

            mark_w = 0.8;
            translate([center_x - (mark_w / 2), y + strip_w, plate_thick]) cube([mark_w, 1.6, guide_thick]);
            translate([center_x - (mark_w / 2), y - 1.6, plate_thick])     cube([mark_w, 1.6, guide_thick]);

            dir_right = (r % 2 == 0);
            y_center  = y + (strip_w / 2);
            translate([margin_x + (1.5 * led_pitch), y_center, plate_thick])           data_flow_arrow(dir_right);
            translate([margin_x + grid_w - (1.5 * led_pitch), y_center, plate_thick])  data_flow_arrow(dir_right);
        }

        dots_rail_x   = margin_x + (3.0 * led_pitch) - (baffle_wall / 2) + 0.5;
        dots_rail_len = (dots_block_cols * led_pitch) + baffle_wall - 1.0;
        y_dots_strip  = dots_y - (strip_w / 2);

        translate([dots_rail_x, y_dots_strip + strip_w, plate_thick]) cube([dots_rail_len, 0.8, guide_thick]);
        translate([dots_rail_x, y_dots_strip - 0.8, plate_thick])     cube([dots_rail_len, 0.8, guide_thick]);

        dots_center_x = dots_rail_x + (dots_rail_len / 2);
        mark_w = 0.8;
        translate([dots_center_x - (mark_w / 2), y_dots_strip + strip_w, plate_thick]) cube([mark_w, 1.6, guide_thick]);
        translate([dots_center_x - (mark_w / 2), y_dots_strip - 1.6, plate_thick])     cube([mark_w, 1.6, guide_thick]);

        translate([dots_rail_x + (led_pitch * 0.8), dots_y, plate_thick])             data_flow_arrow(true);
        translate([dots_rail_x + dots_rail_len - (led_pitch * 0.8), dots_y, plate_thick]) data_flow_arrow(true);
    }
}

wordclock_led_plate();
