#include "noise.h"

/*
 * нулевой тестовый эффект
 */

uint16_t testLED = 0;
void testEffect()
{
    FastLED.clear();
    leds[++testLED] = CRGB::White;
    if (testLED >= NUM_LEDS) testLED = 0;
}



/*
 * зебра из LedPanelWiFi, почти без изменений
 */

void zebraNoise()
{
    if (loadingFlag) {
        loadingFlag = false;
        createNoise();
        fill_solid( currentPalette, 16, CRGB::Black);
        currentPalette[0] = CRGB::White;
        currentPalette[4] = CRGB::White;
        currentPalette[8] = CRGB::White;
        currentPalette[12] = CRGB::White;
    }
    fillNoiseLED();
}



/*
 * нахально взятый фейервек из simple_firework.jns (jinx)
 */

// конфигурация
uint8_t particles, particle_length, particle_step, particle_start_speed;
float gravity;
// рабочие переменные
uint8_t color_step, particle_visible;
int8_t pos_x, pos_y, lifetime;
CRGB particle_color;
// рабочие массивы
uint8_t *particle_speed;
float   *particle_angle;

void createFirework()
{
    // точка взрыва в верхней половине
    pos_x = random8((pWIDTH / 3), (pWIDTH / 3 * 2));
    pos_y = random8((pHEIGHT / 2), (pHEIGHT));

    // создание частиц
    particle_speed = new uint8_t[particles];
    particle_angle = new float[particles];

    for (uint8_t n = 0; n < particles; n += 1) {
        // скорость разлёта
        uint8_t s = random8(5, particle_start_speed);
        particle_speed[n] = s;

        // начальный угол движения
        float a = random(360) * 3.141596 / 180.0;
        particle_angle[n] = a;
    }

    // начало взрыва
    lifetime = particle_length * (-1);
    color_step = 0;
    // цвет поярче
    particle_color = CRGB(random8(127, 255), random8(127, 255), random8(127, 255));
}


void firework2()
{
    if (loadingFlag) {
        gravity = 4;
        particles = scale.as<uint8_t>();
        particle_length = 7;
        particle_step = 15;
        particle_start_speed = 10;

        particle_visible = 0;
        loadingFlag = false;
    }
    // бух
    if (particle_visible == 0) {
        particles = scale.as<uint8_t>();
        createFirework();
        particle_visible = particles;
    }

    FastLED.clear();

    // подстройка скорости
    float speed_koef = 1.0 / (float)speed; // 0.05 (0) ... 0.3 (255)

    uint8_t nmax = particle_length*particle_length;
    for (uint8_t n = 0; n < nmax; n += particle_step) {
        // предрасчёт времени
        float tm = (n / particle_length + lifetime) * speed_koef;
        if (tm < 0) tm = 0;

        for (uint8_t i = 0; i < particles; i++) {
            // рисуем только видимые частицы
            if (particle_speed[i] > 0) {
                int8_t x = (int8_t)(particle_speed[i] * cos(particle_angle[i]) * tm) + pos_x;

                // считаем только те частицы, что улетели недалеко за границы
                if (x < (int8_t)pWIDTH * -0.5 or x > (int8_t)pWIDTH * 1.5) {
                    particle_speed[i] = -1;
                    particle_visible -= 1;
                } else {
                    // добавим вектор гравитации
                    float v = -0.5 * gravity * tm * tm;
                    int8_t y = (int8_t)(particle_speed[i] * sin(particle_angle[i]) * tm) + v + pos_y;

                    // улетать вверх можно далеко, всё равно частица вернётся
                    if (y < (int8_t)pHEIGHT * -0.5) {
                        particle_speed[i] = -1;
                        particle_visible -= 1;
                    } else {
                        // чем моложе частица, тем она тусклее
                        uint8_t cs = color_step - n;
                        CRGB color = CRGB(particle_color.r - cs, particle_color.g - cs, particle_color.b - cs);

                        // совсем тёмные не рисуем
                        if (color.r + color.g + color.b < 3) {
                            particle_speed[i] = -1;
                            particle_visible -= 1;
                        } else {
                            // проверяем нахождение в границах
                            if (x >=0 && x < pWIDTH && y>= 0  && y < pHEIGHT)
                                leds[XY(x, y)] = color;
// TODO: надо накладывать цвета на имеющиеся, иначе новые частицы просто затемняют старые
                        }
                    }
                }
            }
        }
    }

    // делаем старость и угосание цвета
    lifetime += 1;
    color_step += 3;

    // перезапуск по кол-ву циклов или видимости
    if (lifetime >= 100 || particle_visible < 2)
        particle_visible = 0;
}
