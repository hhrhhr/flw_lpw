#include "FastLED.h"

// размеры матрицы и тип укладки (зигзаг или нет, левый нижний угол, вправо)
#define MATRIX_WIDTH 30
#define MATRIX_HEIGHT 20
#define IS_SERPENTINE true


// список эффектов
typedef enum EFFECT {
    MC_ZERO,        // 0
    MC_NOISE_ZEBRA, // 1
    MC_FIREWORKS2,  // ...
    MC_MAX          // max
} EFFECT;

inline EFFECT& operator++ (EFFECT& eff, int) {
    const int i = static_cast<int>(eff)+1;
    eff = static_cast<EFFECT>(i >= MC_MAX ? MC_ZERO : i);
    return eff;
}

inline EFFECT& operator-- (EFFECT& eff, int) {
    const int i = static_cast<int>(eff)-1;
    eff = static_cast<EFFECT>(i < 0 ? MC_MAX-1 : i);
    return eff;
}

EFFECT currentEffect = MC_ZERO;


// всякая фигня из FastLED
#define NUM_LEDS (MATRIX_WIDTH * MATRIX_HEIGHT)
#define LED_TYPE   WS2811
#define COLOR_ORDER   GRB
#define DATA_PIN        3

// управляющие элементы
Slider brightness("Brightness", 255, 0, 255, 1);
Slider scale("Scale", 25, 1, 255, 1);
Slider speed("Speed", 10, 1, 255, 1);
Button nextEffect("Next effect");
Button prevEffect("Previous effect");


const uint8_t kMatrixWidth = MATRIX_WIDTH;
const uint8_t kMatrixHeight = MATRIX_HEIGHT;
const bool    kMatrixSerpentineLayout = IS_SERPENTINE;
const bool    kMatrixVertical = false;

uint16_t XY( uint8_t x, uint8_t y)
{
    uint16_t i;
    if( kMatrixSerpentineLayout == false) {
        if (kMatrixVertical == false) {
            i = (y * kMatrixWidth) + x;
        } else {
            i = kMatrixHeight * (kMatrixWidth - (x+1))+y;
        }
    }
    if( kMatrixSerpentineLayout == true) {
        if (kMatrixVertical == false) {
            if( y & 0x01) {
                // Odd rows run backwards
                uint8_t reverseX = (kMatrixWidth - 1) - x;
                i = (y * kMatrixWidth) + reverseX;
            } else {
                // Even rows run forwards
                i = (y * kMatrixWidth) + x;
            }
        } else { // vertical positioning
            if ( x & 0x01) {
                i = kMatrixHeight * (kMatrixWidth - (x+1))+y;
            } else {
                i = kMatrixHeight * (kMatrixWidth - x) - (y+1);
            }
        }
    }
    return i;
}


// сама матрица
CRGB leds[NUM_LEDS];
XYMap xyMap = XYMap(kMatrixWidth, kMatrixHeight, kMatrixSerpentineLayout);


#include "LedPanelWiFi.h"
#include "effects.h"


/*
 * main
 */

void setup()
{
    delay(1000);
    FastLED.addLeds<LED_TYPE, DATA_PIN, COLOR_ORDER>(leds, NUM_LEDS)
    .setScreenMap(xyMap); // !!! без этого будет просто полоска, а не XY матрица
}


void loop()
{
    FastLED.setBrightness(brightness);

    // переключалка эффектов
    if (nextEffect) {
        currentEffect++;
        loadingFlag = true;
Serial.print("next effect: ");
Serial.println((uint8_t)currentEffect);

    } else if (prevEffect) {
        currentEffect--;
        loadingFlag = true;
Serial.print("previous effect: ");
Serial.println((uint8_t)currentEffect);

    }
    
    switch (currentEffect) {
        case MC_ZERO:           testEffect(); break;
        case MC_NOISE_ZEBRA:    zebraNoise(); break;
        case MC_FIREWORKS2:     firework2(); break;
        default:                testEffect();
    }

    FastLED.show();
}
