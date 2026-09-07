# Reloj de Palabras (WordClock) - Seeed Studio XIAO ESP32-C6

🌐 **Idioma / Language:** **Español** | [English](README.en.md)

---

Proyecto completo de hardware, firmware, modelos 3D y simulador web para un reloj de palabras (*WordClock*) en español, con matriz de 158 LEDs direccionables WS2812B y control WiFi / RTC.

---

## Estructura del Repositorio

El repositorio está organizado en módulos independientes para facilitar la navegación y el mantenimiento:

```text
wordclock/
├── docs/                                  # Especificaciones técnicas y esquemas de la matriz
│   ├── matrix-layout.txt                  # Mapeo físico detallado de los 158 LEDs (cableado progresivo)
│   └── matrix-grid.txt                    # Distribución de la cuadrícula de texto (11x14)
│
├── simulator/                             # Simulador Web interactivo
│   ├── index.html                         # Interfaz gráfica del simulador
│   ├── index.css                          # Estilos visuales y efectos de iluminación LED
│   └── app.js                             # Lógica de tiempo, modos (real/manual) y portal WiFi
│
├── arduino/                               # Firmware para Arduino IDE
│   ├── wordclock/                         # Sketch principal
│   │   └── wordclock.ino                  # Firmware completo (ESP32-C6 + FastLED + RTC DS1307 + AP Portal)
│   ├── test_words/                        # Sketch de diagnóstico y pruebas
│   │   └── test_words.ino                 # Prueba secuencial de palabras e iluminación
│   └── reference/                         # Códigos de referencia y ejemplos base
│       └── wordclock-example.code.txt
│
├── 3d_models/                             # Archivos de impresión 3D (OpenSCAD, STL, 3MF)
│   ├── best_parameters.txt                # Parámetros recomendados de laminación (Bambu Studio)
│   ├── opcion_1_tapa_superpuesta/         # Opción 1: Tapa exterior superpuesta para marco estándar
│   └── opcion_2_tapa_incrustada_al_ras/   # Opción 2: Tapa incrustada al ras para marco optimizado
│
└── backups/                               # Concentrador unificado de respaldos y versiones históricas
    ├── simulator/                         # Respaldos de versiones anteriores del simulador
    ├── scad_188x240_pre_optimized/        # Diseños preliminares SCAD 188x240 mm
    ├── scad_perfect/                      # Diseños intermedios SCAD
    ├── scad_backup_flush_lid/             # Diseños previos con tapa al ras
    ├── version_1_superpuesta_no_al_ras/   # Versión inicial no al ras
    ├── version_2_incrustada_al_ras/       # Versión inicial incrustada
    └── root_legacy_3d/                    # Archivos 3D preliminares de raíz
```

---

## Hardware Utilizado

* **Microcontrolador**: [Seeed Studio XIAO ESP32-C6](https://wiki.seeedstudio.com/xiao_esp32c6_getting_started/)
* **Driver de LEDs**: Seeed LED Driver Board (Level Shifter bidireccional 3.3V → 5V)
* **Tira de LEDs**: WS2812B de 74 LEDs/m (158 LEDs en total: matriz 11×14 + 4 puntos de minutos)
* **Módulo RTC**: Grove - DS1307 RTC (bus I2C nativo a 100 kHz)
* **Pines Principales**:
  * Pin de datos LEDs: `D0` / `GPIO 0`
  * LED integrado (estado AP): `GPIO 15`
  * Bus I2C: Pines Grove SDA/SCL

---

## Matriz de Letras y Lógica en Español

La matriz cuenta con 11 columnas × 14 filas (154 LEDs) más 4 LEDs dedicados a los minutos individuales (+1, +2, +3, +4):

```text
Fila 0  (0-10):    E S O N X L A S U N A    (ES, SON, LA, LAS, UNA)
Fila 1  (11-21):   V E I N T I C I N C O    (Minutos para bloque PARA)
Fila 2  (22-32):   D I E Z V E I N T E G    (Minutos para bloque PARA)
Fila 3  (33-43):   C U A R T O K P A R A    (CUARTO, PARA)
Fila 4  (44-54):   L A S U N A Z W I F I    (LA, LAS, UNA para bloque PARA + WIFI)
Fila 5  (55-65):   T R E S Z B G K D O S    (Horas: TRES, DOS)
Fila 6  (66-76):   C U A T R O C I N C O    (Horas: CUATRO, CINCO)
Fila 7  (77-87):   U S E I S O S I E T E    (Horas: SEIS, SIETE)
Fila 8  (88-98):   O C H O N U E V E N V    (Horas: OCHO, NUEVE)
Fila 9  (99-109):  D I E Z D S O N C E A    (Horas: DIEZ, ONCE)
Fila 10 (110-120): D O C E L Y E I J K V    (Horas: DOCE, Conjunción Y)
Fila 11 (121-131): V E I N T E Z D I E Z    (Minutos para bloque Y)
Fila 12 (132-142): V E I N T I C I N C O    (Minutos para bloque Y)
Fila 13 (143-153): C U A R T O M E D I A    (Minutos para bloque Y)
Fila 14 (154-157): Puntos de minutos (+1, +2, +3, +4)
```

* **Bloque "Y"** (minutos 00 a 34): *Ej. "SON LAS ONCE Y VEINTE"*
* **Bloque "PARA"** (minutos 35 a 59): *Ej. "VEINTICINCO PARA LAS DOCE"*
* **Puntos de minutos**: Permiten precisión minuto a minuto.

---

## Cómo Usar

### 1. Simulador Web
Abre directamente `simulator/index.html` en cualquier navegador web moderno para verificar la lógica de iluminación, ajustar la hora manualmente con el slider o sincronizarla en tiempo real.

### 2. Firmware (Arduino IDE)
1. Instala la placa **ESP32 by Espressif Systems** en el Gestor de Placas de Arduino IDE.
2. Instala las librerías necesarias: `FastLED` y `RTClib` (Adafruit).
3. Abre el sketch `arduino/wordclock/wordclock.ino`.
4. Selecciona la placa **Seeed Studio XIAO ESP32C6** y el puerto correspondiente.
5. Compila y carga el código.

### 3. Impresión 3D
Dentro de `3d_models/` encontrarás los modelos OpenSCAD paramétricos y los archivos `.stl` / `.3mf` listos para rebanar. Consulta `3d_models/best_parameters.txt` para los ajustes de capa, ancho de línea y patrones de relleno recomendados.
