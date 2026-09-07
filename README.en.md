# Word Clock (WordClock) - Seeed Studio XIAO ESP32-C6

🌐 **Idioma / Language:** [Español](README.md) | **English**

---

Complete project including hardware, firmware, 3D printable models, and an interactive web simulator for a Spanish Word Clock (*WordClock*), powered by an addressable 158-LED WS2812B matrix with WiFi AP configuration and RTC timekeeping.

---

## Repository Structure

The repository is organized into modular directories for clean navigation and maintenance:

```text
wordclock/
├── docs/                                  # Technical specifications and LED matrix layout
│   ├── matrix-layout.txt                  # Detailed physical mapping for all 158 LEDs (progressive wiring)
│   └── matrix-grid.txt                    # Letter grid distribution (11x14)
│
├── simulator/                             # Interactive Web Simulator
│   ├── index.html                         # Simulator user interface
│   ├── index.css                          # Visual styling and realistic LED glow effects
│   └── app.js                             # Clock logic, modes (real-time/manual slider), and WiFi portal
│
├── arduino/                               # Firmware for Arduino IDE
│   ├── wordclock/                         # Main sketch folder
│   │   └── wordclock.ino                  # Complete firmware (ESP32-C6 + FastLED + DS1307 RTC + AP Web Portal)
│   ├── test_words/                        # Diagnostic and test sketch
│   │   └── test_words.ino                 # Sequential word and LED lighting tests
│   └── reference/                         # Reference source codes and examples
│       └── wordclock-example.code.txt
│
├── 3d_models/                             # 3D Printing files (OpenSCAD, STL, 3MF)
│   ├── best_parameters.txt                # Recommended slicing parameters (Bambu Studio)
│   ├── opcion_1_tapa_superpuesta/         # Option 1: External overlaid back lid for standard frame
│   └── opcion_2_tapa_incrustada_al_ras/   # Option 2: Flush-mount embedded lid for optimized frame
│
└── backups/                               # Consolidated backups and historical iterations
    ├── simulator/                         # Legacy versions of the web simulator
    ├── scad_188x240_pre_optimized/        # Early 188x240 mm OpenSCAD designs
    ├── scad_perfect/                      # Intermediate OpenSCAD iterations
    ├── scad_backup_flush_lid/             # Previous flush-lid OpenSCAD designs
    ├── version_1_superpuesta_no_al_ras/   # Early non-flush back lid model
    ├── version_2_incrustada_al_ras/       # Early flush-mount model
    └── root_legacy_3d/                    # Historical 3D files originally located in root
```

---

## Hardware Components

* **Microcontroller**: [Seeed Studio XIAO ESP32-C6](https://wiki.seeedstudio.com/xiao_esp32c6_getting_started/)
* **LED Driver**: Seeed LED Driver Board (Bidirectional 3.3V → 5V Level Shifter)
* **LED Strip**: WS2812B @ 74 LEDs/m (158 total LEDs: 11×14 matrix + 4 individual minute dots)
* **RTC Module**: Grove - DS1307 RTC (Native I2C bus @ 100 kHz)
* **Key Pinout**:
  * LED Data Pin: `D0` / `GPIO 0`
  * Built-in LED (AP Status): `GPIO 15`
  * I2C Bus: Native Grove SDA/SCL pins

---

## Letter Matrix & Spanish Time Logic

The matrix features 11 columns × 14 rows (154 LEDs) plus 4 discrete LEDs for individual minutes (+1, +2, +3, +4):

```text
Row 0  (0-10):    E S O N X L A S U N A    (ES, SON, LA, LAS, UNA)
Row 1  (11-21):   V E I N T I C I N C O    (Minutes for "PARA" phrase)
Row 2  (22-32):   D I E Z V E I N T E G    (Minutes for "PARA" phrase)
Row 3  (33-43):   C U A R T O K P A R A    (CUARTO, PARA)
Row 4  (44-54):   L A S U N A Z W I F I    (LA, LAS, UNA for "PARA" + WIFI)
Row 5  (55-65):   T R E S Z B G K D O S    (Hours: TRES, DOS)
Row 6  (66-76):   C U A T R O C I N C O    (Hours: CUATRO, CINCO)
Row 7  (77-87):   U S E I S O S I E T E    (Hours: SEIS, SIETE)
Row 8  (88-98):   O C H O N U E V E N V    (Hours: OCHO, NUEVE)
Row 9  (99-109):  D I E Z D S O N C E A    (Hours: DIEZ, ONCE)
Row 10 (110-120): D O C E L Y E I J K V    (Hours: DOCE, Conjunction Y)
Row 11 (121-131): V E I N T E Z D I E Z    (Minutes for "Y" phrase)
Row 12 (132-142): V E I N T I C I N C O    (Minutes for "Y" phrase)
Row 13 (143-153): C U A R T O M E D I A    (Minutes for "Y" phrase)
Row 14 (154-157): Minute Dots (+1, +2, +3, +4)
```

* **"Y" Block** (minutes 00 to 34): *e.g., "SON LAS ONCE Y VEINTE" (It's 11:20)*
* **"PARA" Block** (minutes 35 to 59): *e.g., "VEINTICINCO PARA LAS DOCE" (25 to 12)*
* **Minute Dots**: Provide single-minute precision (+1 to +4).

---

## Getting Started

### 1. Web Simulator
Open `simulator/index.html` directly in any modern web browser to simulate and verify word illumination, change color presets, adjust time with the slider, or sync to your browser's real clock.

### 2. Firmware (Arduino IDE)
1. Install **ESP32 by Espressif Systems** via the Arduino IDE Boards Manager.
2. Install the required libraries: `FastLED` and `RTClib` (by Adafruit).
3. Open the sketch `arduino/wordclock/wordclock.ino`.
4. Select board **Seeed Studio XIAO ESP32C6** and your USB serial port.
5. Compile and upload.

### 3. 3D Printing
All parametric OpenSCAD sources and exported `.stl` / `.3mf` files are located in `3d_models/`. Check `3d_models/best_parameters.txt` for recommended layer heights, line widths, and infill patterns.
