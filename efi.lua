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
end
