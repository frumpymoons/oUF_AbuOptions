local _, ns = ...
local L = oUFAbu.localization
local options = _G['oUF_AbuOptions']
local panel = CreateFrame('Frame', options:GetName()..'_Positions')

local GAP, HEIGHT = 2, 32

local BACKDROP = {
  bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
  edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
  edgeSize = 16,
  tile = true, tileSize = 16,
  insets = {left = 4, right = 4, top = 4, bottom = 4}
}

--------------------------------------------------
---		Rows

local function getInput(box)
	local text = box:GetText()
	if (text == '-') or (#text == 0) then
		text = 0
	end

	return tonumber(text) or text
end

local function createEditbox(parent)
	local box = CreateFrame('EditBox', nil, parent, 'InputBoxTemplate')
	box:SetWidth(100)
	box:SetAutoFocus(false)
	box:SetFontObject(GameFontHighlight)
	box:SetPoint('TOP', 0, -2)
	box:SetPoint('BOTTOM', 0, 2)
	box:SetJustifyH('CENTER')
	box:SetMaxLetters(6)

	box:SetScript('OnEditFocusGained', function(self) 
		self.old = self:GetText()
		self.new = nil
	end)
	box:SetScript('OnEditFocusLost', function(self) 
		local text = getInput(self)
		self:SetText(string.format('%d', text))
		self.old, self.new = nil, nil
	end)
	box:SetScript('OnEscapePressed', function(self) 
		self:SetText(self.old)
		self:ClearFocus()
	end)
	box:SetScript('OnEnterPressed', function(self) 
		self:GetParent():Update()
		self:ClearFocus()
	end)
	box:SetScript('OnTextChanged', function(self, userInput) 
		if (not userInput) then return; end
		self.new = self:GetText()
		self:GetParent():Save()
	end)
	box:SetScript('OnChar', function(self, key) 
		local text = self:GetText()
		if (not tonumber(text..'0')) or ((not tonumber(key)) and (key ~= '-')) then
			local pos = self:GetCursorPosition() - 1
			self:SetText(self.new or self.old)
			self:SetCursorPosition(pos)
		end
		self.new = self:GetText()
	end)

	return box
end

local function createRow(parent)
	local row = CreateFrame('Frame', nil, parent, BackdropTemplateMixin and 'BackdropTemplate')
	row:SetPoint('LEFT', 10, 0)
	row:SetPoint('RIGHT', -10, 0)
	row:SetHeight(HEIGHT)

	row:SetBackdrop(BACKDROP)
	row:SetBackdropBorderColor(.3, .3, .3)
	row:SetBackdropColor(.1, .1, .1, .5)

	local name = row:CreateFontString(nil, nil, 'GameFontHighlight')
	name:SetPoint('LEFT', 10, 0)
	name:SetJustifyH('LEFT')
	name:SetWidth(160)
	row.name = name

	local xBox = createEditbox(row)
	xBox:SetPoint('LEFT', name, 'RIGHT', 40, 0)
	row.xBox = xBox

	local yBox = createEditbox(row)
	yBox:SetPoint('LEFT', xBox, 'RIGHT', 10, 0)
	row.yBox = yBox

	local pText = row:CreateFontString(nil, nil, 'GameFontDisable')
	pText:SetPoint('LEFT', yBox, 'RIGHT', 10, 0)
	pText:SetJustifyH('CENTER')
	pText:SetWidth(130)
	row.pText = pText

	local reset = CreateFrame('Button', nil, row)
	reset:SetWidth(22)
	reset:SetHeight(22)
	reset:SetPoint('RIGHT', -16, 0)

	reset:SetNormalTexture([[Interface\Buttons\UI-Panel-MinimizeButton-Up]])
	reset:SetPushedTexture([[Interface\Buttons\UI-Panel-MinimizeButton-Down]])
	reset:SetHighlightTexture([[Interface\Buttons\UI-Panel-MinimizeButton-Highlight]])
	reset:SetScript('OnClick', function( self )
		self:GetParent():Reset()
	end)

	row.Save = function(self)
		local data = ns.settings[self.key1][self.key2]
		local point = string.split('/', data)
		ns.settings[self.key1][self.key2] = string.format('%s/%d/%d', point, getInput(self.xBox), getInput(self.yBox))
		oUFAbu:UpdateAnchorPositions()
	end

	row.Update = function(self)
		local db = ns.settings[self.key1][self.key2]
		local point, x, y = string.split('/', db)
		local first, second = string.match(point, "(%w+)(LEFT)$")
		if not second then
			first, second = string.match(point, "(%w+)(RIGHT)$")
		end
		self.pText:SetText(second and L[first]..L[second] or L[point])
		self.xBox:SetText(x)
		self.yBox:SetText(y)
	end

	row.Reset = function(self)
		ns.settings[self.key1][self.key2] = ns.defaultsettings[self.key1][self.key2]
		self:Update()
		oUFAbu:UpdateAnchorPositions()
	end

	return row
end

function panel:Create()
	self.rows = {}
	--10 [name160] 40 [x100] 10 [y100] 10 [130]
	-- Header with labels
	do 
		local header = CreateFrame('Frame', nil, self, BackdropTemplateMixin and 'BackdropTemplate')
		header:SetPoint('TOPLEFT', 10, -20)
		header:SetPoint('TOPRIGHT', -10, -20)
		header:SetHeight(HEIGHT)
		header:SetBackdrop(BACKDROP)
		header:SetBackdropBorderColor(.3, .3, .3)
		header:SetBackdropColor(.1, .1, .1, .5)
		self.rows[0] = header

		local name = header:CreateFontString(nil, nil, 'GameFontNormal')
		name:SetText(L.Positions_Name)
		name:SetPoint('LEFT', 10, 0)
		name:SetJustifyH('LEFT')
		name:SetWidth(160)
		local xTitle = header:CreateFontString(nil, nil, 'GameFontNormal')
		xTitle:SetText(L.Positions_X)
		xTitle:SetPoint('LEFT', name, 'RIGHT', 40 + 10, 0)
		xTitle:SetJustifyH('CENTER')
		xTitle:SetWidth(80)
		local yTitle = header:CreateFontString(nil, nil, 'GameFontNormal')
		yTitle:SetText(L.Positions_Y)
		yTitle:SetPoint('LEFT', xTitle, 'RIGHT', 10 + 10 + 10, 0)
		yTitle:SetJustifyH('CENTER')
		yTitle:SetWidth(80)
		local pTitle = header:CreateFontString(nil, nil, 'GameFontNormal')
		pTitle:SetText(L.Positions_Point)
		pTitle:SetPoint('LEFT', yTitle, 'RIGHT', 10 + 10 + 25, 0)
		pTitle:SetJustifyH('CENTER')
		pTitle:SetWidth(80)
		local resetTitle = header:CreateFontString(nil, nil, 'GameFontNormal')
		resetTitle:SetText(RESET)
		resetTitle:SetPoint('RIGHT', -7, 0)
		resetTitle:SetJustifyH('CENTER')
		resetTitle:SetWidth(40)
	end

	local frames = oUFAbu:GetAnchorFrames()
	for i = 1, #frames do
		local frame = frames[i]
		local row = createRow(self)
		row:SetPoint('TOPLEFT', self.rows[i-1], 'BOTTOMLEFT', 0, -GAP)
		row.key1, row.key2 = frame.key1, frame.key2
		
		row.name:SetText(frame.objectname)

		self.rows[i] = row
	end

	local butt = CreateFrame("Button", nil, self, "UIPanelButtonTemplate")
	butt:SetSize(140, 25)
	butt:SetText(L.Positions_Toggle)
	butt:SetScript("OnClick", function(self)
		if ( not oUFAbu:ToggleAllAnchors() ) then
			self:LockHighlight()
		else
			self:UnlockHighlight()
		end
	end)
	butt:SetPoint('BOTTOMRIGHT', -70, 20)
end

function panel:Update()
	for i = 1, #self.rows do
		self.rows[i]:Update()
	end
	oUFAbu:UpdateAnchorPositions()
end
options:AddTab(L.Positions, panel)