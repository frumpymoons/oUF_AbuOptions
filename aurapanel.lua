local _, ns = ...
local L = ns.L

--[[ utility functions of champions ]]--

local function sort(...)
	table.sort(...)
	return ...
end

-- [[	Popup 	]] --
local function create_AuraProfile(id)
	if oUFAbu:CreateAuraProfile(id) then
		oUFAbuOptions:SetAuraProfile(id)
	end
end

StaticPopupDialogs['OUFABU_CREATE_AURAPROFILE'] = {
	text = L.EnterProfileName,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 24,
	
	OnAccept = function(self)
		local name = _G[self:GetName()..'EditBox']:GetText()
		if name ~= '' or name == 'Default' then
			create_AuraProfile(name)
		end
	end,
	
	EditBoxOnEnterPressed = function(self)
		local name = self:GetText()
		if name ~= '' or name == 'Default' then
			create_AuraProfile(name)
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

	oUFAbu:DeleteAuraProfile(id)
	UIDropDownMenu_SetSelectedValue(self.owner, oUFAbu:GetAuraProfileID())
	UIDropDownMenu_SetText(self.owner, oUFAbu:GetAuraProfileID())

	CloseDropDownMenus()
end

local function resetProfile(self, id)
	oUFAbu:ResetAuraProfile(id)
	oUFAbuOptions:SetAuraProfile(oUFAbu:GetAuraProfileID())

	CloseDropDownMenus()
end

local function addProfile(self)
	StaticPopup_Show('OUFABU_CREATE_AURAPROFILE')
end

local function profileSelector_Create(parent, size, onSetProfile)
	local dd =  CreateFrame('Frame', parent:GetName() .. 'ProfileSelector', parent, 'UIDropDownMenuTemplate')

	dd.SetSavedValue = function(self, value)
		onSetProfile(parent, value)
	end

	dd.GetSavedValue = function(self)
		return oUFAbu:GetAuraProfileID()
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
		local profiles = oUFAbu:GetAllAuraProfiles()
		
		--base group
		local info = UIDropDownMenu_CreateInfo()
		info.text = 'Default'
		info.value = 'Default'
		info.func = selectProfile
		info.owner = self
		info.hasArrow = true
		UIDropDownMenu_AddButton(info, level)

		--custom profiles
		if profiles then
			for i = 1, #profiles do
				if profiles[i] ~= 'Default' then 
					local info = UIDropDownMenu_CreateInfo()
					info.text = profiles[i]
					info.value = profiles[i]
					info.func = selectProfile
					info.menuList = 'petter'
					info.owner = self
					info.hasArrow = true
					UIDropDownMenu_AddButton(info, level)
				end
			end
		end

		--new group button
		local info = UIDropDownMenu_CreateInfo()
		info.text = L.AddProfile
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

local function auraFilter_SetProfile(self, id)
	if oUFAbu:SetAuraProfile(id) then
		UIDropDownMenu_SetSelectedValue(self.dropdown, id)
		UIDropDownMenu_SetText(self.dropdown, id)

		local panel = self:GetCurrentPanel()

		if panel.UpdateValues then
			panel:UpdateValues()
		end
	end
end

-- [[	Build it 	]] --
local a = oUFAbuOptions.TabPanel:CreateTabPanel( AuraFilters, L.AuraFilters)
AuraFilters.dropdown = profileSelector_Create(AuraFilters, 130, auraFilter_SetProfile)

oUFAbuOptions.AddAuraFilterTab = function(self, id, name, panel)
	oUFAbuOptions.TabPanel:CreateTab(a, id, name, panel)
end

oUFAbuOptions.SetAuraProfile = function(self, id)
	auraFilter_SetProfile(a, id)
end