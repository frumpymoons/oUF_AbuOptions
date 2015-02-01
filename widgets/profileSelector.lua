--[[

]]
local _, ns = ...
ns.Widgets = ns.Widgets or {}

function ns.Widgets.ProfileSelector(parent, getFunc)
	local dd =  CreateFrame('Frame', parent:GetName() .. 'ProfileSelector', parent, 'UIDropDownMenuTemplate')

	assert(type(getFunc) == 'function', 'Hey you forgot to implement GetFunction for ' .. dd:GetName())

	dd.OnSetProfile = function(self, id)
		assert(false, 'Hey you forgot to implement OnSetProfile for ' .. self:GetName())
	end

	dd.OnResetProfile = function(self, value)
		assert(false, 'Hey you forgot to implement OnResetProfile for ' .. self:GetName())
	end

	dd.OnDeleteProfile = function(self, value)
		assert(false, 'Hey you forgot to implement OnDeleteProfile for ' .. self:GetName())
	end

	dd.GetAllProfiles = function()
		assert(false, 'Hey you forgot to implement GetAllProfiles for ' .. self:GetName())
	end

	dd.OnAddProfile = function(self)
		assert(false, 'Hey you forgot to implement CreateProfile for ' .. self:GetName())
	end
------------------------------------------------------------------------------

	dd.GetSelected = getFunc

	local function selectProfile(self)
		local dd = self.owner
		dd:OnSetProfile(self.value)
		UIDropDownMenu_SetSelectedValue(dd, self.value)
		UIDropDownMenu_SetText(dd, self.value)
	end


	local function addProfile(self)
		local dd = self.owner
		dd:OnAddProfile()
		CloseDropDownMenus()
	end

	local function deleteProfile(self, value)
		local dd = self.owner
		dd:OnDeleteProfile(value)
		dd:Update()
		CloseDropDownMenus()
	end

	local function resetProfile(self, value)
		local dd = self.owner
		dd:OnResetProfile(value)
		dd:Update()
		CloseDropDownMenus()
	end

	dd.Update = function(self)
		local id = self:GetSelected()
		UIDropDownMenu_SetSelectedValue(self, id)
		UIDropDownMenu_SetText(self, id)
		self:OnSetProfile(id)
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

		if menuList == '1' then
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
		local profiles = self:GetAllProfiles()
		
		--base group
		local info = UIDropDownMenu_CreateInfo()
		info.text = oUFAbu.DEFAULT
		info.value = oUFAbu.DEFAULT
		info.func = selectProfile
		info.owner = self
		info.hasArrow = true
		UIDropDownMenu_AddButton(info, level)

		--custom profiles
		for i,v in ipairs(profiles) do
			if v ~= oUFAbu.DEFAULT then 
				local info = UIDropDownMenu_CreateInfo()
				info.text = v
				info.value = v
				info.func = selectProfile
				info.menuList = '1'
				info.owner = self
				info.hasArrow = true
				UIDropDownMenu_AddButton(info, level)
			end
		end

		--new group button
		local info = UIDropDownMenu_CreateInfo()
		info.text = NEW
		info.func = addProfile
		info.owner = self
		info.notCheckable = true
		UIDropDownMenu_AddButton(info, level)
	end

	dd.initialize = function(self, level, menuList)
		level = level or 1
		if level == 1 then
			init_levelOne(self, level, menuList)
		else
			init_levelTwo(self, level, menuList)
		end
	end

	UIDropDownMenu_SetWidth(dd, 120)
	UIDropDownMenu_SetSelectedValue(dd, getFunc())
	UIDropDownMenu_SetText(dd, getFunc())

	dd:SetPoint('TOPRIGHT', 4, -8)
	return dd
end