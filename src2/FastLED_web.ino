#include "FastLED.h"

// размеры матрицы и тип укладки (зигзаг или нет, левый нижний угол, вправо)
#define MATRIX_WIDTH 30
#define MATRIX_HEIGHT 20


// список эффектов
typedef enum EFFECT {
    MC_ZERO,        // 0

    EFF_AVRORA,
    EFF_WATERCOLOR,

    MC_MAX          // max
} EFFECT;


// переключалка эффектов
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
#define PROGMEM
#define pgm_read_byte(x) *x

//Arduino
#define constrain(amt,low,high) ((amt)<(low)?(low):((amt)>(high)?(high):(amt)))

// управляющие элементы
Slider bri("Brightness", 255, 0, 255, 1);
Slider spd("Speed", 225, 0, 255, 1);
Slider scl("Scale", 40, 0, 255, 1);
Button nextEffect("Next effect");
Button prevEffect("Previous effect");


// сама матрица
CRGB leds[NUM_LEDS];
XYMap xyMap = XYMap(MATRIX_WIDTH, MATRIX_HEIGHT, false);


#include "FieryLedLamp_New_WEB.h"
#include "effects.hpp"

void setup()
{
    delay(1000);
    FastLED.addLeds<LED_TYPE, DATA_PIN, COLOR_ORDER>(leds, NUM_LEDS)
    .setScreenMap(xyMap); // !!! без этого будет просто полоска, а не XY матрица

    currentMode = MC_ZERO;

Serial.println("Start!");
}


void loop()
{
    FastLED.setBrightness(255);

// переключалка эффектов
    if (nextEffect) {
        currentEffect++;
        loadingFlag = true;
        currentMode = currentEffect;

        Serial.print("effect: ");
        Serial.println((uint8_t)currentEffect);
    } else if (prevEffect) {
        currentEffect--;
        loadingFlag = true;
        currentMode = currentEffect;

        Serial.print("effect: ");
        Serial.println((uint8_t)currentEffect);
    }

    for (uint8_t i = 0; i < MC_MAX; i++) {
        modes[i].Brightness = (int)bri;
        modes[i].Speed = (int)spd;
        modes[i].Scale = (int)scl;
    }

    switch (currentMode) {
        case MC_ZERO:               testEffect(); break;

        case EFF_AVRORA:            Avrora(); break;
        case EFF_WATERCOLOR:        Watercolor(); break;

        default:                    testEffect();
    }

    FastLED.show();
}
