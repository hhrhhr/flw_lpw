local function hex2rgb(n)
    local r = bit.band(bit.rshift(n, 16), 0xff)
    local g = bit.band(bit.rshift(n, 8), 0xff)
    local b = bit.band(n, 0xff)
    return CRGB(r, g, b)
end

local CRGB_Black = hex2rgb(0x000000)
local CRGB_White = hex2rgb(0xFFFFFF)
local CRGB_DarkGreen = hex2rgb(0x006400)
local CRGB_DarkOliveGreen = hex2rgb(0x556B2F)
local CRGB_Green = hex2rgb(0x006400)
local CRGB_ForestGreen = hex2rgb(0x228B22)
local CRGB_OliveDrab = hex2rgb(0x6B8E23)
local CRGB_SeaGreen = hex2rgb(0x2E8B57)
local CRGB_MediumAquamarine = hex2rgb(0x66CDAA)
local CRGB_LimeGreen = hex2rgb(0x32CD32)
local CRGB_YellowGreen = hex2rgb(0x9ACD32)
local CRGB_LightGreen = hex2rgb(0x90EE90)
local CRGB_LawnGreen = hex2rgb(0x7CFC00)


--local scale = 60
local speed = 20
local noise = nil

local colorLoop = 1
local ihue = 0
local x, y, z = 0, 0, 0


local function createNoise()
    noise = {[maxDim * maxDim -1] = nil}
    for i = 0, maxDim * maxDim -1 do
        noise[i] = 0
    end
end

local function fill_solid(target, num, color)
    for i = 0, num-1 do
        target[i] = color
    end
end

local function fillNoiseLED()
    local dataSmoothing = 0; --uint8_t
    if ( speed < 50) then
        dataSmoothing = 200 - (speed * 4);
    end

    for i = 0, maxDim-1 do
        local ioffset = scale * i;
        for j = 0, maxDim-1 do
            local joffset = scale * j;

            local data = inoise8(x + ioffset, y + joffset, z);

            data = qsub8(data, 16);
            data = qadd8(data, scale8(data, 39));

            if ( dataSmoothing ) then
                local olddata = noise[i * maxDim + j];
                local newdata = scale8( olddata, dataSmoothing) + scale8( data, 256 - dataSmoothing);
                data = newdata;
            end

            noise[i * maxDim + j] = data;
        end
    end
    z = z + speed;

    -- apply slow drift to X and Y, just for visual variation.
    x = x + speed / 8;
    y = y - speed / 16;

    local effectBrightness = getBrightnessCalculated(globalBrightness, getEffectContrastValue(thisMode));

    for i = 0, pWIDTH-1 do
        for j = 0, pHEIGHT-1 do
            local index = noise[j * maxDim + i];
            local bri =   noise[i * maxDim + j];
            -- if this palette is a 'loop', add a slowly-changing base value
            if ( colorLoop) then
                local ih = (index + ihue)%255
            end
            -- brighten up, as the color palette itself often contains the
            -- light/dark dynamic range desired
            if ( bri > map8(effectBrightness,0,127) ) then
                bri = effectBrightness; -- 255;
            else
                bri = dim8_raw( bri * 2);
            end
            local color = ColorFromPalette( currentPalette, index, bri);
            drawPixelXY(i, j, color);
        end
    end
    ihue = (ihue + 1)%255
end


function zebraNoise()
    if (loadingFlag) then
        loadingFlag = false;
        createNoise();

        fill_solid(currentPalette, 16, CRGB_Black);
        -- and set every fourth one to white.
        currentPalette[0] = CRGB_White;
        currentPalette[4] = CRGB_White;
        currentPalette[8] = CRGB_White;
        currentPalette[12] = CRGB_White;

        colorLoop = 1;
    end
    scale = map8(getEffectScaleParamValue(MC_NOISE_ZEBRA), 0, 100); 

    fillNoiseLED();
end

function forestNoise()
    if (loadingFlag) then
        loadingFlag = false;
        createNoise();

        fill_solid(currentPalette, 16, CRGB_Black);

        currentPalette[0] = CRGB_DarkGreen
        currentPalette[1] = CRGB_DarkGreen
        currentPalette[2] = CRGB_DarkOliveGreen
        currentPalette[3] = CRGB_DarkGreen

        currentPalette[4] = CRGB_Green
        currentPalette[5] = CRGB_ForestGreen
        currentPalette[6] = CRGB_OliveDrab
        currentPalette[7] = CRGB_Green

        currentPalette[8] = CRGB_SeaGreen
        currentPalette[9] = CRGB_MediumAquamarine
        currentPalette[10] = CRGB_LimeGreen
        currentPalette[11] = CRGB_YellowGreen

        currentPalette[12] = CRGB_LightGreen
        currentPalette[13] = CRGB_LawnGreen
        currentPalette[14] = CRGB_MediumAquamarine
        currentPalette[15] = CRGB_ForestGreen

        colorLoop = 0;
    end
    scale = map8(getEffectScaleParamValue(MC_NOISE_FOREST), 0, 100); 

    fillNoiseLED();
end

function fillnoise8()
    for i = 0, maxDim-1 do
        local ioffset = scale * i;
        for j = 0, maxDim-1 do
            local joffset = scale * j;
            noise[i * maxDim + j] = inoise8(x + ioffset, y + joffset, z);
        end
    end
    z = (z + speed)%16383
end

function madnessNoise()
    if (loadingFlag) then
        loadingFlag = false;
        createNoise();
    end

    local effectBrightness = getBrightnessCalculated(globalBrightness, getEffectContrastValue(thisMode));
    scale = map8(getEffectScaleParamValue(MC_NOISE_MADNESS), 0, 100);

    fillnoise8();

    for i = 0, pWIDTH-1 do
        for j = 0, pHEIGHT-1 do
            local thisColor = CHSV(noise[j * maxDim + i], 255, map8(noise[i * maxDim + j], effectBrightness / 2, effectBrightness));
            drawPixelXY(i, j, thisColor);
        end
    end

    ihue = (ihue + 1)%255
end