min = math.min
max = math.max
abs = math.abs
mf = math.floor
rnd = math.random
cos = math.cos
sin = math.sin

require("FastLED")
require("utility")
require("noise")
require("effects")

-- matrix size
pWIDTH = 30
pHEIGHT = 20


NUM_LEDS = pWIDTH * pHEIGHT;


MC_SNOW = 2
MC_RAINBOW = 4
MC_MATRIX = 7
MC_SPARKLES = 10
MC_NOISE_MADNESS = 11
MC_NOISE_ZEBRA = 17
MC_NOISE_FOREST = 18
MC_FW = 50
MAX_EFFECT_SUPPORT = 51

effectContrast = {[MAX_EFFECT_SUPPORT] = nil}
effectContrast[MC_FW] = 255
effectContrast[MC_SNOW] = 255
effectContrast[MC_RAINBOW] = 255
effectContrast[MC_MATRIX] = 255
effectContrast[MC_SPARKLES] = 255
effectContrast[MC_NOISE_MADNESS] = 255
effectContrast[MC_NOISE_ZEBRA] = 255
effectContrast[MC_NOISE_FOREST] = 255

effectScaleParam = {[MAX_EFFECT_SUPPORT] = nil}
effectScaleParam[MC_FW] = 50
effectScaleParam[MC_SNOW] = 50
effectScaleParam[MC_RAINBOW] = 50
effectScaleParam[MC_MATRIX] = 50
effectScaleParam[MC_SPARKLES] = 50
effectScaleParam[MC_NOISE_MADNESS] = 50
effectScaleParam[MC_NOISE_ZEBRA] = 50
effectScaleParam[MC_NOISE_FOREST] = 50


hue = 0
maxDim = math.max(pWIDTH, pHEIGHT)
thisMode = 0
loadingFlag = nil

currentPalette = {[15] = nil}
leds = {[NUM_LEDS] = nil}

particle_visible = nil

--[[ Love2d ]]

local lg = love.graphics

function love.load()
    if arg[#arg] == "-debug" then require("mobdebug").start() end

    FastLED.clear()
    loadingFlag = true
    thisMode = MC_SNOW
    
end


local scr = 0

local dTotal = 0.0
local dD = 4
function love.update(dt)
    dTotal = dTotal + dt
    local dT = 1.0 / 60.0 * dD
    if dTotal >= dT then
        dTotal = dTotal - dT
        if     MC_SNOW == thisMode then snowRoutine()
        elseif MC_FW == thisMode then firework()
        elseif MC_MATRIX == thisMode then matrixRoutine()
        elseif MC_RAINBOW == thisMode then rainbowRoutine()
        elseif MC_SPARKLES == thisMode then sparklesRoutine()
        elseif MC_NOISE_MADNESS == thisMode then madnessNoise()
        elseif MC_NOISE_ZEBRA == thisMode then zebraNoise()
        elseif MC_NOISE_FOREST == thisMode then forestNoise()
        end
    end
    
    lg.captureScreenshot("led_" .. scr .. ".png")
    scr = scr + 1
end


function love.draw()
    local d, s = 8, 10 -- diameter, margin
    lg.setColor(1, 1, 1)
--    lg.rectangle("line", 0, 0, pWIDTH*s, pHEIGHT*s)
--    lg.translate(s/2, s/2)
    
    for x = 0, pWIDTH-1 do
        for y = 0, pHEIGHT-1 do
--            local l = leds[(pHEIGHT-1 - y) * pWIDTH + x]
            local l = leds[(pHEIGHT-1 - y) * pWIDTH + x]
            lg.setColor(l.r/255, l.g/255, l.b/255)
--            lg.circle("fill", x*s, y*s, d)
            lg.rectangle("fill", x*s, y*s, d, d)
--            lg.setColor(0.2, 0.2, 0.2)
--            lg.circle("line", x*s, y*s, d)
        end
    end
--    lg.setColor(1, 1, 1)
--    lg.print("fps/" .. dD .. ", mode " .. thisMode)
--    lg.print("p=" .. (particle_visible or "-1"), 0, 10)
    
    -- draw palette
    if currentPalette[0] then
        for i = 0, 15 do
            l = currentPalette[i]
            lg.setColor(l.r/255, l.g/255, l.b/255)
            lg.rectangle("fill", i*s, (pHEIGHT)*s, s-1, s-1)
        end
    end
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        love.event.quit()
    
    elseif key == "right" then
        repeat
            thisMode = thisMode + 1
            if thisMode > MAX_EFFECT_SUPPORT then
                thisMode = 0
            end
        until effectContrast[thisMode]
        loadingFlag = true
        currentPalette = {}
    elseif key == "left" then
        repeat
            thisMode = thisMode - 1
            if thisMode < 0 then
                thisMode = MAX_EFFECT_SUPPORT
            end
        until effectContrast[thisMode]
        loadingFlag = true
        currentPalette = {}

    elseif key == "kp+" then
        dD = dD < 8 and dD + 1 or 8
    
    elseif key == "kp-" then
        dD = dD > 1 and dD - 1 or 1
        
    elseif key == "c" then
        lg.captureScreenshot("led_" .. scr .. ".png")
        scr = scr + 1
    end
end

