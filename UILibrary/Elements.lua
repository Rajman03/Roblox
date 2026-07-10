-- UILibrary/Elements.lua
-- Wszystkie elementy taba. Każda funkcja jest osobna — edytuj bez strachu.
-- Elements.make(scrollFrame, getT, notifyFn, overlay) → Tab
--
-- notifyFn(title, content, type) — wywoływana przez Toggle przy zmianie stanu.
-- Przekaż nil żeby wyłączyć powiadomienia dla konkretnego taba.

local UIS = game:GetService("UserInputService")
local E   = {}

-- Fonty (zmień jeden wiersz żeby zmienić czcionkę dla całego UI)
local FB = Enum.Font.GothamBold
local FS = Enum.Font.GothamSemibold
local FR = Enum.Font.Gotham

function E.make(frame, getT, notifyFn, overlay)
    local U   = require(script.Parent.Util)
    local Tab = {}

    -- ─────────────────────────────────────────────────
    -- SECTION (opcjonalna etykieta grupująca elementy)
    -- cfg: Name (string)
    -- ─────────────────────────────────────────────────
    function Tab:CreateSection(title)
        local T = getT()
        local row = U.new("Frame", {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundTransparency = 1, ZIndex = 5,
        }, frame)
        U.new("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
            Text = string.upper(title or ""),
            TextColor3 = T.Accent, Font = Enum.Font.GothamBold,
            TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6,
        }, row)
        U.new("Frame", {
            AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0),
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = T.Border, BorderSizePixel = 0, ZIndex = 6,
        }, row)
    end

    -- ─────────────────────────────────────────────────
    -- BUTTON
    -- cfg: Name, Callback
    -- ─────────────────────────────────────────────────
    function Tab:CreateButton(cfg)
        local T = getT()
        local row = U.new("Frame", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = T.SurfaceAlt, ZIndex = 5,
        }, frame)
        U.corner(row, 8); U.stroke(row, T.Border)
        U.pad(row, 0, 0, 14, 14)

        U.new("TextLabel", {
            Size = UDim2.new(1, -80, 1, 0), BackgroundTransparency = 1,
            Text = cfg.Name or "Button", TextColor3 = T.Text,
            Font = FS, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6,
        }, row)

        local badge = U.new("Frame", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0, 58, 0, 24), BackgroundColor3 = T.Accent, ZIndex = 6,
        }, row)
        U.corner(badge, 6)
        U.new("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
            Text = "Wykonaj", TextColor3 = T.White, Font = FS, TextSize = 11, ZIndex = 7,
        }, badge)

        local hit = U.new("TextButton", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 8,
        }, row)
        hit.MouseEnter:Connect(function()  U.tw(row, { BackgroundColor3 = getT().SurfaceHov }, 0.1) end)
        hit.MouseLeave:Connect(function()  U.tw(row, { BackgroundColor3 = getT().SurfaceAlt }, 0.1) end)
        hit.MouseButton1Click:Connect(function()
            U.tw(badge, { BackgroundColor3 = getT().AccentDark }, 0.08)
            task.delay(0.2, function() U.tw(badge, { BackgroundColor3 = getT().Accent }, 0.12) end)
            if cfg.Callback then cfg.Callback() end
        end)
    end

    -- ─────────────────────────────────────────────────
    -- TOGGLE
    -- cfg: Name, CurrentValue, Callback
    -- Automatycznie wysyła powiadomienie po zmianie.
    -- Zwraca ref: ref:Set(bool), ref:Toggle(), ref:Get()
    -- ─────────────────────────────────────────────────
    function Tab:CreateToggle(cfg)
        local T   = getT()
        local val = cfg.CurrentValue or false

        local row = U.new("Frame", {
            Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = T.SurfaceAlt, ZIndex = 5,
        }, frame)
        U.corner(row, 8); U.stroke(row, T.Border)
        U.pad(row, 0, 0, 14, 14)

        U.new("TextLabel", {
            Size = UDim2.new(1, -60, 1, 0), BackgroundTransparency = 1,
            Text = cfg.Name or "Toggle", TextColor3 = T.Text,
            Font = FS, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6,
        }, row)

        local track = U.new("Frame", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0, 42, 0, 22),
            BackgroundColor3 = val and T.Toggle or T.AccentOff, ZIndex = 6,
        }, row)
        U.corner(track, 11)

        local knob = U.new("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position    = UDim2.new(0, val and 21 or 2, 0.5, 0),
            Size        = UDim2.new(0, 18, 0, 18),
            BackgroundColor3 = T.White, ZIndex = 7,
        }, track)
        U.corner(knob, 9)

        local function setVal(v)
            val = v
            local ct = getT()
            U.tw(track, { BackgroundColor3 = v and ct.Toggle or ct.AccentOff }, 0.14)
            U.tw(knob,  { Position = UDim2.new(0, v and 21 or 2, 0.5, 0) }, 0.14)
            if cfg.Callback then cfg.Callback(v) end
            -- Powiadomienie przy każdej zmianie
            if notifyFn then
                notifyFn(
                    v and "Włączono" or "Wyłączono",
                    cfg.Name or "Opcja",
                    v and "success" or "error"
                )
            end
        end

        local lastClick = 0
        U.new("TextButton", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 8,
        }, row).MouseButton1Click:Connect(function()
            local now = tick()
            if now - lastClick < 0.5 then return end
            lastClick = now
            setVal(not val)
        end)

        local ref = {}
        function ref:Set(v)    setVal(v)        end
        function ref:Toggle()  setVal(not val)  end
        function ref:Get()     return val       end
        return ref
    end

    -- ─────────────────────────────────────────────────
    -- SLIDER
    -- cfg: Name, Range {min,max}, Increment, Suffix, CurrentValue, Callback
    -- ─────────────────────────────────────────────────
    function Tab:CreateSlider(cfg)
        local T    = getT()
        local minV = cfg.Range and cfg.Range[1] or 0
        local maxV = cfg.Range and cfg.Range[2] or 100
        local inc  = cfg.Increment or 1
        local suf  = cfg.Suffix or ""
        local val  = math.clamp(cfg.CurrentValue or minV, minV, maxV)

        local row = U.new("Frame", {
            Size = UDim2.new(1, 0, 0, 52), BackgroundColor3 = T.SurfaceAlt, ZIndex = 5,
        }, frame)
        U.corner(row, 8); U.stroke(row, T.Border)
        U.pad(row, 8, 8, 14, 14)

        -- Wiersz z nazwą i wartością
        local topRow = U.new("Frame", {
            Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, ZIndex = 6,
        }, row)
        U.new("TextLabel", {
            Size = UDim2.new(0.6, 0, 1, 0), BackgroundTransparency = 1,
            Text = cfg.Name or "Slider", TextColor3 = T.Text,
            Font = FS, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 7,
        }, topRow)
        local valLbl = U.new("TextLabel", {
            AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.new(0.4, 0, 1, 0), BackgroundTransparency = 1,
            Text = tostring(val) .. suf, TextColor3 = T.Accent,
            Font = FB, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 7,
        }, topRow)

        local track = U.new("Frame", {
            Position = UDim2.new(0, 0, 0, 26), Size = UDim2.new(1, 0, 0, 5),
            BackgroundColor3 = T.Border, ZIndex = 6,
        }, row)
        U.corner(track, 3)

        local p0   = (maxV > minV) and (val - minV) / (maxV - minV) or 0
        local fill = U.new("Frame", {
            Size = UDim2.new(p0, 0, 1, 0), BackgroundColor3 = T.Accent, ZIndex = 7,
        }, track)
        U.corner(fill, 3)

        local thumb = U.new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(p0, 0, 0.5, 0),
            Size = UDim2.new(0, 13, 0, 13), BackgroundColor3 = T.White, ZIndex = 8,
        }, track)
        U.corner(thumb, 7); U.stroke(thumb, T.Accent, 2)

        local function update(v)
            v = math.clamp(math.round(v / inc) * inc, minV, maxV)
            val = v
            local p = (maxV > minV) and (v - minV) / (maxV - minV) or 0
            fill.Size      = UDim2.new(p, 0, 1, 0)
            thumb.Position = UDim2.new(p, 0, 0.5, 0)
            valLbl.Text    = tostring(v) .. suf
            if cfg.Callback then cfg.Callback(v) end
        end

        local dragging = false
        local hit = U.new("TextButton", {
            Position = UDim2.new(0, -8, 0, 18), Size = UDim2.new(1, 16, 0, 28),
            BackgroundTransparency = 1, Text = "", ZIndex = 9,
        }, row)
        hit.MouseButton1Down:Connect(function()
            dragging = true
            local abs = track.AbsolutePosition; local sz = track.AbsoluteSize
            if sz.X == 0 then return end
            update(minV + math.clamp((UIS:GetMouseLocation().X - abs.X) / sz.X, 0, 1) * (maxV - minV))
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        UIS.InputChanged:Connect(function(i)
            if not dragging or i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
            local abs = track.AbsolutePosition; local sz = track.AbsoluteSize
            if sz.X == 0 then return end
            update(minV + math.clamp((i.Position.X - abs.X) / sz.X, 0, 1) * (maxV - minV))
        end)
    end

    -- ─────────────────────────────────────────────────
    -- DROPDOWN
    -- cfg: Name, Options {string,...}, CurrentOption, Callback
    -- Zwraca ref: ref:Refresh(newOpts, reset), ref:GetCurrent()
    -- ─────────────────────────────────────────────────
    function Tab:CreateDropdown(cfg)
        local T       = getT()
        local options = cfg.Options or {}
        local current = cfg.CurrentOption or (options[1] or "")
        local open    = false
        local list    = nil

        local row = U.new("Frame", {
            Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = T.SurfaceAlt, ZIndex = 5,
        }, frame)
        U.corner(row, 8); U.stroke(row, T.Border)
        U.pad(row, 0, 0, 14, 14)

        U.new("TextLabel", {
            Size = UDim2.new(0.5, 0, 1, 0), BackgroundTransparency = 1,
            Text = cfg.Name or "Dropdown", TextColor3 = T.TextSub,
            Font = FS, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6,
        }, row)

        local selLbl = U.new("TextLabel", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -18, 0.5, 0),
            Size = UDim2.new(0.46, 0, 0, 16), BackgroundTransparency = 1,
            Text = current, TextColor3 = T.Text, Font = FS, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Right,
            TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 6,
        }, row)

        local arrow = U.new("TextLabel", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0, 16, 0, 16), BackgroundTransparency = 1,
            Text = "▾", TextColor3 = T.Muted, Font = FB, TextSize = 13, ZIndex = 6,
        }, row)

        local function closeDD()
            open = false; arrow.Text = "▾"
            if list and list.Parent then list:Destroy(); list = nil end
        end

        local function openDD()
            if list and list.Parent then list:Destroy(); list = nil end
            open = true; arrow.Text = "▴"
            local ct  = getT()
            local abs  = row.AbsolutePosition
            local absS = row.AbsoluteSize
            local h    = math.min(#options * 32 + 10, 160)
            list = U.new("ScrollingFrame", {
                Position             = UDim2.new(0, abs.X, 0, abs.Y + absS.Y + 4),
                Size                 = UDim2.new(0, absS.X, 0, h),
                BackgroundColor3     = ct.Surface,
                ScrollBarThickness   = 3, ScrollBarImageColor3 = ct.Border,
                CanvasSize           = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize  = Enum.AutomaticSize.Y,
                ClipsDescendants     = true, ZIndex = 400,
            }, overlay)
            U.corner(list, 8); U.stroke(list, ct.Border)
            U.pad(list, 4, 4, 4, 4); U.vlist(list, 2)

            for _, opt in ipairs(options) do
                local isSel = opt == current
                local item = U.new("TextButton", {
                    Size = UDim2.new(1, -8, 0, 28),
                    BackgroundColor3 = isSel and ct.Accent or ct.SurfaceAlt,
                    Text = opt, TextColor3 = isSel and ct.White or ct.Text,
                    Font = FS, TextSize = 12, AutoButtonColor = false, ZIndex = 401,
                }, list)
                U.corner(item, 6)
                item.MouseEnter:Connect(function()
                    if opt ~= current then U.tw(item, { BackgroundColor3 = getT().SurfaceHov }, 0.1) end
                end)
                item.MouseLeave:Connect(function()
                    if opt ~= current then U.tw(item, { BackgroundColor3 = getT().SurfaceAlt }, 0.1) end
                end)
                item.MouseButton1Click:Connect(function()
                    current = opt; selLbl.Text = opt
                    closeDD()
                    if cfg.Callback then cfg.Callback(opt) end
                end)
            end
        end

        U.new("TextButton", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 7,
        }, row).MouseButton1Click:Connect(function()
            if open then closeDD() else openDD() end
        end)

        UIS.InputBegan:Connect(function(i, gp)
            if gp or not open or i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            task.wait()
            if not open then return end
            local mx, my = i.Position.X, i.Position.Y
            local rp, rs = row.AbsolutePosition, row.AbsoluteSize
            local inRow  = mx >= rp.X and mx <= rp.X+rs.X and my >= rp.Y and my <= rp.Y+rs.Y
            if list and list.Parent then
                local lp2, ls = list.AbsolutePosition, list.AbsoluteSize
                local inList  = mx >= lp2.X and mx <= lp2.X+ls.X and my >= lp2.Y and my <= lp2.Y+ls.Y
                if not inRow and not inList then closeDD() end
            end
        end)

        local ref = {}
        function ref:Refresh(newOpts, reset)
            options = newOpts
            if reset or not table.find(options, current) then
                current = options[1] or ""; selLbl.Text = current
            end
            if open then closeDD() end
        end
        function ref:GetCurrent() return current end
        return ref
    end

    -- ─────────────────────────────────────────────────
    -- INPUT
    -- cfg: Name, Placeholder, Callback(text)
    -- ─────────────────────────────────────────────────
    function Tab:CreateInput(cfg)
        local T = getT()
        local row = U.new("Frame", {
            Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = T.SurfaceAlt, ZIndex = 5,
        }, frame)
        U.corner(row, 8); U.stroke(row, T.Border)
        U.pad(row, 0, 0, 14, 14)

        U.new("TextLabel", {
            Size = UDim2.new(0.45, 0, 1, 0), BackgroundTransparency = 1,
            Text = cfg.Name or "Input", TextColor3 = T.Text,
            Font = FS, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6,
        }, row)

        local box = U.new("Frame", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0, 130, 0, 26), BackgroundColor3 = T.Bg, ZIndex = 6,
        }, row)
        U.corner(box, 6); U.stroke(box, T.Border)
        U.pad(box, 0, 0, 8, 8)

        local tb = U.new("TextBox", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
            PlaceholderText = cfg.Placeholder or "...", PlaceholderColor3 = T.Muted,
            Text = "", TextColor3 = T.Text,
            Font = FR, TextSize = 13, ClearTextOnFocus = false, ZIndex = 7,
        }, box)
        tb.FocusLost:Connect(function(enter)
            if enter and cfg.Callback then cfg.Callback(tb.Text) end
        end)
    end

    -- ─────────────────────────────────────────────────
    -- KEYBIND
    -- cfg: Name, CurrentKey, OnPress, Callback(newKey)
    -- Kliknij pole → tryb nasłuchu → wciśnij klawisz
    -- Escape = anuluj
    -- ─────────────────────────────────────────────────
    function Tab:CreateKeybind(cfg)
        local T          = getT()
        local currentKey = cfg.CurrentKey or Enum.KeyCode.Unknown
        local listening  = false

        local row = U.new("Frame", {
            Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = T.SurfaceAlt, ZIndex = 5,
        }, frame)
        U.corner(row, 8); U.stroke(row, T.Border)
        U.pad(row, 0, 0, 14, 14)

        U.new("TextLabel", {
            Size = UDim2.new(1, -62, 1, 0), BackgroundTransparency = 1,
            Text = cfg.Name or "Keybind", TextColor3 = T.Text,
            Font = FS, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6,
        }, row)

        local keyBox = U.new("Frame", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0, 52, 0, 26), BackgroundColor3 = T.Bg, ZIndex = 6,
        }, row)
        U.corner(keyBox, 6); U.stroke(keyBox, T.Border)

        local keyLbl = U.new("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
            Text = currentKey == Enum.KeyCode.Unknown and "—" or currentKey.Name:sub(1, 6),
            TextColor3 = T.Text, Font = FB, TextSize = 11, ZIndex = 7,
        }, keyBox)

        UIS.InputBegan:Connect(function(input, gp)
            if listening then
                if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                listening = false
                if input.KeyCode == Enum.KeyCode.Escape then
                    keyLbl.Text = currentKey == Enum.KeyCode.Unknown and "—" or currentKey.Name:sub(1, 6)
                    U.tw(keyBox, { BackgroundColor3 = getT().Bg }, 0.1)
                    return
                end
                currentKey = input.KeyCode
                keyLbl.Text = currentKey.Name:sub(1, 6)
                U.tw(keyBox, { BackgroundColor3 = getT().Bg }, 0.1)
                if cfg.Callback then cfg.Callback(currentKey) end
            else
                if gp then return end
                if input.KeyCode == currentKey and currentKey ~= Enum.KeyCode.Unknown then
                    if cfg.OnPress then cfg.OnPress() end
                end
            end
        end)

        U.new("TextButton", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 8,
        }, row).MouseButton1Click:Connect(function()
            listening = true
            keyLbl.Text = "..."
            U.tw(keyBox, { BackgroundColor3 = getT().AccentDark }, 0.1)
        end)
    end

    return Tab
end

return E
