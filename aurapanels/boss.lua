local _, ns = ...
local BossFilterEdit = CreateFrame('Frame', 'oUFAbuOptions_BossFilter')

local L = {
	AuraFilterBossDesc = "Whitelist debuffs for the Boss Frames.",
	InvalidSpellID = "That is a invalid Spell ID!",
	TypeSpellID = "Type in a Spell ID",
	BossFrames = "Boss Frames",
	ShowAll = "Show All",
	OnlyOwn = "Only Own",
}

local DDMenu = {
	[0] = L["ShowAll"],
	[1] = L["Onlyown"],
}

function BossFilterEdit:Create()
	self.editor = oUFAbuOptions.AuraEditor:New(self, "BossAuraEdit", L['AuraFilterBossDesc'], L['TypeSpellID'], L['InvalidSpellID'])

	self.editor.GetItems = function()
		return oUFAbu:GetAuraSettings()['boss']
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

function BossFilterEdit:UpdateValues()
	self.editor:UpdateValues()
end

------------------------------------------------------------------------------
-- Add it
BossFilterEdit:SetScript('OnShow', function(self)
 	self:Create()
 	self:SetScript('OnShow', nil)
end)

oUFAbuOptions.AddAuraFilterTab(self, 'bossfilter', L['BossFrames'], BossFilterEdit)