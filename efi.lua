local menu, pos = {
    "Disks utility",
    "Recovery other EEPROM",
    "Computer info",
    "Reboot"
}, 0

local gpu = component.proxy(component.list("gpu")())
local sWidth, sHeight = gpu.getResolution()
local eeprom = component.proxy(compontent.list('eeprom')())

function center(text)
    return math.ceil(sWidth / 2 - #text / 2), math.ceil(sHeight / 2) - 1
end

function drawMenu()
    gpu.setBackground(0x141414)
    gpu.fill(1, 1, sWidth, sHeight, " ")
    for i, item in ipairs(menu) do
        local w, h = center(item)
        h = h - (#menu // 2) + (i - 1)
        if pos == i then
            gpu.setBackground(0x202020)
        else
            gpu.setBackground(0x141414)
        end
        gpu.set(w, h, item)
    end
end

function request(url)
    local inet = component.list("internet") and component.proxy(component.list("internet")())
    if not inet then error("no internet") end
    local handle = inet.request(url)
    local data = ""
    repeat
        local chunk = handle.read()
        if chunk then data = data .. chunk end
    until not chunk
    handle.close()
    return data
end

while true do
    sWidth, sHeight = gpu.getResolution()
    local event, UUID, a, b, c = computer.pullSignal(1)
    gpu.set(1, 1, "event: " .. tostring(event))
    gpu.set(1, 2, "UUID: " .. tostring(UUID))
    gpu.set(1, 3, "a: " .. tostring(a))
    gpu.set(1, 4, "b: " .. tostring(b))
    gpu.set(1, 5, "c: " .. tostring(c))
    if ( event == 'key_down' ) then
        if ( b == 200 and pos >= 0) then -- Стрелка вверх
            pos = pos - 1
            drawMenu()
        elseif ( b == 208 and #menu ~= pos ) then -- Стрелка вниз
            pos = pos + 1
            drawMenu()
        elseif ( b == 28 ) then -- Enter
            if ( menu[pos] == 'Reboot' ) then
                computer.shutdown(true)
            elseif ( menu[pos] == 'Recovery other EEPROM' ) then
                menu = {
                    "uEFI",
                    "MineOS EFI",
                    "BIOS"
                }
                pos = 0
                drawMenu()
            elseif ( menu[pos] == 'MineOS EFI' ) then
                eeprom.set([[local connection, data, chunk = component.proxy(component.list("internet")()).request("https://raw.githubusercontent.com/IgorTimofeev/MineOS/master/Installer/Main.lua"), ""
while true do
chunk = connection.read(math.huge)
if chunk then
data = data .. chunk
else
break
end
end
connection.close()
load(data)()]])
            end
        end
    end
    drawMenu()
end
