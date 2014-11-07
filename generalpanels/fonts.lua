local _, ns = ...
local FontOptions = CreateFrame('Frame', 'oUFAbuOptions_Fonts')
local L = ns.L

local outlines = {
	['NONE']				= L.None,
	['THINOUTLINE'] 		= L.ThinOutline,
	['OUTLINE']				= L.Outline,
	['THICKOUTLINE'] 		= L.ThickOutline,
	['OUTLINEMONOCHROME']	= L.OutlineMono,
}

local CB_GAP = 5
local SIDE_GAP = 14

function FontOptions:AddWidgets()
	self.widgets = {}
	local normalfont = self:FontSelector(L.NumFont, 'fontNormal')
	normalfont:SetPoint('TOPLEFT', self, 'TOPLEFT', 12, -20)
	normalfont:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', -12, -200)

	local normaloutline = self:CreateDropdown(L.NumFontOutline, 'fontNormalOutline')
	normaloutline:SetPoint('TOPLEFT', normalfont, 'BOTTOMLEFT', 32, -20)

	local normalSize = self:CreateSlider(L.NumFontSize, 'fontNormalSize')
	normalSize:SetPoint('LEFT', normaloutline, 'RIGHT', 40, 0)

	local bigfont = self:FontSelector(L.NameFont, 'fontBig')
	bigfont:SetPoint('TOPLEFT', normalfont, 'BOTTOMLEFT', 0, -65)
	bigfont:SetPoint('BOTTOMRIGHT', normalfont, 'BOTTOMRIGHT', 0, -245)

	local bigoutline = self:CreateDropdown(L.NameFontOutline, 'fontBigOutline')
	bigoutline:SetPoint('TOPLEFT', bigfont, 'BOTTOMLEFT', 32, -20)

	local bigSize = self:CreateSlider(L.NameFontSize, 'fontBigSize')
	bigSize:SetPoint('LEFT', bigoutline, 'RIGHT', 40, 0)
end

local function round(num)
	return math.floor(num + 0.5)
end

function FontOptions:UpdateValues()
	for _,widget in ipairs(self.widgets) do
		widget:UpdateValues()
	end
end

function FontOptions:CreateSlider(name, db)
	local s = oUFAbuOptions.Slider:New(name, self, 50, 150, 5)
	-- I dont trust the values..

	s.SetSavedValue = function(self, value)
		oUFAbuOptions:GetSettings()[db] = round(value)/100
		oUFAbu:SetAllFonts()
	end

	s.GetSavedValue = function(self)
		return round(oUFAbuOptions:GetSettings()[db]*100)
	end

	s.GetFormattedText= function(self, value)
	 	return value .. "%"
	end
	s:UpdateValues()
	tinsert(self.widgets, s)
	return s
end

function FontOptions:CreateDropdown(name, db)
	local dd = oUFAbuOptions.Dropdown:New(name, self, 180)

	dd.SetSavedValue = function(self, value)
		oUFAbuOptions:GetSettings()[db] = value
		oUFAbu:SetAllFonts()
	end

	dd.GetSavedValue = function(self)
		return oUFAbuOptions:GetSettings()[db]
	end

	dd.GetSavedText = function(self)
		return outlines[self:GetSavedValue()]
	end

	UIDropDownMenu_Initialize(dd, function(self)
		for value, desc in pairs(outlines) do
			self:AddItem(desc, value)
		end
	end)
	dd:UpdateValues()
	tinsert(self.widgets, dd)
	return dd
end


function FontOptions:FontSelector(name, db)
	local selector = oUFAbuOptions.FontSelector:New(name, self, 552, 165)

	selector.SetSavedValue = function(self, value)
		oUFAbuOptions:GetSettings()[db] = value
		oUFAbu:SetAllFonts()
	end

	selector.GetSavedValue = function(self)
		return oUFAbuOptions:GetSettings()[db]
	end
	selector:Show()
	tinsert(self.widgets, selector)
	return selector
end

FontOptions:AddWidgets()
oUFAbuOptions:AddGeneralTab('font', L.Font, FontOptions)