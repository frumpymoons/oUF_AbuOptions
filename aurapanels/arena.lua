local ArenaFilterEdit = CreateFrame('Frame', 'oUFAbuOptions_ArenaFilter')

local L = {
	AuraFilterArenaDesc = "Whitelist buffs for the Arena Frames.",
	InvalidSpellID = "That is a invalid Spell ID!",
	TypeSpellID = "Type in a Spell ID",
	ArenaFrames = "Arena Frames",
}

function ArenaFilterEdit:Create()
	self.editor = oUFAbuOptions.AuraEditor:New(self, "ArenaAuraEdit", L['AuraFilterArenaDesc'], L['TypeSpellID'], L['InvalidSpellID'])

	self.editor.GetItems = function()
		return oUFAbu:GetAuraSettings()['arena']
	end

	self.editor.UpdateList = function()
		oUFAbu:UpdateAuraLists()
	end

	self.editor:SetPoint('TOPLEFT', 12, -25)
	self.editor:SetPoint('TOPRIGHT', -12, -25)
	self.editor:SetHeight(472)

	self:UpdateValues()
end

function ArenaFilterEdit:UpdateValues()
	self.editor:UpdateValues()
end

------------------------------------------------------------------------------
-- Add it
ArenaFilterEdit:SetScript('OnShow', function(self)
 	self:Create()
 	self:SetScript('OnShow', nil)
end)

oUFAbuOptions.AddAuraFilterTab(self, 'arenafilter', L['ArenaFrames'], ArenaFilterEdit)