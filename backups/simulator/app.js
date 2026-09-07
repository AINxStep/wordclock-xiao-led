// Matrix Configuration and Letter Grid (14 rows x 11 columns)
const MATRIX_TEXT = [
  "E", "S", "O", "N", "·", "L", "A", "S", "U", "N", "A", // Fila 0 (0-10)
  "V", "E", "I", "N", "T", "I", "C", "I", "N", "C", "O", // Fila 1 (11-21) - Block PARA
  "D", "I", "E", "Z", "V", "E", "I", "N", "T", "E", "·", // Fila 2 (22-32) - Block PARA
  "C", "U", "A", "R", "T", "O", "·", "P", "A", "R", "A", // Fila 3 (33-43) - Block PARA
  "L", "A", "S", "·", "·", "·", "·", "·", "·", "·", "·", // Fila 4 (44-54) - Block PARA (LA / LAS)
  "T", "R", "E", "S", "·", "·", "·", "·", "D", "O", "S", // Fila 5 (55-65) - Hours & WIFI at 59-62
  "C", "U", "A", "T", "R", "O", "C", "I", "N", "C", "O", // Fila 6 (66-76)
  "·", "S", "E", "I", "S", "·", "S", "I", "E", "T", "E", // Fila 7 (77-87)
  "O", "C", "H", "O", "N", "U", "E", "V", "E", "·", "·", // Fila 8 (88-98)
  "D", "I", "E", "Z", "·", "·", "O", "N", "C", "E", "·", // Fila 9 (99-109)
  "D", "O", "C", "E", "·", "Y", "·", "·", "·", "·", "·", // Fila 10 (110-120)
  "D", "I", "E", "Z", "V", "E", "I", "N", "T", "E", "·", // Fila 11 (121-131) - Block Y
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
  DIEZ_Y: [121, 124],
  VEINTE_Y: [125, 130],
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

// Initialize Grid HTML
function initGrid() {
  gridContainer.innerHTML = "";
  MATRIX_TEXT.forEach((char, index) => {
    const cell = document.createElement("div");
    cell.classList.add("cell");
    cell.textContent = char === "·" ? "•" : char;
    cell.setAttribute("data-index", index);
    
    if (char === "·") {
      cell.classList.add("decor");
    }
    
    // Wifi cells are indices 59, 60, 61, 62 in Row 5
    if (index >= 59 && index <= 62) {
      cell.classList.add("wifi-cell");
      cell.textContent = "•";
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
    activeKeys.push(HOUR_WORDS[nextHour]);

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
  const dotsToLight = minutes % 5;
  for (let i = 1; i <= dotsToLight; i++) {
    const dot = document.getElementById(`dot-${i}`);
    if (dot) dot.classList.add("active");
  }

  // Light up WIFI indicators
  for (let i = 59; i < 59 + wifiActiveLeds; i++) {
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
}

// Tick function for real-time mode
function tick() {
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

// Color preset listeners
colorPresets.addEventListener("click", (e) => {
  const swatch = e.target.closest(".color-swatch");
  if (!swatch) return;
  
  document.querySelectorAll(".color-swatch").forEach(s => s.classList.remove("active"));
  swatch.classList.add("active");
  
  const color = swatch.getAttribute("data-color");
  const glow = swatch.getAttribute("data-glow");
  
  document.documentElement.style.setProperty("--led-color-on", color);
  document.documentElement.style.setProperty("--led-glow-on", glow);
});

// Wifi simulator click listeners
document.querySelector(".wifi-switches").addEventListener("click", (e) => {
  const btn = e.target.closest(".wifi-btn");
  if (!btn) return;
  
  document.querySelectorAll(".wifi-btn").forEach(b => b.classList.remove("active"));
  btn.classList.add("active");
  
  const level = parseInt(btn.getAttribute("data-level"));
  
  // Level mappings:
  // 0: Off -> 0 LEDs
  // 1: Bajo -> 1 LED (index 59)
  // 2: Medio -> 2 LEDs (59, 60)
  // 3: Fuerte -> 4 LEDs (59, 60, 61, 62)
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

// Start application
initGrid();
tick();
setInterval(tick, 1000);
