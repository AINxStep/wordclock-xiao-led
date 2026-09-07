// ==============================================================================
// WORDCLOCK ESP32 - OPCION 2: SOPORTE DE ELECTRONICA INDEPENDIENTE
// PIEZA 4: BANDEJA DE MONTAJE PARA ESP32 + MODULO RTC DS1307
// ==============================================================================

tray_w     = 90.0;
tray_h     = 65.0;
tray_thick = 2.0;
standoff_h = 5.0;

module m3_boss(h = 5.0) {
    difference() {
        cylinder(r = 3.5, h = h, $fn = 24);
        translate([0, 0, -0.1]) cylinder(r = 1.4, h = h + 0.2, $fn = 24);
    }
}

module wordclock_electronics_mount() {
    union() {
        difference() {
            cube([tray_w, tray_h, tray_thick]);

            translate([10, 10, -0.1]) {
                cube([tray_w - 20, tray_h - 20, tray_thick + 0.2]);
            }

            translate([5, 5, -0.1])           cylinder(r = 1.6, h = tray_thick + 0.2, $fn = 24);
            translate([tray_w - 5, 5, -0.1])   cylinder(r = 1.6, h = tray_thick + 0.2, $fn = 24);
            translate([5, tray_h - 5, -0.1])  cylinder(r = 1.6, h = tray_thick + 0.2, $fn = 24);
            translate([tray_w - 5, tray_h - 5, -0.1]) cylinder(r = 1.6, h = tray_thick + 0.2, $fn = 24);
        }

        esp32_x = 8;
        esp32_y = 7;
        translate([esp32_x, esp32_y, tray_thick]) {
            m3_boss(standoff_h);
            translate([28, 0, 0])  m3_boss(standoff_h);
            translate([0, 51, 0])  m3_boss(standoff_h);
            translate([28, 51, 0]) m3_boss(standoff_h);
        }

        rtc_x = 44;
        rtc_y = 20;
        translate([rtc_x, rtc_y, tray_thick]) {
            m3_boss(standoff_h);
            translate([38, 0, 0])  m3_boss(standoff_h);
            translate([0, 22, 0])  m3_boss(standoff_h);
            translate([38, 22, 0]) m3_boss(standoff_h);
        }
    }
}

wordclock_electronics_mount();
