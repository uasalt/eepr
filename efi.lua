while true do
    local gpu = g
    local event, UUID, a, b, c = computer.pullSignal(1)
    gpu.set(1, 1, a)
    gpu.set(1, 2, b)
    gpu.set(1, 3, c)
end
