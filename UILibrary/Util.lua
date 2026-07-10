-- UILibrary/Util.lua
-- Bezstanowe funkcje pomocnicze. Edytuj swobodnie.
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local U = {}

function U.tw(obj, props, t, style)
    TweenService:Create(obj, TweenInfo.new(
        t or 0.14, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out
    ), props):Play()
end

function U.new(class, props, parent)
    local i = Instance.new(class)
    for k, v in pairs(props) do i[k] = v end
    if parent then i.Parent = parent end
    return i
end

function U.corner(f, r)
    U.new("UICorner", { CornerRadius = UDim.new(0, r or 8) }, f)
end

function U.stroke(f, col, thick)
    U.new("UIStroke", {
        Color = col, Thickness = thick or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, f)
end

function U.pad(f, t, b, l, r)
    U.new("UIPadding", {
        PaddingTop    = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft   = UDim.new(0, l or 0),
        PaddingRight  = UDim.new(0, r or 0),
    }, f)
end

function U.vlist(f, gap)
    return U.new("UIListLayout", {
        Padding             = UDim.new(0, gap or 6),
        FillDirection       = Enum.FillDirection.Vertical,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    }, f)
end

function U.hlist(f, gap)
    return U.new("UIListLayout", {
        Padding           = UDim.new(0, gap or 4),
        FillDirection     = Enum.FillDirection.Horizontal,
        SortOrder         = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
    }, f)
end

function U.makeDraggable(frame, handle)
    local drag, ds, sp
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; ds = i.Position; sp = frame.Position
        end
    end)
    handle.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - ds
            frame.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end)
end

return U
