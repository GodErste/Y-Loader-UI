-- Y Loader UI. Presentation only.
local Modules, Loaded = {}, {}
Modules["Theme"] = function(require)
return {
	Background = Color3.fromRGB(12, 11, 15),
	Surface = Color3.fromRGB(24, 18, 26),
	Border = Color3.fromRGB(48, 38, 49),
	Text = Color3.fromRGB(243, 239, 243),
	Muted = Color3.fromRGB(170, 161, 174),
	Accent = Color3.fromRGB(112, 18, 67),
	Pink = Color3.fromRGB(237, 132, 185),
	Success = Color3.fromRGB(172, 211, 194),
	Error = Color3.fromRGB(244, 157, 167),
}

end

Modules["Surface"] = function(require)
local Theme = require("./Theme")

--//Variables
local Surface = {}

--//Source
function Surface.Create(Class, Properties, Parent)
	local Object = Instance.new(Class)
	for Name, Value in pairs(Properties) do Object[Name] = Value end
	Object.Parent = Parent
	return Object
end

function Surface.Config(Options)
	local Config = table.clone(Options or {})
	Config.Name = Config.Name or "YHubStartup"
	Config.Discord = Config.Discord or "https://discord.gg/53J4h36DtX"
	Config.Theme = setmetatable(table.clone(Config.Theme or {}), { __index = Theme })
	return Config
end

function Surface.Mount(Gui)
	local function Mount(Parent)
		if typeof(Parent) ~= "Instance" then return false end
		return pcall(function()
			local Previous = Parent:FindFirstChild(Gui.Name)
			if Previous then Previous:Destroy() end
			Gui.Parent = Parent
		end)
	end
	local Success, Hidden = pcall(function() return type(gethui) == "function" and gethui() end)
	if Success and Mount(Hidden) then return end
	if Mount(game:GetService("CoreGui")) then return end
	local Player = game:GetService("Players").LocalPlayer
	assert(Player and Mount(Player:WaitForChild("PlayerGui", 5)), "Y Hub UI is unavailable")
end

function Surface.Animate(Object, Properties, Duration, Repeats, Reverses)
	local Tween = game:GetService("TweenService"):Create(Object,
		TweenInfo.new(Duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, Repeats or 0, Reverses or false), Properties)
	Tween:Play()
	return Tween
end

return Surface

end

Modules["Progress"] = function(require)
local Surface = require("./Surface")

--//Variables
local Progress = {}
Progress.__index = Progress
local Create = Surface.Create

--//Source
function Progress.new(Options)
	local self = setmetatable({ Config = Surface.Config(Options), Connections = {}, Tweens = {}, Stage = 0 }, Progress)
	local Success, Message = pcall(self.Build, self)
	if not Success then self:Destroy() error(Message, 0) end
	return self
end

function Progress:Connect(Signal, Callback)
	self.Connections[#self.Connections + 1] = Signal:Connect(Callback)
end

function Progress:Animate(Key, Object, Properties, Duration, Repeats, Reverses)
	if self.Tweens[Key] then self.Tweens[Key]:Cancel() end
	self.Tweens[Key] = Surface.Animate(Object, Properties, Duration, Repeats, Reverses)
end

function Progress:Build()
	local Theme = self.Config.Theme
	local Gui = Create("ScreenGui", {
		Name = self.Config.Name, ResetOnSpawn = false, DisplayOrder = 10001,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
	})
	self.Gui = Gui
	Surface.Mount(Gui)
	self.Layout = Create("Frame", { Name = "Layout", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 }, Gui)
	local Panel = Create("CanvasGroup", {
		Name = "Panel", AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, 0),
		Size = UDim2.fromOffset(356, 184), BackgroundColor3 = Theme.Background, BorderSizePixel = 0,
		GroupTransparency = 1,
	}, self.Layout)
	self.Panel = Panel
	Create("UICorner", { CornerRadius = UDim.new(0, 6) }, Panel)
	Create("UIStroke", { Color = Theme.Border, Thickness = 1 }, Panel)
	self.Scroll = Create("ScrollingFrame", {
		Name = "Content", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
		CanvasSize = UDim2.fromOffset(0, 184), ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Pink, ScrollingDirection = Enum.ScrollingDirection.Y,
	}, Panel)
	local function Label(Name, Text, Position, Size, TextSize, Color, Font)
		return Create("TextLabel", {
			Name = Name, Text = Text, Position = Position, Size = Size, BackgroundTransparency = 1,
			TextColor3 = Color, Font = Font or Enum.Font.Gotham, TextSize = TextSize,
			TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
		}, self.Scroll)
	end
	local Mark = Label("Mark", "<i>Y</i>", UDim2.fromOffset(18, 17), UDim2.fromOffset(30, 30), 22, Theme.Text, Enum.Font.GothamBold)
	Mark.RichText, Mark.BackgroundTransparency, Mark.BackgroundColor3, Mark.TextXAlignment = true, 0, Theme.Accent, Enum.TextXAlignment.Center
	Label("Brand", "Y HUB.", UDim2.fromOffset(59, 17), UDim2.new(1, -110, 0, 30), 17, Theme.Text, Enum.Font.GothamBold)
	local Close = Create("TextButton", {
		Name = "Close", Text = utf8.char(215), Position = UDim2.new(1, -50, 0, 8), Size = UDim2.fromOffset(44, 44),
		BackgroundTransparency = 1, TextColor3 = Theme.Muted, TextSize = 23, Font = Enum.Font.Gotham,
	}, self.Scroll)
	self.Title = Label("Title", "Starting up", UDim2.fromOffset(18, 61), UDim2.new(1, -36, 0, 25), 15, Theme.Text, Enum.Font.GothamMedium)
	local Track = Create("Frame", {
		Name = "Track", Position = UDim2.fromOffset(18, 102), Size = UDim2.new(1, -36, 0, 3),
		BackgroundColor3 = Theme.Border, BorderSizePixel = 0,
	}, self.Scroll)
	self.Fill = Create("Frame", { Name = "Fill", Size = UDim2.fromScale(0, 1), BackgroundColor3 = Theme.Pink, BorderSizePixel = 0 }, Track)
	self.Hint = Label("Hint", "Community", UDim2.fromOffset(18, 126), UDim2.new(1, -158, 0, 44), 12, Theme.Muted)
	local Discord = Create("TextButton", {
		Name = "Discord", Text = "Discord " .. utf8.char(8599), Position = UDim2.new(1, -136, 0, 126), Size = UDim2.fromOffset(118, 44),
		BackgroundColor3 = Theme.Surface, BackgroundTransparency = 0, BorderSizePixel = 0, AutoButtonColor = false,
		TextColor3 = Theme.Pink, TextSize = 13, Font = Enum.Font.GothamMedium,
	}, self.Scroll)
	Create("UICorner", { CornerRadius = UDim.new(0, 4) }, Discord)
	Create("UIStroke", { Color = Theme.Border, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, Discord)
	self.Discord = Discord
	self.Invite = Create("TextBox", {
		Name = "Invite", Text = self.Config.Discord, Visible = false, ClearTextOnFocus = false, TextEditable = false,
		Position = UDim2.fromOffset(18, 174), Size = UDim2.new(1, -36, 0, 44),
		BackgroundColor3 = Theme.Surface, BorderSizePixel = 0, TextColor3 = Theme.Text, TextSize = 11, Font = Enum.Font.Gotham,
	}, self.Scroll)
	self:Connect(Close.Activated, function() self:Destroy() end)
	self:Connect(Discord.Activated, function() self:CopyInvite() end)
	self:Connect(Discord.MouseEnter, function() self:Animate("Discord", Discord, { BackgroundColor3 = Theme.Accent }, 0.2) end)
	self:Connect(Discord.MouseLeave, function() self:Animate("Discord", Discord, { BackgroundColor3 = Theme.Surface }, 0.2) end)
	self:Connect(self.Layout:GetPropertyChangedSignal("AbsoluteSize"), function() self:Resize() end)
	self:Connect(Gui.Destroying, function() self:Destroy() end)
	self:Resize()
	self:Animate("Entrance", Panel, { GroupTransparency = 0, Position = UDim2.new(0.5, 0, 1, -16) }, 0.38)
	self:Animate("Activity", self.Fill, { BackgroundTransparency = 0.4 }, 0.8, -1, true)
end

function Progress:Resize()
	if self.Destroyed then return end
	local Size = self.Layout.AbsoluteSize
	if Size.X < 1 or Size.Y < 1 then return end
	local Height = self.Invite.Visible and 232 or 184
	self.Scroll.CanvasSize = UDim2.fromOffset(0, Height)
	self.Panel.Size = UDim2.fromOffset(math.min(356, math.max(1, Size.X - 24)), math.min(Height, math.max(1, Size.Y - 24)))
end

function Progress:CopyInvite()
	if self.Destroyed or self.InviteCopied then return end
	local Clipboard = self.Config.CopyInvite or setclipboard or toclipboard
	local Success = type(Clipboard) == "function" and pcall(Clipboard, self.Config.Discord)
	if not Success then
		self.Invite.Visible = true
		self:Resize()
		self.Invite:CaptureFocus()
		self.Invite.SelectionStart, self.Invite.CursorPosition = 1, #self.Invite.Text + 1
		return
	end
	self.InviteCopied = true
	self.Discord.Text, self.Discord.TextColor3 = "Invite copied", self.Config.Theme.Success
	task.delay(2, function()
		if self.Destroyed then return end
		self.InviteCopied = false
		self.Discord.Text, self.Discord.TextColor3 = "Discord " .. utf8.char(8599), self.Config.Theme.Pink
	end)
end

function Progress:WaitForEntry()
	task.wait(0.4)
	return not self.Destroyed
end

function Progress:SetStage(Index)
	if self.Destroyed or self.Resolved then return end
	self.Stage = math.max(self.Stage, math.clamp(Index, 1, 3))
	self.Title.Text = self.Stage == 1 and "Starting up" or "Checking compatibility"
	self:Animate("Fill", self.Fill, { Size = UDim2.fromScale(({ 0.16, 0.48, 0.8 })[self.Stage], 1) }, 0.38)
end

function Progress:SetResult(Success, Message)
	if self.Destroyed or self.Resolved then return end
	self.Resolved = true
	self.Title.Text = Message or (Success and "Ready" or "Executor not supported")
	self.Title.TextColor3 = Success and self.Config.Theme.Success or self.Config.Theme.Error
	self.Hint.Text = Success and "Community" or "Need help?"
	if self.Tweens.Activity then self.Tweens.Activity:Cancel() self.Tweens.Activity = nil end
	self.Fill.BackgroundTransparency = 0
	self.Fill.BackgroundColor3 = self.Title.TextColor3
	self:Animate("Fill", self.Fill, { Size = UDim2.fromScale(1, 1) }, 0.4)
end

function Progress:Dismiss()
	if self.Destroyed then return false end
	self:Animate("Entrance", self.Panel, { GroupTransparency = 1, Position = UDim2.new(0.5, 0, 1, 0) }, 0.25)
	task.wait(0.25)
	if self.Destroyed then return false end
	self:Destroy()
	return true
end

function Progress:Destroy()
	if self.Destroyed then return end
	self.Destroyed = true
	for _, Connection in ipairs(self.Connections) do Connection:Disconnect() end
	for _, Tween in pairs(self.Tweens) do Tween:Cancel() end
	table.clear(self.Connections)
	table.clear(self.Tweens)
	if self.Gui then self.Gui:Destroy() end
end

return Progress

end

Modules["init"] = function(require)
local Progress = require("./Progress")

return {
	Version = "1.0.0",
	CreateProgress = Progress.new,
}

end

local function Import(Path)
	local Name = string.gsub(Path, "^%./", "")
	if Loaded[Name] == nil then Loaded[Name] = assert(Modules[Name], "Unknown UI module")(Import) end
	return Loaded[Name]
end
return Import("init")
