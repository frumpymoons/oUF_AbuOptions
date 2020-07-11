local _, ns = ...

ns.defaultsettings = oUFAbu:GetDefaultSettings()
ns.settings = oUFAbu:GetSettings()
ns.Classic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local L = oUFAbu.localization
-----------------------------------------------------------------------------
-- Build frames

local Options = _G['oUF_AbuOptions']
local Aurafilter = _G['oUF_AbuAuraFilters']

ns.Widgets.TabPanel( Options, Options.name )
ns.Widgets.TabPanel( Aurafilter, Aurafilter.name)

-----------------------------------------------------------------------------
-- Build profile selector
do 
	local dropdown = ns.Widgets.ProfileSelector( Options, function() return oUFAbu:GetProfileID(); end )

	dropdown.OnSetProfile = function(self, id)
		oUFAbu:SetProfile(id)
		ns.reload = true
		ns.settings = oUFAbu:GetSettings()
		oUFAbu:UpdateBaseFrames()

		local panel = Options:GetCurrentTab()

		if (panel.Update) then
			panel:Update()
		end
	end
	dropdown.OnResetProfile = function(self, value)
		oUFAbu:ResetProfile(value)
	end
	dropdown.OnDeleteProfile = function(self, value)
		oUFAbu:DeleteProfile(value)
	end
	dropdown.OnAddProfile = function(self)
		StaticPopup_Show('OUFABU_CREATE_PROFILE')
	end
	dropdown.GetAllProfiles = function()
		return oUFAbu:GetAllProfiles()
	end

	_G.StaticPopupDialogs['OUFABU_CREATE_PROFILE'] = {
		text = L['EnterProfileName'],
		button1 = ACCEPT,
		button2 = CANCEL,
		hasEditBox = 1,
		maxLetters = 24,
		
		OnAccept = function(self)
			local name = _G[self:GetName()..'EditBox']:GetText()
			if name ~= '' or name == oUFAbu.DEFAULT then
				oUFAbu:CreateProfile(name)
				dropdown:Update()-- sets the new profile as current
			end
		end,
		OnShow = function(self)
			_G[self:GetName()..'EditBox']:SetFocus()
		end,
		OnHide = function(self)
			_G[self:GetName()..'EditBox']:SetText('')
		end,
		timeout = 0, exclusive = 1, hideOnEscape = 1, preferredIndex = STATICPOPUP_NUMDIALOGS
	}
end

-----------------------------------------------------------------------------
--	Build aura profile selector

do
	local dropdown = ns.Widgets.ProfileSelector( Aurafilter, function() return oUFAbu:GetAuraProfileID(); end )

	dropdown.OnSetProfile = function(self, id)
		if (oUFAbu:SetAuraProfile(id)) then

			local panel = Aurafilter:GetCurrentTab()

			if (panel.Update) then
				panel:Update()
			end
		end
	end
	dropdown.OnResetProfile = function(self, value)
		oUFAbu:ResetAuraProfile(value)
	end
	dropdown.OnDeleteProfile = function(self, value)
		oUFAbu:DeleteAuraProfile(value)
	end
	dropdown.OnAddProfile = function(self)
		StaticPopup_Show('OUFABU_CREATE_AURAPROFILE')
	end
	dropdown.GetAllProfiles = function()
		return oUFAbu:GetAllAuraProfiles()
	end

	_G.StaticPopupDialogs['OUFABU_CREATE_AURAPROFILE'] = {
		text = L.EnterProfileName,
		button1 = ACCEPT,
		button2 = CANCEL,
		hasEditBox = 1,
		maxLetters = 24,
		
		OnAccept = function(self)
			local name = _G[self:GetName()..'EditBox']:GetText()
			if name ~= '' or name == oUFAbu.DEFAULT then
				oUFAbu:CreateAuraProfile(name)
				dropdown:Update()-- sets the new profile as current
			end
		end,
		
		OnShow = function(self)
			_G[self:GetName()..'EditBox']:SetFocus()
		end,
		
		OnHide = function(self)
			_G[self:GetName()..'EditBox']:SetText('')
		end,
		
		timeout = 0, exclusive = 1, hideOnEscape = 1, preferredIndex = STATICPOPUP_NUMDIALOGS
	}
end
-----------------------------------------------------------------------------

function Options.okay() 
	if (ns.reload == true) then
		StaticPopup_Show("OUFABU_RELOADUIWARNING")
		ns.reload = false
	end
end

_G.StaticPopupDialogs["OUFABU_RELOADUIWARNING"] = {
	text = L['ReloadUIWarning_Desc'],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = ReloadUI,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}
