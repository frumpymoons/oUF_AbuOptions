local GenFilterEdit = CreateFrame('Frame', 'oUFAbuOptions_GenFilterEdit')

local L = {
	AuraFilterGeneralDesc = "Add filters to new auras or edit existing ones.",
	InvalidSpellID = "That is a invalid Spell ID!",
	TypeSpellID = "Type in a Spell ID",
	AllFrames = "All Frames",
	ShowAll = "Show All",
	OnlyOwn = "Only Own",
	HideOnFriendly = "Hide on Friendly",
	NeverShow = "Never Show",
}

local DDMenu = {
	[0] = L["ShowAll"],
	[1] = L["OnlyOwn"],
	[2] = L["HideOnFriendly"],
	[3] = L["NeverShow"],
}

function GenFilterEdit:Create()
	self.editor = oUFAbuOptions.AuraEditor:New(self, "GenAuraEdit", L['AuraFilterGeneralDesc'], L['TypeSpellID'], L['InvalidSpellID'])

	self.editor.GetItems = function()
		return oUFAbu:GetAuraSettings()['general']
	end

	self.editor.GetDDMenu = function()
		return DDMenu
	end

	self.editor.UpdateList = function()
		oUFAbu:UpdateAuraLists()
	end
	
	self.editor:SetPoint('TOPLEFT', 12, -25)
	self.editor:SetPoint('TOPRIGHT', -12, -25)
	self.editor:SetHeight(472)

	self:UpdateValues()
end

function GenFilterEdit:UpdateValues()
	self.editor:UpdateValues()
end

------------------------------------------------------------------------------
-- Add it
GenFilterEdit:SetScript('OnShow', function(self)
 	self:Create()
 	self:SetScript('OnShow', nil)
end)

oUFAbuOptions.AddAuraFilterTab(self, 'genfilter', L['AllFrames'], GenFilterEdit)