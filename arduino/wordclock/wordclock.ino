/*
  Reloj de Palabras (WordClock Seeed Studio XIAO ESP32-C6)
  Hardware: Microcontrolador Seeed Studio XIAO ESP32-C6 + Seeed LED Driver Board + Grove RTC (DS1307)
  Matriz: 11x14 + 4 puntos de minutos (158 LEDs totales, WS2812B 74 LEDs/m)
  Pin de datos LED: D0 / A0 (GPIO 0) mediante Seeed LED Driver Board (Level Shifter 3.3V -> 5V)
  Bus I2C RTC: Puerto Grove I2C nativo (SDA/SCL a 100 kHz para módulo Grove DS1307)
  LED Integrado XIAO: GPIO 15 (Parpadeo durante modo WiFi AP activo)
  Indicador WiFi: índices 51-54 ("WIFI" en Fila 4)
  Configuración: Captive Portal WebServer idéntico al simulador en AP "WORDCLOCK-SETUP"
*/

#include <FastLED.h>
#include <Wire.h>
#include <RTClib.h>

#include <WiFi.h>
#include <WebServer.h>
#include <DNSServer.h>
#include <Preferences.h>
#include <time.h>

/* ========== Configuración Hardware Seeed Studio XIAO ESP32-C6 ========== */
#define DATA_PIN 0            // Pin D0 (GPIO 0) en XIAO ESP32-C6 (Entrada al Level Shifter del LED Driver Board)
#define LED_PIN_BUILTIN 15    // Pin LED Integrado en XIAO ESP32-C6 (Lógica Invertida: LOW = ON, HIGH = OFF)
#define NUM_LEDS 158

// Velocidad I2C Estándar para DS1307 (100 kHz)
#define I2C_SPEED_DS1307 100000UL

// Instancia del RTC Grove basado en chip DS1307
RTC_DS1307 rtc;

CRGB leds[NUM_LEDS];
CRGB targetLeds[NUM_LEDS];

WebServer server(80);
DNSServer dnsServer;
Preferences prefs;

const byte DNS_PORT = 53;

/* ========== Defaults ========== */
const uint8_t DEFAULT_DAY_BRI_PERCENT = 70;
const uint8_t DEFAULT_NIGHT_BRI_PERCENT = 20;
const uint8_t DEFAULT_NIGHT_START = 22;
const uint8_t DEFAULT_NIGHT_END = 6;
const CRGB DEFAULT_COLOR = CRGB(255, 140, 0); // Ámbar por defecto (#ff8c00)

/* ========== Settings (Runtime) ========== */
uint8_t dayBrightPercent = DEFAULT_DAY_BRI_PERCENT;
uint8_t nightBrightPercent = DEFAULT_NIGHT_BRI_PERCENT;
uint8_t nightStartHour = DEFAULT_NIGHT_START;
uint8_t nightEndHour = DEFAULT_NIGHT_END;
CRGB WORD_COLOR = DEFAULT_COLOR;

/* Preference keys */
const char *P_NS = "nightStart";
const char *P_NE = "nightEnd";
const char *P_DB = "dayB";
const char *P_NB = "nightB";
const char *P_R = "rc";
const char *P_G = "gc";
const char *P_B = "bc";

/* ========== WIFI / AP Configuration Status ========== */
bool apActive = false;
bool clientConnected = false;
unsigned long apStartTime = 0;

/* Pulsing Variables */
int pulseValue = 10;
int pulseDir = 6;

/* LED parpadeo integrado */
unsigned long lastBuiltinBlink = 0;
bool builtinLedState = false;

/* Variable global de seguimiento de minutos */
uint8_t lastMinute = 255;

/* Status LED indices for the word "WIFI" (end of Row 4: 51, 52, 53, 54) */
const uint8_t WIFI_LEDS[4] = { 51, 52, 53, 54 };

/* ========== DEBUG ========== */
#define DEBUG_SERIAL 1   // Set to 0 to disable serial prints
String debugWords = "";  // Reconstructed in each buildTimeTarget()

inline void logW(const char *name) {
#if DEBUG_SERIAL
  debugWords += name;
  debugWords += " ";
#endif
}

/* ========== Word Mappings (11x14 Matrix Grid) ========== */
// Verbs / Articles / Hour "uno" (Row 0)
const uint8_t ES[] = {0, 1};
const uint8_t SON[] = {1, 2, 3};
const uint8_t LA[] = {5, 6};
const uint8_t LAS[] = {5, 6, 7};
const uint8_t UNA[] = {8, 9, 10};

// Minutes for "PARA" (Rows 1, 2, 3 - Zig-Zag serpentina)
const uint8_t VEINTICINCO_PARA[] = {21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11};
const uint8_t CINCO_PARA[] = {15, 14, 13, 12, 11};
const uint8_t DIEZ_PARA[] = {22, 23, 24, 25};
const uint8_t VEINTE_PARA[] = {26, 27, 28, 29, 30, 31};
const uint8_t CUARTO_PARA[] = {43, 42, 41, 40, 39, 38};
const uint8_t PARA[] = {36, 35, 34, 33};

// Articles for "PARA" (Row 4 - Par L->R)
const uint8_t LA_PARA[] = {44, 45};
const uint8_t LAS_PARA[] = {44, 45, 46};
const uint8_t UNA_PARA[] = {47, 48, 49};

// Hours (Rows 5 to 10)
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

// Conjunction "Y" (Row 10 - Par L->R)
const uint8_t Y[] = {115};

// Minutes for "Y" (Rows 11, 12, 13)
const uint8_t VEINTE_Y[] = {131, 130, 129, 128, 127, 126};
const uint8_t DIEZ_Y[] = {124, 123, 122, 121};
const uint8_t VEINTICINCO_Y[] = {132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142};
const uint8_t CINCO_Y[] = {138, 139, 140, 141, 142};
const uint8_t CUARTO_Y[] = {153, 152, 151, 150, 149, 148};
const uint8_t MEDIA[] = {147, 146, 145, 144, 143};

// Minute dots (indices 154-157)
const uint8_t MIN_LEDS[4] = { 154, 155, 156, 157 };

/* ========== Helper Functions ========== */

inline bool isWifiLed(uint8_t idx) {
  for (uint8_t i = 0; i < 4; i++) {
    if (WIFI_LEDS[i] == idx) return true;
  }
  return false;
}

void clearTarget() {
  fill_solid(targetLeds, NUM_LEDS, CRGB::Black);
}

void setW(const uint8_t *arr, uint8_t len, const char *name = nullptr) {
  for (uint8_t i = 0; i < len; i++) {
    uint8_t idx = arr[i];
    if (idx < NUM_LEDS && !isWifiLed(idx)) {
      targetLeds[idx] = WORD_COLOR;
    }
  }
  if (name) logW(name);
}

void setMinuteDotsTarget(uint8_t count) {
  for (uint8_t i = 0; i < 4; i++) {
    uint8_t idx = MIN_LEDS[i];
    if (idx < NUM_LEDS) {
      targetLeds[idx] = (i < count) ? WORD_COLOR : CRGB::Black;
    }
  }
}

/* ========== Lectura del Hardware RTC Grove DS1307 ========== */
DateTime getValidRtcDateTime() {
  DateTime now = rtc.now();

  // Verificación de rango BCD seguro (Hora 0-23, Minuto 0-59, Mes 1-12, Año 2024-2099)
  if (now.hour() > 23 || now.minute() > 59 || now.month() == 0 || now.month() > 12 || now.year() < 2024 || now.year() > 2099) {
    static unsigned long lastFixTime = 0;
    if (millis() - lastFixTime > 5000) {
      lastFixTime = millis();
#if DEBUG_SERIAL
      Serial.println(F("[ALERTA DS1307] Lectura BCD fuera de rango. Inicializando registros con hora de compilación..."));
#endif
      rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));
      delay(30);
      now = rtc.now();
    }
  }
  return now;
}

/* ========== Diagnóstico Detallado en Puerto Serial ========== */
void printStartupDiagnostics() {
#if DEBUG_SERIAL
  Serial.println(F("\n=========================================================="));
  Serial.println(F("   WORDCLOCK - DIAGNOSTICO DE INICIALIZACION Y HARDWARE    "));
  Serial.println(F("   Placa: Seeed Studio XIAO ESP32-C6 + LED Driver Board  "));
  Serial.println(F("=========================================================="));

  // 1. Diagnóstico del Procesador ESP32-C6
  Serial.printf("[DIAGNOSTICO] Frecuencia CPU: %d MHz | Memoria Heap Libre: %d bytes\n",
                ESP.getCpuFreqMHz(), ESP.getFreeHeap());

  // 2. Escaneo del Bus I2C en la dirección 0x68 (DS1307)
  Wire.beginTransmission(0x68);
  byte i2cErr = Wire.endTransmission();

  if (i2cErr == 0) {
    Serial.println(F("[OK] Bus I2C (100 kHz): Módulo Grove DS1307 detectado en dirección 0x68."));
  } else {
    Serial.printf("[ERROR] Bus I2C: No respondió dirección 0x68 (Código I2C: %d)\n", i2cErr);
  }

  if (rtc.begin()) {
    Serial.println(F("[OK] Librería RTClib: Comunicación con Grove DS1307 correcta."));
    if (!rtc.isrunning()) {
      Serial.println(F("[ALERTA] Oscilador RTC: DS1307 inactivo (CH bit=1). Inicializando hora de compilación..."));
      rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));
      delay(30);
    } else {
      Serial.println(F("[OK] Oscilador RTC: DS1307 activo y corriendo."));
    }

    DateTime now = getValidRtcDateTime();
    Serial.printf("[INFO] Hora leída del Grove DS1307: %02d:%02d:%02d  %02d/%02d/%04d\n",
                  now.hour(), now.minute(), now.second(),
                  now.day(), now.month(), now.year());
  } else {
    Serial.println(F("[ERROR] Librería RTClib: Falló rtc.begin() para DS1307. Verifique VCC 5V y conector Grove."));
  }

  // 3. Diagnóstico de FastLED
  Serial.printf("[OK] FastLED: Inicializado en Pin D0 (GPIO %d) para %d LEDs.\n", DATA_PIN, NUM_LEDS);

  // 4. Diagnóstico del LED Integrado
  Serial.printf("[OK] LED Integrado XIAO: Configurado en GPIO %d (Parpadeo durante WiFi AP).\n", LED_PIN_BUILTIN);

  // 5. Diagnóstico de Preferencias Guardadas
  Serial.printf("[OK] Ajustes NVS: Brillo Día=%d%%, Brillo Noche=%d%% (%02dh-%02dh), Color RGB=(%d,%d,%d)\n",
                dayBrightPercent, nightBrightPercent, nightStartHour, nightEndHour,
                WORD_COLOR.r, WORD_COLOR.g, WORD_COLOR.b);

  // 6. Diagnóstico del Punto de Acceso WiFi
  Serial.print(F("[OK] Captive Portal WiFi AP: SSID 'WORDCLOCK-SETUP' | IP: "));
  Serial.println(WiFi.softAPIP());
  Serial.println(F("==========================================================\n"));
#endif
}

void printDebugStatus(int hourVal, int minuteVal) {
#if DEBUG_SERIAL
  DateTime now = getValidRtcDateTime();
  Serial.println(F("---------------------------------"));
  Serial.printf("Grove DS1307 RTC ahora: %02d:%02d:%02d  %02d/%02d/%04d\n",
                now.hour(), now.minute(), now.second(),
                now.day(), now.month(), now.year());
  Serial.printf("Hora solicitada para render: %02d:%02d\n", hourVal, minuteVal);
  Serial.print(F("Oración desplegada: "));
  Serial.println(debugWords);

  Serial.print(F("LEDs activos (excluyendo WIFI): "));
  bool first = true;
  for (int i = 0; i < NUM_LEDS; i++) {
    if (targetLeds[i].r != 0 || targetLeds[i].g != 0 || targetLeds[i].b != 0) {
      if (!first) Serial.print(", ");
      Serial.print(i);
      first = false;
    }
  }
  Serial.println();
  Serial.println(F("---------------------------------"));
#endif
}

/* ========== Crossfade Animation ========== */
void crossFade(uint8_t steps = 45, uint16_t delayMs = 18) {
  for (uint8_t s = 0; s <= steps; s++) {
    uint8_t amt = (255 * s) / steps;
    for (int i = 0; i < NUM_LEDS; i++) {
      leds[i] = blend(leds[i], targetLeds[i], amt);
    }
    FastLED.show();
    delay(delayMs);
  }
}

/* ========== Hour mapping helper ========== */
void hour(uint8_t h) {
  switch (h) {
    case 1: setW(UNA, 3, "UNA"); break;
    case 2: setW(DOS, 3, "DOS"); break;
    case 3: setW(TRES, 4, "TRES"); break;
    case 4: setW(CUATRO, 6, "CUATRO"); break;
    case 5: setW(CINCO_H, 5, "CINCO"); break;
    case 6: setW(SEIS, 4, "SEIS"); break;
    case 7: setW(SIETE, 5, "SIETE"); break;
    case 8: setW(OCHO, 4, "OCHO"); break;
    case 9: setW(NUEVE, 5, "NUEVE"); break;
    case 10: setW(DIEZ_H, 4, "DIEZ"); break;
    case 11: setW(ONCE, 4, "ONCE"); break;
    case 12: setW(DOCE, 4, "DOCE"); break;
  }
}

bool isNightHour(uint8_t hour) {
  if (nightStartHour == nightEndHour) return false;
  if (nightStartHour < nightEndHour) {
    return (hour >= nightStartHour && hour < nightEndHour);
  } else {
    return (hour >= nightStartHour || hour < nightEndHour);
  }
}

/* ========== Time -> LED mapping generator ========== */
void buildTimeTarget(int hourVal, int minuteVal) {
  debugWords = "";

  // Day/Night brightness auto adjustment
  uint8_t effectivePercent = isNightHour(hourVal) ? nightBrightPercent : dayBrightPercent;
  uint8_t brightnessVal = map(effectivePercent, 0, 100, 0, 255);
  FastLED.setBrightness(brightnessVal);

  clearTarget();

  uint8_t rounded = (minuteVal / 5) * 5;
  uint8_t extra = minuteVal % 5;

  uint8_t h = hourVal % 12;
  if (h == 0) h = 12;

  uint8_t nextHour = (h % 12) + 1;

  if (rounded >= 35) {
    // --- "PARA" MINUTES BLOCK (35 to 59) ---
    setW(SON, 3, "SON");
    switch (rounded) {
      case 35:
        setW(VEINTICINCO_PARA, 11, "VEINTICINCO");
        setW(PARA, 4, "PARA");
        break;
      case 40:
        setW(VEINTE_PARA, 6, "VEINTE");
        setW(PARA, 4, "PARA");
        break;
      case 45:
        setW(CUARTO_PARA, 6, "CUARTO");
        setW(PARA, 4, "PARA");
        break;
      case 50:
        setW(DIEZ_PARA, 4, "DIEZ");
        setW(PARA, 4, "PARA");
        break;
      case 55:
        setW(CINCO_PARA, 5, "CINCO");
        setW(PARA, 4, "PARA");
        break;
    }

    // Article before the hour: "LA" if next hour is 1, "LAS" for others
    if (nextHour == 1) {
      setW(LA_PARA, 2, "LA");
    } else {
      setW(LAS_PARA, 3, "LAS");
    }

    // Next hour
    if (nextHour == 1) {
      setW(UNA_PARA, 3, "UNA");
    } else {
      hour(nextHour);
    }

  } else {
    // --- "Y" OR ON-THE-HOUR MINUTES BLOCK (0 to 34) ---
    // Verb + Article: "ES LA" if hour is 1, "SON LAS" for others
    if (h == 1) {
      setW(ES, 2, "ES");
      setW(LA, 2, "LA");
    } else {
      setW(SON, 3, "SON");
      setW(LAS, 3, "LAS");
    }

    // Current hour
    hour(h);

    // Minutes additions
    switch (rounded) {
      case 5:
        setW(Y, 1, "Y");
        setW(CINCO_Y, 5, "CINCO");
        break;
      case 10:
        setW(Y, 1, "Y");
        setW(DIEZ_Y, 4, "DIEZ");
        break;
      case 15:
        setW(Y, 1, "Y");
        setW(CUARTO_Y, 6, "CUARTO");
        break;
      case 20:
        setW(Y, 1, "Y");
        setW(VEINTE_Y, 6, "VEINTE");
        break;
      case 25:
        setW(Y, 1, "Y");
        setW(VEINTICINCO_Y, 11, "VEINTICINCO");
        break;
      case 30:
        setW(Y, 1, "Y");
        setW(MEDIA, 5, "MEDIA");
        break;
    }
  }

  uint8_t dotsToLight = (minuteVal >= 35) ? (4 - extra) : extra;
  setMinuteDotsTarget(dotsToLight);
  printDebugStatus(hourVal, minuteVal);
}

/* ========== WiFi Captive Portal WebServer ========== */

String makePageHtml() {
  char colorHex[8];
  sprintf(colorHex, "#%02X%02X%02X", WORD_COLOR.r, WORD_COLOR.g, WORD_COLOR.b);

  DateTime now = getValidRtcDateTime();
  int curY = now.year();
  int curM = now.month();
  int curD = now.day();
  int curH = now.hour();
  int curMin = now.minute();

  char rtcBuf[64];
  sprintf(rtcBuf, "%02d/%02d/%04d %02d:%02d:%02d",
          curD, curM, curY, curH, curMin, now.second());

  String html = R"rawliteral(
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Word Clock Config</title>
<style>
@import url('https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700&display=swap');
body {
  margin: 0;
  background: #0d0f12;
  color: #f0f3f6;
  font-family: 'Outfit', sans-serif;
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  padding: 15px;
  box-sizing: border-box;
}
.container {
  max-width: 400px;
  width: 100%;
  background: rgba(22, 26, 33, 0.85);
  border: 1px solid rgba(255, 255, 255, 0.08);
  backdrop-filter: blur(16px);
  border-radius: 20px;
  padding: 20px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.5);
  box-sizing: border-box;
}
h1 {
  text-align: center;
  font-size: 1.5rem;
  font-weight: 700;
  margin-top: 5px;
  margin-bottom: 4px;
  background: linear-gradient(135deg, #f0f3f6 0%, #8b949e 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}
.subtitle {
  text-align: center;
  font-size: 0.78rem;
  color: #6e7681;
  margin-bottom: 12px;
}
.status-banner {
  background: rgba(16, 185, 129, 0.15);
  border: 1px solid rgba(16, 185, 129, 0.3);
  padding: 8px 12px;
  border-radius: 10px;
  text-align: center;
  margin-bottom: 15px;
  color: #34d399;
  font-size: 0.8rem;
  font-family: monospace;
  font-weight: bold;
}
.card {
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.05);
  padding: 12px 14px;
  border-radius: 12px;
  margin-bottom: 12px;
}
label {
  font-size: 0.85rem;
  font-weight: 600;
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 6px;
  color: #8b949e;
}
.val-display {
  color: #38bdf8;
  font-family: monospace;
  font-weight: bold;
}
input[type=color] {
  width: 100%;
  height: 36px;
  border: none;
  background: none;
  cursor: pointer;
  padding: 0;
}
.swatches {
  display: flex;
  gap: 8px;
  margin-top: 8px;
  justify-content: space-between;
}
.swatch {
  width: 22px;
  height: 22px;
  border-radius: 50%;
  cursor: pointer;
  border: 2px solid transparent;
  transition: transform 0.2s, border-color 0.2s;
}
.swatch:hover { transform: scale(1.15); }
.swatch.active { border-color: #ffffff; }

input[type=range] {
  width: 100%;
  height: 4px;
  background: #2a313d;
  outline: none;
  border-radius: 2px;
  -webkit-appearance: none;
  margin: 8px 0 4px 0;
}
input[type=range]::-webkit-slider-thumb {
  -webkit-appearance: none;
  width: 16px;
  height: 16px;
  border-radius: 50%;
  background: #38bdf8;
  cursor: pointer;
}
.row {
  display: flex;
  gap: 12px;
}
.small-input {
  width: 100%;
  height: 34px;
  background: #1c212b;
  border: 1px solid rgba(255,255,255,0.08);
  border-radius: 6px;
  color: #fff;
  font-size: 0.9rem;
  text-align: center;
}
.small-input:focus {
  outline: none;
  border-color: #38bdf8;
}
.rtc-box {
  text-align: center;
  background: rgba(0, 0, 0, 0.3);
  padding: 8px;
  border-radius: 6px;
  font-family: monospace;
  font-size: 0.85rem;
  color: #38bdf8;
  margin: 6px 0 10px 0;
  border: 1px solid rgba(56, 189, 248, 0.15);
}
.btn-save {
  width: 100%;
  background: #38bdf8;
  color: #0f1115;
  border: none;
  padding: 11px;
  border-radius: 10px;
  font-size: 0.9rem;
  font-weight: bold;
  cursor: pointer;
  transition: background 0.2s;
  margin-top: 5px;
}
.btn-save:hover { background: #7dd3fc; }

.btn-sync {
  width: 100%;
  background: #2a313d;
  color: #f0f3f6;
  border: none;
  padding: 8px;
  border-radius: 8px;
  font-size: 0.8rem;
  font-weight: bold;
  cursor: pointer;
  transition: background 0.2s;
}
.btn-sync:hover { background: #374151; }
</style>
</head>
<body>
<div class="container">
  <h1>Word Clock Config</h1>
  <div class="subtitle">Seeed Studio XIAO ESP32-C6 + Grove DS1307</div>
  <div class="status-banner">CONECTADO: WORDCLOCK-SETUP</div>

  <form action="/save" method="POST">
    <div class="card">
      <label>Color de LEDs</label>
      <input type="color" id="colPicker" name="color" value=")rawliteral" + String(colorHex) + R"rawliteral(">
      <div class="swatches">
        <div class="swatch" style="background:#ff8c00" title="Ámbar" onclick="setCol('#ff8c00')"></div>
        <div class="swatch" style="background:#00e5ff" title="Cian" onclick="setCol('#00e5ff')"></div>
        <div class="swatch" style="background:#ff2a85" title="Rosa" onclick="setCol('#ff2a85')"></div>
        <div class="swatch" style="background:#10b981" title="Verde" onclick="setCol('#10b981')"></div>
        <div class="swatch" style="background:#a855f7" title="Púrpura" onclick="setCol('#a855f7')"></div>
        <div class="swatch" style="background:#f1f5f9" title="Blanco" onclick="setCol('#f1f5f9')"></div>
      </div>
    </div>

    <div class="card">
      <label>Brillo Diurno <span class="val-display"><span id="dayVal">)rawliteral" + String(dayBrightPercent) + R"rawliteral(</span>%</span></label>
      <input type="range" name="dayB" min="1" max="100" value=")rawliteral" + String(dayBrightPercent) + R"rawliteral(" oninput="document.getElementById('dayVal').innerText=this.value">
    </div>

    <div class="card">
      <label>Brillo Nocturno <span class="val-display"><span id="nightVal">)rawliteral" + String(nightBrightPercent) + R"rawliteral(</span>%</span></label>
      <input type="range" name="nightB" min="0" max="100" value=")rawliteral" + String(nightBrightPercent) + R"rawliteral(" oninput="document.getElementById('nightVal').innerText=this.value">
    </div>

    <div class="card">
      <label>Modo Nocturno (Inicio / Fin)</label>
      <div class="row">
        <div style="flex:1;">
          <span style="font-size:0.75rem; color:#8b949e; display:block; margin-bottom:4px;">Inicio (Hora 0-23)</span>
          <input type="number" class="small-input" name="nightStart" min="0" max="23" value=")rawliteral" + String(nightStartHour) + R"rawliteral(">
        </div>
        <div style="flex:1;">
          <span style="font-size:0.75rem; color:#8b949e; display:block; margin-bottom:4px;">Fin (Hora 0-23)</span>
          <input type="number" class="small-input" name="nightEnd" min="0" max="23" value=")rawliteral" + String(nightEndHour) + R"rawliteral(">
        </div>
      </div>
    </div>

    <button type="submit" class="btn-save">Guardar y Reiniciar Reloj</button>
  </form>

  <div class="card" style="margin-top:12px;">
    <label>Hora Sincronizada RTC Grove DS1307</label>
    <div class="rtc-box" id="rtcDisplay">)rawliteral" + String(rtcBuf) + R"rawliteral(</div>
    <button type="button" class="btn-sync" onclick="syncPhoneTime()">Sincronizar Hora Teléfono</button>
  </div>
</div>

<script>
function setCol(hex) {
  document.getElementById('colPicker').value = hex;
}
function syncPhoneTime() {
  const d = new Date();
  const y = d.getFullYear();
  const m = d.getMonth() + 1;
  const day = d.getDate();
  const h = d.getHours();
  const min = d.getMinutes();
  const s = d.getSeconds();

  window.location.href = `/settime?y=${y}&m=${m}&d=${day}&h=${h}&min=${min}&s=${s}`;
}
</script>
</body>
</html>
)rawliteral";

  return html;
}

/* ========== Load/Save Settings using Preferences ========== */
void loadSettings() {
  prefs.begin("wordclock", true);
  dayBrightPercent = prefs.getUChar(P_DB, DEFAULT_DAY_BRI_PERCENT);
  nightBrightPercent = prefs.getUChar(P_NB, DEFAULT_NIGHT_BRI_PERCENT);
  nightStartHour = prefs.getUChar(P_NS, DEFAULT_NIGHT_START);
  nightEndHour = prefs.getUChar(P_NE, DEFAULT_NIGHT_END);

  uint8_t r = prefs.getUChar(P_R, DEFAULT_COLOR.r);
  uint8_t g = prefs.getUChar(P_G, DEFAULT_COLOR.g);
  uint8_t b = prefs.getUChar(P_B, DEFAULT_COLOR.b);
  WORD_COLOR = CRGB(r, g, b);
  prefs.end();
}

void saveSettings() {
  prefs.begin("wordclock", false);
  prefs.putUChar(P_DB, dayBrightPercent);
  prefs.putUChar(P_NB, nightBrightPercent);
  prefs.putUChar(P_NS, nightStartHour);
  prefs.putUChar(P_NE, nightEndHour);
  prefs.putUChar(P_R, WORD_COLOR.r);
  prefs.putUChar(P_G, WORD_COLOR.g);
  prefs.putUChar(P_B, WORD_COLOR.b);
  prefs.end();
}

/* ========== HTTP Handlers ========== */

void handleRoot() {
  server.send(200, "text/html", makePageHtml());
}

void handleSave() {
  if (server.hasArg("color")) {
    String hex = server.arg("color");
    if (hex.startsWith("#")) hex = hex.substring(1);
    long number = strtol(hex.c_str(), NULL, 16);
    WORD_COLOR.r = (number >> 16) & 0xFF;
    WORD_COLOR.g = (number >> 8) & 0xFF;
    WORD_COLOR.b = number & 0xFF;
  }
  if (server.hasArg("dayB")) dayBrightPercent = server.arg("dayB").toInt();
  if (server.hasArg("nightB")) nightBrightPercent = server.arg("nightB").toInt();
  if (server.hasArg("nightStart")) nightStartHour = server.arg("nightStart").toInt();
  if (server.hasArg("nightEnd")) nightEndHour = server.arg("nightEnd").toInt();

  saveSettings();

  // Reconstruir objetivo y copiar INMEDIATAMENTE al búfer físico de LEDs
  DateTime now = getValidRtcDateTime();
  buildTimeTarget(now.hour(), now.minute());

  for (int i = 0; i < NUM_LEDS; i++) {
    leds[i] = targetLeds[i];
  }
  applyWifiStatusVisuals();
  FastLED.show();

#if DEBUG_SERIAL
  Serial.printf("[HTTP CONFIG] Cambios de color/brillo aplicados INSTANTANEAMENTE: RGB=(%d,%d,%d), Brillo Día=%d%%\n",
                WORD_COLOR.r, WORD_COLOR.g, WORD_COLOR.b, dayBrightPercent);
#endif

  server.sendHeader("Location", "/");
  server.send(302, "text/plain", "Guardado");
}

void handleSetTime() {
  if (server.hasArg("y") && server.hasArg("m") && server.hasArg("d") &&
      server.hasArg("h") && server.hasArg("min") && server.hasArg("s")) {

    int y = server.arg("y").toInt();
    int m = server.arg("m").toInt();
    int d = server.arg("d").toInt();
    int h = server.arg("h").toInt();
    int min = server.arg("min").toInt();
    int s = server.arg("s").toInt();

    // Actualizar registros BCD del chip Grove DS1307
    rtc.adjust(DateTime(y, m, d, h, min, s));
    delay(30);

    lastMinute = min;
    buildTimeTarget(h, min);
    FastLED.show();

#if DEBUG_SERIAL
    Serial.printf("[HTTP] Hora sincronizada en el Grove DS1307 desde el teléfono: %02d:%02d:%02d %02d/%02d/%04d\n",
                  h, min, s, d, m, y);
#endif

    server.sendHeader("Location", "/");
    server.send(302, "text/plain", "Hora Sincronizada");
  } else {
    server.send(400, "text/plain", "Parametros insuficientes");
  }
}

/* ========== Start Captive AP ========== */
void startAP() {
  WiFi.mode(WIFI_AP);
  WiFi.softAP("WORDCLOCK-SETUP");
  apStartTime = millis();
  apActive = true;
  clientConnected = false;

  dnsServer.start(DNS_PORT, "*", WiFi.softAPIP());

  server.on("/", handleRoot);
  server.on("/save", HTTP_POST, handleSave);
  server.on("/settime", handleSetTime);
  server.onNotFound([]() {
    server.sendHeader("Location", "http://" + WiFi.softAPIP().toString() + "/");
    server.send(302, "text/plain", "Redirecting...");
  });

  server.begin();

#if DEBUG_SERIAL
  Serial.print(F("[WIFI] Punto de Acceso iniciado: 'WORDCLOCK-SETUP' | IP: "));
  Serial.println(WiFi.softAPIP());
#endif
}

/* ========== Manejo del LED Integrado XIAO y Efectos Visuales WiFi ========== */

void handleBuiltinLedStatus() {
  if (apActive) {
    if (millis() - lastBuiltinBlink >= 250) {
      lastBuiltinBlink = millis();
      builtinLedState = !builtinLedState;
      digitalWrite(LED_PIN_BUILTIN, builtinLedState ? LOW : HIGH);
    }
  } else {
    digitalWrite(LED_PIN_BUILTIN, HIGH);
  }
}

void applyWifiStatusVisuals() {
  if (apActive) {
    pulseValue += pulseDir;
    if (pulseValue >= 240 || pulseValue <= 15) {
      pulseDir = -pulseDir;
    }

    CRGB compColor = CRGB(255 - WORD_COLOR.r, 255 - WORD_COLOR.g, 255 - WORD_COLOR.b);
    if (compColor.r < 40 && compColor.g < 40 && compColor.b < 40) {
      compColor = CRGB(0, 190, 255);
    }
    CRGB pulsedColor = compColor;
    pulsedColor.nscale8_video(pulseValue);

    for (uint8_t i = 0; i < 4; i++) {
      leds[WIFI_LEDS[i]] = pulsedColor;
    }
  } else {
    for (uint8_t i = 0; i < 4; i++) {
      leds[WIFI_LEDS[i]] = targetLeds[WIFI_LEDS[i]];
    }
  }
}

void showTimeAndFade(int h, int m) {
  buildTimeTarget(h, m);
  crossFade(40, 15);
}

/* ========== Startup Boot Animation (Multicolor Matrix Rain REVEALS Words AT THE END) ========== */
void startAnimation() {
  fill_solid(leds, NUM_LEDS, CRGB::Black);
  FastLED.setBrightness(230);

  struct RainDrop {
    int col;
    float y;
    float speed;
    uint8_t hue;
    uint8_t tailLen;
  };

  RainDrop drops[11];
  for (int c = 0; c < 11; c++) {
    drops[c].col = c;
    drops[c].y = -random(10);
    drops[c].speed = 0.28 + (random(28) / 100.0);
    drops[c].hue = random8();
    drops[c].tailLen = 4 + random(3);
  }

  bool revealed[NUM_LEDS] = {false};
  unsigned long startT = millis();
  const unsigned long totalDuration = 7800;   // 7.8 segundos totales de animación
  const unsigned long revealStartTime = 5000;  // Revelar las palabras a los 5.0s (barrido final de 2.8s)

  while (millis() - startT < totalDuration) {
    unsigned long elapsed = millis() - startT;
    bool isRevealPhase = (elapsed >= revealStartTime);

    // Atenuación paulatina de la estela de gotas en LEDs no revelados
    for (int i = 0; i < 154; i++) {
      if (revealed[i]) {
        leds[i] = targetLeds[i];
      } else {
        leds[i].nscale8_video(198);
      }
    }

    // Desplazar y regenerar gotas verticalmente por cada columna
    for (int c = 0; c < 11; c++) {
      drops[c].y += drops[c].speed;

      if (drops[c].y - drops[c].tailLen > 14) {
        drops[c].y = -random(5);
        drops[c].hue = random8();
        drops[c].speed = 0.28 + (random(28) / 100.0);
      }

      int headY = (int)drops[c].y;
      for (int t = 0; t < drops[c].tailLen; t++) {
        int r = headY - t;
        if (r >= 0 && r < 14) {
          // Mapeo Serpentina (Filas impares R->L, Filas pares L->R)
          uint8_t physicalCol = (r % 2 == 1) ? (10 - drops[c].col) : drops[c].col;
          int idx = r * 11 + physicalCol;

          if (idx < 154) {
            // Durante la fase de revelado final (seg 5.0 a 7.8), al tocar la gota una letra objetivo, la revela
            if (isRevealPhase && t == 0 && (targetLeds[idx].r != 0 || targetLeds[idx].g != 0 || targetLeds[idx].b != 0)) {
              revealed[idx] = true;
            }

            if (revealed[idx]) {
              leds[idx] = targetLeds[idx];
            } else {
              uint8_t val = (t == 0) ? 255 : (210 - t * 38);
              uint8_t dropHue = drops[c].hue + (t * 12);
              leds[idx] = CHSV(dropHue, 255, val);
            }
          }
        }
      }
    }
    FastLED.show();
    delay(40);
  }

  // Al terminar los 7.8 segundos, asegurar que la hora quede 100% limpia y brillante
  for (int i = 0; i < NUM_LEDS; i++) {
    if (targetLeds[i].r != 0 || targetLeds[i].g != 0 || targetLeds[i].b != 0) {
      leds[i] = targetLeds[i];
    } else {
      leds[i] = CRGB::Black;
    }
  }
  FastLED.show();
}

/* ========== Arduino Setup & Main Loop ========== */

void setup() {
  Serial.begin(115200);
  delay(150);

  // Configuración del LED Integrado de la placa XIAO ESP32-C6
  pinMode(LED_PIN_BUILTIN, OUTPUT);
  digitalWrite(LED_PIN_BUILTIN, HIGH); // Apagado inicial

  // Inicialización del bus I2C nativo de la placa XIAO ESP32-C6 a 100 kHz
  Wire.begin();
  Wire.setClock(I2C_SPEED_DS1307);

  // Inicialización de la tira de LEDs en el pin D0 (GPIO 0) del Seeed LED Driver Board
  FastLED.addLeds<WS2812B, DATA_PIN, GRB>(leds, NUM_LEDS);
  fill_solid(leds, NUM_LEDS, CRGB::Black);
  fill_solid(targetLeds, NUM_LEDS, CRGB::Black);

  loadSettings();

  // Imprimir Banner Completo de Diagnóstico de Inicialización
  printStartupDiagnostics();

  // Dibuja la hora inicial obtenida del módulo Grove DS1307 antes de iniciar la animación de revelado
  DateTime now = getValidRtcDateTime();
  lastMinute = now.minute();
  buildTimeTarget(now.hour(), now.minute());

  startAnimation();
  startAP();

  applyWifiStatusVisuals();
  FastLED.show();
}

void loop() {
  dnsServer.processNextRequest();
  server.handleClient();

  // Control del parpadeo del LED Integrado del XIAO durante WiFi activo
  handleBuiltinLedStatus();

  if (apActive) {
    int stations = WiFi.softAPgetStationNum();
    if (stations > 0) {
      clientConnected = true;
    }

    // Access Point timeout: shutdown after 60 seconds if no user connects
    if (!clientConnected && (millis() - apStartTime > 60000UL)) {
      dnsServer.stop();
      WiFi.softAPdisconnect(true);
      apActive = false;
      clientConnected = false;
#if DEBUG_SERIAL
      Serial.println(F("[WIFI] AP apagado por tiempo límite (60s sin clientes)."));
#endif
    }

    // Access Point shutdown: client disconnected
    if (clientConnected && (WiFi.softAPgetStationNum() == 0) && (millis() - apStartTime > 500)) {
      dnsServer.stop();
      WiFi.softAPdisconnect(true);
      apActive = false;
      clientConnected = false;
#if DEBUG_SERIAL
      Serial.println(F("[WIFI] AP apagado: Cliente desconectado."));
#endif
    }
  }

  applyWifiStatusVisuals();

  // Tick time loop (check minutes)
  DateTime now = getValidRtcDateTime();
  if (now.minute() != lastMinute) {
    lastMinute = now.minute();
    showTimeAndFade(now.hour(), now.minute());
  } else {
    FastLED.show();
  }

  delay(60);
}
