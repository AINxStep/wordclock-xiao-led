# Simulador de Reloj de Palabras (WordClock)

Este es un simulador interactivo web de alta fidelidad para una matriz LED de reloj de palabras en español de 11 columnas por 14 filas, más 4 puntos de minutos individuales.

El diseño de la matriz se divide de la siguiente manera:

*   **Fila 0 (0-10)**: `E S O N · L A S U N A` (Verbos, artículos y hora "UNA")
*   **Fila 1 (11-21)**: `V E I N T I C I N C O` (Minutos para el bloque **PARA**)
*   **Fila 2 (22-32)**: `D I E Z V E I N T E ·` (Minutos para el bloque **PARA**)
*   **Fila 3 (33-43)**: `C U A R T O · P A R A` (Minutos para el bloque **PARA**)
*   **Fila 4 (44-54)**: `L A S · · · · · · · ·` (Artículo "LAS" / "LA" para el bloque **PARA**)
*   **Fila 5 (55-65)**: `T R E S · · · · D O S` (Horas + 4 celdas centrales para estado WiFi)
*   **Fila 6 (66-76)**: `C U A T R O C I N C O` (Horas)
*   **Fila 7 (77-87)**: `· S E I S · S I E T E` (Horas)
*   **Fila 8 (88-98)**: `O C H O N U E V E · ·` (Horas)
*   **Fila 9 (99-109)**: `D I E Z · · O N C E ·` (Horas)
*   **Fila 10 (110-120)**: `D O C E · Y · · · · ·` (Horas y conjunción "Y")
*   **Fila 11 (121-131)**: `D I E Z V E I N T E ·` (Minutos para el bloque **Y**)
*   **Fila 12 (132-142)**: `V E I N T I C I N C O` (Minutos para el bloque **Y**)
*   **Fila 13 (143-153)**: `C U A R T O M E D I A` (Minutos para el bloque **Y**)
*   **Fila 14 (154-157)**: 4 LEDs de puntos para ajuste individual de minutos (+1, +2, +3, +4).

## Características del Simulador

1.  **Modo Tiempo Real**: Sincroniza automáticamente la matriz con el reloj de tu navegador.
2.  **Modo Manual**: Desactiva el modo de tiempo real para usar un control deslizante (slider) de 24 horas y probar cualquier hora del día.
3.  **Lógica Avanzada de Hora en Español**:
    *   **Bloque "Y"** (minutos 0 a 34): Por ejemplo, "SON LAS ONCE Y VEINTE" o "ES LA UNA Y DIEZ".
    *   **Bloque "PARA"** (minutos 35 a 59): Por ejemplo, "VEINTICINCO PARA LA UNA" o "DIEZ PARA LAS TRES".
    *   Ajuste fino de minutos individuales mediante los 4 puntos de minutos en la parte inferior.
4.  **Estética Premium**: Interfaz moderna y fluida con efectos de brillo LED realistas y soporte para cambio de color de iluminación (Presets).
5.  **Indicadores de Estado WiFi**: Permite simular los 4 LEDs dedicados a la señal WiFi (nivel bajo, medio, fuerte y apagado).
6.  **Panel de Depuración**: Muestra en tiempo real las palabras activas y sus respectivos índices LED físicos (0 a 153).

## Cómo Ejecutar el Simulador

Basta con abrir el archivo [index.html](file:///Users/lrsg/Documents/antigravity/proyectos/wordclock/index.html) en cualquier navegador web moderno.
