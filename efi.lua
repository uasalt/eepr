local code= [[local p,d,f,s=component.proxy,component.list("filesystem"),component.list("disk_drive"),component.list("screen")()
local g,e=p(component.list("gpu")()),p(component.list("eeprom")())
local z,r=math.huge,math.floor
g.bind(s)
local w,h=g.getResolution()
g.setBackground(0x141414)
g.fill(1,1,w,h," ")
function interface()
local o,m,parents=0,3,0
g.setBackground(0x141414)
g.fill(1,1,w,h," ")
while true do
local b,_,_,k=computer.pullSignal(1)
if b=="key_down" then
if k==200 and o>0 then o=o-1
elseif k==208 and o<m then o=o+1
elseif k==28 then proccess() end
end
end
end
local t="Загрузка..."
g.set(r((w-(#t/2))/2),r(h/2),t)
g.setForeground(0x3d3d3d)
t="Alt для настроек"
g.set(r((w-(#t/2))/2),r(h/2)+1,t)
local eventType,_,x,code=computer.pullSignal(1)
if eventType=="key_down" and (code==56 or code==184) then interface() return end
computer.getBootAddress=function() return e.getData() end
computer.setBootAddress=function(a) e.setData(a) end
local function l(a)
local fs=p(a) if not fs then return nil end
for _,file in ipairs({"/init.lua","/OS.lua"}) do
local h=fs.open(file,"r")
if h then
local b=""
repeat
local c=fs.read(h,z)
if c then b=b..c end
until not c
fs.close(h)
return load(b,"="..file)
end
end
end
local boot=computer.getBootAddress()
if boot then
local init=l(boot)
if init then init() return end
end
for a in d do local init=l(a) if init then computer.setBootAddress(a) init() return end end
for a in f do local init=l(a) if init then computer.setBootAddress(a) init() return end end
interface()]]

local component = require("component")
local eeprom = component.eeprom
if #code > eeprom.getSize() then
    print("Firmware too big -" .. (#code - eeprom.getSize()))
end
eeprom.setLabel("uEFI")
eeprom.set(code)
print("MemoryFree " .. (eeprom.getSize() - #code))