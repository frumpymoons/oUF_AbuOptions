--[[
	fontSelector.lua
		Displays a list of fonts registered with LibSharedMedia for the user to pick from

		Thanks to Tuller, the author of OmniCC
--]]

local _, ns = ...
ns.Widgets = ns.Widgets or {}

local LSM = LibStub('LibSharedMedia-3.0')
local LSM_FONT = LSM.MediaType.FONT

local FONT_HEIGHT = 22
local BUTTON_HEIGHT, BUTTON_PADDING = 52, 2
local ROW_HEIGHT = BUTTON_HEIGHT + BUTTON_PADDING
local SCROLLFRAME_BORDER_SPACING, SCROLLBAR_WIDTH  = 8, 20
local NUM_COLUMNS = 1

local function getFontIDs()
	return LSM:List(LSM_FONT)
end

local fontTester = nil
local function isValidFont(font)
	if not fontTester then
		fontTester = CreateFont('oUFAbuOptions_FontTester')
	end
	return fontTester:SetFont(font, FONT_HEIGHT, 'OUTLINE')
end

local function fetchFont(fontId)
	if fontId and LSM:IsValid(LSM_FONT, fontId) then
		return LSM:Fetch(LSM_FONT, fontId)
	end
	return LSM:GetDefault(LSM_FONT)
end

--[[
	The Font Button
--]]

local function createFontButton(parent, i)
	local b = CreateFrame('CheckButton', nil, parent)
	b:SetHeight(BUTTON_HEIGHT)

	local bg = b:CreateTexture(nil, 'BACKGROUND')
	bg:SetAllPoints(b)
	bg:SetColorTexture(.3, .3, .3, 0.6)
    b.bg = bg

	local text = b:CreateFontString(nil, 'ARTWORK')
	text:SetPoint('BOTTOM', 0, PADDING)

	b:SetFontString(text)
	b:SetNormalFontObject('GameFontNormalSmall')
	b:SetHighlightFontObject('GameFontHighlightSmall')

	local fontText = b:CreateFontString(nil, 'ARTWORK')
	fontText:SetPoint('BOTTOM', text, 'TOP', 0, 2)
	b.fontText = fontText

	local ct = b:CreateTexture(nil, 'OVERLAY')
	ct:SetTexture([[Interface\Buttons\UI-CheckBox-Check]])
    ct:SetPoint('RIGHT', fontText, 'LEFT', -5, 0)
	ct:SetSize(24, 24)
	b:SetCheckedTexture(ct)

	b:SetScript('OnEnter', function(self)
		self.bg:SetColorTexture(1, 1, 1, 0.3)
	end)
	b:SetScript('OnLeave', function(self)
		self.bg:SetColorTexture(.3, .3, .3, 0.6)
	end)
	b:SetScript("OnClick", function(self)
		local selector = self:GetParent()
		selector:SetSavedValue(selector.items[self.index].font)
		selector:UpdateScroll(true)
	end)
	
	return b
end

--[[
	The Font Selector
--]]

function ns.Widgets.FontSelector(parent, title)
	local f = ns.Widgets.Group(parent, title)
	f:SetText(title)

	local scrollFrame = CreateFrame('ScrollFrame', f:GetName().."Faux", f, 'FauxScrollFrameTemplate')
	scrollFrame:SetPoint('TOPLEFT', SCROLLFRAME_BORDER_SPACING, -SCROLLFRAME_BORDER_SPACING)
	scrollFrame:SetPoint('BOTTOMRIGHT', -SCROLLFRAME_BORDER_SPACING, SCROLLFRAME_BORDER_SPACING)
	scrollFrame:SetScript('OnVerticalScroll', function(self, offset)
		self.offset = math.floor(offset / ROW_HEIGHT + 0.5)
		f:UpdateScroll()
	end)
	f.scrollFrame = scrollFrame

	local bar = scrollFrame.ScrollBar
	local upbuttonHeight = 10
	bar:ClearAllPoints()
	bar:SetPoint('TOPRIGHT', scrollFrame, -4, -16)
	bar:SetPoint('BOTTOMRIGHT', scrollFrame, -4, 16)

	local buttons = setmetatable({}, {__index = function(t, i)
		local button = createFontButton(f, i)

		if i == 1 then
			button:SetPoint('TOPLEFT', scrollFrame)
			button:SetPoint('TOPRIGHT', scrollFrame, 'TOPRIGHT', -(bar:GetWidth() + SCROLLFRAME_BORDER_SPACING + BUTTON_PADDING), 0)
		else
			button:SetPoint('TOPLEFT', f.buttons[i-1], 'BOTTOMLEFT', 0, -BUTTON_PADDING)
			button:SetPoint('TOPRIGHT', f.buttons[i-1], 'BOTTOMRIGHT', 0, -BUTTON_PADDING)
		end

		rawset(t, i, button)
		return button
	end })
	f.buttons = buttons

	f.UpdateScroll = function(self, forceUpdate)
		local items = self.items
		local offset = FauxScrollFrame_GetOffset(self.scrollFrame)

		if (not forceUpdate) and (self.lastOffset == offset) then
			return; -- no need to update
		end
		self.lastOffset = offset

		local selected = self:GetSavedValue() 
		for i = 1, (self.maxRows*NUM_COLUMNS) do
			local itemIndex = i + (offset * NUM_COLUMNS)
			if itemIndex <= #items then
				local button = self.buttons[i]
				button.fontText:SetFont(items[itemIndex].font, FONT_HEIGHT, 'OUTLINE')
				button.fontText:SetText('1234567890')
				button:SetText(items[itemIndex].name)	
				button:SetChecked(items[itemIndex].font == selected)
				button.index = itemIndex
				button:Show()
			else
				self.buttons[i]:Hide()
			end
		end
	end

	f.Update = function(self)
		if (not self.items) then
			return self:UpdateMediaList()
		end

		self.maxRows = math.floor(self.scrollFrame:GetHeight() / ROW_HEIGHT)
		FauxScrollFrame_Update(self.scrollFrame, math.ceil(#self.items / NUM_COLUMNS), self.maxRows, ROW_HEIGHT, nil, nil, nil, nil, nil, nil, true )
		
		-- changing offset so we jump to selected item
		local selected = self:GetSavedValue()
		for i = 1, #self.items do
			if self.items[i].font == selected then
				local selected_offset = math.floor((i - 1) / NUM_COLUMNS)
				local offset = self.scrollFrame.offset 	-- 0

				if (offset > selected_offset) or (offset + self.maxRows <= selected_offset) then
					local selectedRowOffset = selected_offset - 1
					selectedRowOffset = math.max(selectedRowOffset, 0)
					selectedRowOffset = math.min(selectedRowOffset, (self.maxRows * NUM_COLUMNS) + (#self.items / NUM_COLUMNS))
					FauxScrollFrame_OnVerticalScroll(self.scrollFrame, (selectedRowOffset * ROW_HEIGHT), ROW_HEIGHT)
				end
				break
			end
		end

		self:UpdateScroll(true)
	end

	f.UpdateMediaList = function(self)
		local items = getFontIDs()

		self.items = self.items or {}
		wipe(self.items)

		for i = 1, #items do
			local name = items[i]
			local font = fetchFont(name)
			if isValidFont(font) then
				self.items[#self.items + 1] = {name = name, font = font}
			end
		end

		table.sort(self.items, function( a, b ) return (a.name < b.name); end)

		self:Update()
	end

	LSM:RegisterCallback("LibSharedMedia_Registered", function(callback, mediaType, key)
		if mediaType == "font" then
			f:UpdateMediaList()
		end
	end)

	function f:SetSavedValue(value)
		assert(false, 'Hey, you forgot to set SetSavedValue for ' .. self:GetName())
	end

	function f:GetSavedValue()
		return assert(false, 'Hey, you forgot to set GetSavedValue for ' .. self:GetName())
	end

	return f
end
