/*
 * функции из LedPanelWiFi
 */

#define pWIDTH MATRIX_WIDTH
#define pHEIGHT MATRIX_HEIGHT

uint8_t hue = 0;
uint8_t ihue = 0;
uint8_t  *noise = nullptr;
CRGBPalette16 currentPalette;

static uint16_t x;
static uint16_t y;
static uint16_t z;

uint8_t maxDim = max(pWIDTH, pHEIGHT);
uint8_t minDim = min(pWIDTH, pHEIGHT);

bool loadingFlag = true;
