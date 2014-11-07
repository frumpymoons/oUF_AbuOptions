local _, ns = ...
local L = ns.L
local BasicOptions = CreateFrame('Frame', 'oUFAbuOptions_Basic')

local CB_GAP = 5
local SIDE_GAP = 14
--[[
local L = {
	Shift = "Shift",
	Ctrl = "Ctrl",
	Alt = "Alt",
	Disable = "Disable",
	Button1 = "Button 1",
	Button2 = "Button 2",
	MButton = "Middle Button",
	General = "General",

	NoEffectUntilRL = "These options will not take effect until you reload the UI.",
	EnablePartyFrames = "Enable Party Frames",
	ShowPartyInRaid = "Display Party Frames in Raid",
	EnableArena = "Enable Arena Frames",
	EnableBoss = "Enable Boss Frames",
	EnableCastbars = "Enable Castbars",
	DisplayChannelTicks = "Display Channeling Ticks",
	ShowPortraitTimer = "Show Portrait Timers",
	ShowCBFeedback = "Show Combat Feedback",
	EnableThreatGlow = "Enable Threat Glow",
	OnlyColorPlayer = "Only Color Player Debuffs",
	ShowAuraTimer = "Show Aura Timer",
	ShowAuraTimerTip = "Disable the inbuilt Aura Timer",
	ClickthroughFrames = "Clickthrough frames",
	ClickthroughFramesTip = "Make the frames click through.",
	FocusModKey = 'Focus Modifier Key',
	FocusModButton = 'Focus Mouse Button',
	EnableAbsorbBar = "Enable Absorb Bar",
	EnableAbsorbBarTip = "Display a bar showing total absorb on a unit.",
	EnableClassPortait = "Enable Class Portraits",
	EnableClassPortaitTip = "Display a class icon instead of portrait on players.",
	EnableResolve = "Enable Resolve Bar",
	EnableResolveTip = "Display a Resolve bar for Tanks above the player frame.",
	EnableEnrageBar = "Enable Warrior Enrage Bar",
	EnableEnrageBarTip = "Display a Enrage bar for Fury Warriors above the player frame.",
	EnableWSBar = "Enable Weakened Soul Bar",
	EnableWSBarTip = "Display a Weakened Soul bar for Priests.",
	EnableArcCharge = "Enable Mage Arcane Charge",
	EnableArcChargeTip = "Display a counter for Arcane Charges.",
	EnableSnD = "Enable Slice and Dice bar",
	EnableSnDTip = "Display a bar for Slice and Dice.",
	EnableAnticipation = "Show Anticipation Charges",
	EnableAnticipationTip = "Display additional combopoints for Anticipation charges.",
}]]

local FocusModiKey = {
	['shift-'] = L.Shift,
	['ctrl-'] = L.Ctrl,
	['alt-'] = L.Alt,
}
local FocusButton = {
	['NONE'] = L.Disable,
	['1'] = L.Button1,
	['2'] = L.Button2,
	['3'] = L.MButton,
} 

function BasicOptions:GetConfig(db)
	return oUFAbuOptions:GetSettings()[db]
end

function BasicOptions:SetConfig(db, val, reload)
	oUFAbuOptions:GetSettings()[db] = val
	if type(reload) == "function" then
		reload()
	elseif reload then
		oUFAbuOptions.reload = true
	end
end

function BasicOptions:AddWidgets()
	local checkboxes = self:CreateCheckBoxes('')	
	checkboxes:SetPoint('TOPLEFT', self, 'TOPLEFT', 12, -20)
	checkboxes:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', -12, 12)
end

function BasicOptions:UpdateValues()
	if self.widges then
		for _, w in pairs(self.widges) do
			w:UpdateValues()
		end
	end
end

--[[ Drop Down]]
function BasicOptions:CreateFocusDropDown(parent, name, dropmenu, db)
	local dd = oUFAbuOptions.Dropdown:New(name, parent, 150)

	dd.SetSavedValue = function(self, value)
		BasicOptions:SetConfig(db, value, true)
	end

	dd.GetSavedValue = function(self)
		return BasicOptions:GetConfig(db)
	end

	dd.GetSavedText = function(self)
		return dropmenu[self:GetSavedValue()]
	end

	UIDropDownMenu_Initialize(dd, function(self)
		for k,v in pairs(dropmenu) do
			self:AddItem(v, k)
		end
	end)

	self.widgets = self.widgets or {}
	table.insert(self.widgets, dd)
	return dd
end

--[[ Unlock Frames Button]]
function BasicOptions:CreateUnlockerButton(parent)
	local butt = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	butt:SetSize(140, 25)
	butt:SetText("Toggle Anchors")
	butt:SetScript("OnClick", function(self)
		if ( oUFAbu:ToggleDummyFrames() ) then
			self:LockHighlight()
		else
			self:UnlockHighlight()
		end
	end)
	return butt
end

--[[ Check Boxes ]]
function BasicOptions:SimpleCheckBox(parent, name, db, reqReload)
	local cb = oUFAbuOptions.CheckButton:New(L[name], parent)

	cb.OnEnableSetting = function(self, enable)
		BasicOptions:SetConfig(db, enable, reqReload)
	end

	cb.IsSettingEnabled = function(self)
		return BasicOptions:GetConfig(db)
	end	

	if L[name.."Tip"] then
		cb.tooltip = L[name.."Tip"]
	end

	self.widgets = self.widgets or {}
	table.insert(self.widgets, cb)
	return cb
end

function BasicOptions:CreateCheckBoxes(title)
	local f = oUFAbuOptions.Group:New(title, self)
	local _, class = UnitClass("player")
	local RAID_CLASS_COLORS = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
	local color = RAID_CLASS_COLORS[class]

	local text = f:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
	text:SetHeight(32)
	text:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -18)
	text:SetNonSpaceWrap(true)
	text:SetJustifyH("LEFT")
	text:SetJustifyV("TOP")
	text:SetText(L.NoEffectUntilRL)
	--RIGHT
	local showparty = self:SimpleCheckBox(f, "EnablePartyFrames", 'showParty', true)
	showparty:SetPoint('TOPLEFT', f, 'TOPLEFT', SIDE_GAP, -38)
	local partyinraid = self:SimpleCheckBox(f, "ShowPartyInRaid", 'showPartyInRaid', true)
	partyinraid:SetPoint('TOPLEFT', showparty, 'BOTTOMLEFT', 20, -CB_GAP)
	local showArena = self:SimpleCheckBox(f, "EnableArena", 'showArena', true)
	showArena:SetPoint('TOPLEFT', partyinraid, 'BOTTOMLEFT', -20, -CB_GAP)
	local showBoss = self:SimpleCheckBox(f, "EnableBoss", 'showBoss', true)
	showBoss:SetPoint('TOPLEFT', showArena, 'BOTTOMLEFT', 0, -CB_GAP)

	local enablecb = self:SimpleCheckBox(f, "EnableCastbars", 'castbars', true)
	enablecb:SetPoint('TOPLEFT', showBoss, 'BOTTOMLEFT', 0, (-CB_GAP)*3)
	local showTicks = self:SimpleCheckBox(f, "DisplayChannelTicks", 'castbarticks')
	showTicks:SetPoint('TOPLEFT', enablecb, 'BOTTOMLEFT', 20, -CB_GAP)

	local portraitTimer = self:SimpleCheckBox(f, "ShowPortraitTimer", 'portraitTimer', true)
	portraitTimer:SetPoint('TOPLEFT', showTicks, 'BOTTOMLEFT', -20, (-CB_GAP)*3)
	local combattext = self:SimpleCheckBox(f, "ShowCBFeedback", 'combatText', true)
	combattext:SetPoint('TOPLEFT', portraitTimer, 'BOTTOMLEFT', 0, -CB_GAP)
	local threatglow = self:SimpleCheckBox(f, "EnableThreatGlow", 'threatGlow', true)
	threatglow:SetPoint('TOPLEFT', combattext, 'BOTTOMLEFT', 0, -CB_GAP)
	local colorDebuff = self:SimpleCheckBox(f, "OnlyColorPlayer", 'colorPlayerDebuffsOnly')
	colorDebuff:SetPoint('TOPLEFT', threatglow, 'BOTTOMLEFT', 0, -CB_GAP)
	local useAuraTimer = self:SimpleCheckBox(f, "ShowAuraTimer", 'useAuraTimer', true)
	useAuraTimer:SetPoint('TOPLEFT', colorDebuff, 'BOTTOMLEFT', 0, -CB_GAP)
	local clickThrough = self:SimpleCheckBox(f, "ClickthroughFrames", 'clickThrough', oUFAbu.UpdateBaseFrames)
	clickThrough:SetPoint('TOPLEFT', useAuraTimer, 'BOTTOMLEFT', 0, -CB_GAP)

	--LEFT
	local focModDrop = self:CreateFocusDropDown(f, L.FocusModKey, FocusModiKey, 'focMod', true)
	focModDrop:SetPoint("TOPLEFT", f, "TOPRIGHT", -265, -38)
	local focButDrop = self:CreateFocusDropDown(f, L.FocusModButton, FocusButton, 'focBut', true)
	focButDrop:SetPoint("TOPLEFT", focModDrop, "BOTTOMLEFT", 0, -20)

	local absorbBar = self:SimpleCheckBox(f, "EnableAbsorbBar", 'absorbBar', true)
	absorbBar:SetPoint('TOPRIGHT', f, 'TOPRIGHT', -220, -138)
	local classPortraits = self:SimpleCheckBox(f, "EnableClassPortait", 'classPortraits')
	classPortraits:SetPoint('TOPLEFT', absorbBar, 'BOTTOMLEFT', 0, -CB_GAP)

		-- Class buttons
	if class == "DRUID" or class == "DEATHKNIGHT" or class == "PALADIN" or class == "WARRIOR" or class == "MONK" then
		local showVeng = self:SimpleCheckBox(f, "EnableResolve", 'showVengeance', true)
		showVeng:SetPoint('TOPLEFT', classPortraits, 'BOTTOMLEFT', 0, -CB_GAP)
		_G[showVeng:GetName().."Text"]:SetTextColor(color.r, color.g, color.b)
		if class == "WARRIOR" then
			local showEnraged = self:SimpleCheckBox(f, "EnableEnrageBar", 'showEnraged', true)
			showEnraged:SetPoint('TOPLEFT', showVeng, 'BOTTOMLEFT', 0, -CB_GAP)
			_G[showEnraged:GetName().."Text"]:SetTextColor(color.r, color.g, color.b)
		end
	elseif class == "PRIEST" then
		local showWeak = self:SimpleCheckBox(f, "EnableWSBar", 'showWeakenedSoul', true)
		showWeak:SetPoint('TOPLEFT', classPortraits, 'BOTTOMLEFT', 0, -CB_GAP)
		_G[showWeak:GetName().."Text"]:SetTextColor(color.r, color.g, color.b)
	elseif class == "MAGE" then
		local showArcStacks = self:SimpleCheckBox(f, "EnableArcCharge", 'showArcStacks', true)
		showArcStacks:SetPoint('TOPLEFT', classPortraits, 'BOTTOMLEFT', 0, -CB_GAP)
		_G[showArcStacks:GetName().."Text"]:SetTextColor(color.r, color.g, color.b)
	elseif class == "ROGUE" then
		local sliceanddice = self:SimpleCheckBox(f, "EnableSnD", 'showSlicenDice', true)
		sliceanddice:SetPoint('TOPLEFT', classPortraits, 'BOTTOMLEFT', 0, -CB_GAP)
		_G[sliceanddice:GetName().."Text"]:SetTextColor(color.r, color.g, color.b)
		local anticipation = self:SimpleCheckBox(f, "EnableAnticipation", 'showAnticipation', true)
		anticipation:SetPoint('TOPLEFT', sliceanddice, 'BOTTOMLEFT', 0, -CB_GAP)
		_G[anticipation:GetName().."Text"]:SetTextColor(color.r, color.g, color.b)
	end

	local anchorbutton = self:CreateUnlockerButton(f)
	anchorbutton:SetPoint('BOTTOMRIGHT', f, "BOTTOMRIGHT", -70, 20)

	return f
end

BasicOptions:AddWidgets()
BasicOptions:UpdateValues()
oUFAbuOptions:AddGeneralTab('basic', L.General, BasicOptions)