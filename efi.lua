local menu, pos = {
    "Disks utility",
    "Recovery other EEPROM",
    "Computer info",
    "Reboot"
}, 0

function center(text)
    return math.ceil(sWidth / 2 - (#text /2 )), math.ceil(sHeight / 2) - 1
end

function drawMenu()
    gpu.setBackground(0x141414)
    for i, _ in ipairs(menu) do
        if (pos == i) then
            gpu.setBackground(0x202020)
            local w, h = center(menu[i])
            gpu.set(w, h - (#menu - pos))
            gpu.setBackground(0x141414)
        else
            gpu.set(center(menu[i]))
        end
    end
end

while true do
    local gpu = component.proxy(component.list("gpu")())
    local sWidth, sHeight = gpu.getResolution()
    local event, UUID, a, b, c = computer.pullSignal(1)
    gpu.set(1, 1, "event: " .. tostring(event))
    gpu.set(1, 2, "UUID: " .. tostring(UUID))
    gpu.set(1, 3, "a: " .. tostring(a))
    gpu.set(1, 4, "b: " .. tostring(b))
    gpu.set(1, 5, "c: " .. tostring(c))
    gpu.fill(0, 0, sWidth, sHeight, " ")
    if ( event == 'key_down' ) then
        if (b == 200 and pos > 0) then -- Стрелка вверх
            pos = pos - 1
            drawMenu()
        elseif (b == 208 and #menu ~= pos ) then -- Стрелка вниз
            pos = pos + 1
            drawMenu()
        end
    end
end
