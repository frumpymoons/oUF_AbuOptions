local _, ns = ...
local L = oUFAbu.localization

local options = _G['oUF_AbuOptions']
local optionsName = options:GetName()

local function GET(db, db2)
	if db2 then 
		return ns.settings[db][db2]
	end
	return ns.settings[db]
end

local function SET(db, value, reload, db2)
	if db2 then 
		ns.settings[db][db2] = value
	else
		ns.settings[db] = value
	end
	if type(reload) == "function" then
		reload()
	elseif reload then
		ns.reload = true
	end
end

local function RESET(db, reload, db2)
	if db2 then 
		ns.settings[db][db2] = ns.defaultsettings[db][db2]
	else
		ns.settings[db] = ns.defaultsettings[db]
	end
	if type(reload) == "function" then
		reload()
	elseif reload then
		ns.reload = true
	end
end

------------------------------------------------------------

local function createDropDown(parent, anchor, text, db, reload, items, width)
	width = tonumber(width) or 150
	local f = ns.Widgets.Dropdown(anchor, L[text], width, items)
	--UIDropDownMenu_JustifyText(f, "LEFT");
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

local function createSlider(parent, anchor, text, db, reload, lo, hi, step)
	local f = ns.Widgets.Slider(anchor, L[text], lo, hi, step)
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
	local dropdown = createDropDown(parent, parent, text, dropDB, reload, items, 180)

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

local function classAuraBar(parent)
	local f = CreateFrame('Frame', parent:GetName()..'ClassAuraBar', parent)
	f:SetSize(200,45)
	f.tooltip = L["General_classAuraBarTip"]
	f:SetScript('OnEnter', function(self)
		if self.tooltip then
			GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
			GameTooltip:SetText(self.tooltip)
		end
	end)

	f:SetScript('OnLeave', function(self)
		if GameTooltip:IsOwned(self) then
			GameTooltip:Hide()
		end
	end)

	local icon = f:CreateTexture(nil, 'BACKGROUND')
	icon:SetSize(20,20)
	icon:SetPoint('TOPLEFT', f, 'TOPLEFT', 3, 0)
	f.icon = icon

	local text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	text:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 5, 0)
	text:SetPoint('TOPLEFT', icon, 'TOPRIGHT', 5, 0)
	text:SetJustifyH("LEFT")
	text:SetJustifyV("CENTER")
	f.text = text

	local colorpicker = ns.Widgets.ColorSelector(f, false)
	colorpicker:SetPoint('BOTTOMLEFT', f, 'BOTTOMLEFT', 4, 3)
	f.colorpicker = colorpicker

	colorpicker.OnSetColor = function(self, r,g,b)
		local t = ns.settings.classBar[self:GetParent().specId]
		t.r, t.g, t.b = r, g, b
		self:GetParent():SaveValue()
	end

	colorpicker.GetColor = function(self)
		local t = ns.settings.classBar[self:GetParent().specId]
		return t.r, t.g, t.b
	end

	local box = CreateFrame("EditBox", nil, f, 'InputBoxTemplate')
	box:SetAutoFocus(false)
	box:SetMaxLetters(6)
	box:SetNumeric(true)	
	box:SetWidth(70)
	box:SetHeight(20)
	box:SetPoint('BOTTOMLEFT', f.colorpicker, 'BOTTOMRIGHT', 7, -1)
	box:SetCursorPosition(0)
	f.box = box

	box:SetScript("OnEnterPressed", function(self)
		self:ClearFocus()
		local id = self:GetNumber()
		if id and (id == 0 or GetSpellInfo(id)) then
			ns.settings.classBar[self:GetParent().specId].spellID = id
			self:GetParent():SaveValue()
		else
			self:SetNumber("")
		end
	end)

	box:SetScript("OnEscapePressed", function(self)
		self:ClearFocus()
		self:SetText(ns.settings.classBar[self:GetParent().specId].spellID)
	end)

	local spelltext = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	spelltext:SetPoint('TOPLEFT', box, 'TOPRIGHT', 5, -4)
	spelltext:SetJustifyH("LEFT")
	spelltext:SetJustifyV("TOP")
	spelltext:SetWidth(150)
	f.spelltext = spelltext

	f.SaveValue = function(self)
		self:Update()
		if oUF_AbuPlayer.Aurabar then
			oUF_AbuPlayer.Aurabar:ForceUpdate()
		end
	end

	f.Update = function(self)
		if ns.Classic then return self:Hide() end
		local index = GetSpecialization()
		if not index or not self:GetParent():IsVisible() then
			return self:Hide()
		end
		self:Show()
		local id, name, description, icon, background, role = GetSpecializationInfo(index)
		self.icon:SetTexture(icon)
		self.text:SetText(string.format(L["General_classAuraBar"], name))
		self.specId = id

		local _, class = UnitClass('player')
		local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
		self.text:SetTextColor(color.r, color.g, color.b)

		if not ns.settings.classBar[self.specId] or type(ns.settings.classBar[self.specId]) ~= 'table' then
			ns.settings.classBar[self.specId] = {spellID = 0, r = 0, g = 0, b = 0}
		end

		self.colorpicker:Update()
		self.box:GetScript("OnEscapePressed")(self.box)

		local spell = ns.settings.classBar[self.specId].spellID
		if spell == 0 then
			self.spelltext:SetText(ADDON_DISABLED)
		else
			local name, _, icon = GetSpellInfo(spell)
			if name and icon then
				self.spelltext:SetFormattedText("|T%s:0|t %s", icon, name)
			else
				self.spelltext:SetText("Invalid Spell") -- shouldnt happen
			end
		end
	end

	f:SetScript('OnEvent', f.Update)
	if not ns.Classic then
		f:RegisterEvent('PLAYER_TALENT_UPDATE')
	end

	table.insert(parent.widgets, f)
	return f
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
	local selfinparty = createCheckButton(self, "General_SelfInParty", 'showSelfInParty', true)
	selfinparty:SetPoint('TOPLEFT', partyinraid, 'BOTTOMLEFT', 0, -CB_GAP)
	local showArena = createCheckButton(self, "General_Arena", 'showArena', true)
	showArena:SetPoint('TOPLEFT', selfinparty, 'BOTTOMLEFT', -INDENT, -CB_GAP)
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
	local ThreatIndicator = createCheckButton(self, "General_Threat", 'ThreatIndicator', true)
	ThreatIndicator:SetPoint('TOPLEFT', combattext, 'BOTTOMLEFT', 0, -CB_GAP)
	local colorDebuff = createCheckButton(self, "General_OnlyPlayer", 'colorPlayerDebuffsOnly')
	colorDebuff:SetPoint('TOPLEFT', ThreatIndicator, 'BOTTOMLEFT', 0, -CB_GAP)
	local useAuraTimer = createCheckButton(self, "General_AuraTimer", 'useAuraTimer', true)
	useAuraTimer:SetPoint('TOPLEFT', colorDebuff, 'BOTTOMLEFT', 0, -CB_GAP)
	local clickThrough = createCheckButton(self, "General_Click", 'clickThrough', oUFAbu.UpdateBaseFrames)
	clickThrough:SetPoint('TOPLEFT', useAuraTimer, 'BOTTOMLEFT', 0, -CB_GAP)
	local combatFade = createCheckButton(self, "General_FadeFramesInCombat", 'combatFade', oUFAbu.UpdateBaseFrames)
	combatFade:SetPoint('TOPLEFT', clickThrough, 'BOTTOMLEFT', 0, -CB_GAP)

	--LEFT
	local focMod = createDropDown(self, self, "General_ModKey", 'focMod', true,
		{	{ value = 'shift-', text = SHIFT_KEY },
			{ value = 'ctrl-', text = CTRL_KEY },
			{ value = 'alt-', text = ALT_KEY }
	})
	focMod:SetPoint("TOPLEFT", self, "TOPRIGHT", -265, -38)
	local focBut = createDropDown(self, self, "General_ModButton", 'focBut', true,
		{	{ value = 'NONE', text = DISABLE },
			{ value = '1', text = KEY_BUTTON1 },
			{ value = '2', text = KEY_BUTTON2 },
			{ value = '3', text = KEY_BUTTON3 },
	})
	focBut:SetPoint("TOPLEFT", focMod, "BOTTOMLEFT", 0, -20)

	--local absorbBar = createCheckButton(self, "General_Absorb", 'absorbBar', true)
	--absorbBar:SetPoint('TOPRIGHT', -220, -138)
	local classPortraits = createCheckButton(self, "General_ClassP", 'classPortraits')
	classPortraits:SetPoint('TOPRIGHT', -220, -138)
	local comboPoints = createCheckButton(self, "General_showComboPoints", 'showComboPoints', function() oUFAbu:UpdateBaseFrames('player') end)
	comboPoints:SetPoint('TOPLEFT', self.widgets[#self.widgets-1], 'BOTTOMLEFT', 0, -CB_GAP)

	local powerPredictionBar = createCheckButton(self, "General_powerPredictionBar", 'powerPredictionBar')
	powerPredictionBar:SetPoint('TOPLEFT', self.widgets[#self.widgets-1], 'BOTTOMLEFT', 0, -CB_GAP)
	local builderSpender = createCheckButton(self, "General_builderSpender", 'builderSpender')
	builderSpender:SetPoint('TOPLEFT', self.widgets[#self.widgets-1], 'BOTTOMLEFT', 0, -CB_GAP)

	local asd = classAuraBar(self)
	asd:SetPoint('TOPLEFT', self.widgets[#self.widgets-1], 'BOTTOMLEFT', 0, -CB_GAP)

	for k, v in pairs(GET(class)) do
		local button = ns.Widgets.CheckButton(self, L['General_'..k])
		button.db = class
		button.db2 = k
		button.reload = true
		button.tooltip = L['General_'..k..'Tip']

		button.OnEnableSetting = function(self, enable)
			SET(self.db, enable, self.reload, self.db2)
		end

		button.IsSettingEnabled = function(self)
			return GET(self.db, self.db2)
		end

		table.insert(self.widgets, button)
		local i = #self.widgets

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
	Text = function()
		return oUFAbu:UpdateBaseFrames()
	end,
	Healthbars = function()
		local mode = GET("healthcolormode")
		local r, g, b = unpack(GET("healthcolor"))
		for _, v in pairs(oUF.objects) do
			local hp = v.Health
			if hp and v.style == "oUF_Abu" then
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
		local useAtlas = GET("powerUseAtlas")
		local r, g, b = unpack(GET("powercolor"))
		for _, v in ipairs(oUF.objects) do
			local mp = v.Power
			if (mp and v.style == "oUF_Abu") then
				mp.useAtlas = useAtlas
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
		playerTexture = createDropDown(self, self, "Texture_Player", 'playerStyle', update.PlayerTexture,
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

	local borderTex = createDropDown(self, self, 'Texture_Border', 'borderType', true,
		{	{ value = 'abu', text = "Abu" },
			{ value = 'neal', text = "Neal" }
		}, 180)
	borderTex:SetPoint('TOPLEFT', playerTexture, 'TOPRIGHT', 70, 0)

	local hpBar = createDropdownWithColorSelector(self, 'Color_HealthBar', 'healthcolormode', 'healthcolor', update.Healthbars, 
		{
			{ value = 'NORMAL', text = L['Color_Gradient'], tooltip = L['Color_GradientTip'] },
			{ value = 'CLASS', 	text = L['Color_Class'], 	tooltip = L['Color_ClassTip'] },
			{ value = 'CUSTOM', text = L['Color_Custom'], 	tooltip = L['Color_CustomTip'] },
		})
	hpBar:SetPoint('TOPLEFT', borderTex, 'BOTTOMLEFT', 0, -GAP)
	local mpBar = createDropdownWithColorSelector(self, 'Color_PowerBar', 'powercolormode', 'powercolor', update.Powerbars, 
		{
			{ value = 'TYPE', text = L['Color_Power'], tooltip = L['Color_PowerTip'] },
			{ value = 'CLASS', text = L['Color_Class'], tooltip = L['Color_ClassTip'] },
			{ value = 'CUSTOM', text = L['Color_Custom'], tooltip = L['Color_CustomTip'] },
		})
	mpBar:SetPoint('TOPLEFT', hpBar, 'BOTTOMLEFT', 0, -GAP)

	local useAtlas = createCheckButton(self, "General_useAtlas", 'powerUseAtlas', update.Powerbars)
	useAtlas:SetPoint('TOPLEFT', mpBar, 'BOTTOMLEFT', 20, -5)

	-- createColorSelector(parent, db, reload, hasOpacity, hasResetButton)
	local unInterruptibleColor = createColorSelector(self, 'castbarUnInterruptibleColor', update.Framecolors, true, true)
	unInterruptibleColor:SetPoint('TOPLEFT', frameColor, 'TOPRIGHT', 280, 0)
	unInterruptibleColor:SetText(L['Color_UnInterruptible'])

	-- local interruptibleColor = createColorSelector(self, 'castbarInterruptibleColor', update.Framecolors, true, true)
	-- interruptibleColor:SetPoint('TOPLEFT', unInterruptibleColor, 'BOTTOMLEFT', 0, -GAP)
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

	local dim = _G[optionsName..'_PanelArea']
	fonts.scrollFrame = CreateFrame('ScrollFrame',optionsName..'_FontsScrollFrame',fonts,'UIPanelScrollFrameTemplate')
	fonts.scrollFrame:ClearAllPoints()
	fonts.scrollFrame:SetPoint('TOPLEFT', dim, 4, -4)
	fonts.scrollFrame:SetPoint('BOTTOMRIGHT', dim, -4, 4)

	fonts.scrollFrame.child = CreateFrame('Frame', optionsName..'_FontsScrollFrameChild', fonts.scrollFrame)
	fonts.scrollFrame.child:SetSize(fonts.scrollFrame:GetWidth(), 700)
	fonts.scrollFrame:SetScrollChild(fonts.scrollFrame.child)

	fonts.scrollFrame.ScrollBar:SetPoint('TOPLEFT', fonts.scrollFrame, 'TOPRIGHT', -16, -16)
	fonts.scrollFrame.ScrollBar:SetPoint('BOTTOMLEFT', fonts.scrollFrame, 'BOTTOMRIGHT', -16, 16)
	fonts.scrollFrame.ScrollBar.scrollStep = 20

	local function createselector(self, name, db)
		local f = ns.Widgets.FontSelector(fonts.scrollFrame.child, L[name])
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
		{ value = 'OUTLINE', text = L['Font_Outline'] },
		{ value = 'OUTLINEMONOCHROME', text = L['Font_OutlineMono'] },
	}
	local function slider_GetFormattedText(self, value)
		return string.format('%d%%', value * 100)
	end

	local numberFont = createselector(self, "Font_Number", 'fontNumber')
	numberFont:SetPoint('TOPLEFT', fonts.scrollFrame.child, 'TOPLEFT', 12, -20)
	numberFont:SetPoint('BOTTOMRIGHT', fonts.scrollFrame.child, 'TOP', -8, -200)

	local numberOutline = createDropDown(self, fonts.scrollFrame.child, "Font_NumberOutline", 'fontNumberOutline', oUFAbu.SetAllFonts, outlines, 180)
	numberOutline:SetPoint('TOPLEFT', numberFont, 'TOPRIGHT', 18, -20)

	local numberSize = createSlider(self, fonts.scrollFrame.child, "Font_NumberSize", 'fontNumberSize', oUFAbu.SetAllFonts, .5, 1.5, .05)
	numberSize:SetPoint('TOP', numberOutline, 'BOTTOM', 0, -18)
	numberSize.GetFormattedText = slider_GetFormattedText

	local healthOffset = createSlider(self, fonts.scrollFrame.child, "Font_HealthOffset", 'fontHealthOffset', update.Text, -20, 20, 1)
	healthOffset:SetPoint('TOP', numberSize, 'BOTTOM', 0, -22)

	local powerOffset = createSlider(self, fonts.scrollFrame.child, "Font_PowerOffset", 'fontPowerOffset', update.Text, -20, 20, 1)
	powerOffset:SetPoint('TOP', healthOffset, 'BOTTOM', 0, -22)

	local nameFont = createselector(self, "Font_Name", 'fontName')
	nameFont:SetPoint('TOPLEFT', numberFont, 'BOTTOMLEFT', 0, -30)
	nameFont:SetPoint('BOTTOMRIGHT', numberFont, 'BOTTOMRIGHT', 0, -210)

	local nameOutline = createDropDown(self, fonts.scrollFrame.child, "Font_NameOutline", 'fontNameOutline', oUFAbu.SetAllFonts, outlines, 180)
	nameOutline:SetPoint('TOPLEFT', nameFont, 'TOPRIGHT', 18, -20)

	local nameSize = createSlider(self, fonts.scrollFrame.child, "Font_NameSize", 'fontNameSize', oUFAbu.SetAllFonts, .5, 1.5, .05)
	nameSize:SetPoint('TOP', nameOutline, 'BOTTOM', 0, -18)
	nameSize.GetFormattedText = slider_GetFormattedText

	local barFont = createselector(self, "Font_Bar", 'fontBar')
	barFont:SetPoint('TOPLEFT', nameFont, 'BOTTOMLEFT', 0, -30)
	barFont:SetPoint('BOTTOMRIGHT', nameFont, 'BOTTOMRIGHT', 0, -210)

	local barOutline = createDropDown(self, fonts.scrollFrame.child, "Font_BarOutline", 'fontBarOutline', oUFAbu.SetAllFonts, outlines, 180)
	barOutline:SetPoint('TOPLEFT', barFont, 'TOPRIGHT', 18, -20)

	local barSize = createSlider(self, fonts.scrollFrame.child, "Font_BarSize", 'fontBarSize', oUFAbu.SetAllFonts, .5, 1.5, .05)
	barSize:SetPoint('TOP', barOutline, 'BOTTOM', 0, -18)
	barSize.GetFormattedText = slider_GetFormattedText

	-- local levelFont = createselector(self, "Font_Level", 'fontLevel')
	-- levelFont:SetPoint('TOPLEFT', nameFont, 'BOTTOMLEFT', 0, -65)
	-- levelFont:SetPoint('BOTTOMRIGHT', nameFont, 'BOTTOMRIGHT', 0, -245)

	-- local levelOutline = createDropDown(self, fonts, "Font_LevelOutline", 'fontLevelOutline', oUFAbu.SetAllFonts, outlines, 180)
	-- levelOutline:SetPoint('TOPLEFT', levelFont, 'BOTTOMLEFT', 32, -20)

	-- local levelSize = createSlider(self, fonts, "Font_LevelSize", 'fontLevelSize', oUFAbu.SetAllFonts, .5, 1.5, .05)
	-- levelSize:SetPoint('LEFT', levelOutline, 'RIGHT', 40, 0)
	-- levelSize.GetFormattedText = slider_GetFormattedText
end

function fonts:Update()
	for i = 1, #self.widgets do
		self.widgets[i]:Update()
	end
end

options:AddTab(L["Font"], fonts)