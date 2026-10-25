-- Prime Visuals: original faceted prism monogram, drawn in a 26px native header slot.
return function(holder, main, runService)
    assert(holder, "Prime Visuals header icon holder is unavailable")
    holder.Image = ""
    holder.BackgroundTransparency = 1
    local root = Instance.new("Frame")
    root.Name = "PrimePrism"
    root.BackgroundTransparency = 1
    root.Size = UDim2.fromScale(1, 1)
    root.Parent = holder
    local strokes = {}
    local function segment(a, b, width, phase, alpha)
        local dx, dy = b[1] - a[1], b[2] - a[2]
        local length = math.sqrt(dx * dx + dy * dy)
        for layer = 1, 3 do
            local line = Instance.new("Frame")
            line.Name = layer == 3 and "Facet" or "Aura"
            line.AnchorPoint = Vector2.new(0.5, 0.5)
            line.Position = UDim2.fromScale((a[1] + b[1]) / 52, (a[2] + b[2]) / 52)
            line.Size = UDim2.fromOffset(length, width + (3 - layer) * 2)
            line.Rotation = math.deg(math.atan2(dy, dx))
            line.BorderSizePixel = 0
            line.BackgroundTransparency = layer == 3 and alpha or (layer == 2 and 0.87 or 0.96)
            line.ZIndex = holder.ZIndex + layer
            line.Parent = root
            strokes[#strokes + 1] = {frame = line, phase = phase}
        end
    end
    -- Six-sided crown/shield silhouette; asymmetric inner facets form a compact P.
    local crown = {{13,2},{22,7},{20,17},{13,24},{6,17},{4,7}}
    for i = 1, #crown do
        segment(crown[i], crown[i % #crown + 1], 1.25, (i - 1) * 0.065, 0)
    end
    segment({4,7},{13,5},0.65,0.12,0.42)
    segment({13,5},{22,7},0.65,0.22,0.42)
    segment({6,17},{13,24},0.7,0.36,0.35)
    segment({13,5},{13,8},0.65,0.16,0.45)
    segment({9,19},{9,8},1.5,0.08,0)
    segment({9,8},{15,8},1.5,0.18,0)
    segment({15,8},{18,11},1.5,0.25,0)
    segment({18,11},{15,14},1.5,0.32,0)
    segment({15,14},{9,14},1.5,0.4,0)
    segment({15,14},{13,20},0.7,0.46,0.4)
    -- Small crown glint, kept inside the icon slot.
    segment({21,2},{21,5},0.85,0.58,0.18)
    segment({19.5,3.5},{22.5,3.5},0.85,0.58,0.18)
    local elapsed, accumulator = 0, 0
    local function paint()
        for _, stroke in ipairs(strokes) do
            local hue = (elapsed / 14 + stroke.phase) % 1
            local glint = math.max(0, math.cos(elapsed * 1.5 - stroke.phase * math.pi * 2)) ^ 18
            stroke.frame.BackgroundColor3 = Color3.fromHSV(hue, 0.64 - glint * 0.32, 1)
        end
    end
    paint()
    return runService.RenderStepped:Connect(function(dt)
        if not root.Parent or not main.Visible or not holder.Visible then return end
        elapsed = elapsed + dt
        accumulator = accumulator + dt
        if accumulator < 1 / 30 then return end
        accumulator = accumulator % (1 / 30)
        paint()
    end)
end
