while true do
    local event, UUID, a, b, c = computer.pullSignal(1)
    computer.gpu.set(1, 1, a)
    computer.gpu.set(1, 2, b)
    computer.gpu.set(1, 3, c)
end
