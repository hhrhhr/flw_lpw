
bool loadingFlag = true;
uint8_t currentMode = 0;

#define WIDTH MATRIX_WIDTH
#define HEIGHT MATRIX_HEIGHT

#define SEGMENTS (1U)

uint8_t deltaValue;
uint8_t hue, hue2;
uint8_t deltaHue, deltaHue2;
uint8_t step;

struct ModeType
{
  uint8_t Brightness = 50U;
  uint8_t Speed = 225U;
  uint8_t Scale = 40U;
};
#define MODE_AMOUNT MC_MAX
ModeType modes[MODE_AMOUNT];

uint16_t XY(uint8_t x, uint8_t y) {
    return y * WIDTH + x;
}

#define trackingOBJECT_MAX_COUNT (100U)
uint8_t trackingObjectHue[trackingOBJECT_MAX_COUNT];

uint32_t getPixColor(uint32_t thisSegm)
{
  uint32_t thisPixel = thisSegm * SEGMENTS;
  if (thisPixel > NUM_LEDS - 1) return 0;
  return (((uint32_t)leds[thisPixel].r << 16) | ((uint32_t)leds[thisPixel].g << 8 ) | (uint32_t)leds[thisPixel].b); // а почему не просто return (leds[thisPixel])?
}

uint32_t getPixColorXY(uint8_t x, uint8_t y)
{
  return getPixColor(XY(x, y));
}

void drawPixelXY(int8_t x, int8_t y, CRGB color)
{
  if (x < 0 || x > (WIDTH - 1) || y < 0 || y > (HEIGHT - 1)) return;
  uint32_t thisPixel = XY((uint8_t)x, (uint8_t)y) * SEGMENTS;
  for (uint8_t i = 0; i < SEGMENTS; i++)
  {
    leds[thisPixel + i] = color;
  }
}

//
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

