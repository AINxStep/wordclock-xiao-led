// Matrix Configuration and Letter Grid (14 rows x 11 columns)
const MATRIX_TEXT = [
  "E", "S", "O", "N", "X", "L", "A", "S", "U", "N", "A", // Fila 0 (0-10)
  "V", "E", "I", "N", "T", "I", "C", "I", "N", "C", "O", // Fila 1 (11-21) - Block PARA
  "D", "I", "E", "Z", "V", "E", "I", "N", "T", "E", "G", // Fila 2 (22-32) - Block PARA
  "C", "U", "A", "R", "T", "O", "K", "P", "A", "R", "A", // Fila 3 (33-43) - Block PARA
  "L", "A", "S", "U", "N", "A", "Z", "W", "I", "F", "I", // Fila 4 (44-54) - Block PARA (LA / LAS / UNA) & WIFI
  "T", "R", "E", "S", "Z", "B", "G", "K", "D", "O", "S", // Fila 5 (55-65) - Hours
  "C", "U", "A", "T", "R", "O", "C", "I", "N", "C", "O", // Fila 6 (66-76)
  "U", "S", "E", "I", "S", "O", "S", "I", "E", "T", "E", // Fila 7 (77-87)
  "O", "C", "H", "O", "N", "U", "E", "V", "E", "N", "V", // Fila 8 (88-98)
  "D", "I", "E", "Z", "D", "S", "O", "N", "C", "E", "A", // Fila 9 (99-109)
  "D", "O", "C", "E", "L", "Y", "E", "I", "J", "K", "V", // Fila 10 (110-120)
  "V", "E", "I", "N", "T", "E", "Z", "D", "I", "E", "Z", // Fila 11 (121-131) - Block Y
  "V", "E", "I", "N", "T", "I", "C", "I", "N", "C", "O", // Fila 12 (132-142) - Block Y
  "C", "U", "A", "R", "T", "O", "M", "E", "D", "I", "A"  // Fila 13 (143-153) - Block Y
];

// LED index mappings for each word (0-indexed, left-to-right, row-by-row)
const WORDS = {
  // Verbs / Articles / Hour "uno" (Row 0)
  ES: [0, 1],
  SON: [1, 3],
  LA: [5, 6],
  LAS: [5, 7],
  UNA: [8, 10],

  // Minutes for "PARA" (Rows 1, 2, 3)
  VEINTICINCO_PARA: [11, 21],
  CINCO_PARA: [17, 21],
  DIEZ_PARA: [22, 25],
  VEINTE_PARA: [26, 31],
  CUARTO_PARA: [33, 38],
  PARA: [40, 43],

  // Articles for "PARA" (Row 4)
  LA_PARA: [44, 45],
  LAS_PARA: [44, 46],
  UNA_PARA: [47, 49],

  // Hours (Rows 5 to 10)
  TRES: [55, 58],
  DOS: [63, 65],
  CUATRO: [66, 71],
  CINCO_H: [72, 76],
  SEIS: [78, 81],
  SIETE: [83, 87],
  OCHO: [88, 91],
  NUEVE: [92, 96],
  DIEZ_H: [99, 102],
  ONCE: [105, 108],
  DOCE: [110, 113],

  // Conjunction "Y" (Row 10)
  Y: [115, 115],

  // Minutes for "Y" (Rows 11, 12, 13)
  VEINTE_Y: [121, 126],
  DIEZ_Y: [128, 131],
  VEINTICINCO_Y: [132, 142],
  CINCO_Y: [138, 142],
  CUARTO_Y: [143, 148],
  MEDIA: [149, 153]
};

// Map display hour to word key
const HOUR_WORDS = {
  1: "UNA",
  2: "DOS",
  3: "TRES",
  4: "CUATRO",
  5: "CINCO_H",
  6: "SEIS",
  7: "SIETE",
  8: "OCHO",
  9: "NUEVE",
  10: "DIEZ_H",
  11: "ONCE",
  12: "DOCE"
};

// UI Elements
const gridContainer = document.getElementById("matrix-grid");
const realtimeToggle = document.getElementById("realtime-toggle");
const timeSlider = document.getElementById("time-slider");
const timeDisplay = document.getElementById("time-display");
const manualTimeInputs = document.getElementById("manual-time-inputs");
const hourInput = document.getElementById("hour-input");
const minuteInput = document.getElementById("minute-input");
const colorPresets = document.getElementById("color-presets");
const activeWordsList = document.getElementById("active-words");
const wifiButtons = document.querySelectorAll(".wifi-btn");

let wifiActiveLeds = 0; // how many wifi LEDs to light up
let isAnimating = false; // block updates during startup animation
let currentActiveColor = "#ff8c00"; // store the currently selected clock color

// Initialize Grid HTML
function initGrid() {
  gridContainer.innerHTML = "";
  MATRIX_TEXT.forEach((char, index) => {
    const cell = document.createElement("div");
    cell.classList.add("cell");
    cell.textContent = char;
    cell.setAttribute("data-index", index);
    
    // Wifi cells are indices 51, 52, 53, 54 in Row 4
    if (index >= 51 && index <= 54) {
      cell.classList.add("wifi-cell");
    }
    
    gridContainer.appendChild(cell);
  });
}

// Translate HH:MM to list of active word keys
function timeToWords(hours, minutes) {
  const activeKeys = [];
  
  // Convert hours to 12-hour format
  let currentHour = hours % 12;
  if (currentHour === 0) currentHour = 12;
  
  // Next hour for the "PARA" section
  let nextHour = (hours + 1) % 12;
  if (nextHour === 0) nextHour = 12;

  // Determine 5-minute interval block
  const block = Math.floor(minutes / 5) * 5;

  if (block >= 35) {
    // --- "PARA" MINUTES BLOCK (35 to 59) ---
    activeKeys.push("SON");
    switch (block) {
      case 35:
        activeKeys.push("VEINTICINCO_PARA", "PARA");
        break;
      case 40:
        activeKeys.push("VEINTE_PARA", "PARA");
        break;
      case 45:
        activeKeys.push("CUARTO_PARA", "PARA");
        break;
      case 50:
        activeKeys.push("DIEZ_PARA", "PARA");
        break;
      case 55:
        activeKeys.push("CINCO_PARA", "PARA");
        break;
    }

    // Article before the hour: "LA" if next hour is 1, "LAS" for others
    if (nextHour === 1) {
      activeKeys.push("LA_PARA");
    } else {
      activeKeys.push("LAS_PARA");
    }

    // Next hour
    if (nextHour === 1) {
      activeKeys.push("UNA_PARA");
    } else {
      activeKeys.push(HOUR_WORDS[nextHour]);
    }

  } else {
    // --- "Y" OR ON-THE-HOUR MINUTES BLOCK (0 to 34) ---
    // Verb + Article: "ES LA" if hour is 1, "SON LAS" for others
    if (currentHour === 1) {
      activeKeys.push("ES", "LA");
    } else {
      activeKeys.push("SON", "LAS");
    }

    // Current hour
    activeKeys.push(HOUR_WORDS[currentHour]);

    // Minutes additions
    switch (block) {
      case 5:
        activeKeys.push("Y", "CINCO_Y");
        break;
      case 10:
        activeKeys.push("Y", "DIEZ_Y");
        break;
      case 15:
        activeKeys.push("Y", "CUARTO_Y");
        break;
      case 20:
        activeKeys.push("Y", "VEINTE_Y");
        break;
      case 25:
        activeKeys.push("Y", "VEINTICINCO_Y");
        break;
      case 30:
        activeKeys.push("Y", "MEDIA");
        break;
    }
  }

  return activeKeys;
}

// Update the simulated clock display
function updateClock(hours, minutes) {
  if (isAnimating) return;
  // Format leading zeros
  const formattedTime = `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}`;
  timeDisplay.textContent = formattedTime;

  // Clear previous active states
  document.querySelectorAll(".cell.active").forEach(cell => {
    cell.classList.remove("active");
  });
  document.querySelectorAll(".dot.active").forEach(dot => {
    dot.classList.remove("active");
  });

  // Get active word keys
  const activeKeys = timeToWords(hours, minutes);

  // Light up matrix letters
  activeKeys.forEach(key => {
    const range = WORDS[key];
    if (range) {
      const [start, end] = range;
      for (let i = start; i <= end; i++) {
        const cell = document.querySelector(`.cell[data-index="${i}"]`);
        if (cell) cell.classList.add("active");
      }
    }
  });

  // Light up minute dots (+1, +2, +3, +4 minutes)
  const extra = minutes % 5;
  const dotsToLight = (minutes >= 35) ? (4 - extra) : extra;
  for (let i = 1; i <= 4; i++) {
    const dot = document.getElementById(`dot-${i}`);
    if (dot) {
      if (i <= dotsToLight) dot.classList.add("active");
      else dot.classList.remove("active");
    }
  }

  // Light up WIFI indicators
  for (let i = 51; i < 51 + wifiActiveLeds; i++) {
    const cell = document.querySelector(`.cell[data-index="${i}"]`);
    if (cell) cell.classList.add("active");
  }

  // Update Active Words sidebar badge list
  activeWordsList.innerHTML = "";
  if (activeKeys.length === 0) {
    activeWordsList.innerHTML = "<span style='color: var(--text-secondary); font-size: 0.9rem;'>Ninguna</span>";
  } else {
    activeKeys.forEach(key => {
      const badge = document.createElement("span");
      badge.classList.add("word-badge");
      
      // Make badge label user friendly
      let label = key.replace("_PARA", "").replace("_Y", "").replace("_H", "");
      if (label === "LA_PARA") label = "LA";
      if (label === "LAS_PARA") label = "LAS";
      
      const range = WORDS[key];
      badge.textContent = `${label} (${range[0]}-${range[1]})`;
      activeWordsList.appendChild(badge);
    });
  }
  updateClockBrightness();
}

// Tick function for real-time mode
function tick() {
  if (isAnimating) return;
  if (realtimeToggle.checked) {
    const now = new Date();
    const hours = now.getHours();
    const minutes = now.getMinutes();
    
    updateClock(hours, minutes);
    
    // Update controls to reflect real time
    const totalMinutes = hours * 60 + minutes;
    timeSlider.value = totalMinutes;
    hourInput.value = hours;
    minuteInput.value = minutes;
  }
}

// Event Listeners for controls
realtimeToggle.addEventListener("change", (e) => {
  const isRealtime = e.target.checked;
  timeSlider.disabled = isRealtime;
  
  if (isRealtime) {
    manualTimeInputs.style.opacity = "0.5";
    manualTimeInputs.style.pointerEvents = "none";
    tick();
  } else {
    manualTimeInputs.style.opacity = "1";
    manualTimeInputs.style.pointerEvents = "auto";
  }
});

timeSlider.addEventListener("input", (e) => {
  if (!realtimeToggle.checked) {
    const totalMinutes = parseInt(e.target.value);
    const hours = Math.floor(totalMinutes / 60);
    const minutes = totalMinutes % 60;
    
    hourInput.value = hours;
    minuteInput.value = minutes;
    updateClock(hours, minutes);
  }
});

function handleManualInputChange() {
  let hours = parseInt(hourInput.value) || 0;
  let minutes = parseInt(minuteInput.value) || 0;
  
  // Clamp values
  if (hours < 0) hours = 0;
  if (hours > 23) hours = 23;
  if (minutes < 0) minutes = 0;
  if (minutes > 59) minutes = 59;
  
  hourInput.value = hours;
  minuteInput.value = minutes;
  
  const totalMinutes = hours * 60 + minutes;
  timeSlider.value = totalMinutes;
  
  updateClock(hours, minutes);
}

hourInput.addEventListener("change", handleManualInputChange);
minuteInput.addEventListener("change", handleManualInputChange);

// // Color preset listeners
colorPresets.addEventListener("click", (e) => {
  const swatch = e.target.closest(".color-swatch");
  if (!swatch) return;
  
  const color = swatch.getAttribute("data-color");
  updateActiveColor(color);
});

// Wifi simulator click listeners
document.querySelector(".wifi-switches").addEventListener("click", (e) => {
  const btn = e.target.closest(".wifi-btn");
  if (!btn) return;
  
  stopApMode(); // Turn off AP mode if user overrides WiFi manually

  document.querySelectorAll(".wifi-btn").forEach(b => b.classList.remove("active"));
  btn.classList.add("active");
  
  const level = parseInt(btn.getAttribute("data-level"));
  
  // Level mappings:
  // 0: Off -> 0 LEDs
  // 1: Bajo -> 1 LED (index 51)
  // 2: Medio -> 2 LEDs (51, 52)
  // 3: Fuerte -> 4 LEDs (51, 52, 53, 54)
  if (level === 0) wifiActiveLeds = 0;
  else if (level === 1) wifiActiveLeds = 1;
  else if (level === 2) wifiActiveLeds = 2;
  else if (level === 3) wifiActiveLeds = 4;
  
  // Re-run current update
  let hours, minutes;
  if (realtimeToggle.checked) {
    const now = new Date();
    hours = now.getHours();
    minutes = now.getMinutes();
  } else {
    const totalMinutes = parseInt(timeSlider.value);
    hours = Math.floor(totalMinutes / 60);
    minutes = totalMinutes % 60;
  }
  updateClock(hours, minutes);
});

// AP Mode and WiFi Pulsing Simulation variables
let isApActive = false;
let wifiPulseInterval = null;
let apTimerInterval = null;
let apSecondsRemaining = 60;

function startApMode() {
  if (isApActive) return;
  isApActive = true;
  apSecondsRemaining = 60;

  // Set Phone Simulator UI status to connected
  const apBanner = document.getElementById("phone-ap-banner");
  apBanner.style.background = "rgba(16, 185, 129, 0.15)";
  apBanner.style.borderColor = "rgba(16, 185, 129, 0.3)";
  apBanner.style.color = "#34d399";
  apBanner.textContent = `AP CONECTADO (192.168.4.1) - ${apSecondsRemaining}s`;

  const phoneControls = document.getElementById("phone-controls-wrapper");
  phoneControls.style.opacity = "1";
  phoneControls.style.pointerEvents = "auto";

  // Start pulsing loop for WIFI cells in complementary color
  let pulseValue = 10;
  let pulseDir = 6;
  
  clearInterval(wifiPulseInterval);
  wifiPulseInterval = setInterval(() => {
    pulseValue += pulseDir;
    if (pulseValue >= 200 || pulseValue <= 6) pulseDir = -pulseDir;
    const pv = Math.max(0, Math.min(255, pulseValue));

    // Get complementary color directly from currentActiveColor
    const r = parseInt(currentActiveColor.slice(1, 3), 16);
    const g = parseInt(currentActiveColor.slice(3, 5), 16);
    const b = parseInt(currentActiveColor.slice(5, 7), 16);

    let compR = 255 - r;
    let compG = 255 - g;
    let compB = 255 - b;
    if (compR < 50 && compG < 50 && compB < 50) {
      compR = 120;
      compG = 130;
      compB = 140;
    }

    // Scale color by brightness pulse
    const pr = Math.round((compR * pv) / 255);
    const pg = Math.round((compG * pv) / 255);
    const pb = Math.round((compB * pv) / 255);

    const pColor = `rgb(${pr}, ${pg}, ${pb})`;
    const pGlow = `0 0 8px rgba(${pr}, ${pg}, ${pb}, 0.6), 0 0 20px rgba(${pr}, ${pg}, ${pb}, 0.3)`;

    for (let idx = 51; idx <= 54; idx++) {
      const cell = document.querySelector(`.cell[data-index="${idx}"]`);
      if (cell) {
        cell.style.color = pColor;
        cell.style.textShadow = pGlow;
      }
    }
  }, 20);

  // AP Timeout Countdown
  clearInterval(apTimerInterval);
  apTimerInterval = setInterval(() => {
    apSecondsRemaining--;
    if (apSecondsRemaining <= 0) {
      stopApMode();
    } else {
      apBanner.textContent = `AP CONECTADO (192.168.4.1) - ${apSecondsRemaining}s`;
    }
  }, 1000);
}

function stopApMode() {
  if (!isApActive) return;
  isApActive = false;
  
  clearInterval(wifiPulseInterval);
  clearInterval(apTimerInterval);
  
  // Reset Phone Simulator UI status to disconnected
  const apBanner = document.getElementById("phone-ap-banner");
  apBanner.style.background = "rgba(239, 68, 68, 0.15)";
  apBanner.style.borderColor = "rgba(239, 68, 68, 0.3)";
  apBanner.style.color = "#fca5a5";
  apBanner.textContent = "AP DESCONECTADO (Sin señal)";

  const phoneControls = document.getElementById("phone-controls-wrapper");
  phoneControls.style.opacity = "0.3";
  phoneControls.style.pointerEvents = "none";

  // Clear inline styles from WiFi cells
  for (let idx = 51; idx <= 54; idx++) {
    const cell = document.querySelector(`.cell[data-index="${idx}"]`);
    if (cell) {
      cell.style.color = "";
      cell.style.textShadow = "";
    }
  }

  // Force clock redraw to match the actual time/wifi level
  let hours, minutes;
  if (realtimeToggle.checked) {
    const now = new Date();
    hours = now.getHours();
    minutes = now.getMinutes();
  } else {
    const totalMinutes = parseInt(timeSlider.value);
    hours = Math.floor(totalMinutes / 60);
    minutes = totalMinutes % 60;
  }
  updateClock(hours, minutes);
}

// Update Active Colors on both Main and Phone panel
function updateActiveColor(hex) {
  currentActiveColor = hex;
  const r = parseInt(hex.slice(1, 3), 16);
  const g = parseInt(hex.slice(3, 5), 16);
  const b = parseInt(hex.slice(5, 7), 16);
  const glow = `0 0 10px rgba(${r}, ${g}, ${b}, 0.7), 0 0 25px rgba(${r}, ${g}, ${b}, 0.4)`;

  // Update root variables
  document.documentElement.style.setProperty("--led-color-on", hex);
  document.documentElement.style.setProperty("--led-glow-on", glow);

  // Calculate complementary color for WiFi
  let compR = 255 - r;
  let compG = 255 - g;
  let compB = 255 - b;
  if (compR < 50 && compG < 50 && compB < 50) {
    compR = 120;
    compG = 130;
    compB = 140;
  }
  const compColor = "#" + [compR, compG, compB].map(x => x.toString(16).padStart(2, "0")).join("");
  const compGlow = `0 0 8px rgba(${compR}, ${compG}, ${compB}, 0.6), 0 0 20px rgba(${compR}, ${compG}, ${compB}, 0.3)`;
  
  document.documentElement.style.setProperty("--wifi-color-on", compColor);
  document.documentElement.style.setProperty("--wifi-glow-on", compGlow);

  // Sync color swatches in main panel
  document.querySelectorAll(".color-swatch").forEach(s => {
    if (s.getAttribute("data-color") === hex) {
      s.classList.add("active");
    } else {
      s.classList.remove("active");
    }
  });

  // Sync color swatches in phone panel
  const idMap = {
    "phone-swatch-amber": "#ff8c00",
    "phone-swatch-cyan": "#00e5ff",
    "phone-swatch-rose": "#ff2a85",
    "phone-swatch-green": "#10b981",
    "phone-swatch-purple": "#a855f7",
    "phone-swatch-white": "#f1f5f9"
  };
  Object.keys(idMap).forEach(id => {
    const el = document.getElementById(id);
    if (el) {
      if (idMap[id] === hex) {
        el.classList.add("active");
      } else {
        el.classList.remove("active");
      }
    }
  });

  // Update inputs value
  document.getElementById("phone-col").value = hex;
}

// Night Mode logic inside simulator
function isPhoneNightHour(hour) {
  const ns = parseInt(document.getElementById("phone-ns").value) || 22;
  const ne = parseInt(document.getElementById("phone-ne").value) || 6;
  if (ns === ne) return false;
  if (ns < ne) {
    return (hour >= ns && hour < ne);
  } else {
    return (hour >= ns || hour < ne);
  }
}

function updateClockBrightness() {
  let hour = 12;
  if (realtimeToggle.checked) {
    hour = new Date().getHours();
  } else {
    const totalMinutes = parseInt(timeSlider.value);
    hour = Math.floor(totalMinutes / 60);
  }

  const isNight = isPhoneNightHour(hour);
  const dayB = parseInt(document.getElementById("phone-day").value) || 70;
  const nightB = parseInt(document.getElementById("phone-night").value) || 20;
  const percent = isNight ? nightB : dayB;

  // Scale clock brightness filter
  const factor = percent / 100;
  const finalBrightness = 0.15 + factor * 0.85;
  
  if (!isAnimating) {
    document.getElementById("wordclock").style.filter = `brightness(${finalBrightness})`;
  }
}

function updatePhoneRtcDisplay(date) {
  const rtcVal = document.getElementById("phone-rtc-val");
  if (rtcVal) {
    const d = date || new Date();
    const formatted = `${String(d.getDate()).padStart(2, '0')}/${String(d.getMonth() + 1).padStart(2, '0')}/${d.getFullYear()} ${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}:${String(d.getSeconds()).padStart(2, '0')}`;
    rtcVal.textContent = formatted;
  }
}

/// ESP32 Startup Animation Simulation (Matrix Rain REVEALS Clock Words AT THE END)
function playStartupAnimation() {
  if (isAnimating) return;
  isAnimating = true;

  const btn = document.getElementById("play-startup-btn");
  if (btn) btn.disabled = true;

  // 1. Obtener la hora actual del simulador y calcular los índices de las palabras objetivo
  let hours, minutes;
  if (realtimeToggle.checked) {
    const now = new Date();
    hours = now.getHours();
    minutes = now.getMinutes();
  } else {
    const totalMinutes = parseInt(timeSlider.value);
    hours = Math.floor(totalMinutes / 60);
    minutes = totalMinutes % 60;
  }

  const activeKeys = timeToWords(hours, minutes);
  const targetIndices = new Set();

  activeKeys.forEach(key => {
    const range = WORDS[key];
    if (range) {
      for (let i = range[0]; i <= range[1]; i++) {
        targetIndices.add(i);
      }
    }
  });

  // Incluir celdas activas de WiFi si aplica
  for (let i = 51; i < 51 + wifiActiveLeds; i++) {
    targetIndices.add(i);
  }

  // 2. Limpiar todos los estados e inline styles
  document.querySelectorAll(".cell").forEach(c => {
    c.classList.remove("active");
    c.style.color = "";
    c.style.textShadow = "";
    c.style.opacity = "";
    c.removeAttribute("data-alpha");
  });
  document.querySelectorAll(".dot").forEach(d => {
    d.classList.remove("active");
  });

  const clock = document.getElementById("wordclock");
  if (clock) clock.style.filter = "brightness(1)";

  const numCols = 11;
  const numRows = 14;

  // Estructura de gotas por columna con posiciones iniciales escalonadas sobre la matriz
  const drops = Array.from({ length: numCols }, (_, col) => ({
    col: col,
    y: -Math.floor(Math.random() * 10),
    speed: 0.28 + Math.random() * 0.28,
    hue: Math.floor(Math.random() * 360),
    tailLength: 4 + Math.floor(Math.random() * 3) // Estela más larga (4 a 6 letras)
  }));

  // Registro de celdas objetivo que ya fueron "reveladas" por la lluvia
  const revealedIndices = new Set();
  const rainStartTime = Date.now();
  const totalDuration = 7800; // 7.8 segundos totales de animación
  const revealStartTime = 5000; // ¡Comenzar el barrido gran final al segundo 5.0 (duración del barrido: 2.8s)!

  const rainInterval = setInterval(() => {
    const elapsed = Date.now() - rainStartTime;
    const isEnding = elapsed >= totalDuration;
    const isRevealPhase = elapsed >= revealStartTime;

    // Atenuación paulatina del rastro de lluvia en celdas no reveladas (desvanecimiento más suave)
    document.querySelectorAll(".cell").forEach(cell => {
      const idx = parseInt(cell.getAttribute("data-index"));

      if (revealedIndices.has(idx)) {
        // La letra objetivo revelada se mantiene encendida en el color del reloj
        cell.classList.add("active");
        cell.style.color = "";
        cell.style.textShadow = "";
        cell.style.opacity = "1";
      } else if (cell.style.color) {
        // Atenuación de la estela de la gota (retención más prolongada)
        const currentAlpha = parseFloat(cell.getAttribute("data-alpha") || "1");
        const newAlpha = currentAlpha * 0.78;
        cell.setAttribute("data-alpha", newAlpha.toFixed(2));
        if (newAlpha < 0.05) {
          cell.style.color = "";
          cell.style.textShadow = "";
          cell.style.opacity = "";
          cell.removeAttribute("data-alpha");
        } else {
          cell.style.opacity = newAlpha;
        }
      }
    });

    // Desplazar las gotas hacia abajo y regenerar continuamente
    drops.forEach(drop => {
      drop.y += drop.speed;

      if (drop.y - drop.tailLength > numRows) {
        drop.y = -Math.floor(Math.random() * 5);
        drop.hue = (drop.hue + 65 + Math.floor(Math.random() * 120)) % 360;
        drop.speed = 0.30 + Math.random() * 0.30;
      }

      const headY = Math.floor(drop.y);

      for (let t = 0; t < drop.tailLength; t++) {
        const row = headY - t;
        if (row >= 0 && row < numRows) {
          const idx = row * 11 + drop.col;

          // ¡ÚNICAMENTE durante la fase final de revelación (después del seg 7.2), al pasar la gota, REVELA la letra!
          if (isRevealPhase && targetIndices.has(idx) && t === 0) {
            revealedIndices.add(idx);
          }

          // Si aún no ha sido revelada, dibujar el destello multicolor de la lluvia
          const cell = document.querySelector(`.cell[data-index="${idx}"]`);
          if (cell && !revealedIndices.has(idx)) {
            const headBrightness = t === 0 ? "85%" : `${60 - t * 15}%`;
            const alpha = t === 0 ? 1.0 : Math.max(0.2, 1.0 - (t / drop.tailLength));
            const dropHue = (drop.hue + t * 12) % 360;
            const colorStr = `hsl(${dropHue}, 100%, ${headBrightness})`;
            const glowStr = t === 0 
              ? `0 0 12px ${colorStr}, 0 0 25px ${colorStr}` 
              : `0 0 6px ${colorStr}`;

            cell.style.color = colorStr;
            cell.style.textShadow = glowStr;
            cell.style.opacity = alpha;
            cell.setAttribute("data-alpha", alpha.toString());
          }
        }
      }
    });

    // Al llegar a los 10.0 segundos
    if (isEnding) {
      clearInterval(rainInterval);

      // Asegurar que todas las palabras objetivo queden totalmente activas
      targetIndices.forEach(idx => {
        const cell = document.querySelector(`.cell[data-index="${idx}"]`);
        if (cell) {
          cell.classList.add("active");
          cell.style.color = "";
          cell.style.textShadow = "";
          cell.style.opacity = "1";
        }
      });

      // Limpiar rastro restante en celdas no objetivo
      document.querySelectorAll(".cell").forEach(c => {
        const idx = parseInt(c.getAttribute("data-index"));
        if (!targetIndices.has(idx)) {
          c.classList.remove("active");
          c.style.color = "";
          c.style.textShadow = "";
          c.style.opacity = "";
          c.removeAttribute("data-alpha");
        }
      });

      // Encender puntos de minutos
      const extra = minutes % 5;
      const dotsToLight = (minutes >= 35) ? (4 - extra) : extra;
      for (let i = 1; i <= 4; i++) {
        const dot = document.getElementById(`dot-${i}`);
        if (dot) {
          if (i <= dotsToLight) dot.classList.add("active");
          else dot.classList.remove("active");
        }
      }

      isAnimating = false;
      if (btn) btn.disabled = false;

      // Iniciar portal cautivo WiFi AP si corresponde
      startApMode();
    }
  }, 45);
}

// Bind phone events
document.getElementById("phone-col").addEventListener("input", (e) => {
  updateActiveColor(e.target.value);
});

document.getElementById("phone-swatch-amber").addEventListener("click", () => updateActiveColor("#ff8c00"));
document.getElementById("phone-swatch-cyan").addEventListener("click", () => updateActiveColor("#00e5ff"));
document.getElementById("phone-swatch-rose").addEventListener("click", () => updateActiveColor("#ff2a85"));
document.getElementById("phone-swatch-green").addEventListener("click", () => updateActiveColor("#10b981"));
document.getElementById("phone-swatch-purple").addEventListener("click", () => updateActiveColor("#a855f7"));
document.getElementById("phone-swatch-white").addEventListener("click", () => updateActiveColor("#f1f5f9"));

document.getElementById("phone-day").addEventListener("input", (e) => {
  document.getElementById("phone-day-val").textContent = e.target.value;
  updateClockBrightness();
});

document.getElementById("phone-night").addEventListener("input", (e) => {
  document.getElementById("phone-night-val").textContent = e.target.value;
  updateClockBrightness();
});

document.getElementById("phone-ns").addEventListener("change", updateClockBrightness);
document.getElementById("phone-ne").addEventListener("change", updateClockBrightness);

document.getElementById("phone-sync-btn").addEventListener("click", () => {
  const now = new Date();
  const h = now.getHours();
  const m = now.getMinutes();
  
  if (realtimeToggle.checked) {
    alert("El simulador ya está en tiempo real. Desactiva 'Tiempo Real' para forzar manual.");
    return;
  }
  
  hourInput.value = h;
  minuteInput.value = m;
  timeSlider.value = h * 60 + m;
  
  updateClock(h, m);
  updateClockBrightness();
  updatePhoneRtcDisplay(now);
  alert("¡Hora de teléfono sincronizada al RTC!");
});

document.getElementById("phone-save-btn").addEventListener("click", () => {
  // Simulates saving variables to NVS and rebooting
  stopApMode();
  playStartupAnimation();
});

document.getElementById("play-startup-btn").addEventListener("click", playStartupAnimation);

// Start application
initGrid();
updateActiveColor("#ff8c00");
updatePhoneRtcDisplay();
updateClockBrightness();
playStartupAnimation();

// Update ticking and phone RTC ticking
setInterval(() => {
  tick();
  updatePhoneRtcDisplay();
}, 1000);
