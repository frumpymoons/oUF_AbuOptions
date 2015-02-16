local _, ns = ...
local L = oUFAbu.localization

local options = _G['oUF_AbuOptions']
local optionsName = options:GetName()

local function GET(db)
	return ns.settings[db]
end

local function SET(db, value, reload)
	ns.settings[db] = value
	if type(reload) == "function" then
		reload()
	elseif reload then
		ns.reload = true
	end
end

local function RESET(db, reload)
	ns.settings[db] = ns.defaultsettings[db]
	if type(reload) == "function" then
		reload()
	elseif reload then
		ns.reload = true
	end
end

------------------------------------------------------------

local function createDropDown(parent, text, db, reload, items, width)
	width = tonumber(width) or 150
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

	f.SetSavedValue = function(self, value)
		SET(self.db, value, self.reload)
	end

	f.GetSavedValue = function(self)
		return GET(self.db)
	end

	table.insert(parent.widgets, f)
	return f
end

local function createColorSelector(parent, db, reload, hasOpacity, hasResetButton)
	local f = ns.Widgets.ColorSelector(parent, hasOpacity)
	f.db = db
	f.reload = reload

	if hasOpacity then
		f.OnSetColor = function(self, r, g, b, a)
			SET(self.db, {r, g, b, a}, self.reload)
		end

		f.GetColor = function(self)
			local color = GET(self.db)
			return color[1], color[2], color[3], color[4]
		end
	else
		f.OnSetColor = function(self, r, g, b)
			SET(self.db, {r, g, b}, self.reload)
		end

		f.GetColor = function(self)
			local color = GET(self.db)
			return color[1], color[2], color[3]
		end
	end

	if hasResetButton then
		local rebutt = CreateFrame('Button', nil, f, 'UIPanelCloseButton')
		rebutt:SetSize(32, 32)
		rebutt:SetPoint('RIGHT', f, 'LEFT', -5, 0)
		rebutt:SetScript('OnClick', function(self)
			local picker = self:GetParent()
			RESET(picker.db, picker.reload)
			picker:Update()
		end)
		f.button = rebutt
	end

	table.insert(parent.widgets, f)
	return f
end

local function createDropdownWithColorSelector(parent, text, dropDB, colorDB, reload, items)
	local dropdown = createDropDown(parent, text, dropDB, reload, items, 180)

	local color = createColorSelector(parent, colorDB, reload)
	color:SetPoint('TOPLEFT', dropdown, 'TOPRIGHT', -5, -4)
	dropdown.ColorSelector = color

	dropdown.GetSavedValue = function(self)
		local value = GET(self.db)
		if (value == 'CUSTOM') then
			self.ColorSelector:Show()
		else
			self.ColorSelector:Hide()
		end
		return value
	end

	return dropdown
end

--------------------------------------------------------
--		BASIC PANEL
local general = CreateFrame('Frame', optionsName..'_General', options)

function general:Create(  )
	local _, class, classIndex = UnitClass('player')
	local RAID_CLASS_COLORS = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
	local color = RAID_CLASS_COLORS[class]

	local CB_GAP, SIDE_GAP, INDENT = 5, 14, 20

	local text = self:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
	text:SetHeight(32)
	text:SetPoint("TOPLEFT", 20, -18)
	text:SetNonSpaceWrap(true)
	text:SetJustifyH("LEFT")
	text:SetJustifyV("TOP")
	text:SetText(L.NoEffectUntilRL)

	self.widgets = { }

	-- LEFT
	local showparty = createCheckButton(self, "General_Party", 'showParty', true)
	showparty:SetPoint('TOPLEFT', SIDE_GAP, -38)
	local partyinraid = createCheckButton(self, "General_PartyInRaid", 'showPartyInRaid', true)
	partyinraid:SetPoint('TOPLEFT', showparty, 'BOTTOMLEFT', INDENT, -CB_GAP)
	local showArena = createCheckButton(self, "General_Arena", 'showArena', true)
	showArena:SetPoint('TOPLEFT', partyinraid, 'BOTTOMLEFT', -INDENT, -CB_GAP)
	local showBoss = createCheckButton(self, "General_Boss", 'showBoss', true)
	showBoss:SetPoint('TOPLEFT', showArena, 'BOTTOMLEFT', 0, -CB_GAP)

	local enablecb = createCheckButton(self, "General_Castbars", 'castbars', true)
	enablecb:SetPoint('TOPLEFT', showBoss, 'BOTTOMLEFT', 0, -(CB_GAP*3))
	local showTicks = createCheckButton(self, "General_Ticks", 'castbarticks')
	showTicks:SetPoint('TOPLEFT', enablecb, 'BOTTOMLEFT', INDENT, -CB_GAP)

	local portraitT = createCheckButton(self, "General_PTimer", 'portraitTimer', true)
	portraitT:SetPoint('TOPLEFT', showTicks, 'BOTTOMLEFT', -INDENT, (-CB_GAP)*3)
	local combattext = createCheckButton(self, "General_Feedback", 'combatText', true)
	combattext:SetPoint('TOPLEFT', portraitT, 'BOTTOMLEFT', 0, -CB_GAP)
	local threatglow = createCheckButton(self, "General_Threat", 'threatGlow', true)
	threatglow:SetPoint('TOPLEFT', combattext, 'BOTTOMLEFT', 0, -CB_GAP)
	local colorDebuff = createCheckButton(self, "General_OnlyPlayer", 'colorPlayerDebuffsOnly')
	colorDebuff:SetPoint('TOPLEFT', threatglow, 'BOTTOMLEFT', 0, -CB_GAP)
	local useAuraTimer = createCheckButton(self, "General_AuraTimer", 'useAuraTimer', true)
	useAuraTimer:SetPoint('TOPLEFT', colorDebuff, 'BOTTOMLEFT', 0, -CB_GAP)
	local clickThrough = createCheckButton(self, "General_Click", 'clickThrough', oUFAbu.UpdateBaseFrames)
	clickThrough:SetPoint('TOPLEFT', useAuraTimer, 'BOTTOMLEFT', 0, -CB_GAP)

	--LEFT
	local focMod = createDropDown(self, "General_ModKey", 'focMod', true,
		{	{ value = 'shift-', text = SHIFT_KEY },
			{ value = 'ctrl-', text = CTRL_KEY },
			{ value = 'alt-', text = ALT_KEY }
	})
	focMod:SetPoint("TOPLEFT", self, "TOPRIGHT", -265, -38)
	local focBut = createDropDown(self, "General_ModButton", 'focBut', true,
		{	{ value = 'NONE', text = DISABLE },
			{ value = '1', text = KEY_BUTTON1 },
			{ value = '2', text = KEY_BUTTON2 },
			{ value = '3', text = KEY_BUTTON3 },
	})
	focBut:SetPoint("TOPLEFT", focMod, "BOTTOMLEFT", 0, -20)

	local absorbBar = createCheckButton(self, "General_Absorb", 'absorbBar', true)
	absorbBar:SetPoint('TOPRIGHT', -220, -138)
	local classPortraits = createCheckButton(self, "General_ClassP", 'classPortraits')
	classPortraits:SetPoint('TOPLEFT', absorbBar, 'BOTTOMLEFT', 0, -CB_GAP)

	-- Class buttons
	local inital = #self.widgets
	if type(GET(class)) == "boolean" then
		createCheckButton(self, "General_ClassModule", class, true)
	end

	if class == "DRUID" or class == "DEATHKNIGHT" or class == "PALADIN" or class == "WARRIOR" or class == "MONK" then
		createCheckButton(self, "General_Resolve", 'showVengeance', true)
		if class == "WARRIOR" then
			createCheckButton(self, "General_Enrage", 'showEnraged', true)
		elseif class == "DRUID" then
			createCheckButton(self, "General_Shrooms", 'showShrooms', true)
		end
	elseif class == "PRIEST" then
		createCheckButton(self, "General_WSBar", 'showWeakenedSoul', true)
	elseif class == "MAGE" then
		createCheckButton(self, "General_Arcane", 'showArcStacks', true)
	elseif class == "ROGUE" then
		createCheckButton(self, "General_SnD", 'showSlicenDice', true)
		createCheckButton(self, "General_Ant", 'showAnticipation', true)
	end

	for i = inital + 1, #self.widgets do
		self.widgets[i]:SetPoint('TOPLEFT', self.widgets[i-1], 'BOTTOMLEFT', 0, -CB_GAP)
		self.widgets[i].Text:SetTextColor(color.r, color.g, color.b)
	end
end

function general:Update()
	for i = 1, #self.widgets do
		self.widgets[i]:Update()
	end
end
options:AddTab(L.General, general)

--------------------------------------------------------
--		TEXTURE PANEL

local textures = CreateFrame('Frame', optionsName..'_Textures', options)

local update = {
	PlayerTexture = function()
		return oUFAbu:UpdateBaseFrames("player")
	end,
	Healthbars = function()
		local mode = GET("healthcolormode")
		local r, g, b = unpack(GET("healthcolor"))
		for _, v in pairs(oUF.objects) do
			local hp = v.Health
			if (hp) then
				hp.colorClass = mode == 'CLASS'
				hp.colorReaction = mode == 'CLASS'
				hp.colorSmooth = mode == 'NORMAL'
				hp.colorTapping = mode ~= 'CUSTOM'
				if mode == 'CUSTOM' then
					hp:SetStatusBarColor(r, g, b)
				else
					hp:ForceUpdate()
				end
			end
		end
	end,
	Powerbars = function()
		local mode = GET("powercolormode")
		local r, g, b = unpack(GET("powercolor"))
		for _, v in ipairs(oUF.objects) do
			local mp = v.Power
			if (mp) then
				mp.colorClass = mode == 'CLASS'
				mp.colorPower = mode == 'TYPE'
				if mode == 'CUSTOM' then
					mp:SetStatusBarColor(r, g, b)
				else
					mp:ForceUpdate()
				end
			end
		end
	end,
	
	Safezone = function()
		if oUF_AbuPlayerCastbar and oUF_AbuPlayerCastbar.SafeZone then
			oUF_AbuPlayerCastbar.SafeZone:SetVertexColor(unpack(GET"castbarSafezoneColor"))
		end
	end,
	Framecolors = function() oUFAbu:SetAllFrameColors() end,
	Backdrops = function() oUFAbu:SetAllBackdrops() end,
}

function textures:Create()
	self.widgets = { }

	-- Statusbar selector
	local selector = ns.Widgets.StatusbarSelector(self, L["Texture_Statusbar"])
	selector:SetPoint('TOPLEFT', self, 'TOPLEFT', 12, -20)
	selector:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', -12, -200)
	selector.db = 'statusbar'
	selector.reload = function() oUFAbu:SetAllStatusBars() end

	selector.SetSavedValue = function(self, value)
		SET(self.db, value, self.reload)
	end
	selector.GetSavedValue = function(self)
		return GET(self.db)
	end
	table.insert(self.widgets, selector)

	-- Bottom group
	local f = ns.Widgets.Group(self, L["Texture_Frames"])
	f:SetPoint('TOPLEFT', selector, 'BOTTOMLEFT', 0 , -16)
	f:SetPoint('BOTTOMRIGHT', -12 , 12)
	f:SetText(L["Texture_Frames"])

	--		player texture
	local playerTexture
	do
		playerTexture = createDropDown(self, "Texture_Player", 'playerStyle', update.PlayerTexture,
			{	{ value = 'normal', 	text = L['Texture_Normal'], 	tooltip = L['Texture_NormalTip'] },
				{ value = 'rare', 		text = L['Texture_Rare'], 		tooltip = L['Texture_RareTip'] },
				{ value = 'elite', 		text = L['Texture_Elite'], 		tooltip = L['Texture_EliteTip'] },
				{ value = 'rareelite', 	text = L['Texture_RareElite'], 	tooltip = L['Texture_RareEliteTip'] },
				{ value = 'custom', 	text = L['Texture_Custom'], 	tooltip = L['Texture_CustomTip'] },
			}, 180)

		local box = CreateFrame("EditBox", nil, playerTexture, 'InputBoxTemplate')
		box:SetAutoFocus(false)
		box:SetWidth(325)
		box:SetHeight(20)
		box:SetPoint('TOPLEFT', playerTexture, 'TOPRIGHT', 0, -3)
		box:SetText(GET("customPlayerTexture"))
		box:SetCursorPosition(0)
		box.db = 'customPlayerTexture'

		box:SetScript("OnEnterPressed", function(self)
			SET(self.db, self:GetText(), self:GetParent().reload)
			self:ClearFocus()
		end)

		box:SetScript("OnEscapePressed", function(self)
			RESET(self.db, self:GetParent().reload)
			self:SetText(GET(self.db))
			self:ClearFocus()
		end)

		local path = box:CreateFontString(nil, 'ARTWORK', "GameFontNormal")
		path:SetText(L["Texture_Path"])
		path:SetPoint('TOPLEFT', box, 'TOPLEFT', 0, 13)

		playerTexture.GetSavedValue = function(self)
			if GET(self.db) == 'custom' then
				box:Show()
			else
				box:Hide()
			end
			return GET(self.db)
		end
	end
	playerTexture:SetPoint('TOPLEFT', f, 'TOPLEFT', 6, -22)

	local GAP = 14
	local nameText = createDropdownWithColorSelector(self, 'Color_NameText', 'TextNameColorMode', 'TextNameColor', false, 
		{	
			{ value = 'CLASS', 	text = L['Color_Class'], 	tooltip = L['Color_ClassTip'] },
			{ value = 'CUSTOM', text = L['Color_Custom'], 	tooltip = L['Color_CustomTip'] }, 
		})
	nameText:SetPoint('TOPLEFT', playerTexture, 'BOTTOMLEFT', 0, -GAP)
	local hpText = createDropdownWithColorSelector(self, 'Color_HealthText', 'TextHealthColorMode', 'TextHealthColor', false, 
		{
			{ value = 'CLASS', text = L['Color_Class'], tooltip = L['Color_ClassTip'] },
			{ value = 'GRADIENT', text = L['Color_Gradient'], tooltip = L['Color_GradientTip'] },
			{ value = 'CUSTOM', text = L['Color_Custom'], tooltip = L['Color_CustomTip'] },
		})
	hpText:SetPoint('TOPLEFT', nameText, 'BOTTOMLEFT', 0, -GAP)
	local mpText = createDropdownWithColorSelector(self, 'Color_PowerText', 'TextPowerColorMode', 'TextPowerColor', false, 
		{
			{ value = 'CLASS', text = L['Color_Class'], tooltip = L['Color_ClassTip'] },
			{ value = 'TYPE', text = L['Color_Power'], tooltip = L['Color_PowerTip'] },
			{ value = 'CUSTOM', text = L['Color_Custom'], tooltip = L['Color_CustomTip'] },
		})
	mpText:SetPoint('TOPLEFT', hpText, 'BOTTOMLEFT', 0, -GAP)

	local frameColor = createColorSelector(self, 'frameColor', update.Framecolors, false, true)
	frameColor:SetPoint('TOPLEFT', mpText, 'BOTTOMLEFT', 52, -1)
	frameColor:SetText(L['Color_Frame'])
	local szColor = createColorSelector(self, 'castbarSafezoneColor', update.Safezone, true, true)
	szColor:SetPoint('TOPLEFT', frameColor, 'BOTTOMLEFT', 0, -10)
	szColor:SetText(L['Color_Latency'])
	local backdColor = createColorSelector(self, 'backdropColor', update.Backdrops, true, true)
	backdColor:SetPoint('TOPLEFT', szColor, 'BOTTOMLEFT', 0, -10)
	backdColor:SetText(L['Color_Backdrop'])

	local hpBar = createDropdownWithColorSelector(self, 'Color_HealthBar', 'healthcolormode', 'healthcolor', update.Healthbars, 
		{
			{ value = 'NORMAL', text = L['Color_Gradient'], tooltip = L['Color_GradientTip'] },
			{ value = 'CLASS', 	text = L['Color_Class'], 	tooltip = L['Color_ClassTip'] },
			{ value = 'CUSTOM', text = L['Color_Custom'], 	tooltip = L['Color_CustomTip'] },
		})
	hpBar:SetPoint('TOPLEFT', hpText, 'TOPRIGHT', 70, 0)
	local mpBar = createDropdownWithColorSelector(self, 'Color_PowerBar', 'powercolormode', 'powercolor', update.Powerbars, 
		{
		{ value = 'TYPE', text = L['Color_Power'], tooltip = L['Color_PowerTip'] },
		{ value = 'CLASS', text = L['Color_Class'], tooltip = L['Color_ClassTip'] },
		{ value = 'CUSTOM', text = L['Color_Custom'], tooltip = L['Color_CustomTip'] },
	})
	mpBar:SetPoint('TOPLEFT', hpBar, 'BOTTOMLEFT', 0, -GAP)

end

function textures:Update()
	for i = 1, #self.widgets do
		self.widgets[i]:Update()
	end
end

options:AddTab(L.Texture, textures)

--------------------------------------------------------
--		FONT PANEL

local fonts = CreateFrame('Frame', optionsName..'_Fonts', options)

function fonts:Create()
	self.widgets = { }

	local function createselector(self, name, db)
		local f = ns.Widgets.FontSelector(self, L[name])
		f.db = db
		f.reload = oUFAbu.SetAllFonts

		function f:SetSavedValue(value)
			SET(self.db, value, self.reload)
		end
		function f:GetSavedValue()
			return GET(self.db)
		end

		table.insert(self.widgets, f)
		return f
	end

	local outlines = {
		{ value = 'NONE', text = NONE },
		{ value = 'THINOUTLINE', text = L['Font_ThinOutline'] },
		{ value = 'OUTLINE', text = L['Font_Outline'] },
		{ value = 'THICKOUTLINE', text = L['Font_ThickOutline'] },
		{ value = 'OUTLINEMONOCHROME', text = L['Font_OutlineMono'] },
	}
	local function slider_GetFormattedText(self, value)
		return string.format('%d%%', value * 100)
	end

	local normalfont = createselector(self, "Font_Number", 'fontNormal')
	normalfont:SetPoint('TOPLEFT', self, 'TOPLEFT', 12, -20)
	normalfont:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', -12, -200)

	local normaloutline = createDropDown(self, "Font_NumberOutline", 'fontNormalOutline', oUFAbu.SetAllFonts, outlines, 180)
	normaloutline:SetPoint('TOPLEFT', normalfont, 'BOTTOMLEFT', 32, -20)

	local normalSize = createSlider(self, "Font_NumberSize", 'fontNormalSize', oUFAbu.SetAllFonts, .5, 1.5, .05)
	normalSize:SetPoint('LEFT', normaloutline, 'RIGHT', 40, 0)
	normalSize.GetFormattedText = slider_GetFormattedText

	local bigfont = createselector(self, "Font_Name", 'fontBig')
	bigfont:SetPoint('TOPLEFT', normalfont, 'BOTTOMLEFT', 0, -65)
	bigfont:SetPoint('BOTTOMRIGHT', normalfont, 'BOTTOMRIGHT', 0, -245)

	local bigoutline = createDropDown(self, "Font_NameOutline", 'fontBigOutline', oUFAbu.SetAllFonts, outlines, 180)
	bigoutline:SetPoint('TOPLEFT', bigfont, 'BOTTOMLEFT', 32, -20)

	local bigSize = createSlider(self, "Font_NameSize", 'fontBigSize', oUFAbu.SetAllFonts, .5, 1.5, .05)
	bigSize:SetPoint('LEFT', bigoutline, 'RIGHT', 40, 0)
	bigSize.GetFormattedText = slider_GetFormattedText

end

function fonts:Update()
	for i = 1, #self.widgets do
		self.widgets[i]:Update()
	end
end

options:AddTab(L["Font"], fonts)