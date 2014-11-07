local _, ns = ...
local L = ns.L

-- [[	Popup 	]] --
local function create_Profile(id)
	if oUFAbu:CreateProfile(id) then
		oUFAbuOptions:SetProfile(id)
	end
end

StaticPopupDialogs['OUFABU_CREATE_PROFILE'] = {
	text = L['EnterProfileName'],
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 24,
	
	OnAccept = function(self)
		local name = _G[self:GetName()..'EditBox']:GetText()
		if name ~= '' or name == 'Default' then
			create_Profile(name)
		end
	end,
	
	EditBoxOnEnterPressed = function(self)
		local name = self:GetText()
		if name ~= '' or name == 'Default' then
			create_Profile(name)
		end
		self:GetParent():Hide()
	end,
	
	OnShow = function(self)
		_G[self:GetName()..'EditBox']:SetFocus()
	end,
	
	OnHide = function(self)
		_G[self:GetName()..'EditBox']:SetText('')
	end,
	
	timeout = 0, exclusive = 1, hideOnEscape = 1, preferredIndex = STATICPOPUP_NUMDIALOGS
}

-- [[	DropDOWN	]] --

local function selectProfile(self)
	self.owner:SetSavedValue(self.value)
end

local function deleteProfile(self, id)

	oUFAbuOptions.reload = true
	oUFAbu:DeleteProfile(id)
	UIDropDownMenu_SetSelectedValue(self.owner, oUFAbu:GetProfileID())
	UIDropDownMenu_SetText(self.owner, oUFAbu:GetProfileID())

	CloseDropDownMenus()
end

local function resetProfile(self, id)
	oUFAbu:ResetProfile(id)
	oUFAbuOptions:SetProfile(oUFAbu:GetProfileID())

	CloseDropDownMenus()
end

local function addProfile(self)
	StaticPopup_Show('OUFABU_CREATE_PROFILE')
end

local function profileSelector_Create(parent, size, onSetProfile)
	local dd =  CreateFrame('Frame', parent:GetName() .. 'ProfileSelector', parent, 'UIDropDownMenuTemplate')

	dd.SetSavedValue = function(self, value)
		onSetProfile(parent, value)
	end

	dd.GetSavedValue = function(self)
		return oUFAbu:GetProfileID()
	end

	--delete button for custom groups
	local function init_levelTwo(self, level, menuList)
		local info = UIDropDownMenu_CreateInfo()
		info.text = RESET
		info.arg1 = UIDROPDOWNMENU_MENU_VALUE
		info.func = resetProfile
		info.owner = self
		info.notCheckable = true
		UIDropDownMenu_AddButton(info, level)
		if menuList == 'petter' then
			local info = UIDropDownMenu_CreateInfo()
			info.text = DELETE
			info.arg1 = UIDROPDOWNMENU_MENU_VALUE
			info.func = deleteProfile
			info.owner = self
			info.notCheckable = true
			UIDropDownMenu_AddButton(info, level)
		end
	end

	local function init_levelOne(self, level, menuList)
		local profiles = oUFAbu:GetAllProfiles()
		
		--base group
		local info = UIDropDownMenu_CreateInfo()
		info.text = 'Default'
		info.value = 'Default'
		info.func = selectProfile
		info.owner = self
		info.hasArrow = true
		UIDropDownMenu_AddButton(info, level)

		--custom profiles
		for i,v in ipairs(profiles) do
			if v ~= 'Default' then 
				local info = UIDropDownMenu_CreateInfo()
				info.text = v
				info.value = v
				info.func = selectProfile
				info.menuList = 'petter'
				info.owner = self
				info.hasArrow = true
				UIDropDownMenu_AddButton(info, level)
			end
		end

		--new group button
		local info = UIDropDownMenu_CreateInfo()
		info.text = L['AddProfile']
		info.func = addProfile
		info.owner = self
		info.notCheckable = true
		UIDropDownMenu_AddButton(info, level)
	end

	UIDropDownMenu_Initialize(dd, function(self, level, menuList)
		level = level or 1
		if level == 1 then
			init_levelOne(self, level, menuList)
		else
			init_levelTwo(self, level, menuList)
		end
	end)

	UIDropDownMenu_SetWidth(dd, 120)
	UIDropDownMenu_SetSelectedValue(dd, dd:GetSavedValue())

	dd:SetPoint('TOPRIGHT', 4, -8)
	return dd
end

local function options_SetProfile(self, id)
	if oUFAbu:SetProfile(id) then
		oUFAbuOptions.reload = true
		UIDropDownMenu_SetSelectedValue(self.dropdown, id)
		UIDropDownMenu_SetText(self.dropdown, id)

		local panel = self:GetCurrentPanel()

		if panel.UpdateValues then
			panel:UpdateValues()
		end
	end
end

-- Build general frame stuff
local f = oUFAbuOptions.TabPanel:CreateTabPanel( oUFAbuOptions, "oUF_Abu")
oUFAbuOptions.dropdown = profileSelector_Create(oUFAbuOptions, 130, options_SetProfile)

oUFAbuOptions.AddGeneralTab = function(self, id, name, panel)
	oUFAbuOptions.TabPanel:CreateTab(f, id, name, panel)
end

oUFAbuOptions.SetProfile = function(self, id)
	options_SetProfile(f, id)
end

oUFAbuOptions.GetSettings = function()
	return oUFAbu:GetSettings()
end

oUFAbuOptions.GetDefaultSettings = function()
	return oUFAbu:GetDefaultSettings()
end

-----------------------------------------------------------------------------

function oUFAbuOptions.okay() 
	if (oUFAbuOptions.reload == true) then
		StaticPopup_Show("OUFABU_RELOADUIWARNING")
		oUFAbuOptions.reload = false
	end
end

StaticPopupDialogs["OUFABU_RELOADUIWARNING"] = {
	text = L['ReloadUIWarning_Desc'],
	button1 = L["Yes"],
	button2 = L["No"],
	OnAccept = ReloadUI,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}