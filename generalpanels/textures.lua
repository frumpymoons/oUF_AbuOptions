local _, ns = ...
local TextureOptions = CreateFrame('Frame', 'oUFAbuOptions_Textures')
local L = ns.L

local HealthModeDropmenu = {
	['NORMAL'] = 	{L.ColorGradient, 	L.ColorGradientTip},
	['CLASS']   = 	{L.ColorClass, 		L.ColorClassTip},
	['CUSTOM']  = 	{L.ColorCustom, 	L.ColorCustomTip},
}
local PowerModeDropmenu = {
	['TYPE'] 	=	{ L.ColorPower , L.ColorPowerTip },
	['CLASS']   =	{ L.ColorClass , L.ColorClassTip },
	['CUSTOM']  =	{ L.ColorCustom , L.ColorCustomTip },
}
local HealthTextModeDropmenu = {
	["CLASS"] 	= 	{ L.ColorClass,		L.ColorClassTip 	},
	["GRADIENT"]= 	{ L.ColorGradient,	L.ColorGradientTip	},
	["CUSTOM"] 	= 	{ L.ColorCustom,	L.ColorCustomTip	},
}
local PowerTextModeDropmenu = {
	["CLASS"] 	= 	{ L.ColorClass,  L.ColorClassTip  },
	["TYPE"] = 		{ L.ColorPower,  L.ColorPowerTip  },
	["CUSTOM"] 	= 	{ L.ColorCustom, L.ColorCustomTip },
}
local NameTextModeDropmenu = {
	["CLASS"] = {L.ColorClass, L.ColorClassTip },
	["CUSTOM"] 	= 	{ L.ColorCustom, L.ColorCustomTip },
}

function TextureOptions:AddWidgets()
	self.widgets = {}

	local statusbarSelector = self:StatusbarSelector(L.StatusBarTex, 'statusbar')
	statusbarSelector:SetPoint('TOPLEFT', self, 'TOPLEFT', 12, -20)
	statusbarSelector:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', -12, -200)

	local f = oUFAbuOptions.Group:New(L.Frames, self)
	f:SetPoint('TOPLEFT', statusbarSelector, 'BOTTOMLEFT', 0 , -16)
	f:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', -12 , 12)

	local playerTexture = self:PlayerTexture(f)
	playerTexture:SetPoint('TOPLEFT', f, 'TOPLEFT', 6, -22)
	

	local ddgap = -14
	local nametext = self:DropdownWithColor(f, "NameText", NameTextModeDropmenu, "TextNameColorMode", "TextNameColor")
	nametext:SetPoint('TOPLEFT', playerTexture, 'BOTTOMLEFT', 0, ddgap)

	local hpbar = self:DropdownWithColor(f, "Health", HealthModeDropmenu, "healthcolormode", "healthcolor")
	hpbar:SetPoint('TOPLEFT', nametext, 'BOTTOMLEFT', 0, ddgap)
	local mpbar = self:DropdownWithColor(f, "Power", PowerModeDropmenu, "powercolormode", "powercolor")
	mpbar:SetPoint('TOPLEFT', hpbar, 'BOTTOMLEFT', 0, ddgap)

	local framecp = self:CreateColorSelector(f, L.FrameColor, 'frameColor', false, true)
	framecp:SetPoint('TOPLEFT', mpbar, 'BOTTOMLEFT', 52, -1)
	local szcp = self:CreateColorSelector(f, L.LatencyColor, 'castbarSafezoneColor', true, true)
	szcp:SetPoint('TOPLEFT', framecp, 'BOTTOMLEFT', 0, -10)
	local bdcp = self:CreateColorSelector(f, L.BackdropColor, 'backdropColor', true, true)
	bdcp:SetPoint('TOPLEFT', szcp, 'BOTTOMLEFT', 0, -10)

	local hptext = self:DropdownWithColor(f, "HealthText", HealthTextModeDropmenu, "TextHealthColorMode", "TextHealthColor")
	hptext:SetPoint('TOPLEFT', hpbar, 'TOPRIGHT', 30, -2)
	local mptext = self:DropdownWithColor(f, "PowerText", PowerTextModeDropmenu, "TextPowerColorMode", "TextPowerColor")
	mptext:SetPoint('TOPLEFT', hptext, 'BOTTOMLEFT', 0, ddgap)
end

-- [[ Update Fucntion ]] --
function TextureOptions:UpdateValues()
	for i, dd in pairs(self.widgets) do
		dd:UpdateValues()
	end

	oUFAbu:SetAllStatusBars()
	oUFAbu:SetAllBackdrops()
	oUFAbu:UpdateBaseFrames("player")
	oUFAbu:SetAllFrameColors()

	if oUF_AbuPlayerCastbar and oUF_AbuPlayerCastbar.SafeZone then
		oUF_AbuPlayerCastbar.SafeZone:SetVertexColor(unpack(self:GetSettings("castbarSafezoneColor")))
	end

	for _, unitframe in ipairs(oUF.objects) do
		local hp = unitframe.Health
		if (hp) then
			hp.colorClass = self:GetSettings("healthcolormode") == 'CLASS'
			hp.colorReaction = self:GetSettings("healthcolormode") == 'CLASS'
			hp.colorSmooth = self:GetSettings("healthcolormode") == 'NORMAL'
			if self:GetSettings("healthcolormode") == 'CUSTOM' then
				hp:SetStatusBarColor(unpack(self:GetSettings("healthcolor")))
			else
				hp:ForceUpdate()
			end
		end
		local mp = unitframe.Power
		if (mp) then
			mp.colorClass = TextureOptions:GetSettings("powercolormode") == 'CLASS'
			mp.colorPower = TextureOptions:GetSettings("powercolormode") == 'TYPE'
			if self:GetSettings("powercolormode") == 'CUSTOM' then
				mp:SetStatusBarColor(unpack(self:GetSettings("powercolor")))
			else
				mp:ForceUpdate()
			end
		end
	end
end

-- [[ Getting/setting settings ]]
function TextureOptions:GetSettings(db)
	return oUFAbuOptions:GetSettings()[db]
end

function TextureOptions:SetSetting(db, val, reqReload)
	oUFAbuOptions:GetSettings()[db] = val
	if (reqReload) then
		oUFAbuOptions.reload = true
	end
	self:UpdateValues()
end

function TextureOptions:ResetSetting(db, reqReload)
	self:SetSetting(db, oUFAbuOptions:GetDefaultSettings()[db], reqReload)
end

-- [[ Status bar selector ]] --
function TextureOptions:StatusbarSelector(name, db)
	local selector = oUFAbuOptions.StatusbarSelector:New(name, self, 552, 165)

	selector.SetSavedValue = function(self, value)
		TextureOptions:SetSetting(db, value)
	end

	selector.GetSavedValue = function(self)
		return TextureOptions:GetSettings(db)
	end
	
	selector:Show()
	return selector
end

function TextureOptions:CreateColorSelector(parent, name, db, alpha, button, hidetext)
	local cp = oUFAbuOptions.ColorSelector:New(name, parent, alpha, hidetext)
	cp.db = db
	if alpha then
		cp.OnSetColor = function(self, r, g, b, a)
			TextureOptions:SetSetting(self.db, {r, g, b, a})
		end

		cp.GetColor = function(self)
			local color = TextureOptions:GetSettings(self.db)
			return color[1], color[2], color[3], color[4]
		end
	else
		cp.OnSetColor = function(self, r, g, b)
			TextureOptions:SetSetting(self.db, {r, g, b})
		end

		cp.GetColor = function(self)
			local color = TextureOptions:GetSettings(self.db)
			return color[1], color[2], color[3]
		end
	end
	cp:SetColor(cp:GetColor())

	if not button then return cp; end
	local rebutt = CreateFrame('Button', nil, cp, 'UIPanelButtonTemplate')
	rebutt:SetSize(25, 25)
	rebutt:SetPoint('RIGHT', cp, 'LEFT', -5, 0)
	rebutt:SetText('X')
	rebutt:SetScript('OnClick', function(self)
		local cp = self:GetParent()
		TextureOptions:ResetSetting(cp.db)
		cp:SetColor(cp:GetColor())
	end)

	return cp
end

--[[ Dropdown Style Picker ]]
function TextureOptions:PlayerTexture(parent)
	local dd = oUFAbuOptions.Dropdown:New(L.PlayerTex, parent, 180)
	-- Editbox
	local box = CreateFrame("EditBox", dd:GetName().."box", dd, 'InputBoxTemplate')
	box:SetAutoFocus(false)
	box:SetWidth(325)
	box:SetHeight(20)
	box:SetPoint('TOPLEFT', dd, 'TOPRIGHT', 0, -3)
	box:SetText(self:GetSettings("customPlayerTexture"))
	box:SetCursorPosition(0)

	box:SetScript("OnEnterPressed", function(self)
		TextureOptions:SetSetting("customPlayerTexture", self:GetText())
		self:ClearFocus()
	end)

	box:SetScript("OnEscapePressed", function(self)
		TextureOptions:ResetSetting("customPlayerTexture")
		self:SetText(TextureOptions:GetSettings("customPlayerTexture"))
		self:ClearFocus()
	end)

	local desc = box:CreateFontString(box:GetName().."Desc", 'ARTWORK', "GameFontNormal")
	desc:SetText(L.Path)
	desc:SetPoint('TOPLEFT', box, 'TOPLEFT', 0, 13)

	--Dropdown
	local ddmenu = { 
		['normal'] = 	{L.PlayerTexNormal, 	L.PlayerTexNormalTip },
		['rare']   = 	{L.PlayerTexRare,		L.PlayerTexRareTip },
		['elite']  = 	{L.PlayerTexElite, 		L.PlayerTexEliteTip },
		['rareelite'] = {L.PlayerTexRareElite, 	L.PlayerTexRareEliteTip },
		['custom'] = 	{L.PlayerTexCustom, 	L.PlayerTexCustomTip },
	}

	dd.SetSavedValue = function(self, value)
		TextureOptions:SetSetting("playerStyle", value)
		if value == 'custom' then
			box:Show()
		else
			box:Hide()
		end
	end

	dd.GetSavedValue = function(self)
		if TextureOptions:GetSettings("playerStyle") == 'custom' then
			box:Show()
		else
			box:Hide()
		end
		return TextureOptions:GetSettings("playerStyle")
	end

	dd.GetSavedText = function(self)
		return ddmenu[self:GetSavedValue()][1]
	end

	UIDropDownMenu_Initialize(dd, function(self)
		for value, desc in pairs(ddmenu) do
			self:AddItem(desc[1], value, desc[2])
		end
	end)

	table.insert(self.widgets, dd)
	return dd
end

function TextureOptions:DropdownWithColor(parent, prefix, dropdownmenu, modeDB, colorDB)
	local dd = oUFAbuOptions.Dropdown:New(L[prefix.."ColorMode"], parent, 180)
	dd.db = modeDB
	local cp = self:CreateColorSelector(dd, L[prefix.."ColorCustom"], colorDB, nil, nil, true)
	cp:SetPoint('TOPLEFT', dd, 'TOPRIGHT', -5, -4)

	dd.SetSavedValue = function(self, value)
		if value == "CUSTOM" then
			cp:Show()
		else
			cp:Hide()
		end
		TextureOptions:SetSetting(self.db, value)
	end
	dd.GetSavedValue = function(self)
		local value = TextureOptions:GetSettings(self.db)
		if value == "CUSTOM" then
			cp:Show()
		else
			cp:Hide()
		end 
		return value
	end
	dd.GetSavedText = function(self)
		return dropdownmenu[self:GetSavedValue()][1]
	end
	UIDropDownMenu_Initialize(dd, function(self)
		for value, desc in pairs(dropdownmenu) do
			self:AddItem(desc[1], value, desc[2])
		end
	end)

	table.insert(self.widgets, dd)
	return dd
end

TextureOptions:AddWidgets()
oUFAbuOptions:AddGeneralTab('textures', L.Textures, TextureOptions)