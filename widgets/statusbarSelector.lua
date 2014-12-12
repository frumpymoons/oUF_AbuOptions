--[[
	statusbarSelector.lua
		Displays a list of statusbars registered with SharedMedia
--]]

_G.oUFAbuOptions = oUFAbuOptions or {}

local LSM = LibStub('LibSharedMedia-3.0')
local Classy = LibStub('Classy-1.0')
local LSM_BAR = LSM.MediaType.STATUSBAR
local PADDING = 2
local FONT_HEIGHT = 24
local BUTTON_HEIGHT = 54
local SCROLL_STEP = BUTTON_HEIGHT + PADDING

local function getStatusbarIDs()
	return LSM:List(LSM_BAR)
end

local function fetchStatusbar(key)
	if key and LSM:IsValid(LSM_BAR, key) then
		return LSM:Fetch(LSM_BAR, key)
	end
	return LSM:GetDefault(LSM_BAR)
end

local barTester = nil
local function isValidStatusbar(texture)
	local f
	if not barTester then
		f = CreateFrame("Frame", nil)
		barTester = f:CreateTexture("Frame", "StatusbarTest")
	end
	return barTester:SetTexture(texture)
end

--[[
	The Font Button
--]]

local StatusbarButton = Classy:New('CheckButton')

function StatusbarButton:New(parent)
	local b = self:Bind(CreateFrame('CheckButton', nil, parent))
	b:SetHeight(BUTTON_HEIGHT)
	b:SetScript('OnClick', b.OnClick)
	b:SetScript('OnEnter', b.OnEnter)
	b:SetScript('OnLeave', b.OnLeave)

	local bg = b:CreateTexture(nil, 'BACKGROUND')
	bg:SetAllPoints(b)
	b.bg = bg
	b:OnLeave()

	local text = b:CreateFontString(nil, 'ARTWORK')
	text:SetPoint('BOTTOM', 0, PADDING)

	b:SetFontString(text)
	b:SetNormalFontObject('GameFontNormalSmall')
	b:SetHighlightFontObject('GameFontHighlightSmall')

	local ct = b:CreateTexture(nil, 'OVERLAY')
	ct:SetTexture([[Interface\Buttons\UI-CheckBox-Check]])
	ct:SetPoint('RIGHT', text, 'LEFT', -5, 0)
	ct:SetSize(24, 24)
	b:SetCheckedTexture(ct)

	return b
end

function StatusbarButton:SetStatusbarTexture(texture)
	self.bg:SetTexture(texture)
	return self
end

function StatusbarButton:GetStatusbarTexture()
	return (self.bg:GetTexture())
end

function StatusbarButton:OnEnter()
	self.bg:SetVertexColor(1, 1, 1, 1)
end

function StatusbarButton:OnLeave()
	self.bg:SetVertexColor(0.8, 0.8, 0.8)
end


--[[
	The Font Selector
--]]

local StatusbarSelector = Classy:New('Frame')
oUFAbuOptions.StatusbarSelector = StatusbarSelector

function StatusbarSelector:New(title, parent, width, height)
	local f = self:Bind(oUFAbuOptions.Group:New(title, parent))
	local scrollFrame = f:CreateScrollFrame()
	scrollFrame:SetPoint('TOPLEFT', 8, -8)
	f.scrollFrame = scrollFrame

	local scrollChild = f:CreateScrollChild()
	scrollFrame:SetScrollChild(scrollChild)
	f.scrollChild = scrollChild

	local scrollBar = f:CreateScrollBar()
	scrollBar:SetPoint('TOPRIGHT', -8, -8)
	scrollBar:SetPoint('BOTTOMRIGHT', -8, 6)
	scrollBar:SetWidth(16)
	scrollFrame:SetSize(width, height)
	f.scrollBar = scrollBar
	f:Hide()
	f:SetScript('OnShow', f.OnShow)

	return f
end

do
	local function scrollFrame_OnSizeChanged(self)
		local scrollChild = self:GetParent().scrollChild
		scrollChild:SetWidth(self:GetWidth())
	
		local scrollBar  = self:GetParent().scrollBar
		local scrollMax = max(scrollChild:GetHeight() - self:GetHeight(), 0)
		scrollBar:SetMinMaxValues(0, scrollMax)
		scrollBar:SetValue(0)
	end
	
	local function scrollFrame_OnMouseWheel(self, delta)
		local scrollBar = self:GetParent().scrollBar
		local min, max = scrollBar:GetMinMaxValues()
		local current = scrollBar:GetValue()

		if IsShiftKeyDown() and (delta > 0) then
		   scrollBar:SetValue(min)
		elseif IsShiftKeyDown() and (delta < 0) then
		   scrollBar:SetValue(max)
		elseif (delta < 0) and (current < max) then
		   scrollBar:SetValue(current + SCROLL_STEP)
		elseif (delta > 0) and (current > 1) then
		   scrollBar:SetValue(current - SCROLL_STEP)
		end
	end

	function StatusbarSelector:CreateScrollFrame()
		local scrollFrame = CreateFrame('ScrollFrame', nil, self)
		scrollFrame:EnableMouseWheel(true)
		scrollFrame:SetScript('OnSizeChanged', scrollFrame_OnSizeChanged)
		scrollFrame:SetScript('OnMouseWheel', scrollFrame_OnMouseWheel)

		return scrollFrame
	end
end

do
	local function scrollBar_OnValueChanged(self, value)
		self:GetParent().scrollFrame:SetVerticalScroll(value)
	end

	function StatusbarSelector:CreateScrollBar()
		local scrollBar = CreateFrame('Slider', nil, self)
		scrollBar:SetOrientation('VERTICAL')
		scrollBar:SetScript('OnValueChanged', scrollBar_OnValueChanged)

		local bg = scrollBar:CreateTexture(nil, 'BACKGROUND')
		bg:SetAllPoints(true)
		bg:SetTexture(0, 0, 0, 0.5)

		local thumb = scrollBar:CreateTexture(nil, 'OVERLAY')
		thumb:SetTexture([[Interface\Buttons\UI-ScrollBar-Knob]])
		thumb:SetSize(25, 25)
		scrollBar:SetThumbTexture(thumb)

		return scrollBar
	end
end

function StatusbarSelector:CreateScrollChild()
	local scrollChild = CreateFrame('Frame')
	local f_OnClick = function(f) self:Select(f:GetStatusbarTexture()) end
	local buttons = {}

	local i = 0
	local list = getStatusbarIDs()
	for num = 1, #list do
		local name = list[num]
		local texture = fetchStatusbar(name)
		if isValidStatusbar(texture) then
			i = i + 1
			local f = StatusbarButton:New(scrollChild)
			f:SetStatusbarTexture(texture):SetText(name)
			f:SetScript('OnClick', f_OnClick)

			if i == 1 then
				f:SetPoint('TOPLEFT')
				f:SetPoint('TOPRIGHT', scrollChild, 'TOP', -PADDING/2, 0)
			elseif i == 2 then
				f:SetPoint('TOPLEFT', scrollChild, 'TOP', PADDING/2, 0)
				f:SetPoint('TOPRIGHT')
			else
				f:SetPoint('TOPLEFT', buttons[i-2], 'BOTTOMLEFT', 0, -PADDING)
				f:SetPoint('TOPRIGHT', buttons[i-2], 'BOTTOMRIGHT', 0, -PADDING)
			end
			tinsert(buttons, f)
		end
	end

	scrollChild:SetWidth(self.scrollFrame:GetWidth())
	scrollChild:SetHeight(ceil(#buttons / 2) * (BUTTON_HEIGHT + PADDING) - PADDING)
	self.buttons = buttons
	return scrollChild
end

function StatusbarSelector:OnShow()
	self:UpdateSelected()
end

function StatusbarSelector:Select(value)
	self:SetSavedValue(value)
	self:UpdateSelected()
end

function StatusbarSelector:SetSavedValue(value)
	assert(false, 'Hey, you forgot to set SetSavedValue for ' .. self:GetName())
end

function StatusbarSelector:GetSavedValue()
	assert(false, 'Hey, you forgot to set GetSavedValue for ' .. self:GetName())
end

function StatusbarSelector:UpdateSelected()
	local selectedValue = self:GetSavedValue()
	for i, button in pairs(self.buttons) do
		button:SetChecked(button:GetStatusbarTexture() == selectedValue)
	end
end