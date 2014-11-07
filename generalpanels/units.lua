
local _, ns = ...
local UnitOptions = CreateFrame('Frame', 'oUFAbuOptions_Units')
local Classy = LibStub('Classy-1.0')
local L = ns.L

local BUTTON_HEIGHT = 20
local CB_GAP = 5
local SIDE_GAP = 14

local unitTable = {
	[1] = "player",
	[2] = "target",
	[3] = "targettarget",
	[4] = "pet",
	[5] = "focus",
	[6] = "focustarget",
	[7] = "party",
	[8] = "boss",
	[9] = "arena",
}

local auraPosDropMenu = {
	["TOP"] = 	 { L.Top, L.Top,},
	["BOTTOM"] = { L.Bottom, L.Bottom,},
	["LEFT"] = 	 { L.Left, L.Left,},
	["NONE"] = 	 { L.Disable, L.Disable,},
}

local styleDataDropMenu = {
	["normal"] = { L.Normal, L.Normal,},
	["fat"] = 	 { L.Fat, L.Fat,},
}

local cbIconDropMenu = {
	['NONE'] =  { L.DontShow, L.DontShow,},
	['LEFT'] =  { L.IconOnLeft, L.IconOnLeft,},
	['RIGHT'] = { L.IconOnRight, L.IconOnRight,},
}

local healthTagDropMenu = {
	["NUMERIC"] = { L.TagNumeric,	L.TagNumericTip },
	["BOTH"]	= { L.TagBoth,		L.TagBothTip },
	["PERCENT"] = { L.TagPercent,	L.TagPercentTip },
	["MINIMAL"] = { L.TagMinimal,	L.TagMinimalTip },
	["DEFICIT"] = { L.TagDeficit,	L.TagDeficitTip },
	["DISABLE"]	= { L.TagDisable,	L.TagDisableTip },
}

local powerTagDropMenu = {
	["NUMERIC"] = { L.TagNumeric,	L.TagNumericTip },
	["PERCENT"] = { L.TagPercent,	L.TagPercentTip },
	["MINIMAL"] = { L.TagMinimal,	L.TagMinimalTip },
	["DISABLE"]	= { L.TagDisable,	L.TagDisableTip },
}

local function round(num)
	return math.floor(num + 0.5)
end

local UnitButton = Classy:New('Button')
function UnitButton:New(parent, unit, onClick)
	local b = self:Bind(CreateFrame('Button', "UnitOptions_" ..unit.. "_Button", parent))
	b:SetHeight(BUTTON_HEIGHT)
	b:SetScript('OnClick', onClick)
	b.unit = unit

	local ht = b:CreateTexture(nil, 'BACKGROUND')
	ht:SetTexture([[Interface\QuestFrame\UI-QuestLogTitleHighlight]])
	ht:SetVertexColor(0.196, 0.388, 0.8)
	ht:SetBlendMode('ADD')
	ht:SetAllPoints(b)
	b:SetHighlightTexture(ht)

	local text = b:CreateFontString(nil, 'ARTWORK')
	text:SetJustifyH('LEFT')
	text:SetAllPoints(b)
	b:SetFontString(text)
	b:SetNormalFontObject('GameFontNormal')
	b:SetHighlightFontObject('GameFontHighlight')
	return b
end

function UnitOptions:GetConfig(db)
	local unit = self.selected or 'player'
	return oUFAbuOptions:GetSettings()[unit][db]
end

function UnitOptions:SetConfig(db, val, requiresReload)
	local unit = self.selected
	oUFAbuOptions:GetSettings()[unit][db] = val
	if (requiresReload) then
		oUFAbuOptions.reload = true
	else
		oUFAbu:UpdateBaseFrames(unit)
	end
end

function UnitOptions:ResetConfig(db)
	local unit = self.selected
	oUFAbuOptions:GetSettings()[unit][db] =  oUFAbuOptions:GetDefaultSettings()[unit][db]
end

function UnitOptions:SelectUnit(unit)
	self.selected = unit or "player"
	self.Name:SetText(L[self.selected])

	for i = 1, #unitTable do
		if unitTable[i] == self.selected then
			self.buttons[i]:LockHighlight()
		else
			self.buttons[i]:UnlockHighlight()
		end
	end
	self:UpdateValues()
end
	
function UnitOptions:UpdateValues()
	if not self.selected then return self:SelectUnit() end

	local sliderfix --Sliders saves vallues when updated
	if not oUFAbuOptions.reload then 
		sliderfix = true; 
	end
	for i = 1, #self.widgets do
		local widget = self.widgets[i]
		if self:GetConfig(widget.db) ~= nil then
			widget:Show()
			widget:UpdateValues()
		else
			widget:Hide()
		end
	end
	if sliderfix then oUFAbuOptions.reload = false; end

	if type(self:GetConfig('cbshow')) == 'boolean' then
		self.CastBar:Show()
	else 
		self.CastBar:Hide()
	end
end

--[[ Sliders ]]--
function UnitOptions:GetSlider(parent, name, db, low, high, step)
	local s = oUFAbuOptions.Slider:New(name, parent, low, high, step)
	s.db = db
	s:SetWidth(180)
	s.OnShow = function() end
	table.insert(self.widgets, s)
	return s
end

function UnitOptions:CreateScaleSlider(parent, name, db, low, high, step)
	local s = self:GetSlider(parent, L[name], db, low, high, step)

	s.SetSavedValue = function(self, value)
		UnitOptions:SetConfig(db, round(value)/100, false)
	end

	s.GetSavedValue = function(self)
		return round(UnitOptions:GetConfig(db)*100)
	end

	s.GetFormattedText= function(self, value)
	 	return value .. "%"
	end
	return s
end

function UnitOptions:CreateSizeSlider(parent, name, db, low, high, step)
	local s = self:GetSlider(parent, L[name], db, low, high, step)

	s.SetSavedValue = function(self, value)
		UnitOptions:SetConfig(db, round(value), true)
	end

	s.GetSavedValue = function(self)
		return round(UnitOptions:GetConfig(db))
	end

	s.GetFormattedText= function(self, value)
	 	return value
	end
	return s
end

function UnitOptions:CreatePosSlider(parent, name, db, isHorizontal, low, high, step)
	local s = self:GetSlider(parent, L[name], db, low, high, step)

	s.SetSavedValue = function(self, value)
		local x, y = unpack(UnitOptions:GetConfig(db))
		if isHorizontal then
			UnitOptions:SetConfig(db, {round(value), y}, true)
		else
			UnitOptions:SetConfig(db, {x, round(value)}, true)
		end
	end

	s.GetSavedValue = function(self)
		local x, y = unpack(UnitOptions:GetConfig(db))
		if isHorizontal then
			return round(x)
		else
			return round(y)
		end
	end

	s.GetFormattedText= function(self, value)
	 	return value
	end
	return s
end

-- [[ CheckButton ]] --
function UnitOptions:CreateCheckButton(parent, name, db)
	local b = oUFAbuOptions.CheckButton:New(L[name], parent)
	b.db = db

	b.OnEnableSetting = function(self, enable)
		UnitOptions:SetConfig(db, enable, true)
	end

	b.IsSettingEnabled = function(self)
		return UnitOptions:GetConfig(db)
	end

	b.tooltip = L[name.."Tip"] or L[name]

	table.insert(self.widgets, b)
	return b
end

-- [[ Dropdown ]] --
function UnitOptions:CreateDropdown(parent, name, menu, db, reqRe)
	local dd = oUFAbuOptions.Dropdown:New(L[name], parent, 160)
	dd.db = db
	dd.reqRe = reqRe

	dd.SetSavedValue = function(self, value)
		UnitOptions:SetConfig(self.db, value, self.reqRe)
	end

	dd.GetSavedValue = function(self)
		return UnitOptions:GetConfig(db)
	end

	dd.GetSavedText = function(self)
		return menu[self:GetSavedValue()][1]
	end

	UIDropDownMenu_Initialize(dd, function(self)
		for value, description in pairs(menu) do
			self:AddItem(description[1], value, description[2])
		end
	end)

	self.widgets = self.widgets or {}
	table.insert(self.widgets, dd)
	return dd
end

function UnitOptions:AddWidgets()
	--[[ Left unit List ]]--
	local list = oUFAbuOptions.Group:New('', self)
	list:SetPoint('TOPLEFT', self, 'TOPLEFT', 12, -20)
	list:SetPoint('BOTTOMLEFT', self, 'BOTTOMLEFT', 12, 12)
	list:SetWidth(155)

	self.buttons = {}
	self.widgets = {}

	local butt_OnClick = function(b)
		self:SelectUnit(b.unit)
	end

	for i = 1, #unitTable do
		local unit = unitTable[i]
		local button = UnitButton:New(list, unit, butt_OnClick)
		if i == 1 then
			button:SetPoint('TOPLEFT', 0, -6)
			button:SetPoint('TOPRIGHT', 0, -6)
		else
			button:SetPoint('TOPLEFT', self.buttons[i-1], 'BOTTOMLEFT')
			button:SetPoint('TOPRIGHT', self.buttons[i-1], 'BOTTOMRIGHT')
		end
		button:SetText("   "..L[unit])
		self.buttons[i] = button
	end

	--[[ Right Window ]] 
	local config = oUFAbuOptions.Group:New('', self)
	config:SetPoint('TOPLEFT', list, 'TOPRIGHT', 6, 0)
	config:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', -12, 12)
	self.config = config

	local tit = config:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	tit:SetPoint('TOPLEFT', config, 'TOPLEFT', 40, -12)
	self.Name = tit

	local desc = config:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
	desc:SetJustifyH('LEFT')
	desc:SetPoint('TOPLEFT', config, 'TOPLEFT', 13, -34)
	desc:SetText(L.NoEffectUntilRL)

	local scale = self:CreateScaleSlider(config, "Scale", "scale", 70, 150, 5)
	scale:SetPoint('TOPLEFT', config, 'TOPLEFT', 20, -70)
	local style = self:CreateDropdown(config, "Style", styleDataDropMenu, "style", false)
	style:SetPoint("TOPLEFT", scale, "TOPLEFT", -17, -33)
	-- Tags
	local healthTag = self:CreateDropdown(config, "TextHealthTag", healthTagDropMenu, "HealthTag")
	healthTag:SetPoint('BOTTOMLEFT', style, 0, -55)
	local powerTag = self:CreateDropdown(config, "TextPowerTag", powerTagDropMenu, "PowerTag")
	powerTag:SetPoint('TOPLEFT', healthTag, "TOPLEFT", 0, -43)

	local enAura = self:CreateCheckButton(config, 'EnableAuras', 'enableAura')
	enAura:SetPoint('TOPLEFT', powerTag, 'TOPLEFT', 17, -33)
	-- or
	local buffPos = self:CreateDropdown(config, 'BuffPos', auraPosDropMenu, 'buffPos', true)
	buffPos:SetPoint('TOPLEFT', powerTag, 'TOPLEFT', 0, -55)
	local debuffPos = self:CreateDropdown(config, 'DebuffPos', auraPosDropMenu, 'debuffPos', true)
	debuffPos:SetPoint('TOPLEFT', buffPos, 'TOPLEFT', 0, -43)
	
	--Castbars
	local castbar = config:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	castbar:SetPoint('CENTER', config, 'TOPRIGHT', -120, -70)
	castbar:SetText(L.Castbar)
	castbar:Hide()
	self.CastBar = castbar

	local cbShow = self:CreateCheckButton(config, 'ShowCastbar', 'cbshow')
	cbShow:SetPoint('TOPLEFT', castbar, 'CENTER', -80, -14)
	local cbWidth = self:CreateSizeSlider(config, 'Width', 'cbwidth', 100, 350, 10)
	cbWidth:SetPoint('TOPLEFT', cbShow, 'TOPLEFT', -2, -43)
	local cbHeight = self:CreateSizeSlider(config, 'Height', 'cbheight', 10, 50, 2)
	cbHeight:SetPoint('TOPLEFT', cbWidth, 'TOPLEFT', 0, -35)
	local cbIcon = self:CreateDropdown(config, 'CastbarIcon', cbIconDropMenu, 'cbicon', true)
	cbIcon:SetPoint('TOPLEFT', cbHeight, 'TOPLEFT', -17, -33)
	local cbxpos = self:CreatePosSlider(config, 'HoriPos', 'cbposition', true, -500, 500, 10)
	cbxpos:SetPoint('TOPLEFT', cbIcon, 'TOPLEFT', 17, -50)
	local cpypos = self:CreatePosSlider(config, 'VertPos', 'cbposition', false, -500, 500, 10)
	cpypos:SetPoint('TOPLEFT', cbxpos, 'TOPLEFT', 0, -35)

	self:SelectUnit()
end

UnitOptions:AddWidgets()
oUFAbuOptions:AddGeneralTab('basic', L.UnitSpecific, UnitOptions)