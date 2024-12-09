getEffectContrastValue = function(eff) -- int8_t 
    return effectContrast[eff] -- uint8_t
end

getEffectScaleParamValue = function(eff)
    return effectScaleParam[eff]
end

getEffectScaleParamValue2 = function(eff)
    return effectScaleParam2[eff]
end


function matrixRoutine()
    if loadingFlag then
        loadingFlag = false;
        FastLED.clear();
    end

    local effectBrightness = getBrightnessCalculated(globalBrightness, getEffectContrastValue(thisMode));
    local cut_out = pHEIGHT < 10 and 0x40 or 0x20 -- на 0x004000 хвосты матрицы короткие (4 точки), на 0x002000 - длиннее (8 точек)

    for x = 0, pWIDTH-1 do
        -- заполняем случайно верхнюю строку
        local thisColor = getPixColorXY(x, pHEIGHT - 1)
        if (thisColor.g == 0.0) then
            local idx = getPixelNumber(x, pHEIGHT - 1)
            if (idx >= 0) then
                local map = map8(255 - getEffectScaleParamValue(MC_MATRIX), 5, 15)
                leds[idx] = random8(0, map) == 0 and CRGB(0, effectBrightness, 0) or CRGB(0,0,0)
            end
        elseif (thisColor.g < cut_out) then
            drawPixelXY(x, pHEIGHT - 1, CRGB(0,0,0));
        else
            local c = thisColor
            drawPixelXY(x, pHEIGHT - 1, CRGB(c.r - cut_out, c.g - cut_out, c.b - cut_out))
        end
    end

    -- сдвигаем всё вниз
    shiftDown();
end


function snowRoutine()
    if (loadingFlag) then
        loadingFlag = false;
        FastLED.clear()
    end

    shiftDown();

    local effectBrightness = getBrightnessCalculated(globalBrightness, getEffectContrastValue(thisMode));

    for x = 0, pWIDTH-1 do
        -- заполняем случайно верхнюю строку
        -- а также не даём двум блокам по вертикали вместе быть
        local v1 = getPixColorXY(x, pHEIGHT - 2)
        local v2 = random8(0, map8(255 - getEffectScaleParamValue(MC_SNOW), 5, 15))

        if (v1.r + v1.g + v1.b == 0 and v2 == 0) then
            local color = CRGB(effectBrightness, effectBrightness, effectBrightness); --0xE0FFFF
            if (color.r > 0x20 and random8(0, 4) == 0) then
                color = CRGB(color.r - 0x10, color.g - 0x10, color.b - 0x10);
            end
            drawPixelXY(x, pHEIGHT - 1, color);
        else
            drawPixelXY(x, pHEIGHT - 1, CRGB(0, 0, 0));
        end
    end
end


local function rainbowDiagonal()
    local effectBrightness = getBrightnessCalculated(globalBrightness, getEffectContrastValue(thisMode));
    local koef = map8(getEffectScaleParamValue(MC_RAINBOW), 1, maxDim);
    hue = hue >= 256 and hue - 256 or hue + 3

    for x = 0, pWIDTH-1 do
        for y = 0, pHEIGHT-1 do
            local dx = (pWIDTH >= pHEIGHT)
            and (pWIDTH / pHEIGHT * x + y)
            or (pHEIGHT / pWIDTH * y + x);

            local thisColor = CHSV((hue + dx * koef), 255, effectBrightness);

            drawPixelXY(x, y, thisColor)
        end
    end
end

function rainbowRoutine()
    if (loadingFlag) then
        loadingFlag = false;
        FastLED.clear()
    end
    rainbowDiagonal()
end


local SPARKLES_FADE_STEP = 70    -- шаг уменьшения яркости

function sparklesRoutine()
    if (loadingFlag) then
        loadingFlag = false;
        FastLED.clear()
    end

    local effectBrightness = getBrightnessCalculated(globalBrightness, getEffectContrastValue(thisMode));
    local sparklesCount = map8(getEffectScaleParamValue(MC_SPARKLES), 1, 25);

    for i = 0, sparklesCount-1 do
        local x = random8(0, pWIDTH);
        local y = random8(0, pHEIGHT);
        local c = getPixColorXY(x, y)
        if (c.r + c.g + c.b < 1) then
            local idx = getPixelNumber(x, y)
            if (idx >= 0) then
                local h = random8(0, 256)
                local v = effectBrightness
                leds[idx] = CHSV(h, 255, v);
            end
        end
    end

    local step = map8(effectBrightness, 4, SPARKLES_FADE_STEP)
    fader(step);
end



--[[ Firework ]]
-- config
local gravity, particles, particle_length, particle_step, particle_start_speed
-- work var
local pos_x, pos_y, lifetime, color_step, particle_color
particle_visible = nil -- TODO make it local
-- work array
local particle_speed, particle_angle

local function createFirework()
    --position of the new explosion
    pos_x = rnd(mf(pWIDTH * 0.333), mf(pWIDTH * 0.666))
    pos_y = rnd(mf(pHEIGHT * 0.5), pHEIGHT)

    --create particles
    particle_speed = {[particles-1] = nil}
    particle_angle = {[particles-1] = nil}
    for n = 0, particles-1 do
        --set a random speed for particle movement
        particle_speed[n] = rnd(5, particle_start_speed)
        --set a random angle for particle movement
        local a = rnd(0, math.pi * 200) / 100
        particle_angle[n] = a
    end
    --start explosion
    lifetime = particle_length * (-1)
    color_step = 0
    --get new random color
    particle_color = CRGB(rnd(127, 255), rnd(127, 255), rnd(127, 255))
end

function firework()
    if (loadingFlag) then
        gravity = 4
        particles = 25
        particle_length = 7
        particle_step = 15
        particle_start_speed = 10

        particle_visible = 0
        loadingFlag = false
    end

    if particle_visible <= 0 then
        createFirework()
    end

    --clear the matrix
    FastLED.clear()
    particle_visible = 0

    --step over particle length
    local speed_koef = 0.1
    for n = 0, particle_length*particle_length-1, particle_step do
        --pre calculate time
        local time = (lifetime + n/particle_length ) * speed_koef
        if time < 0 then
            time = 0
        end
        --calculate and draw the particle
        for i = 0, particles-1 do
            if particle_speed[i] > 0 then
                particle_visible = particle_visible + 1
                
                local x = mf((particle_speed[i] * cos(particle_angle[i]) * time)) + pos_x
                -- check for H fly away
                if (x < -pWIDTH*0.5 or x >= pWIDTH*1.5) then
                    particle_speed[i] = -1
                    particle_visible = particle_visible - 1
                else
                    

                    local v = -0.5 * gravity * time * time -- gravity vector
                    local y = mf((particle_speed[i] * sin(particle_angle[i]) * time) + v) + pos_y
                    -- check for -V fly away
                    if (y < -pHEIGHT*0.5) then
                        particle_speed[i] = -1
                        particle_visible = particle_visible - 1
                    else
                        
                        local cs = color_step - n -- make first particle brighter
                        local color = CRGB(particle_color.r - cs, particle_color.g - cs, particle_color.b - cs)
                        -- kill dimmed partitions
                        if color.r + color.g + color.b < 3 then
                            particle_speed[i] = -1
                            particle_visible = particle_visible - 1
                        else
                            drawPixelXY(x, y, color)
                        end
                    end
                end
            end
        end
    end

    --rise the age of the particle
    lifetime = lifetime + 1
    color_step = color_step + 3

    --reached lifetime of explosion ?
    if lifetime >= 100 or particle_visible < 2 then
        --set flag to start next explosion
        print("lifetime", lifetime, particle_visible)
        --particle_visible = 0
    end
    
--        drawPixelXY(0, pHEIGHT-1, CRGB(255, 255, 255))
end
