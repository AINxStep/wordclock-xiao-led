// ==============================================================================
// WORDCLOCK ESP32 - PIEZA INDEPENDIENTE: SOPORTE DE ELECTRÓNICA (ESP32 + RTC)
// Parametric OpenSCAD Model for Bambu Lab (256x256 mm build plate)
// Print flat on bed without any supports. Attach to rear lid or inner frame.
// ==============================================================================

tray_w     = 90.0;  // Ancho de la bandeja (mm)
tray_h     = 65.0;  // Alto de la bandeja (mm)
tray_thick = 2.0;   // Grosor base (mm)
standoff_h = 5.0;   // Altura de torretas M3 (mm)

module m3_boss(h = 5.0) {
    difference() {
        cylinder(r = 3.5, h = h, $fn = 24);
        translate([0, 0, -0.1]) cylinder(r = 1.4, h = h + 0.2, $fn = 24);
    }
}

module wordclock_electronics_mount() {
    union() {
        difference() {
            // Base Plana de la Bandeja
            cube([tray_w, tray_h, tray_thick]);

            // Aligerado de peso central
            translate([10, 10, -0.1]) {
                cube([tray_w - 20, tray_h - 20, tray_thick + 0.2]);
            }

            // 4 Orificios M3 en las esquinas para atornillar/pegar la bandeja
            translate([5, 5, -0.1])           cylinder(r = 1.6, h = tray_thick + 0.2, $fn = 24);
            translate([tray_w - 5, 5, -0.1])   cylinder(r = 1.6, h = tray_thick + 0.2, $fn = 24);
            translate([5, tray_h - 5, -0.1])  cylinder(r = 1.6, h = tray_thick + 0.2, $fn = 24);
            translate([tray_w - 5, tray_h - 5, -0.1]) cylinder(r = 1.6, h = tray_thick + 0.2, $fn = 24);
        }

        // 1. Torretas M3 para ESP32 DevKit (30 pines: ~28 x 51 mm)
        esp32_x = 8;
        esp32_y = 7;
        translate([esp32_x, esp32_y, tray_thick]) {
            m3_boss(standoff_h);
            translate([28, 0, 0])  m3_boss(standoff_h);
            translate([0, 51, 0])  m3_boss(standoff_h);
            translate([28, 51, 0]) m3_boss(standoff_h);
        }

        // 2. Torretas M3 para Módulo RTC DS3231 (~38 x 22 mm)
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

// Generar modelo
wordclock_electronics_mount();
