local _, ns = ...
local auras = _G.oUF_AbuAuraFilters
local aurasname = auras:GetName()

local L = oUFAbu.localization

-------------------------------------------------------------------------

do
	local panel = CreateFrame('Frame', aurasname .. "_General")

	function panel:Create()
		local editor = ns.Widgets.AuraEditor(self, self:GetName().."Editor", L['AuraFilterGeneralDesc'])

		editor.DropDownMenu = {
			[0] = L["ShowAll"],
			[1] = L["OnlyOwn"],
			[2] = L["HideOnFriendly"],
			[3] = L["NeverShow"],
		}

		editor.GetItems = function()
			return oUFAbu:GetAuraSettings()['general']
		end

		editor.UpdateList = function()
			oUFAbu:UpdateAuraLists()
			for i = 1, #oUF.objects do
				oUF.objects[i]:UpdateAllElements("OptionsRefresh")
			end
		end
		
		editor:SetPoint('TOPLEFT', 12, -25)
		editor:SetPoint('TOPRIGHT', -12, -25)
		editor:SetHeight(472)

		self.editor = editor
	end

	function panel:Update()
		self.editor:Update()
	end

	auras:AddTab(L['AllFrames'], panel)
end

------------------------------------------------------------------------------

do
	local panel = CreateFrame('Frame', aurasname .. "_Arena")

	function panel:Create()
		local editor = ns.Widgets.AuraEditor(self, self:GetName().."Editor", L['AuraFilterArenaDesc'])

		editor.GetItems = function()
			return oUFAbu:GetAuraSettings()['arena']
		end

		editor.UpdateList = function()
			oUFAbu:UpdateAuraLists()
			for i = 1, #oUF.objects do
				oUF.objects[i]:UpdateAllElements("OptionsRefresh")
			end
		end

		editor:SetPoint('TOPLEFT', 12, -25)
		editor:SetPoint('TOPRIGHT', -12, -25)
		editor:SetHeight(472)

		self.editor = editor
	end

	function panel:Update()
		self.editor:Update()
	end

	auras:AddTab(L['ArenaFrames'], panel)
end

------------------------------------------------------------------------------

do
	local panel = CreateFrame('Frame', aurasname .."_Boss")

	function panel:Create()
		local editor = ns.Widgets.AuraEditor(self, self:GetName().."Editor", L['AuraFilterBossDesc'])

		editor.DropDownMenu = {
			[0] = L["ShowAll"],
			[1] = L["OnlyOwn"],
		}

		editor.GetItems = function()
			return oUFAbu:GetAuraSettings()['boss']
		end

		editor.UpdateList = function()
			oUFAbu:UpdateAuraLists()
			for i = 1, #oUF.objects do
				oUF.objects[i]:UpdateAllElements("OptionsRefresh")
			end
		end
		
		editor:SetPoint('TOPLEFT', 12, -25)
		editor:SetPoint('TOPRIGHT', -12, -25)
		editor:SetHeight(472)

		self.editor = editor
	end

	function panel:Update()
		self.editor:Update()
	end

	auras:AddTab(L['BossFrames'], panel)
end