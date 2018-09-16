local _, ns = ...

local options = _G['oUF_AbuOptions']
local panel = CreateFrame('Frame', options:GetName()..'_Units')
local L = oUFAbu.localization
local BUTTON_HEIGHT = 20

local unitTable = {
	"player", "target", "targettarget", "pet",
	"focus", "focustarget", "party", "boss", "arena",
}

local SELECTED_UNIT

local function GET(db)
	return ns.settings[SELECTED_UNIT][db]
end

local function SET(db, value, reload)
	ns.settings[SELECTED_UNIT][db] = value
	if type(reload) == "function" then
		reload()
	elseif reload then
		ns.reload = true
	else
		oUFAbu:UpdateBaseFrames(SELECTED_UNIT)
	end
end

local function RESET(db, reload)
	ns.settings[SELECTED_UNIT][db] = ns.defaultsettings[SELECTED_UNIT][db]
	if type(reload) == "function" then
		reload()
	elseif reload then
		ns.reload = true
	end
end

local function createDropDown(parent, text, db, reload, items, width)
	width = tonumber(width) or 160
	local f = ns.Widgets.Dropdown(parent, L[text], width, items)
	f.db = db
	f.reload = reload
	f.tooltip = L[text..'Tip']

	f.SetSavedValue = function(self, value)
		SET(self.db, value, self.reload)
	end

	f.GetSavedValue = function(self)
		return GET(self.db)
	end

	table.insert(parent.widgets, f)
	return f
end

local function createCheckButton(parent, text, db, reload)
	local f = ns.Widgets.CheckButton(parent, L[text])
	f.db = db
	f.reload = reload
	f.tooltip = L[text..'Tip']

	f.OnEnableSetting = function(self, enable)
		SET(self.db, enable, self.reload)
	end

	f.IsSettingEnabled = function(self)
		return GET(self.db)
	end

	table.insert(parent.widgets, f)
	return f
end

local function createSlider(parent, text, db, reload, lo, hi, step)
	local f = ns.Widgets.Slider(parent, L[text], lo, hi, step)
	f.db = db
	f.reload = reload
	f.tooltip = L[text..'Tip']
	f:SetWidth(180)

	f.SetSavedValue = function(self, value)
		SET(self.db, value, self.reload)
	end

	f.GetSavedValue = function(self)
		return GET(self.db)
	end

	table.insert(parent.widgets, f)
	return f
end

function panel:Create()
	--[[ Left unit List ]]--
	local list = ns.Widgets.Group(self, 'Units')
	list:SetPoint('TOPLEFT', self, 'TOPLEFT', 12, -20)
	list:SetPoint('BOTTOMLEFT', self, 'BOTTOMLEFT', 12, 12)
	list:SetWidth(155)

	self.buttons = {}
	self.widgets = {}

	for i = 1, #unitTable do
		local unit = unitTable[i]

		local button = CreateFrame('Button', self:GetName().. "_" ..unit.. "Button", self)
		button:SetHeight(BUTTON_HEIGHT)
		button.unit = unit

		local ht = button:CreateTexture(nil, 'BACKGROUND')
		ht:SetTexture([[Interface\QuestFrame\UI-QuestLogTitleHighlight]])
		ht:SetVertexColor(0.196, 0.388, 0.8)
		ht:SetBlendMode('ADD')
		ht:SetAllPoints(button)
		button:SetHighlightTexture(ht)

		local text = button:CreateFontString(nil, 'ARTWORK')
		text:SetJustifyH('LEFT')
		text:SetAllPoints(button)
		button:SetFontString(text)
		button:SetNormalFontObject('GameFontNormal')
		button:SetHighlightFontObject('GameFontHighlight')

		button:SetScript('OnClick', function(self)
			SELECTED_UNIT = self.unit
			self:GetParent():Update()
		end)

		if i == 1 then
			button:SetPoint('TOPLEFT', list, 'TOPLEFT', 0, -6)
			button:SetPoint('TOPRIGHT', list, 'TOPRIGHT', 0, -6)
		else
			button:SetPoint('TOPLEFT', self.buttons[i-1], 'BOTTOMLEFT')
			button:SetPoint('TOPRIGHT', self.buttons[i-1], 'BOTTOMRIGHT')
		end
		button:SetText("   "..L[unit])
		self.buttons[i] = button
	end

	--[[ Right Window ]] 
	local config = ns.Widgets.Group(self, 'Config')
	config:SetPoint('TOPLEFT', list, 'TOPRIGHT', 6, 0)
	config:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', -12, 12)
	self.config = config

	local tit = config:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	tit:SetPoint('TOPLEFT', config, 'TOPLEFT', 40, -12)
	SELECTED_UNIT = unitTable[1]
	self.Name = tit

	local desc = config:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
	desc:SetJustifyH('LEFT')
	desc:SetPoint('TOPLEFT', config, 'TOPLEFT', 13, -34)
	desc:SetText(L.NoEffectUntilRL)

	local enable = createCheckButton(self, 'Enable', "enable", true)
	enable:SetPoint('TOPLEFT', config, 'TOPLEFT', 20, -50)

	local scale = createSlider(self, "Scale", "scale", false, .5, 1.5, 0.05)
	scale:SetPoint('TOPLEFT', enable, 'TOPLEFT', -2, -43)
	scale.GetFormattedText = function(self, value)
		return format('%d%%', value * 100)
	end

	local style = createDropDown(self, "Style", "style", false,
		{
			{ value = 'normal', text = L.Normal },
			{ value = 'fat', text = L.Fat },
		})
	style:SetPoint("TOPLEFT", scale, "TOPLEFT", -17, -33)

	-- Tags
	local healthTag = createDropDown(self, "TextHealthTag", "HealthTag", false, 
		{
			{ value = 'NUMERIC', text = L.Tag_Numeric, tooltip = L.Tag_NumericTip },
			{ value = 'BOTH', 	 text = L.Tag_Both,    tooltip = L.Tag_BothTip },
			{ value = 'PERCENT', text = L.Tag_Percent, tooltip = L.Tag_PercentTip },
			{ value = 'MINIMAL', text = L.Tag_Minimal, tooltip = L.Tag_MinimalTip },
			{ value = 'DEFICIT', text = L.Tag_Deficit, tooltip = L.Tag_DeficitTip },
			{ value = 'DISABLE', text = L.Tag_Disable, tooltip = L.Tag_DisableTip },
		})
	healthTag:SetPoint('BOTTOMLEFT', style, 0, -55)
	local powerTag = createDropDown(self, "TextPowerTag", "PowerTag", false,
		{
			{ value = 'NUMERIC', text = L.Tag_Numeric, tooltip = L.Tag_NumericTip },
			{ value = 'PERCENT', text = L.Tag_Percent, tooltip = L.Tag_PercentTip },
			{ value = 'MINIMAL', text = L.Tag_Minimal, tooltip = L.Tag_MinimalTip },
			{ value = 'DISABLE', text = L.Tag_Disable, tooltip = L.Tag_DisableTip },
		})
	powerTag:SetPoint('TOPLEFT', healthTag, "TOPLEFT", 0, -43)


	local enAura = createCheckButton(self, 'EnableAuras', 'enableAura', true)
	enAura:SetPoint('TOPLEFT', powerTag, 'TOPLEFT', 17, -33)
	-- or
	local AuraPositionMenu = {
		{ value = 'TOP', text = L.TOP },
		{ value = 'BOTTOM', text = L.BOTTOM },
		{ value = 'LEFT', text = L.LEFT },
		{ value = 'NONE', text = DISABLE },
	}
	local buffPos = createDropDown(self, 'BuffPos', 'buffPos', true, AuraPositionMenu)
	buffPos:SetPoint('TOPLEFT', powerTag, 'TOPLEFT', 0, -55)
	local debuffPos = createDropDown(self, 'DebuffPos', 'debuffPos', true, AuraPositionMenu)
	debuffPos:SetPoint('TOPLEFT', buffPos, 'TOPLEFT', 0, -43)
	

	--Castbars
	local castbar = config:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	castbar:SetPoint('CENTER', config, 'TOPRIGHT', -120, -70)
	castbar:SetText(L.Castbar)
	castbar:Hide()
	self.CastBar = castbar

	local cbShow = createCheckButton(self, 'ShowCastbar', 'cbshow', true)
	cbShow:SetPoint('TOPLEFT', castbar, 'CENTER', -80, -14)
	local cbWidth = createSlider(self, 'Width', 'cbwidth', true, 100, 350, 10)
	cbWidth:SetPoint('TOPLEFT', cbShow, 'TOPLEFT', -2, -43)
	local cbHeight = createSlider(self, 'Height', 'cbheight', true, 10, 50, 2)
	cbHeight:SetPoint('TOPLEFT', cbWidth, 'TOPLEFT', 0, -35)
	local cbIcon = createDropDown(self, 'CastbarIcon', 'cbicon', true,
		{
			{ value = 'NONE', text = L.Icon_DontShow },
			{ value = 'LEFT', text = L.Icon_Left },
			{ value = 'RIGHT', text = L.Icon_Right },
		})
	cbIcon:SetPoint('TOPLEFT', cbHeight, 'TOPLEFT', -17, -33)

	local cbxpos = createSlider(self, 'HoriPos', 'cboffset', true, -500, 500, 10)
	cbxpos:SetPoint('TOPLEFT', cbIcon, 'TOPLEFT', 17, -50)
	function cbxpos:SetSavedValue(value)
		SET(self.db, {value, GET(self.db)[2]}, true)
	end
	function cbxpos:GetSavedValue()
		return GET(self.db)[1]
	end

	local cpypos = createSlider(self, 'VertPos', 'cboffset', true, -500, 500, 10)
	cpypos:SetPoint('TOPLEFT', cbxpos, 'TOPLEFT', 0, -35)
	function cpypos:SetSavedValue(value)
		SET(self.db, {GET(self.db)[1], value}, true)
	end
	function cpypos:GetSavedValue()
		return GET(self.db)[2]
	end
	
	local cbscale = createSlider(self, 'Scale', 'cbscale', true, .5, 1.5, 0.05)
	cbscale:SetPoint('TOPLEFT', cpypos, 'TOPLEFT', 0, -35)
	cbscale.GetFormattedText = function(self, value)
		return format('%d%%', value * 100)
	end
end

function panel:Update()
	self.Name:SetText(L[SELECTED_UNIT])

	for i = 1, #unitTable do
		if unitTable[i] == SELECTED_UNIT then
			self.buttons[i]:LockHighlight()
		else
			self.buttons[i]:UnlockHighlight()
		end
	end

	for i = 1, #self.widgets do
		local widget = self.widgets[i]
		if GET(widget.db) ~= nil then
			widget:Show()
			widget:Update()
		else
			widget:Hide()
		end
	end

	if type(GET('cbshow')) == 'boolean' then
		self.CastBar:Show()
	else 
		self.CastBar:Hide()
	end
end

options:AddTab(L.UnitSpecific, panel)