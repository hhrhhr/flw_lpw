void fillNoiseLED()
{
    uint8_t dataSmoothing = 0;
    uint8_t s = speed.as<uint8_t>();
    if ( s < 50) {
        dataSmoothing = 200 - (s * 4);
    }

    for (uint8_t i = 0; i < maxDim; i++) {

        uint16_t ioffset = scale.as<uint16_t>() * i;
        for (uint8_t j = 0; j < maxDim; j++) {

            uint16_t joffset = scale.as<uint16_t>() * j;

            uint8_t data = inoise8(x + ioffset, y + joffset, z);

            data = qsub8(data, 16);
            data = qadd8(data, scale8(data, 39));

            if ( dataSmoothing ) {
                uint8_t olddata = noise[i * maxDim + j];
                uint8_t newdata = scale8( olddata, dataSmoothing) + scale8( data, 256 - dataSmoothing);
                data = newdata;
            }

            noise[i * maxDim + j] = data;
        }
    }
    z += s;

    // apply slow drift to X and Y, just for visual variation.
    x += s / 8;
    y -= s / 16;

    for (uint8_t i = 0; i < pWIDTH; i++) {
        for (uint8_t j = 0; j < pHEIGHT; j++) {
            uint8_t index = noise[j * maxDim + i];
            uint8_t bri =   noise[i * maxDim + j];
            // if this palette is a 'loop', add a slowly-changing base value

            index += ihue;

            // brighten up, as the color palette itself often contains the
            // light/dark dynamic range desired
            if ( bri > map8(brightness,0,127) ) {
                bri = brightness; // 255;
            } else {
                bri = dim8_raw( bri * 2);
            }
            CRGB color = ColorFromPalette( currentPalette, index, bri);

            //drawPixelXY(i, j, color);
            leds[XY(i, j)] = color;
        }
    }
    ihue += 1;
}

void createNoise()
{
    if (noise == nullptr) {
        noise = new uint8_t[maxDim * maxDim];
    }
}
