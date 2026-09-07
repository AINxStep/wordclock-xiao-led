/* ==============================================================================
   WORDCLOCK ESP32 - SKETCH DE PRUEBA Y DIAGNÓSTICO PALABRA POR PALABRA
   Placa: Seeed Studio XIAO ESP32-C6 + Seeed LED Driver Board
   Mantiene el mapeo Serpentina / Zig-Zag (Filas Impares 1,3,5,7,9,11,13 de Der->Izq)
   ============================================================================== */

#include <FastLED.h>

#define DATA_PIN        0     // D0 en XIAO ESP32-C6 (Level Shifter 5V)
#define NUM_LEDS        158
#define LED_TYPE        WS2812B
#define COLOR_ORDER     GRB

CRGB leds[NUM_LEDS];

// --- Estructura para registrar cada palabra y sus LEDs ---
struct WordTest {
  const char* name;
  const uint8_t* leds;
  uint8_t len;
};

// --- Mapeo de Palabras (Modo Serpentina Zig-Zag) ---
const uint8_t ES[] = {0, 1};
const uint8_t SON[] = {1, 2, 3};
const uint8_t LA[] = {5, 6};
const uint8_t LAS[] = {5, 6, 7};
const uint8_t UNA[] = {8, 9, 10};

const uint8_t VEINTICINCO_PARA[] = {21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11};
const uint8_t CINCO_PARA[] = {15, 14, 13, 12, 11};
const uint8_t DIEZ_PARA[] = {22, 23, 24, 25};
const uint8_t VEINTE_PARA[] = {26, 27, 28, 29, 30, 31};
const uint8_t CUARTO_PARA[] = {43, 42, 41, 40, 39, 38};
const uint8_t PARA[] = {36, 35, 34, 33};

const uint8_t LA_PARA[] = {44, 45};
const uint8_t LAS_PARA[] = {44, 45, 46};
const uint8_t UNA_PARA[] = {47, 48, 49};
const uint8_t WIFI[] = {51, 52, 53, 54};

const uint8_t TRES[] = {65, 64, 63, 62};
const uint8_t DOS[] = {57, 56, 55};
const uint8_t CUATRO[] = {66, 67, 68, 69, 70, 71};
const uint8_t CINCO_H[] = {72, 73, 74, 75, 76};
const uint8_t SEIS[] = {86, 85, 84, 83};
const uint8_t SIETE[] = {81, 80, 79, 78, 77};
const uint8_t OCHO[] = {88, 89, 90, 91};
const uint8_t NUEVE[] = {92, 93, 94, 95, 96};
const uint8_t DIEZ_H[] = {109, 108, 107, 106};
const uint8_t ONCE[] = {103, 102, 101, 100};
const uint8_t DOCE[] = {110, 111, 112, 113};

const uint8_t Y[] = {115};

const uint8_t VEINTE_Y[] = {131, 130, 129, 128, 127, 126};
const uint8_t DIEZ_Y[] = {124, 123, 122, 121};
const uint8_t VEINTICINCO_Y[] = {132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142};
const uint8_t CINCO_Y[] = {138, 139, 140, 141, 142};
const uint8_t CUARTO_Y[] = {153, 152, 151, 150, 149, 148};
const uint8_t MEDIA[] = {147, 146, 145, 144, 143};

const uint8_t DOT_1[] = {154};
const uint8_t DOT_2[] = {155};
const uint8_t DOT_3[] = {156};
const uint8_t DOT_4[] = {157};

// Lista secuencial de todas las palabras para probar
WordTest testSequence[] = {
  {"ES", ES, 2},
  {"SON", SON, 3},
  {"LA", LA, 2},
  {"LAS", LAS, 3},
  {"UNA (Fila 0)", UNA, 3},
  {"VEINTICINCO (bloque PARA)", VEINTICINCO_PARA, 11},
  {"CINCO (bloque PARA)", CINCO_PARA, 5},
  {"DIEZ (bloque PARA)", DIEZ_PARA, 4},
  {"VEINTE (bloque PARA)", VEINTE_PARA, 6},
  {"CUARTO (bloque PARA)", CUARTO_PARA, 6},
  {"PARA", PARA, 4},
  {"LA (bloque PARA)", LA_PARA, 2},
  {"LAS (bloque PARA)", LAS_PARA, 3},
  {"UNA (bloque PARA)", UNA_PARA, 3},
  {"WIFI", WIFI, 4},
  {"TRES (Hora)", TRES, 4},
  {"DOS (Hora)", DOS, 3},
  {"CUATRO (Hora)", CUATRO, 6},
  {"CINCO (Hora)", CINCO_H, 5},
  {"SEIS (Hora)", SEIS, 4},
  {"SIETE (Hora)", SIETE, 5},
  {"OCHO (Hora)", OCHO, 4},
  {"NUEVE (Hora)", NUEVE, 5},
  {"DIEZ (Hora)", DIEZ_H, 4},
  {"ONCE (Hora)", ONCE, 4},
  {"DOCE (Hora)", DOCE, 4},
  {"Y (Conjunción)", Y, 1},
  {"VEINTE (bloque Y)", VEINTE_Y, 6},
  {"DIEZ (bloque Y)", DIEZ_Y, 4},
  {"VEINTICINCO (bloque Y)", VEINTICINCO_Y, 11},
  {"CINCO (bloque Y)", CINCO_Y, 5},
  {"CUARTO (bloque Y)", CUARTO_Y, 6},
  {"MEDIA", MEDIA, 5},
  {"PUNTO +1 MINUTO", DOT_1, 1},
  {"PUNTO +2 MINUTOS", DOT_2, 1},
  {"PUNTO +3 MINUTOS", DOT_3, 1},
  {"PUNTO +4 MINUTOS", DOT_4, 1}
};

const uint8_t TOTAL_WORDS = sizeof(testSequence) / sizeof(WordTest);

void setup() {
  Serial.begin(115200);
  delay(1500);

  Serial.println(F("\n=========================================================="));
  Serial.println(F("   WORDCLOCK ESP32 - TEST SECUENCIAL PALABRA POR PALABRA    "));
  Serial.println(F("   Modo: Serpentina (Zig-Zag) | Filas 11x14 + 4 Puntos    "));
  Serial.println(F("=========================================================="));

  FastLED.addLeds<LED_TYPE, DATA_PIN, COLOR_ORDER>(leds, NUM_LEDS);
  FastLED.setBrightness(180); // Brillo al 70%
  FastLED.clear(true);
}

void loop() {
  for (uint8_t w = 0; w < TOTAL_WORDS; w++) {
    // 1. Apagar todos los LEDs
    fill_solid(leds, NUM_LEDS, CRGB::Black);

    // 2. Encender únicamente la palabra actual en color Ámbar Neón
    for (uint8_t i = 0; i < testSequence[w].len; i++) {
      uint8_t idx = testSequence[w].leds[i];
      if (idx < NUM_LEDS) {
        leds[idx] = CRGB(255, 140, 0);
      }
    }
    FastLED.show();

    // 3. Imprimir en Serial la palabra que se está probando y sus LEDs físicos
    Serial.printf("[%02d/%02d] Probando: '%s' | LEDs en tira: ", w + 1, TOTAL_WORDS, testSequence[w].name);
    for (uint8_t i = 0; i < testSequence[w].len; i++) {
      Serial.print(testSequence[w].leds[i]);
      if (i < testSequence[w].len - 1) Serial.print(", ");
    }
    Serial.println();

    // 4. Pausa de 1.8 segundos por palabra para inspección visual
    delay(1800);
  }

  Serial.println(F("\n--- Ciclo completado. Reiniciando prueba secuencial en 3 segundos ---\n"));
  fill_solid(leds, NUM_LEDS, CRGB::Black);
  FastLED.show();
  delay(3000);
}
