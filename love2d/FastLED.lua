
FastLED = {}
FastLED.clear = function()
    for i = 0, NUM_LEDS-1 do
        leds[i] = {r = 0.0, g = 0.0, b = 0.0}
    end
end

map8 = function(val, r1, r2)
    local t = val / 255
    local r = (1 - t) * r1 + t * r2
    return mf(r)
end

random8 = function(min, max)
    if min and max then
        return rnd(min, max-1)
    else
        return rnd(0, 255)
    end
end


local function crop_color(c)
    c = mf(c)
    c = c > 255 and 255 or (c < 0 and 0 or c)
    return c
end

CRGB = function(r, g, b)
    local c = {r = crop_color(r), g = crop_color(g), b = crop_color(b)}
    return c
end

-- hsv to rgb
CHSV = function(h, s, v)
    h = h / 255 * 360
    s = s / 255
    v = v / 255
    
    local k1 = v * (1 - s)
    local k2 = v - k1
    local r = min(max(3 * abs(((h     )/180)%2-1)-1, 0), 1)
    local g = min(max(3 * abs(((h -120)/180)%2-1)-1, 0), 1)
    local b = min(max(3 * abs(((h +120)/180)%2-1)-1, 0), 1)
    
    r = k1 + k2 * r
    g = k1 + k2 * g
    b = k1 + k2 * b

    return {r = mf(r*255), g = mf(g*255), b = mf(b*255)}
end


local div = 1/128
function inoise8(x, y, z) -- 0...255
    local ans = love.math.noise( x*div, y*div, z*div )
    return mf(ans * 255);
end

function qsub8(a, b)
    local res = a - b
    return res < 0 and 0 or res
end

function scale8(i, s)
    local res = i * (s / 256)
    return mf(res)
end

function qadd8(a, b)
    local res = a + b
    return res > 255 and 255 or res
end

function dim8_raw(x)
    return scale8(x, x)
end

function ColorFromPalette(pal, idx, bri)
    local hi4 = bit.rshift(idx, 4)
    local lo4 = bit.band(idx, 0x0f)

    local entry = pal[hi4]
    local blend = lo4

    local red1 = entry.r
    local green1 = entry.g
    local blue1 = entry.b

    if( blend ) then

        if( hi4 == 15 ) then
            entry = pal[0]
        else
            entry = pal[hi4+1]
        end

        local f2 = bit.lshift(lo4, 4)
        local f1 = 255 - f2;

        --    rgb1.nscale8(f1);
        local red2   = entry.r;
        red1   = scale8( red1,   f1);
        red2   = scale8( red2,   f2);
        red1   = red1 + red2;

        local green2 = entry.g;
        green1 = scale8( green1, f1);
        green2 = scale8( green2, f2);
        green1 = green1 + green2;

        local blue2  = entry.b
        blue1  = scale8( blue1,  f1);
        blue2  = scale8( blue2,  f2);
        blue1  = blue1 + blue2;
    end

    red1 = scale8(red1, bri)
    green1 = scale8(green1, bri)
    blue1 = scale8(blue1, bri)

    return {r = red1, g = green1, b = blue1}
end

local nscale8x3 = function(r, g, b, s)
    local d = 255
    r = r * s / d
    g = g * s / d
    b = b * s / d
    return r, g, b
end

fadeToBlackBy = function(c, step)
     local r, g, b = nscale8x3(c.r, c.g, c.b, 255 - step) -- 250-70=180
     return CRGB(r, g, b)
end

