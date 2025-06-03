local menu, pos, prevPos = {
    {
        ['title'] = "Disks utility",
        ['id'] = 0
    },
    {
        ['title'] = "Recovery other",
        ['id'] = 0
    },
    {
        ['title'] = "Computer info",
        ['id'] = 0
    },
    {
        ['title'] = "Reboot",
        ['id'] = 0
    }
}, 1, 1
local general = menu

local gpu = component.proxy(component.list("gpu")())
local sWidth, sHeight = gpu.getResolution()
local eeprom = component.proxy(component.list('eeprom')())
gpu.setForeground(0xFFFFFF)

function center(text)
    return math.ceil(sWidth / 2 - #text / 2), math.ceil(sHeight / 2) - 1
end

function drawMenu()
    gpu.setBackground(0x141414)
    gpu.fill(1, 1, sWidth, sHeight, " ")
    for i, item in ipairs(menu) do
        local w, h = center(item['title'])
        h = h - (#menu // 2) + (i - 1)
        if pos == i then
            gpu.setBackground(0x202020)
        else
            gpu.setBackground(0x141414)
        end
        gpu.set(w, h + 2, item['title'])
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

function contains(tbl, val)
  for _, v in ipairs(tbl) do
    if v == val then return true end
  end
  return false
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
        if ( b == 200 and pos > 1) then -- Стрелка вверх
            pos = pos - 1
            drawMenu()
        elseif ( b == 208 and #menu ~= pos ) then -- Стрелка вниз
            pos = pos + 1
            drawMenu()
        elseif ( b == 28 ) then -- Enter
            if ( menu[pos]['title'] == 'Reboot' ) then
                computer.shutdown(true)
            elseif ( menu[pos]['title'] == 'Computer info' ) then
                local total = computer.totalMemory()
                local used = total - computer.freeMemory()
                local percent = math.floor((used / total) * 100 + 0.5)
                menu = {
                    {
                        ['title'] = 'RAM: ' .. tostring(used) .. '/' .. tostring(total) .. '(' .. percent .. '%)',
                        ['id'] = 0
                    },
                    {
                        ['title'] = 'Energy: ' .. tostring(computer.energy() - computer.maxEnergy()) .. '/' .. tostring(computer.maxEnergy()) .. '(' .. math.floor((computer.energy() - computer.maxEnergy() / computer.maxEnergy()) * 100 + 0.5) .. '%)',
                        ['id'] = 0
                    }
                }
            elseif ( menu[pos]['title'] == 'Disks utility' ) then
                menu = { {
                        ['title'] = 'back',
                        ['id'] = 0
                } }
                for address in component.list('filesystem') do
                    local fs = component.proxy(address)
                    table.insert(menu, {
                        ['title'] = (fs.getLabel() or address) .. " [HDD]" .. (fs.isReadOnly() and "[RO]" or "[RW]") .. (eeprom.getData() == address and "[BOOT]" or ""),
                        ['id'] = address
                    })
                end
                for address in component.list('disk_drive') do
                    local floppy = component.proxy(address)
                    if not floppy.isEmpty() then
                        local fs = component.proxy(floppy['media'][0])
                        table.insert(menu, {
                            ['title'] = (fs.getLabel() or address) .. " [HDD]" .. (fs.isReadOnly() and "[RO]" or "[RW]") .. (eeprom.getData() == address and "[BOOT]" or ""),
                            ['id'] = address
                        })
                    end
                end
                prevPos = menu[pos]
                pos = 1
                drawMenu()
            elseif ( menu[pos]['id'] ~= 0 and #menu[pos]['id'] == 36 and not contains({"Set as bootable", "Change label", "Erase"}, menu[pos]['title']) ) then
                menu = {
                    {
                        ['title'] = "Set as bootable",
                        ['id'] = menu[pos]['id']
                    },
                    {
                        ['title'] = "Change label",
                        ['id'] = menu[pos]['id']
                    },
                    {
                        ['title'] = "Erase",
                        ['id'] = menu[pos]['id']
                    },
                    {
                        ['title'] = "back",
                        ['id'] = menu[pos]['id']
                    }
                }
                prevPos = menu[pos]
                pos = 1
                drawMenu()
            elseif contains({"Set as bootable", "Change label", "Erase"}, menu[pos]['title']) then
                if menu[pos]['title'] == 'Set as bootable' then
                    eeprom.setData(menu[pos]['id'])
                elseif menu[pos]['title'] == 'Erase' then
                    component.proxy(menu[pos]['id']).format()
                    pos = 1
                    menu = general
                    drawMenu()
                end
            elseif ( menu[pos]['title'] == 'Recovery other' ) then
                menu = {
                    {
                        ['title'] = "uEFI",
                        ['id'] = 0
                    },
                    {
                        ['title'] = "MineOS EFI",
                        ['id'] = 0
                    },
                    {
                        ['title'] = "BIOS",
                        ['id'] = 0
                    },
                    {
                        ['title'] = "back",
                        ['id'] = 0
                    }
                }
                prevPos = menu[pos]
                pos = 1
                drawMenu()
            elseif (menu[pos]['title'] == 'uEFI') then
                local code = request("https://raw.githubusercontent.com/uasalt/eepr/refs/heads/main/installer.lua")
                eeprom.set(code)
                eeprom.setLabel("uEFI")
            elseif ( menu[pos]['title'] == 'MineOS EFI' ) then
                menu = {
                    {
                        ["title"] = "EFI",
                        ["id"] = 0
                    },
                    {
                        ["title"] = "Installer",
                        ["id"] = 0
                    },
                    {
                        ["title"] = "back",
                        ["id"] = 0
                    }
                }
                prevPos = menu[pos]
                pos = 1
                drawMenu()
            elseif ( menu[pos]['title'] == 'EFI' and prevPos['title'] == 'MineOS EFI' ) then
                local code = request("https://raw.githubusercontent.com/IgorTimofeev/MineOS/refs/heads/master/EFI/Minified.lua")
                eeprom.set(code)
                eeprom.setLabel("MineOS EFI")
            elseif ( menu[pos]['title'] == 'Installer' and prevPos['title'] == 'MineOS EFI' ) then
                eeprom.setLabel("MineOS EFI")
                eeprom.set([[local connection, data, chunk = component.proxy(component.list("internet")()).request("https://raw.githubusercontent.com/IgorTimofeev/MineOS/master/Installer/Main.lua"), "";while true do chunk = connection.read(math.huge);if chunk then data = data .. chunk else break end;end;connection.close();load(data)()]])
            elseif ( menu[pos]['title'] == 'BIOS' ) then
                local code = request("https://raw.githubusercontent.com/uasalt/eepr/refs/heads/main/BIOS.lua")
                eeprom.setLabel("EEPROM (Lua BIOS)")
                eeprom.set(code)
            elseif ( menu[pos]['title'] == 'back' ) then
                menu = general
                prevPos = menu[pos]
                pos = 1
                drawMenu()
            end
        end
    end
    drawMenu()
end
