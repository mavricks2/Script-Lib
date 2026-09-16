--[[
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║                    COMPLETE UI LIBRARY v1.0                              ║
    ║                                                                           ║
    ║  Features:                                                                ║
    ║  ✓ Customizable Window (Width: 600px, Height: 400-500px)                 ║
    ║  ✓ Tabs with Lucide Icons (rbxassetid support)                           ║
    ║  ✓ Dynamic tab width based on text length                                ║
    ║  ✓ Toggle Switches with animations                                       ║
    ║  ✓ Sliders with value input                                              ║
    ║  ✓ Textboxes with callbacks                                              ║
    ║  ✓ Buttons with hover effects                                            ║
    ║  ✓ StatusBox with dynamic sizing                                         ║
    ║  ✓ Separators                                                            ║
    ║  ✓ Draggable Window                                                      ║
    ║  ✓ Smooth Animations & Transitions                                       ║
    ║                                                                           ║
    ║  Usage:                                                                   ║
    ║  local UILib = require(script)                                           ║
    ║  local window = UILib:CreateWindow({...})                                ║
    ║                                                                           ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")

----------------------------------------------------------------
-- THEME CONFIGURATION
----------------------------------------------------------------
local THEME = {
    Background   = Color3.fromRGB(18, 16, 28),
    Panel        = Color3.fromRGB(26, 22, 40),
    Accent       = Color3.fromRGB(148, 0, 211), -- Violet
    Dark         = Color3.fromRGB(15, 12, 20),
    Text         = Color3.fromRGB(235, 235, 245),
    SubText      = Color3.fromRGB(160, 155, 180),
    ToggleOff    = Color3.fromRGB(60, 55, 75),
    Success      = Color3.fromRGB(76, 175, 80),
    Error        = Color3.fromRGB(244, 67, 54),
    Warning      = Color3.fromRGB(255, 152, 0),
}

-- Global variables for easy access
_G.Primary = THEME.Panel
_G.Dark = THEME.Dark
_G.Accent = THEME.Accent

----------------------------------------------------------------
-- LIBRARY STRUCTURE
----------------------------------------------------------------
local LibraryUI = {}

function LibraryUI:CreateWindow(config)
    config = config or {}
    local windowName = config.Name or "UI Library"
    local windowWidth = config.Width or 600
    local windowHeight = config.Height or 450
    
    ----------------------------------------------------------------
    -- ROOT GUI
    ----------------------------------------------------------------
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LibraryGui"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game:GetService("CoreGui")

    local MainWindow = Instance.new("Frame")
    MainWindow.Name = "MainWindow"
    MainWindow.Size = UDim2.new(0, windowWidth, 0, windowHeight)
    MainWindow.Position = UDim2.new(0.5, -windowWidth/2, 0.5, -windowHeight/2)
    MainWindow.BackgroundColor3 = THEME.Background
    MainWindow.BorderSizePixel = 0
    MainWindow.Parent = ScreenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 14)
    mainCorner.Parent = MainWindow

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = THEME.Accent
    mainStroke.Thickness = 1.5
    mainStroke.Transparency = 0.3
    mainStroke.Parent = MainWindow

    ----------------------------------------------------------------
    -- TITLE BAR (DRAGGABLE)
    ----------------------------------------------------------------
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 42)
    TitleBar.BackgroundColor3 = THEME.Panel
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainWindow

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 14)
    titleCorner.Parent = TitleBar

    local titleFix = Instance.new("Frame")
    titleFix.Size = UDim2.new(1, 0, 0, 14)
    titleFix.Position = UDim2.new(0, 0, 1, -14)
    titleFix.BackgroundColor3 = THEME.Panel
    titleFix.BorderSizePixel = 0
    titleFix.ZIndex = 0
    titleFix.Parent = TitleBar

    local TitleText = Instance.new("TextLabel")
    TitleText.BackgroundTransparency = 1
    TitleText.Position = UDim2.new(0, 15, 0, 0)
    TitleText.Size = UDim2.new(1, -30, 1, 0)
    TitleText.Font = Enum.Font.GothamBold
    TitleText.Text = windowName
    TitleText.TextColor3 = THEME.Text
    TitleText.TextSize = 16
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar

    -- Drag logic
    do
        local dragging, dragStart, startPos
        TitleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = MainWindow.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                MainWindow.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)
    end

    ----------------------------------------------------------------
    -- TAB BAR - DYNAMIC WIDTH SUPPORT
    ----------------------------------------------------------------
    local TabBar = Instance.new("Frame")
    TabBar.Name = "TabBar"
    TabBar.Size = UDim2.new(1, -20, 0, 40)
    TabBar.Position = UDim2.new(0, 10, 0, 50)
    TabBar.BackgroundColor3 = THEME.Panel
    TabBar.BorderSizePixel = 0
    TabBar.ClipsDescendants = true
    TabBar.Parent = MainWindow

    local tabBarCorner = Instance.new("UICorner")
    tabBarCorner.CornerRadius = UDim.new(0, 10)
    tabBarCorner.Parent = TabBar

    local TabHighlight = Instance.new("Frame")
    TabHighlight.Name = "TabHighlight"
    TabHighlight.BackgroundColor3 = THEME.Accent
    TabHighlight.BorderSizePixel = 0
    TabHighlight.ZIndex = 1
    TabHighlight.Size = UDim2.new(0, 60, 0, 28)
    TabHighlight.Position = UDim2.new(0, 10, 0, 6)
    TabHighlight.Parent = TabBar

    local highlightCorner = Instance.new("UICorner")
    highlightCorner.CornerRadius = UDim.new(0, 6)
    highlightCorner.Parent = TabHighlight

    local highlightStroke = Instance.new("UIStroke")
    highlightStroke.Color = THEME.Accent
    highlightStroke.Thickness = 1.5
    highlightStroke.Parent = TabHighlight

    ----------------------------------------------------------------
    -- CONTENT AREA
    ----------------------------------------------------------------
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -20, 1, -100)
    ContentArea.Position = UDim2.new(0, 10, 0, 98)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainWindow
    ContentArea.ClipsDescendants = true

    ----------------------------------------------------------------
    -- LIBRARY METHODS
    ----------------------------------------------------------------
    local pages = {}
    local tabButtons = {}
    local tabPositions = {}
    local tabOrder = {}
    local activeTab = nil

    local function createPage(name)
        local page = Instance.new("ScrollingFrame")
        page.Name = name .. "Page"
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = THEME.Accent
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.Visible = false
        page.Parent = ContentArea

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 8)
        layout.Parent = page

        local pagePadding = Instance.new("UIPadding")
        pagePadding.PaddingLeft = UDim.new(0, 6)
        pagePadding.PaddingRight = UDim.new(0, 6)
        pagePadding.PaddingTop = UDim.new(0, 6)
        pagePadding.PaddingBottom = UDim.new(0, 6)
        pagePadding.Parent = page

        pages[name] = page
        return page
    end

    local function selectTab(name)
        if activeTab == name then return end
        activeTab = name

        for tabName, page in pairs(pages) do
            page.Visible = (tabName == name)
        end

        local pos = tabPositions[name]
        
        TweenService:Create(TabHighlight, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, pos.x, 0, 6),
            Size = UDim2.new(0, pos.width, 0, 28),
        }):Play()

        for tabName, tabBtn in pairs(tabButtons) do
            TweenService:Create(tabBtn.label, TweenInfo.new(0.2), {
                TextColor3 = (tabName == name) and THEME.Text or THEME.SubText
            }):Play()
            if tabBtn.icon then
                TweenService:Create(tabBtn.icon, TweenInfo.new(0.2), {
                    ImageColor3 = (tabName == name) and THEME.Text or THEME.SubText
                }):Play()
            end
        end
    end

    local windowApi = {}

    function windowApi:AddTab(tabName, iconId)
        local page = createPage(tabName)
        
        local tabIndex = #tabOrder + 1
        local TabButton = Instance.new("Frame")
        TabButton.Name = tabName .. "Tab"
        TabButton.Size = UDim2.new(0, 100, 0, 30) -- Will be adjusted based on text
        TabButton.BackgroundTransparency = 1
        TabButton.Parent = TabBar
        TabButton.ZIndex = 2

        -- Tab Icon
        local tabIcon = nil
        local tabLabelPosition = 0
        
        if iconId then
            tabIcon = Instance.new("ImageLabel")
            tabIcon.BackgroundTransparency = 1
            tabIcon.Size = UDim2.new(0, 16, 0, 16)
            tabIcon.Position = UDim2.new(0, 8, 0.5, -8)
            tabIcon.Image = iconId
            tabIcon.ImageColor3 = THEME.SubText
            tabIcon.Parent = TabButton
            tabLabelPosition = 28
        else
            tabLabelPosition = 8
        end

        -- Tab Label
        local tabLabel = Instance.new("TextLabel")
        tabLabel.BackgroundTransparency = 1
        tabLabel.Position = UDim2.new(0, tabLabelPosition, 0.5, 0)
        tabLabel.AnchorPoint = Vector2.new(0, 0.5)
        tabLabel.Size = UDim2.new(1, -tabLabelPosition - 8, 1, 0)
        tabLabel.Font = Enum.Font.GothamMedium
        tabLabel.Text = tabName
        tabLabel.TextSize = 12
        tabLabel.TextColor3 = THEME.SubText
        tabLabel.TextXAlignment = Enum.TextXAlignment.Left
        tabLabel.Parent = TabButton

        -- Calculate tab width based on text
        task.wait(0.01) -- Wait for text to render
        local textBounds = tabLabel.TextBounds.X
        local tabWidth = 0
        
        if iconId then
            -- With icon: TextBounds + 52 pixels (icon + padding)
            tabWidth = textBounds + 52
        else
            -- Without icon: TextBounds + 30 pixels
            tabWidth = textBounds + 30
        end
        
        TabButton.Size = UDim2.new(0, tabWidth, 0, 30)

        local tabClickArea = Instance.new("TextButton")
        tabClickArea.BackgroundTransparency = 1
        tabClickArea.Size = UDim2.new(1, 0, 1, 0)
        tabClickArea.Text = ""
        tabClickArea.Parent = TabButton

        -- Calculate X position based on previous tabs
        local xPos = 10
        for i = 1, tabIndex - 1 do
            xPos = xPos + tabPositions[tabOrder[i]].width + 4 -- 4px gap between tabs
        end

        TabButton.Position = UDim2.new(0, xPos, 0, 5)
        tabButtons[tabName] = { button = TabButton, icon = tabIcon, label = tabLabel }
        tabPositions[tabName] = { x = xPos, width = tabWidth }
        table.insert(tabOrder, tabName)

        tabClickArea.MouseButton1Click:Connect(function()
            selectTab(tabName)
        end)

        -- Update hover effects
        tabClickArea.MouseEnter:Connect(function()
            if activeTab ~= tabName then
                TweenService:Create(tabLabel, TweenInfo.new(0.2), {
                    TextColor3 = THEME.Text
                }):Play()
                if tabIcon then
                    TweenService:Create(tabIcon, TweenInfo.new(0.2), {
                        ImageColor3 = THEME.Text
                    }):Play()
                end
            end
        end)

        tabClickArea.MouseLeave:Connect(function()
            if activeTab ~= tabName then
                TweenService:Create(tabLabel, TweenInfo.new(0.2), {
                    TextColor3 = THEME.SubText
                }):Play()
                if tabIcon then
                    TweenService:Create(tabIcon, TweenInfo.new(0.2), {
                        ImageColor3 = THEME.SubText
                    }):Play()
                end
            end
        end)

        local pageApi = {}

        ----------------------------------------------------------------
        -- TOGGLE COMPONENT
        ----------------------------------------------------------------
        function pageApi:AddToggle(labelText, default, onChange)
            local Row = Instance.new("Frame")
            Row.Size = UDim2.new(1, 0, 0, 40)
            Row.BackgroundColor3 = THEME.Panel
            Row.BorderSizePixel = 0
            Row.Parent = page

            local rowCorner = Instance.new("UICorner")
            rowCorner.CornerRadius = UDim.new(0, 8)
            rowCorner.Parent = Row

            local Label = Instance.new("TextLabel")
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 14, 0, 0)
            Label.Size = UDim2.new(1, -90, 1, 0)
            Label.Font = Enum.Font.Gotham
            Label.Text = labelText
            Label.TextColor3 = THEME.Text
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Row

            local Track = Instance.new("Frame")
            Track.Size = UDim2.new(0, 42, 0, 22)
            Track.Position = UDim2.new(1, -54, 0.5, -11)
            Track.BackgroundColor3 = default and THEME.Accent or THEME.ToggleOff
            Track.BorderSizePixel = 0
            Track.Parent = Row

            local trackCorner = Instance.new("UICorner")
            trackCorner.CornerRadius = UDim.new(1, 0)
            trackCorner.Parent = Track

            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 18, 0, 18)
            Knob.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
            Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Knob.BorderSizePixel = 0
            Knob.Parent = Track

            local knobCorner = Instance.new("UICorner")
            knobCorner.CornerRadius = UDim.new(1, 0)
            knobCorner.Parent = Knob

            local Click = Instance.new("TextButton")
            Click.BackgroundTransparency = 1
            Click.Size = UDim2.new(1, 0, 1, 0)
            Click.Text = ""
            Click.Parent = Row

            local state = default and true or false

            local function render(instant)
                local knobGoal = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
                local trackColorGoal = state and THEME.Accent or THEME.ToggleOff
                if instant then
                    Knob.Position = knobGoal
                    Track.BackgroundColor3 = trackColorGoal
                else
                    TweenService:Create(Knob, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Position = knobGoal
                    }):Play()
                    TweenService:Create(Track, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundColor3 = trackColorGoal
                    }):Play()
                end
            end

            Click.MouseButton1Click:Connect(function()
                state = not state
                render(false)
                if onChange then
                    onChange(state)
                end
            end)

            render(true)
            
            local toggleApi = {}
            function toggleApi:SetValue(value)
                state = value
                render(false)
                if onChange then onChange(state) end
            end
            function toggleApi:GetValue()
                return state
            end
            
            return toggleApi
        end

        ----------------------------------------------------------------
        -- SLIDER COMPONENT
        ----------------------------------------------------------------
        function pageApi:AddSlider(labelText, minVal, maxVal, defaultVal, onChange)
            local frame = Instance.new("Frame")
            frame.Parent = page
            frame.Name = "Slider"
            frame.Size = UDim2.new(1, 0, 0, 45)
            frame.BackgroundTransparency = 1

            local corner = Instance.new("UICorner"); corner.Parent = frame; corner.CornerRadius = UDim.new(0, 8)

            local sliderBg = Instance.new("Frame")
            sliderBg.Parent = frame
            sliderBg.Name = "sliderBg"
            sliderBg.Size = UDim2.new(1, 0, 0, 45)
            sliderBg.BackgroundColor3 = THEME.Panel
            sliderBg.BackgroundTransparency = 0
            local sbCorner = Instance.new("UICorner"); sbCorner.Parent = sliderBg; sbCorner.CornerRadius = UDim.new(0, 8)

            local label = Instance.new("TextLabel")
            label.Parent = sliderBg
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0, 15, 0.5, 0)
            label.AnchorPoint = Vector2.new(0, 0.5)
            label.Size = UDim2.new(1, 0, 0, 30)
            label.Font = Enum.Font.GothamSemibold
            label.Text = labelText
            label.TextColor3 = THEME.Text
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left

            local outerBar = Instance.new("Frame")
            outerBar.Parent = sliderBg
            outerBar.Name = "bar"
            outerBar.Size = UDim2.new(0, 110, 0, 4)
            outerBar.Position = UDim2.new(1, -10, 0.5, 10)
            outerBar.AnchorPoint = Vector2.new(1, 0.5)
            outerBar.BackgroundColor3 = THEME.Dark
            outerBar.BackgroundTransparency = 0.3
            local obCorner = Instance.new("UICorner"); obCorner.Parent = outerBar; obCorner.CornerRadius = UDim.new(0, 5)

            minVal = tonumber(minVal) or 0
            maxVal = tonumber(maxVal) or 100
            defaultVal = tonumber(defaultVal) or minVal
            local range = maxVal - minVal
            local normalized = 0
            if range ~= 0 then normalized = (defaultVal - minVal) / range end

            local fill = Instance.new("Frame")
            fill.Parent = outerBar
            fill.Name = "bar1"
            fill.Size = UDim2.new(math.clamp(normalized, 0, 1), 0, 0, 4)
            fill.BackgroundColor3 = THEME.Accent
            local fillCorner = Instance.new("UICorner"); fillCorner.Parent = fill; fillCorner.CornerRadius = UDim.new(0, 5)

            local handle = Instance.new("Frame")
            handle.Parent = fill
            handle.Name = "circlebar"
            handle.Size = UDim2.new(0, 14, 0, 14)
            handle.Position = UDim2.new(1, 0, 0, -5)
            handle.AnchorPoint = Vector2.new(0.5, 0)
            handle.BackgroundColor3 = THEME.Accent
            local handleCorner = Instance.new("UICorner"); handleCorner.Parent = handle; handleCorner.CornerRadius = UDim.new(0, 100)

            local valueBox = Instance.new("TextBox")
            valueBox.Parent = sliderBg
            valueBox.BackgroundColor3 = THEME.Dark
            valueBox.BackgroundTransparency = 0.1
            valueBox.Font = Enum.Font.Code
            valueBox.Size = UDim2.new(0, 35, 0, 15)
            valueBox.AnchorPoint = Vector2.new(1, 0.5)
            valueBox.Position = UDim2.new(1, -10, 0.5, -10)
            valueBox.TextColor3 = THEME.Text
            valueBox.TextSize = 9
            valueBox.Text = tostring(defaultVal)
            valueBox.ClearTextOnFocus = false
            valueBox.TextXAlignment = Enum.TextXAlignment.Center
            local vbCorner = Instance.new("UICorner"); vbCorner.Parent = valueBox; vbCorner.CornerRadius = UDim.new(0, 3)

            local sliding = false

            local function updateSlider(input)
                local relX = math.clamp(input.Position.X - outerBar.AbsolutePosition.X, 0, outerBar.AbsoluteSize.X)
                local value = math.floor(relX / outerBar.AbsoluteSize.X * (range) + minVal)
                pcall(onChange, value)
                valueBox.Text = tostring(value)
                fill.Size = UDim2.new(0, math.clamp(relX, 0, outerBar.AbsoluteSize.X), 0, 4)
                handle.Position = UDim2.new(0, math.clamp(relX - 5, 0, outerBar.AbsoluteSize.X), 0, -5)
            end

            handle.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                end
            end)
            outerBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    updateSlider(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input)
                end
            end)

            valueBox.FocusLost:Connect(function()
                local num = tonumber(valueBox.Text) or defaultVal
                if num > maxVal then num = maxVal end
                if num < minVal then num = minVal end
                local frac = 0
                if range ~= 0 then frac = (num - minVal) / range end
                fill.Size = UDim2.new(frac, 0, 0, 4)
                handle.Position = UDim2.new(frac, 0, 0, -5)
                valueBox.Text = tostring(num)
                pcall(onChange, num)
            end)

            pcall(function() if onChange then onChange(defaultVal) end end)
            
            local sliderApi = {}
            function sliderApi:SetValue(value)
                value = math.clamp(value, minVal, maxVal)
                local frac = 0
                if range ~= 0 then frac = (value - minVal) / range end
                fill.Size = UDim2.new(frac, 0, 0, 4)
                handle.Position = UDim2.new(frac, 0, 0, -5)
                valueBox.Text = tostring(value)
                pcall(onChange, value)
            end
            function sliderApi:GetValue()
                return tonumber(valueBox.Text)
            end
            
            return sliderApi
        end

        ----------------------------------------------------------------
        -- TEXTBOX COMPONENT
        ----------------------------------------------------------------
        function pageApi:AddTextbox(labelText, onConfirm)
            local frame = Instance.new("Frame")
            frame.Parent = page
            frame.Name = "Textbox"
            frame.BackgroundColor3 = THEME.Panel
            frame.BackgroundTransparency = 0
            frame.Size = UDim2.new(1, 0, 0, 35)
            local corner = Instance.new("UICorner"); corner.Parent = frame; corner.CornerRadius = UDim.new(0, 8)

            local label = Instance.new("TextLabel")
            label.Name = "TextboxLabel"
            label.Parent = frame
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0, 15, 0.5, 0)
            label.Text = labelText
            label.Size = UDim2.new(1, 0, 0, 35)
            label.Font = Enum.Font.GothamSemibold
            label.AnchorPoint = Vector2.new(0, 0.5)
            label.TextColor3 = THEME.Text
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left

            local realBox = Instance.new("TextBox")
            realBox.Name = "RealTextbox"
            realBox.Parent = frame
            realBox.BackgroundColor3 = THEME.Dark
            realBox.BackgroundTransparency = 0.1
            realBox.Position = UDim2.new(1, -5, 0.5, 0)
            realBox.AnchorPoint = Vector2.new(1, 0.5)
            realBox.Size = UDim2.new(0, 80, 0, 25)
            realBox.Font = Enum.Font.GothamSemibold
            realBox.Text = ""
            realBox.TextColor3 = THEME.Text
            realBox.TextSize = 11
            realBox.ClearTextOnFocus = false
            realBox.TextXAlignment = Enum.TextXAlignment.Center
            realBox.ClipsDescendants = true
            local realCorner = Instance.new("UICorner"); realCorner.Parent = realBox; realCorner.CornerRadius = UDim.new(0, 5)

            realBox.FocusLost:Connect(function()
                pcall(onConfirm, realBox.Text)
            end)
            
            local textboxApi = {}
            function textboxApi:SetValue(value)
                realBox.Text = tostring(value)
            end
            function textboxApi:GetValue()
                return realBox.Text
            end
            
            return textboxApi
        end

        ----------------------------------------------------------------
        -- BUTTON COMPONENT
        ----------------------------------------------------------------
        function pageApi:AddButton(text, callback)
            local frame = Instance.new("Frame")
            frame.Name = "Button"
            frame.Parent = page
            frame.BackgroundColor3 = THEME.Panel
            frame.BackgroundTransparency = 0
            frame.Size = UDim2.new(1, 0, 0, 36)
            local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 8); corner.Parent = frame

            local label = Instance.new("TextLabel")
            label.Name = "TextLabel"
            label.Parent = frame
            label.BackgroundTransparency = 1
            label.AnchorPoint = Vector2.new(0, 0.5)
            label.Position = UDim2.new(0, 15, 0.5, 0)
            label.Size = UDim2.new(1, -40, 1, 0)
            label.Font = Enum.Font.GothamSemibold
            label.Text = text
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextColor3 = THEME.Text
            label.TextSize = 13

            local btn = Instance.new("TextButton")
            btn.Name = "TextButton"
            btn.Parent = frame
            btn.BackgroundColor3 = THEME.Accent
            btn.BackgroundTransparency = 0
            btn.AnchorPoint = Vector2.new(1, 0.5)
            btn.Position = UDim2.new(1, -10, 0.5, 0)
            btn.Size = UDim2.new(0, 22, 0, 22)
            btn.AutoButtonColor = false

            local btnCorner = Instance.new("UICorner"); btnCorner.CornerRadius = UDim.new(0, 6); btnCorner.Parent = btn

            local img = Instance.new("ImageLabel")
            img.Name = "ImageLabel"
            img.Parent = btn
            img.BackgroundTransparency = 1
            img.AnchorPoint = Vector2.new(0.5, 0.5)
            img.Position = UDim2.new(0.5, 0, 0.5, 0)
            img.Size = UDim2.new(0, 15, 0, 15)
            img.Image = "rbxassetid://10723375250"
            img.ImageTransparency = 0.05
            img.ImageColor3 = THEME.Text

            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(168, 20, 231)
                }):Play()
            end)

            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.2), {
                    BackgroundColor3 = THEME.Accent
                }):Play()
            end)

            btn.MouseButton1Click:Connect(function()
                pcall(callback)
            end)
            
            local buttonApi = {}
            function buttonApi:SetCallback(newCallback)
                btn.MouseButton1Click:Connect(function()
                    pcall(newCallback)
                end)
            end
            
            return buttonApi
        end

        ----------------------------------------------------------------
        -- STATUS BOX COMPONENT
        ----------------------------------------------------------------
        function pageApi:AddStatusBox(titleText, initialText, textColor)
            initialText = tostring(initialText or "")
            local container = Instance.new("Frame")
            container.Name = "StatusBox"
            container.Parent = page
            container.BackgroundColor3 = THEME.Panel
            container.BackgroundTransparency = 0
            container.Size = UDim2.new(1, 0, 0, 60)
            local corner = Instance.new("UICorner"); corner.Parent = container; corner.CornerRadius = UDim.new(0, 8)

            local title = Instance.new("TextLabel")
            title.Parent = container
            title.BackgroundTransparency = 1
            title.Position = UDim2.new(0, 10, 0, 6)
            title.Size = UDim2.new(1, -20, 0, 18)
            title.Font = Enum.Font.GothamSemibold
            title.Text = titleText or "Status"
            title.TextColor3 = THEME.Text
            title.TextSize = 12
            title.TextXAlignment = Enum.TextXAlignment.Left

            local content = Instance.new("TextLabel")
            content.Parent = container
            content.Name = "StatusContent"
            content.BackgroundTransparency = 1
            content.Position = UDim2.new(0, 15, 0, 28)
            content.Size = UDim2.new(1, -30, 0, 20)
            content.Font = Enum.Font.Code
            content.TextWrapped = true
            content.TextXAlignment = Enum.TextXAlignment.Left
            content.TextYAlignment = Enum.TextYAlignment.Top
            content.TextColor3 = textColor or THEME.SubText
            content.TextSize = 10
            content.Text = initialText

            local function refreshSize()
                local txt = tostring(content.Text or "")
                local textSize = TextService:GetTextSize(txt, content.TextSize, content.Font, Vector2.new(content.AbsoluteSize.X, 1e6))
                local totalHeight = 18 + 10 + textSize.Y + 8
                container.Size = UDim2.new(1, 0, 0, math.max(60, totalHeight))
                content.Size = UDim2.new(1, -30, 0, textSize.Y)
            end

            RunService.Heartbeat:Wait()
            refreshSize()

            local api = {}
            function api:Set(newText)
                content.Text = tostring(newText or "")
                RunService.Heartbeat:Wait()
                refreshSize()
                return api
            end
            function api:Append(moreText)
                content.Text = content.Text .. tostring(moreText or "")
                RunService.Heartbeat:Wait()
                refreshSize()
                return api
            end
            function api:Clear()
                content.Text = ""
                refreshSize()
                return api
            end
            function api:GetText()
                return content.Text
            end
            function api:SetColor(clr)
                if typeof(clr) == "Color3" then
                    content.TextColor3 = clr
                end
                return api
            end

            return api
        end

        ----------------------------------------------------------------
        -- SEPARATOR COMPONENT
        ----------------------------------------------------------------
        function pageApi:AddSeparator(height)
            height = height or 2
            local separator = Instance.new("Frame")
            separator.Parent = page
            separator.Name = "Separator"
            separator.Size = UDim2.new(1, 0, 0, height + 10)
            separator.BackgroundTransparency = 1

            local line = Instance.new("Frame")
            line.Parent = separator
            line.Size = UDim2.new(0.8, 0, 0, height)
            line.Position = UDim2.new(0.1, 0, 0.5, 0)
            line.AnchorPoint = Vector2.new(0, 0.5)
            line.BackgroundColor3 = THEME.Accent
            line.BorderSizePixel = 0
            line.BackgroundTransparency = 0.5

            local lineCorner = Instance.new("UICorner")
            lineCorner.CornerRadius = UDim.new(0, 2)
            lineCorner.Parent = line
        end

        ----------------------------------------------------------------
        -- LABEL COMPONENT
        ----------------------------------------------------------------
        function pageApi:AddLabel(text, textSize)
            textSize = textSize or 14
            local labelFrame = Instance.new("Frame")
            labelFrame.Parent = page
            labelFrame.Name = "Label"
            labelFrame.Size = UDim2.new(1, 0, 0, 30)
            labelFrame.BackgroundTransparency = 1

            local label = Instance.new("TextLabel")
            label.Parent = labelFrame
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0, 10, 0, 0)
            label.Size = UDim2.new(1, -20, 1, 0)
            label.Font = Enum.Font.GothamSemibold
            label.Text = text
            label.TextColor3 = THEME.Text
            label.TextSize = textSize
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextWrapped = true
        end

        return pageApi
    end

    -- Initialize first tab
    task.defer(function()
        task.wait()
        if #tabOrder > 0 then
            selectTab(tabOrder[1])
        end
    end)

    return windowApi
end

return LibraryUI
