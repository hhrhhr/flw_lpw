getBrightnessCalculated = function(brightness, contrast) -- uint8_t, uint8_t
    return map8(contrast, 16, 255) -- uint8_t
end

getPixColor = function(thisPixel) -- int16_t
    if (not leds) then return {r = 0, g = 0, b = 0} end
    if (thisPixel < 0 or thisPixel > NUM_LEDS - 1) then return {r = 0, g = 0, b = 0} end

    local ret = {
        r = leds[thisPixel].r,
        g = leds[thisPixel].g,
        b = leds[thisPixel].b,
    }
    return ret
end

getPixelNumber = function(x, y)
    return y * pWIDTH + x
end

getPixColorXY = function(x, y) -- int8_t, int8_t
    return getPixColor(getPixelNumber(x, y)) -- uint32_t
end

drawPixelXY = function(x, y, c)
    if x >= 0 and x < pWIDTH
    and y >= 0 and y < pHEIGHT then
        leds[y * pWIDTH + x] = c
    end
end

shiftDown = function()
    for x = 0, pWIDTH-1 do
        for y = 0, pHEIGHT-1 - 1 do
            local c = getPixColorXY(x, y + 1)
            drawPixelXY(x, y, c);
        end
    end
end


local fadePixel = function(x, y, step)
    local pixelNum = getPixelNumber(x, y);
    if (pixelNum < 0) then return end
    
    local c = getPixColor(pixelNum)
    if c.r + c.g + c.b < 8 then return end

    local l = leds[pixelNum]
    if (l.r >= 8 or
        l.g >= 8 or
        l.b >= 8) then
        leds[pixelNum] = fadeToBlackBy(l, step);
    else
        leds[pixelNum] = CRGB(0, 0, 0)
    end
end

fader = function(step)
    for x = 0, pWIDTH-1 do
        for y = 0, pHEIGHT-1 do
            fadePixel(x, y, step);
        end
    end
end
