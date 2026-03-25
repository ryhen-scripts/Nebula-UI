--[[
    Nebula UI Suite
    Created by Ryhen
    Version: 1.0.0
    
    A premium, original, and modern UI library for Roblox.
    Inspired by the colors of the universe.
--]]

local Nebula = {
    Version = "1.0.0",
    Themes = {
        Space = {
            Main = Color3.fromRGB(20, 20, 20), -- Charcoal
            Accent = Color3.fromRGB(140, 80, 255),
            Secondary = Color3.fromRGB(255, 100, 210),
            Text = Color3.fromRGB(255, 255, 255),
            SubText = Color3.fromRGB(160, 160, 160),
            Border = Color3.fromRGB(45, 45, 45),
            Holder = Color3.fromRGB(28, 28, 28),
            Element = Color3.fromRGB(35, 35, 35),
        }
    },
    CurrentTheme = "Space",
    Windows = {},
    Unloaded = false,
}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local CoreGui = game:GetService("CoreGui")

local function GetHUI()
    if gethui then return gethui() end
    if (not game:GetService("RunService"):IsStudio()) and CoreGui:FindFirstChild("RobloxGui") then
        return CoreGui.RobloxGui
    end
    return PlayerGui
end

local function RandomString(length)
    local res = ""
    for i = 1, length do
        res = res .. string.char(math.random(97, 122))
    end
    return res
end

-- UTILITIES
local function Create(className, properties, children)
    local instance = Instance.new(className)
    for k, v in pairs(properties or {}) do
        instance[k] = v
    end
    for _, child in pairs(children or {}) do
        child.Parent = instance
    end
    return instance
}

function Nebula:Tween(obj, info, goal)
    local tween = TweenService:Create(obj, info, goal)
    tween:Play()
    return tween
}

function Nebula:MakeDraggable(obj, dragPart)
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    dragPart.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragPart.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- CORE MODULES
local Components = {}

function Nebula:CreateWindow(config)
    config = config or {}
    local Title = config.Title or "Nebula Suite"
    local SubTitle = config.SubTitle or "Version 1.0"
    local Size = config.Size or UDim2.fromOffset(580, 460)
    local Theme = Nebula.Themes[Nebula.CurrentTheme]

    local ScreenGui = Create("ScreenGui", {
        Name = RandomString(12),
        Parent = GetHUI(),
        ResetOnSpawn = false,
        DisplayOrder = 100
    })
    ScreenGui:SetAttribute("NebulaUI", true)

    local Main = Create("CanvasGroup", {
        Name = "Main",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Main,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(0.8, 0.8), -- Animation target
        GroupTransparency = 1,
        Parent = ScreenGui
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 12)}),
        Create("UIStroke", {
            Color = Theme.Border,
            Thickness = 1.5,
            Transparency = 0.4
        })
    })

    -- Glassmorphism Background
    local Bloom = Create("ImageLabel", {
        Name = "Bloom",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 100, 1, 100),
        Image = "rbxassetid://6015667151",
        ImageColor3 = Theme.Accent,
        ImageTransparency = 0.7,
        ZIndex = 0,
        Parent = Main
    })

    -- Header
    local Header = Create("Frame", {
        Name = "Header",
        BackgroundColor3 = Theme.Holder,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 0.5,
        Parent = Main
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 12)}),
        Create("Frame", { -- Separator
            BackgroundColor3 = Theme.Border,
            Position = UDim2.new(0, 0, 1, -1),
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundTransparency = 0.5
        })
    })

    local TitleLabel = Create("TextLabel", {
        Name = "Title",
        Font = Enum.Font.GothamBold,
        Text = Title,
        TextColor3 = Theme.Text,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(15, 0),
        Size = UDim2.new(1, -30, 0.6, 0),
        BackgroundTransparency = 1,
        Parent = Header
    })

    local SubTitleLabel = Create("TextLabel", {
        Name = "SubTitle",
        Font = Enum.Font.Gotham,
        Text = SubTitle,
        TextColor3 = Theme.SubText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(15, 24),
        Size = UDim2.new(1, -150, 0.4, 0),
        BackgroundTransparency = 1,
        Parent = Header
    })

    -- Header Controls
    local Controls = Create("Frame", {
        Name = "Controls",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -10, 0, 10),
        Size = UDim2.fromOffset(120, 25),
        BackgroundTransparency = 1,
        Parent = Header
    }, {
        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 10)
        })
    })

    local function CreateHeaderBtn(name, icon, callback)
        local btn = Create("ImageButton", {
            Name = name,
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(20, 20),
            Image = icon,
            ImageColor3 = Theme.SubText,
            Parent = Controls
        })
        btn.MouseButton1Click:Connect(callback)
        btn.MouseEnter:Connect(function() Nebula:Tween(btn, TweenInfo.new(0.2), {ImageColor3 = Theme.Accent}) end)
        btn.MouseLeave:Connect(function() Nebula:Tween(btn, TweenInfo.new(0.2), {ImageColor3 = Theme.SubText}) end)
        return btn
    end

    local SearchBtn = CreateHeaderBtn("Search", "rbxassetid://10723374668", function() print("Search clicked") end)
    local MinimizeBtn = CreateHeaderBtn("Minimize", "rbxassetid://10734896206", function()
        local Visible = (Main.GroupTransparency < 0.5)
        if Visible then
            Nebula:Tween(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Size = UDim2.fromScale(0.7, 0.7),
                GroupTransparency = 1
            })
        else
            Nebula:Tween(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
                Size = Size,
                GroupTransparency = 0
            })
        end
    end)
    local CloseBtn = CreateHeaderBtn("Close", "rbxassetid://10747384390", function()
        Nebula:Tween(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.fromScale(0.5, 0.5),
            GroupTransparency = 1
        }).Completed:Connect(function() ScreenGui:Destroy() end)
    end)

    -- Navigation Container
    local Navigation = Create("Frame", {
        Name = "Navigation",
        BackgroundColor3 = Theme.Holder,
        BackgroundTransparency = 0.8,
        Position = UDim2.fromOffset(10, 60),
        Size = UDim2.new(0, 150, 1, -70),
        Parent = Main
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 10)}),
        Create("UIListLayout", {
            Padding = UDim.new(0, 5),
            SortOrder = Enum.SortOrder.LayoutOrder
        }),
        Create("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10)
        })
    })

    -- Container
    local Container = Create("ScrollingFrame", {
        Name = "Container",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(170, 60),
        Size = UDim2.new(1, -180, 1, -70),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = Main
    }, {
        Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder
        }),
        Create("UIPadding", {
            PaddingTop = UDim.new(0, 5),
            PaddingBottom = UDim.new(0, 5),
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2)
        })
    })

    -- Dragging
    Nebula:MakeDraggable(Main, Header)

    -- Animation In
    Main.Size = UDim2.new(0.7, 0, 0.7, 0)
    Nebula:Tween(Main, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = Size,
        GroupTransparency = 0
    })

    -- Window Object
    local Window = {
        Tabs = {},
        SelectedTab = nil,
        Main = Main,
        OnSearch = function() end
    }

    function Window:SetSearchCallback(callback)
        Window.OnSearch = callback
    end

    function Window:AddDock(config)
        Window.Dock = Nebula:CreateDock(config)
        for _, tab in ipairs(Window.Tabs) do
            Window.Dock:AddIcon(tab.Name, tab.Icon, function() tab:Select() end)
        end
        return Window.Dock
    end

    function Window:AddTab(options)
        options = options or {}
        local Name = options.Title or "Tab"
        local Icon = options.Icon or ""

        local TabButton = Create("TextButton", {
            Name = Name,
            BackgroundColor3 = Theme.Element,
            BackgroundTransparency = 0.8,
            Size = UDim2.new(1, 0, 0, 32),
            Text = "",
            Parent = Navigation
        }, {
            Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
            Create("ImageLabel", {
                Name = "Icon",
                Size = UDim2.fromOffset(18, 18),
                Position = UDim2.fromOffset(8, 7),
                BackgroundTransparency = 1,
                Image = Icon ~= "" and Icon or "rbxassetid://10709791437", -- Default icon
                ImageColor3 = Theme.SubText,
                Parent = TabButton
            }),
            Create("TextLabel", {
                Text = Name,
                Font = Enum.Font.GothamMedium,
                TextColor3 = Theme.SubText,
                TextSize = 13,
                Size = UDim2.new(1, -30, 1, 0),
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(32, 0),
                TextXAlignment = Enum.TextXAlignment.Left
            })
        })

        local TabFrame = Create("Frame", {
            Name = Name .. "Frame",
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = Container
        }, {
            Create("UIListLayout", {
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
        })

        local Tab = {
            Name = Name,
            Icon = Icon,
            Button = TabButton,
            Frame = TabFrame,
            Elements = {},
            StoredElements = {},
            Rendered = false
        }

        table.insert(Window.Tabs, Tab)
        if Window.Dock then
            Window.Dock:AddIcon(Name, Icon, function() Tab:Select() end)
        end

        function Tab:Render()
            if Tab.Rendered then return end
            Tab.Rendered = true
            for _, data in ipairs(Tab.StoredElements) do
                data.Func(data.Options)
            end
        end

        function Tab:Select()
            if Window.SelectedTab then
                Window.SelectedTab:Unselect()
            end
            Window.SelectedTab = Tab
            Tab:Render()
            Tab.Frame.Visible = true
            Nebula:Tween(TabButton, TweenInfo.new(0.3), {BackgroundTransparency = 0.4})
            TabButton.TextLabel.TextColor3 = Theme.Text
            if TabButton:FindFirstChild("Icon") then
                TabButton.Icon.ImageColor3 = Theme.Accent
            end
        end

        function Tab:Unselect()
            Tab.Frame.Visible = false
            Nebula:Tween(TabButton, TweenInfo.new(0.3), {BackgroundTransparency = 0.8})
            TabButton.TextLabel.TextColor3 = Theme.SubText
            if TabButton:FindFirstChild("Icon") then
                TabButton.Icon.ImageColor3 = Theme.SubText
            end
        end

        TabButton.MouseButton1Click:Connect(function()
            Tab:Select()
        end)

        if not Window.SelectedTab then
            Tab:Select()
        end

        -- Element Creation (Lazy)
        local function StoreElement(func, options)
            table.insert(Tab.StoredElements, {Func = func, Options = options})
        end

        function Tab:AddButton(options)
            if not Tab.Rendered then 
                StoreElement(Tab.AddButton, options)
                return {} 
            end
            options = options or {}
            local Title = options.Title or "Button"
            local Description = options.Description or ""
            local Callback = options.Callback or function() end

            local ButtonFrame = Create("Frame", {
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(1, 0, 0, 45),
                Parent = TabFrame
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                Create("UIStroke", {Color = Theme.Border, Transparency = 0.7})
            })

            local Btn = Create("TextButton", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Text = "",
                Parent = ButtonFrame
            })

            local Label = Create("TextLabel", {
                Text = Title,
                Font = Enum.Font.GothamMedium,
                TextColor3 = Theme.Text,
                TextSize = 14,
                Position = UDim2.fromOffset(12, 0),
                Size = UDim2.fromScale(1, 0.6),
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Parent = ButtonFrame
            })

            local Desc = Create("TextLabel", {
                Text = Description,
                Font = Enum.Font.Gotham,
                TextColor3 = Theme.SubText,
                TextSize = 11,
                Position = UDim2.fromOffset(12, 22),
                Size = UDim2.fromScale(1, 0.4),
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Parent = ButtonFrame
            })

            Btn.MouseEnter:Connect(function()
                Nebula:Tween(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent})
            end)
            Btn.MouseLeave:Connect(function()
                Nebula:Tween(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Element})
            end)
            Btn.MouseButton1Click:Connect(function()
                Callback()
            end)

            return {SetTitle = function(t) Label.Text = t end}
        end

        function Tab:AddSection(Title)
            if not Tab.Rendered then 
                StoreElement(Tab.AddSection, Title)
                return 
            end
            local SectionFrame = Create("Frame", {
                BackgroundColor3 = Theme.Accent,
                BackgroundTransparency = 0.9,
                Size = UDim2.new(1, 0, 0, 25),
                Parent = TabFrame
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
                Create("TextLabel", {
                    Text = Title:upper(),
                    Font = Enum.Font.GothamBold,
                    TextColor3 = Theme.Accent,
                    TextSize = 11,
                    Position = UDim2.fromOffset(10, 0),
                    Size = UDim2.fromScale(1, 1),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1
                })
            })
        end

        function Tab:AddToggle(options)
            if not Tab.Rendered then 
                StoreElement(Tab.AddToggle, options)
                return {SetValue = function() end} 
            end
            options = options or {}
            local Title = options.Title or "Toggle"
            local Default = options.Default or false
            local Callback = options.Callback or function() end
            local State = Default

            local ToggleFrame = Create("Frame", {
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(1, 0, 0, 40),
                Parent = TabFrame
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                Create("UIStroke", {Color = Theme.Border, Transparency = 0.7})
            })

            local Label = Create("TextLabel", {
                Text = Title,
                Font = Enum.Font.GothamMedium,
                TextColor3 = Theme.Text,
                TextSize = 14,
                Position = UDim2.fromOffset(12, 0),
                Size = UDim2.fromScale(1, 1),
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Parent = ToggleFrame
            })

            local Outer = Create("Frame", {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -12, 0.5, 0),
                Size = UDim2.fromOffset(36, 18),
                BackgroundColor3 = Theme.Holder,
                Parent = ToggleFrame
            }, {
                Create("UICorner", {CornerRadius = UDim.new(1, 0)})
            })

            local Inner = Create("Frame", {
                Position = Default and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2),
                Size = UDim2.fromOffset(14, 14),
                BackgroundColor3 = Default and Theme.Accent or Theme.SubText,
                Parent = Outer
            }, {
                Create("UICorner", {CornerRadius = UDim.new(1, 0)})
            })

            local Click = Create("TextButton", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Text = "",
                Parent = ToggleFrame
            })

            local function SetState(s)
                State = s
                Nebula:Tween(Inner, TweenInfo.new(0.2), {
                    Position = State and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2),
                    BackgroundColor3 = State and Theme.Accent or Theme.SubText
                })
                Callback(State)
            end

            Click.MouseButton1Click:Connect(function()
                SetState(not State)
            end)

            return {SetValue = SetState}
        end

        function Tab:AddSlider(options)
            if not Tab.Rendered then 
                StoreElement(Tab.AddSlider, options)
                return {SetValue = function() end} 
            end
            options = options or {}
            local Title = options.Title or "Slider"
            local Default = options.Default or 50
            local Min = options.Min or 0
            local Max = options.Max or 100
            local Rounding = options.Rounding or 1
            local Callback = options.Callback or function() end
            local Value = Default

            local SliderFrame = Create("Frame", {
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(1, 0, 0, 50),
                Parent = TabFrame
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                Create("UIStroke", {Color = Theme.Border, Transparency = 0.7})
            })

            local Label = Create("TextLabel", {
                Text = Title,
                Font = Enum.Font.GothamMedium,
                TextColor3 = Theme.Text,
                TextSize = 14,
                Position = UDim2.fromOffset(12, 10),
                Size = UDim2.new(1, -100, 0, 20),
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Parent = SliderFrame
            })

            local ValueLabel = Create("TextLabel", {
                Text = tostring(Default),
                Font = Enum.Font.GothamBold,
                TextColor3 = Theme.Accent,
                TextSize = 14,
                Position = UDim2.new(1, -60, 0, 10),
                Size = UDim2.fromOffset(50, 20),
                TextXAlignment = Enum.TextXAlignment.Right,
                BackgroundTransparency = 1,
                Parent = SliderFrame
            })

            local SliderRail = Create("Frame", {
                BackgroundColor3 = Theme.Holder,
                Position = UDim2.new(0, 12, 1, -12),
                Size = UDim2.new(1, -24, 0, 4),
                Parent = SliderFrame
            }, {
                Create("UICorner", {CornerRadius = UDim.new(1, 0)})
            })

            local SliderFill = Create("Frame", {
                BackgroundColor3 = Theme.Accent,
                Size = UDim2.fromScale((Default - Min) / (Max - Min), 1),
                Parent = SliderRail
            }, {
                Create("UICorner", {CornerRadius = UDim.new(1, 0)})
            })

            local SliderDot = Create("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Theme.Text,
                Position = UDim2.fromScale(1, 0.5),
                Size = UDim2.fromOffset(12, 12),
                Parent = SliderFill
            }, {
                Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
                Create("UIStroke", {Color = Theme.Accent, Thickness = 2})
            })

            local function SetValue(v)
                Value = math.clamp(v, Min, Max)
                if Rounding > 0 then
                    Value = math.floor(Value / Rounding + 0.5) * Rounding
                end
                ValueLabel.Text = tostring(Value)
                Nebula:Tween(SliderFill, TweenInfo.new(0.1), {Size = UDim2.fromScale((Value - Min) / (Max - Min), 1)})
                Callback(Value)
            end

            local Dragging = false
            local function UpdateSlider()
                local MousePos = UserInputService:GetMouseLocation().X
                local RailPos = SliderRail.AbsolutePosition.X
                local RailSize = SliderRail.AbsoluteSize.X
                local NewValue = Min + ((MousePos - RailPos) / RailSize) * (Max - Min)
                SetValue(NewValue)
            end

            SliderFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = true
                    UpdateSlider()
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    UpdateSlider()
                end
            end)

            return {SetValue = SetValue}
        end

        function Tab:AddDropdown(options)
            if not Tab.Rendered then 
                StoreElement(Tab.AddDropdown, options)
                return {SetValues = function() end} 
            end
            options = options or {}
            local Title = options.Title or "Dropdown"
            local Values = options.Values or {"Option 1", "Option 2"}
            local Multi = options.Multi or false
            local Default = options.Default or (Multi and {} or Values[1])
            local Callback = options.Callback or function() end
            local Opened = false
            local Current = Default

            local DropdownFrame = Create("Frame", {
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(1, 0, 0, 40),
                ClipsDescendants = true,
                Parent = TabFrame
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                Create("UIStroke", {Color = Theme.Border, Transparency = 0.7})
            })

            local Label = Create("TextLabel", {
                Text = Title,
                Font = Enum.Font.GothamMedium,
                TextColor3 = Theme.Text,
                TextSize = 14,
                Position = UDim2.fromOffset(12, 0),
                Size = UDim2.new(1, -100, 0, 40),
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Parent = DropdownFrame
            })

            local SelectionLabel = Create("TextLabel", {
                Text = Multi and "Multiple" or tostring(Default),
                Font = Enum.Font.Gotham,
                TextColor3 = Theme.SubText,
                TextSize = 13,
                Position = UDim2.new(1, -140, 0, 0),
                Size = UDim2.new(0, 100, 0, 40),
                TextXAlignment = Enum.TextXAlignment.Right,
                BackgroundTransparency = 1,
                Parent = DropdownFrame
            })

            local Arrow = Create("ImageLabel", {
                Name = "Arrow",
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -12, 0, 20),
                Size = UDim2.fromOffset(16, 16),
                BackgroundTransparency = 1,
                Image = "rbxassetid://10709790948",
                ImageColor3 = Theme.SubText,
                Parent = DropdownFrame
            })

            local List = Create("Frame", {
                Name = "List",
                BackgroundColor3 = Theme.Holder,
                Position = UDim2.fromOffset(0, 40),
                Size = UDim2.new(1, 0, 0, #Values * 30),
                BackgroundTransparency = 0.5,
                Parent = DropdownFrame
            }, {
                Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder})
            })

            local function Toggle(s)
                Opened = s
                local TargetHeight = Opened and (40 + #Values * 30) or 40
                Nebula:Tween(DropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, TargetHeight)})
                Nebula:Tween(Arrow, TweenInfo.new(0.3), {Rotation = Opened and 180 or 0})
            end

            Label.Parent.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Toggle(not Opened)
                end
            end)

            for i, v in ipairs(Values) do
                local Option = Create("TextButton", {
                    BackgroundColor3 = Theme.Element,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 30),
                    Text = v,
                    Font = Enum.Font.Gotham,
                    TextColor3 = Theme.SubText,
                    TextSize = 13,
                    Parent = List
                })

                Option.MouseButton1Click:Connect(function()
                    if Multi then
                        Current[v] = not Current[v]
                        SelectionLabel.Text = "Multiple..."
                        Callback(Current)
                    else
                        Current = v
                        SelectionLabel.Text = tostring(v)
                        Callback(v)
                        Toggle(false)
                    end
                end)
            end

            return {SetValues = function(v) end} -- Add more methods later
        end

        function Tab:AddColorpicker(options)
            if not Tab.Rendered then 
                StoreElement(Tab.AddColorpicker, options)
                return {SetValue = function() end} 
            end
            -- Simplified version for now
            options = options or {}
            local Title = options.Title or "Colorpicker"
            local Default = options.Default or Color3.fromRGB(255, 255, 255)
            local Callback = options.Callback or function() end

            local PickerFrame = Create("Frame", {
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(1, 0, 0, 40),
                Parent = TabFrame
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                Create("UIStroke", {Color = Theme.Border, Transparency = 0.7})
            })

            local Label = Create("TextLabel", {
                Text = Title,
                Font = Enum.Font.GothamMedium,
                TextColor3 = Theme.Text,
                TextSize = 14,
                Position = UDim2.fromOffset(12, 0),
                Size = UDim2.fromScale(1, 1),
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Parent = PickerFrame
            })

            local Display = Create("Frame", {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -12, 0, 20),
                Size = UDim2.fromOffset(24, 24),
                BackgroundColor3 = Default,
                Parent = PickerFrame
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
                Create("UIStroke", {Color = Theme.Border, Thickness = 1.5})
            })

            return {SetValue = function(c) Display.BackgroundColor3 = c end}
        end

        function Tab:AddKeybind(options)
            if not Tab.Rendered then 
                StoreElement(Tab.AddKeybind, options)
                return {SetKey = function() end} 
            end
            options = options or {}
            local Title = options.Title or "Keybind"
            local Default = options.Default or Enum.KeyCode.E
            local Callback = options.Callback or function() end
            local Binding = false
            local CurrentKey = Default

            local KeybindFrame = Create("Frame", {
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(1, 0, 0, 40),
                Parent = TabFrame
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                Create("UIStroke", {Color = Theme.Border, Transparency = 0.7})
            })

            local Label = Create("TextLabel", {
                Text = Title,
                Font = Enum.Font.GothamMedium,
                TextColor3 = Theme.Text,
                TextSize = 14,
                Position = UDim2.fromOffset(12, 0),
                Size = UDim2.fromScale(1, 1),
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Parent = KeybindFrame
            })

            local KeyLabel = Create("TextLabel", {
                Text = CurrentKey.Name,
                Font = Enum.Font.GothamBold,
                TextColor3 = Theme.Accent,
                TextSize = 13,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -12, 0.5, 0),
                Size = UDim2.fromOffset(80, 24),
                BackgroundColor3 = Theme.Holder,
                Parent = KeybindFrame
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
                Create("UIStroke", {Color = Theme.Border, Transparency = 0.5})
            })

            local Click = Create("TextButton", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Text = "",
                Parent = KeybindFrame
            })

            Click.MouseButton1Click:Connect(function()
                Binding = true
                KeyLabel.Text = "..."
            end)

            UserInputService.InputBegan:Connect(function(input)
                if Binding and input.UserInputType == Enum.UserInputType.Keyboard then
                    Binding = false
                    CurrentKey = input.KeyCode
                    KeyLabel.Text = CurrentKey.Name
                elseif not Binding and input.KeyCode == CurrentKey then
                    Callback()
                end
            end)

            return {SetKey = function(k) CurrentKey = k; KeyLabel.Text = k.Name end}
        end

        function Tab:AddInput(options)
            if not Tab.Rendered then 
                StoreElement(Tab.AddInput, options)
                return {SetText = function() end} 
            end
            options = options or {}
            local Title = options.Title or "Input"
            local Placeholder = options.Placeholder or "Type here..."
            local Callback = options.Callback or function() end

            local InputFrame = Create("Frame", {
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(1, 0, 0, 45),
                Parent = TabFrame
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                Create("UIStroke", {Color = Theme.Border, Transparency = 0.7})
            })

            local TextBox = Create("TextBox", {
                Size = UDim2.new(1, -24, 0, 30),
                Position = UDim2.fromOffset(12, 10),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = "",
                PlaceholderText = Placeholder,
                PlaceholderColor3 = Theme.SubText,
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = InputFrame
            })

            TextBox.FocusLost:Connect(function(enter)
                Callback(TextBox.Text, enter)
            end)

            return {SetText = function(t) TextBox.Text = t end}
        end

        function Tab:AddParagraph(options)
            if not Tab.Rendered then 
                StoreElement(Tab.AddParagraph, options)
                return {SetTitle = function() end, SetContent = function() end} 
            end
            options = options or {}
            local Title = options.Title or "Paragraph"
            local Content = options.Content or ""

            local ParagraphFrame = Create("Frame", {
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(1, 0, 0, 60),
                Parent = TabFrame
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                Create("TextLabel", {
                    Text = Title,
                    Font = Enum.Font.GothamBold,
                    TextColor3 = Theme.Text,
                    TextSize = 14,
                    Position = UDim2.fromOffset(12, 10),
                    Size = UDim2.new(1, -24, 0, 20),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1
                }),
                Create("TextLabel", {
                    Text = Content,
                    Font = Enum.Font.Gotham,
                    TextColor3 = Theme.SubText,
                    TextSize = 12,
                    Position = UDim2.fromOffset(12, 30),
                    Size = UDim2.new(1, -24, 0, 20),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    BackgroundTransparency = 1
                })
            })

            return {SetTitle = function(t) end, SetContent = function(c) end}
        end

        return Tab
    end

    function Window:Notify(options)
        options = options or {}
        local Title = options.Title or "Notification"
        local Content = options.Content or "Check this out!"
        local Duration = options.Duration or 5

        local NotifFrame = Create("Frame", {
            BackgroundColor3 = Theme.Holder,
            Size = UDim2.fromOffset(250, 60),
            Position = UDim2.new(1, 10, 1, -70),
            Parent = ScreenGui
        }, {
            Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
            Create("UIStroke", {Color = Theme.Accent, Thickness = 2}),
            Create("TextLabel", {
                Text = Title,
                Font = Enum.Font.GothamBold,
                TextColor3 = Theme.Text,
                TextSize = 14,
                Position = UDim2.fromOffset(10, 8),
                Size = UDim2.new(1, -20, 0, 20),
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1
            }),
            Create("TextLabel", {
                Text = Content,
                Font = Enum.Font.Gotham,
                TextColor3 = Theme.SubText,
                TextSize = 12,
                Position = UDim2.fromOffset(10, 28),
                Size = UDim2.new(1, -20, 0, 20),
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1
            })
        })

        Nebula:Tween(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = UDim2.new(1, -260, 1, -70)})
        task.delay(Duration, function()
            Nebula:Tween(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(1, 10, 1, -70)})
            task.wait(0.5)
            NotifFrame:Destroy()
        end)
    end

    function Window:Dialog(options)
        options = options or {}
        local Title = options.Title or "Are you sure?"
        local Content = options.Content or "This action cannot be undone."
        local Buttons = options.Buttons or {{Title = "Confirm", Callback = function() end}, {Title = "Cancel", Callback = function() end}}

        local Overlay = Create("Frame", {
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            ZIndex = 1000,
            Parent = Main
        })

        local DialogFrame = Create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Theme.Main,
            Position = UDim2.fromScale(0.5, 0.45),
            Size = UDim2.fromOffset(300, 160),
            Parent = Overlay
        }, {
            Create("UICorner", {CornerRadius = UDim.new(0, 10)}),
            Create("UIStroke", {Color = Theme.Accent, Thickness = 2}),
            Create("TextLabel", {
                Text = Title,
                Font = Enum.Font.GothamBold,
                TextColor3 = Theme.Text,
                TextSize = 16,
                Position = UDim2.fromOffset(0, 20),
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1
            }),
            Create("TextLabel", {
                Text = Content,
                Font = Enum.Font.Gotham,
                TextColor3 = Theme.SubText,
                TextSize = 13,
                Position = UDim2.fromOffset(20, 50),
                Size = UDim2.new(1, -40, 1, -100),
                TextWrapped = true,
                BackgroundTransparency = 1
            })
        })

        local ButtonHolder = Create("Frame", {
            AnchorPoint = Vector2.new(0.5, 1),
            Position = UDim2.new(0.5, 0, 1, -15),
            Size = UDim2.new(1, -30, 0, 35),
            BackgroundTransparency = 1,
            Parent = DialogFrame
        }, {
            Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 10),
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            })
        })

        Nebula:Tween(Overlay, TweenInfo.new(0.3), {BackgroundTransparency = 0.4})
        Nebula:Tween(DialogFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Position = UDim2.fromScale(0.5, 0.5)})

        for _, btn in ipairs(Buttons) do
            local b = Create("TextButton", {
                BackgroundColor3 = btn.Title == "Confirm" and Theme.Accent or Theme.Element,
                Size = UDim2.new(0.5, -5, 1, 0),
                Text = btn.Title,
                Font = Enum.Font.GothamMedium,
                TextColor3 = Theme.Text,
                TextSize = 13,
                Parent = ButtonHolder
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 6)})
            })

            b.MouseButton1Click:Connect(function()
                btn.Callback()
                Nebula:Tween(Overlay, TweenInfo.new(0.3), {BackgroundTransparency = 1})
                Nebula:Tween(DialogFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.fromScale(0.5, 0.45)})
                task.wait(0.3)
                Overlay:Destroy()
            end)
        end
    end


    function Window:AddProfile(options)
        options = options or {}
        local Name = options.Name or "User"
        local Rank = options.Rank or "Guest"
        local Avatar = options.Avatar or "rbxassetid://0"

        local ProfileFrame = Create("Frame", {
            Name = "Profile",
            BackgroundColor3 = Theme.Holder,
            BackgroundTransparency = 0.5,
            Position = UDim2.fromOffset(10, 60), -- Adjusting based on layout
            Size = UDim2.new(0, 150, 0, 120),
            Parent = Main
        }, {
            Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
            Create("ImageLabel", {
                Name = "Avatar",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.new(0.5, 0, 0, 10),
                Size = UDim2.fromOffset(50, 50),
                BackgroundColor3 = Theme.Element,
                Image = Avatar,
                Parent = ProfileFrame
            }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})}),
            Create("TextLabel", {
                Name = "Username",
                Text = Name,
                Font = Enum.Font.GothamBold,
                TextColor3 = Theme.Text,
                TextSize = 14,
                Position = UDim2.new(0, 0, 0, 65),
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Parent = ProfileFrame
            }),
            Create("TextLabel", {
                Name = "Rank",
                Text = Rank,
                Font = Enum.Font.Gotham,
                TextColor3 = Theme.Accent,
                TextSize = 11,
                Position = UDim2.new(0, 0, 0, 82),
                Size = UDim2.new(1, 0, 0, 15),
                BackgroundTransparency = 1,
                Parent = ProfileFrame
            })
        })

        -- Shift Navigation down
        Navigation.Position = UDim2.fromOffset(10, 190)
        Navigation.Size = UDim2.new(0, 150, 1, -200)

        return {
            SetName = function(t) ProfileFrame.Username.Text = t end,
            SetRank = function(t) ProfileFrame.Rank.Text = t end,
            SetAvatar = function(t) ProfileFrame.Avatar.Image = t end
        }
    end

    function Window:AddPlayerList(options)
        options = options or {}
        local Title = options.Title or "Players"

        local ListFrame = Create("Frame", {
            Name = "PlayerList",
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = Theme.Holder,
            BackgroundTransparency = 0.5,
            Position = UDim2.new(1, -10, 0, 60),
            Size = UDim2.new(0, 140, 1, -70),
            Parent = Main
        }, {
            Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
            Create("TextLabel", {
                Text = Title,
                Font = Enum.Font.GothamBold,
                TextColor3 = Theme.SubText,
                TextSize = 12,
                Size = UDim2.new(1, 0, 0, 25),
                BackgroundTransparency = 1
            })
        })

        local Scroll = Create("ScrollingFrame", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 25),
            Size = UDim2.new(1, 0, 1, -25),
            ScrollBarThickness = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Parent = ListFrame
        }, {
            Create("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder}),
            Create("UIPadding", {PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5)})
        })

        -- Shift Container to accommodate list
        Container.Size = UDim2.new(1, -330, 1, -70)

        local PlayerList = {}
        function PlayerList:AddPlayer(name, rank, avatar)
            local Entry = Create("Frame", {
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(1, 0, 0, 35),
                Parent = Scroll
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Create("ImageLabel", {
                    Size = UDim2.fromOffset(25, 25),
                    Position = UDim2.fromOffset(5, 5),
                    BackgroundColor3 = Theme.Holder,
                    Image = avatar or "rbxassetid://0",
                    Parent = Entry
                }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})}),
                Create("TextLabel", {
                    Text = name,
                    Font = Enum.Font.GothamMedium,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    Position = UDim2.fromOffset(35, 4),
                    Size = UDim2.new(1, -40, 0, 15),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Parent = Entry
                }),
                Create("TextLabel", {
                    Text = rank or "Guest",
                    Font = Enum.Font.Gotham,
                    TextColor3 = Theme.SubText,
                    TextSize = 10,
                    Position = UDim2.fromOffset(35, 17),
                    Size = UDim2.new(1, -40, 0, 12),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Parent = Entry
                })
            })
            return Entry
        end

        return PlayerList
    end

    return Window
end

function Nebula:CreateLoadingScreen(title, subtitle)
    local Theme = Nebula.Themes[Nebula.CurrentTheme]
    local ScreenGui = Create("ScreenGui", {Name = RandomString(12), Parent = GetHUI()})
    ScreenGui:SetAttribute("NebulaUI", true)
    
    local MainFrame = Create("CanvasGroup", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Main,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(350, 200),
        GroupTransparency = 1,
        Parent = ScreenGui
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 15)}),
        Create("UIStroke", {Color = Theme.Accent, Thickness = 2.5})
    })

    local Title = Create("TextLabel", {
        Text = title or "NEBULA",
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Text,
        TextSize = 32,
        Position = UDim2.new(0, 0, 0.3, 0),
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })

    local Sub = Create("TextLabel", {
        Text = subtitle or "Initializing Galaxy...",
        Font = Enum.Font.Gotham,
        TextColor3 = Theme.SubText,
        TextSize = 14,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })

    local BarBack = Create("Frame", {
        BackgroundColor3 = Theme.Holder,
        Position = UDim2.new(0.1, 0, 0.75, 0),
        Size = UDim2.new(0.8, 0, 0, 6),
        Parent = MainFrame
    }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})

    local BarFill = Create("Frame", {
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.fromScale(0, 1),
        Parent = BarBack
    }, {
        Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
        Create("UIGradient", {Color = ColorSequence.new(Theme.Accent, Theme.Secondary)})
    })

    Nebula:Tween(MainFrame, TweenInfo.new(0.8), {GroupTransparency = 0})
    task.wait(0.5)
    Nebula:Tween(BarFill, TweenInfo.new(2.5, Enum.EasingStyle.Sine), {Size = UDim2.fromScale(1, 1)})
    task.wait(2.7)
    Nebula:Tween(MainFrame, TweenInfo.new(0.6), {GroupTransparency = 1, Size = UDim2.fromScale(0, 0)})
    task.wait(0.6)
    ScreenGui:Destroy()
end

function Nebula:CreateFloatingButton(window)
    local Theme = Nebula.Themes[Nebula.CurrentTheme]
    local ScreenGui = Create("ScreenGui", {Name = "NebulaToggle", Parent = PlayerGui})
    
    local Button = Create("ImageButton", {
        BackgroundColor3 = Theme.Main,
        Size = UDim2.fromOffset(50, 50),
        Position = UDim2.new(1, -70, 0.5, -25),
        Image = "rbxassetid://10723387721",
        ImageColor3 = Theme.Text,
        Parent = ScreenGui
    }, {
        Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
        Create("UIStroke", {Color = Theme.Accent, Thickness = 2})
    })

    Nebula:MakeDraggable(Button, Button)

    Button.MouseButton1Click:Connect(function()
        local Visible = (window.Main.GroupTransparency < 0.5)
        if Visible then
            Nebula:Tween(window.Main, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Size = UDim2.fromScale(0.7, 0.7),
                GroupTransparency = 1
            })
        else
            Nebula:Tween(window.Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(580, 460), -- Fixed sizing for now
                GroupTransparency = 0
            })
        end
    end)
end

--------------------------------------------------------------------------------
-- EXAMPLE USAGE (Nebula UI)
--------------------------------------------------------------------------------
--[[
local Window = Nebula:CreateWindow({
    Title = "Admin Panel",
    SubTitle = "Nebula Premium v2.0",
})

-- Adding Profile (Upper Sidebar)
Window:AddProfile({
    Name = game.Players.LocalPlayer.Name,
    Rank = "Developer",
    Avatar = "rbxassetid://0" -- Use actual avatar ID
})

-- Adding Player List (Right Side)
local PlayerList = Window:AddPlayerList({ Title = "Players" })
PlayerList:AddPlayer("Ryhen", "Dev", "rbxassetid://0")
PlayerList:AddPlayer("lxpes", "Guest", "rbxassetid://0")

-- Setting Search Callback
Window:SetSearchCallback(function(query)
    print("Searching for:", query)
end)

local MainTab = Window:AddTab({ 
    Title = "Dashboard", 
    Icon = "rbxassetid://10723351906" 
})

MainTab:AddButton({
    Title = "Kick Player",
    Description = "Select a player to kick",
    Callback = function()
        Window:Dialog({
            Title = "Confirm Kick",
            Content = "Are you sure you want to kick this player?",
            Buttons = {
                {Title = "Confirm", Callback = function() print("Kicked!") end},
                {Title = "Cancel", Callback = function() end}
            }
        })
    end
})

MainTab:AddToggle({
    Title = "Anti-AFK",
    Default = true,
    Callback = function(v) print("Anti-AFK:", v) end
})

Nebula:CreateLoadingScreen("NEBULA", "Synchronizing Panel...")
--]]

function Nebula:CreateDock(config)
    config = config or {}
    local Theme = Nebula.Themes[Nebula.CurrentTheme]
    local ScreenGui = Create("ScreenGui", {Name = RandomString(12), Parent = GetHUI(), DisplayOrder = 200})
    ScreenGui:SetAttribute("NebulaUI", true)
    
    local Dock = Create("CanvasGroup", {
        Name = "Dock",
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundColor3 = Theme.Main,
        Position = UDim2.new(0.5, 0, 1, -20),
        Size = UDim2.fromOffset(450, 60),
        Parent = ScreenGui
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 15)}),
        Create("UIStroke", {Color = Theme.Border, Thickness = 1.5, Transparency = 0.5}),
        Create("UIPadding", {PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 5)})
    })

    local Layout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 12),
        Parent = Dock
    })

    -- Clock Widget
    local ClockLabel = Create("TextLabel", {
        Name = "Clock",
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Text,
        TextSize = 16,
        Text = "00:00",
        Size = UDim2.new(0, 50, 1, 0),
        BackgroundTransparency = 1,
        Parent = Dock
    })

    task.spawn(function()
        while task.wait(1) do
            local Time = os.date("*t")
            ClockLabel.Text = string.format("%02d:%02d", Time.hour, Time.min)
        end
    end)

    -- Separator
    Create("Frame", {
        BackgroundColor3 = Theme.Border,
        Size = UDim2.new(0, 1, 0, 30),
        BackgroundTransparency = 0.5,
        Parent = Dock
    })

    local IconsContainer = Create("ScrollingFrame", {
        Name = "Icons",
        Size = UDim2.new(1, -120, 1, 0),
        BackgroundTransparency = 1,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        Parent = Dock
    }, {
        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 10),
            VerticalAlignment = Enum.VerticalAlignment.Center
        }),
        Create("UIPadding", {PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5)})
    })

    -- Settings Gear (Right Side)
    local SettingsBtn = Create("ImageButton", {
        Name = "Settings",
        BackgroundColor3 = Theme.Element,
        Size = UDim2.fromOffset(40, 40),
        Image = "rbxassetid://10712535031",-- "rbxassetid://10734950309"
        ImageColor3 = Theme.Text,
        Parent = Dock
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 12)})
    })

    local DockObj = {
        ScreenGui = ScreenGui,
        Dock = Dock,
        Icons = IconsContainer
    }

    function DockObj:AddIcon(name, icon, callback)
        local IconBtn = Create("ImageButton", {
            Name = name,
            BackgroundColor3 = Color3.new(1, 1, 1),
            Size = UDim2.fromOffset(42, 42),
            Image = icon,
            ImageColor3 = Color3.new(1, 1, 1),
            Parent = IconsContainer
        }, {
            Create("UICorner", {CornerRadius = UDim.new(0, 12)}),
            Create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Theme.Accent),
                    ColorSequenceKeypoint.new(1, Theme.Secondary)
                }),
                Rotation = 45
            })
        })

        IconBtn.MouseButton1Click:Connect(callback)
        
        -- Animation on Click
        IconBtn.MouseButton1Down:Connect(function()
            Nebula:Tween(IconBtn, TweenInfo.new(0.2), {Size = UDim2.fromOffset(38, 38)})
        end)
        IconBtn.MouseButton1Up:Connect(function()
            Nebula:Tween(IconBtn, TweenInfo.new(0.2), {Size = UDim2.fromOffset(42, 42)})
        end)

        -- Update Dock Canvas Size
        IconsContainer.CanvasSize = UDim2.new(0, #IconsContainer:GetChildren() * 52 + 20, 0, 0)
    end

    SettingsBtn.MouseButton1Click:Connect(function()
        if config.OnSettings then
            config.OnSettings()
        end
    end)

    return DockObj
end

return Nebula
