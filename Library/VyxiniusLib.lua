--[[
    __      __          _      _             _    _ _____   _      _ _                          
    \ \    / /         (_)    (_)           | |  | |_   _| | |    (_) |                         
     \ \  / /   _ _ __  ___  ___ _   _ ___  | |  | | | |   | |     _| |__  _ __ __ _ _ __ _   _ 
      \ \/ / | | | '_ \| \ \/ / | | | / __| | |  | | | |   | |    | | '_ \| '__/ _` | '__| | | |
       \  /| |_| | | | | |>  <| | |_| \__ \ | |__| |_| |_  | |____| | |_) | | | (_| | |  | |_| |
        \/  \__, |_| |_|_/_/\_\_|\__,_|___/  \____/|_____| |______|_|_.__/|_|  \__,_|_|   \__, |
             __/ |                                                                         __/ |
            |___/                                                                         |___/ 

    Vynixius UI Library v1.1.0c

    UI - Vynixus
    Scripting - Vynixus

    [ What's new? ]

    [+] Can work on mobile and it center screen
    [*] More items now support the .flag setting, useful for configs
    [-] Removed the .Id setting from all library items

]]--
local Players = game:GetService("Players")
local CG = game:GetService("CoreGui")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local Utils = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/UI.lua"))()

local Library = {
    Theme = {
        ThemeColor = Color3.fromRGB(0, 255, 0),
        TopbarColor = Color3.fromRGB(20, 20, 20),
        SidebarColor = Color3.fromRGB(15, 15, 15),
        BackgroundColor = Color3.fromRGB(10, 10, 10),
        SectionColor = Color3.fromRGB(20, 20, 20),
        TextColor = Color3.fromRGB(255, 255, 255),
    },
    Notification = {
        Gui = nil,
		Active = {},
		Queue = {},
		Config = {
			SizeX = 320,
			MaxLines = 5,
			MaxStacking = 5,
			IsBusy = false,
		},
	},
}


function Library:Notify(settings, callback)
    assert(settings)
	assert(settings.Text)
	
	if Library.Notification.Config.IsBusy then
        local notification = {
			Settings = settings,
			Callback = callback,
		}
		table.insert(Library.Notification.Queue, notification)
		return notification
	end
	Library.Notification.Config.IsBusy = true

	local Notification = {
		Title = settings.Title or "Notification",
		Type = "Notification",
		Duration = settings.Duration or 10,
		Selected = nil,
		Dismissed = false,
		Connections = {},
        Buttons = {},
		Callback = callback,
	}

    if not Library.Notification.Gui then
        print("No notifications gui")

		Library.Notification.Gui = Utils.Create("ScreenGui", {
            Name = "Notifications",
            Parent = CG,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        })
        
        Library.Notification.Gui.Parent = CG
	end
    
    Notification.Holder = Utils.Create("Frame", {
        Name = "Holder",
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Size = UDim2.new(0, Library.Notification.Config.SizeX, 0, 42 + Library.Notification.Config.MaxLines * 14),

        Utils.Create("Frame", {
            Name = "Background",
            BackgroundColor3 = Color3.fromRGB(10, 10, 10),
            Position = UDim2.new(0, 0, 0, 28),
            Size = UDim2.new(1, 0, 1, -28),

            Utils.Create("Frame", {
                Name = "Filling",
                BackgroundColor3 = Color3.fromRGB(10, 10, 10),
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 5),
            }),
        }, UDim.new(0, 3)),

        Utils.Create("Frame", {
            Name = "Topbar",
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            Size = UDim2.new(1, 0, 0, 28),

            Utils.Create("Frame", {
                Name = "Filling",
                BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0.5, 0),
                Size = UDim2.new(1, 0, 0.5, 0),
            }),
        }, UDim.new(0, 3)),
    })

    Notification.Title = Utils.Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 11, 0.5, -8),
        Size = UDim2.new(1, -62, 0, 16),
        Font = Enum.Font.SourceSans,
        Text = Notification.Title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    Notification.Description = Utils.Create("TextLabel", {
        Name = "Desc",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 11, 0, 7),
        Size = UDim2.new(1, -18, 1, -14),
        Font = Enum.Font.SourceSans,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Text = "",
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
    })
	
    Notification.Buttons.Yes = Utils.Create("ImageButton", {
        Name = "Yes",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -44, 0.5, -10),
        Size = UDim2.new(0, 20, 0, 20),
        Image = "http://www.roblox.com/asset/?id=7919581359",
    })

    Notification.Buttons.No = Utils.Create("ImageButton", {
        Name = "No",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -22, 0.5, -10),
        Size = UDim2.new(0, 20, 0, 20),
        Image = "http://www.roblox.com/asset/?id=7919583990",
    })

    Notification.Indicator = Utils.Create("Frame", {
        Name = "Indicator",
        BackgroundColor3 = settings.Color or Library.Theme.ThemeColor,
        Size = UDim2.new(0, 4, 1, 0),
        Utils.Create("Frame", {
            Name = "Filling",
            BackgroundColor3 = settings.Color or Library.Theme.ThemeColor,
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, 0, 0, 0),
            Size = UDim2.new(0.5, 0, 1, 0),
        }),
    }, UDim.new(0, 3))

	-- Functions
	
	local function dismissNotification()
		TS:Create(Notification.Holder, TweenInfo.new(.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = UDim2.new(0, -Notification.Holder.AbsoluteSize.X, 0, Notification.Holder.AbsolutePosition.Y),
		}):Play()
		task.wait(.25)

		task.spawn(function()
			task.wait(.25)
			for i, v in next, Notification.Connections do
				v:Disconnect()
				Notification.Connections[i] = nil
			end			
			Notification.Holder:Destroy()
		end)
	end
function Notification:Select(bool, forced)
		if not forced and (Library.Notification.Config.IsBusy or Notification.Dismissed) then
            return
		end
		
		Notification.Dismissed = true
		
		if Notification.Selected == nil then
			Notification.Selected = bool
			pcall(Notification.Callback, bool)
			
			if bool then
				TS:Create(Notification.Buttons.Yes, TweenInfo.new(.25), {
					ImageColor3 = Color3.fromRGB(0, 255, 0),
				}):Play()
			else
				TS:Create(Notification.Buttons.No, TweenInfo.new(.25), {
					ImageColor3 = Color3.fromRGB(255, 0, 0),
				}):Play()
			end
			
			task.wait(.25)
		end
		
		dismissNotification()
	end
	
table.insert(Library.Notification.Active, Notification)
    Notification.Holder.Parent = Library.Notification.Gui
    Notification.Title.Parent = Notification.Holder.Topbar
    Notification.Description.Parent = Notification.Holder.Background
    Notification.Buttons.Yes.Parent = Notification.Holder.Topbar
    Notification.Buttons.No.Parent = Notification.Holder.Topbar
    Notification.Indicator.Parent = Notification.Holder    

	Notification.Description.Text = settings.Text
	local holderSizeY = math.floor(42 + Notification.Description.TextBounds.Y + 1)
	Notification.Holder.Size = UDim2.new(0, Library.Notification.Config.SizeX, 0, holderSizeY)
	Notification.Holder.Position = UDim2.new(0, -Library.Notification.Config.SizeX, 1, -holderSizeY - 10)

	-- Scripts
	
	local sound = Instance.new("Sound", Library.Notification.Gui)
	sound.SoundId, sound.PlayOnRemove = "rbxassetid://700153902", true
	sound:Destroy()
	
	task.spawn(function()		
		if #Library.Notification.Active > Library.Notification.Config.MaxStacking then
			local notification = Library.Notification.Active[1]
			table.remove(Library.Notification.Active, 1)
			notification:Select(false, true)
		end		
		
		for i, v in next, Library.Notification.Active do
			if v ~= Notification then
				TS:Create(v.Holder, TweenInfo.new(.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Position = v.Holder.Position - UDim2.new(0, 0, 0, Notification.Holder.AbsoluteSize.Y + 10),
				}):Play()
			end
		end
		task.wait(.25)
		
		TS:Create(Notification.Holder, TweenInfo.new(.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = UDim2.new(0, 10, 1, -holderSizeY - 10),
		}):Play()
		task.wait(.5)
		Library.Notification.Config.IsBusy = false
		
		
		if #Library.Notification.Queue > 0 then
			local notification = Library.Notification.Queue[1]
			table.remove(Library.Notification.Queue, 1)
			Library:Notify(notification.Settings, notification.Callback)
		end
		

		Notification.Buttons.Yes.MouseEnter:Connect(function()
			if not Notification.Selected then
				TS:Create(Notification.Buttons.Yes, TweenInfo.new(.25), {ImageColor3 = Color3.fromRGB(186, 255, 186)}):Play()
			end
		end)

		Notification.Buttons.Yes.MouseLeave:Connect(function()
			if not Notification.Selected then
				TS:Create(Notification.Buttons.Yes, TweenInfo.new(.25), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
			end
		end)

		Notification.Buttons.Yes.MouseButton1Click:Connect(function()
			Notification:Select(true)
		end)

		Notification.Buttons.No.MouseEnter:Connect(function()
			if not Notification.Selected then
				TS:Create(Notification.Buttons.No, TweenInfo.new(.25), {ImageColor3 = Color3.fromRGB(255, 191, 191)}):Play()
			end
		end)

		Notification.Buttons.No.MouseLeave:Connect(function()
			if not Notification.Selected then
				TS:Create(Notification.Buttons.No, TweenInfo.new(.25), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
			end
		end)

		Notification.Buttons.No.MouseButton1Click:Connect(function()
			Notification:Select(false)
		end)
		
		--
		
		task.wait(Notification.Duration)

		if Notification.Selected == nil then
			Notification:Select(false, true)
		end
	end)

	return Notification
end

return Library




















