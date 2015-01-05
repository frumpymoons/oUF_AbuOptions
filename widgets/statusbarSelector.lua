--[[
	statusbarSelector.lua
		Displays a list of statusbars registered with SharedMedia
--]]

local _, ns = ...
ns.Widgets = ns.Widgets or {}

local LSM = LibStub('LibSharedMedia-3.0')
local LSM_BAR = LSM.MediaType.STATUSBAR

local BUTTON_HEIGHT, BUTTON_PADDING = 52, 2
local ROW_HEIGHT = BUTTON_HEIGHT + BUTTON_PADDING
local SCROLLFRAME_BORDER_SPACING, SCROLLBAR_WIDTH = 8, 20
local NUM_COLUMNS = 2

local function getStatusbarIDs()
	return LSM:List(LSM_BAR)
end

local function fetchStatusbar(key)
	if key and LSM:IsValid(LSM_BAR, key) then
		return LSM:Fetch(LSM_BAR, key)
	end
	return LSM:GetDefault(LSM_BAR)
end

local barTester = nil
local function isValidStatusbar(texture)
	local f
	if not barTester then
		f = CreateFrame("Frame", nil)
		barTester = f:CreateTexture("Frame", "StatusbarTest")
	end
	return barTester:SetTexture(texture)
end

local function createStatusBarButton(parent, i)
	local b = CreateFrame('CheckButton', parent:GetName()..'Button'..i, parent)
	b:SetHeight(BUTTON_HEIGHT)

	local bg = b:CreateTexture(nil, 'BACKGROUND')
	bg:SetAllPoints(b)
	bg:SetVertexColor(0.8, 0.8, 0.8)
	b.bg = bg

	local text = b:CreateFontString(nil, 'ARTWORK')
	text:SetPoint('BOTTOM', 0, 2)

	b:SetFontString(text)
	b:SetNormalFontObject('GameFontNormalSmall')
	b:SetHighlightFontObject('GameFontHighlightSmall')

	local ct = b:CreateTexture(nil, 'OVERLAY')
	ct:SetTexture([[Interface\Buttons\UI-CheckBox-Check]])
	ct:SetPoint('RIGHT', text, 'LEFT', -5, 0)
	ct:SetSize(24, 24)
	b:SetCheckedTexture(ct)

	b:SetScript('OnEnter', function(self)
		self.bg:SetVertexColor(1, 1, 1, 1)
	end)
	b:SetScript('OnLeave', function(self)
		self.bg:SetVertexColor(0.8, 0.8, 0.8)
	end)
	b:SetScript("OnClick", function(self)
		local selector = self:GetParent()
		selector:SetSavedValue(self.bg:GetTexture())
		selector:Update()
	end)

	return b
end

function ns.Widgets.StatusbarSelector(parent, title)
	local f = ns.Widgets.Group(parent, 'StatusBarSelector', title)

	-- Since were using two columns we gotta trick this abit
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
		local button = createStatusBarButton(f, i)

		if i == 1 then
			button:SetPoint('TOPLEFT', scrollFrame)
			button:SetPoint('TOPRIGHT', scrollFrame, 'TOP', -(bar:GetWidth() + SCROLLFRAME_BORDER_SPACING + BUTTON_PADDING)/2, 0)
		elseif i == 2 then
			button:SetPoint('TOPLEFT', f.buttons[1], 'TOPRIGHT', BUTTON_PADDING, 0)
			button:SetPoint('TOPRIGHT', scrollFrame, 'TOPRIGHT', -(bar:GetWidth() + SCROLLFRAME_BORDER_SPACING + BUTTON_PADDING), 0)
		else
			button:SetPoint('TOPLEFT', f.buttons[i-2], 'BOTTOMLEFT', 0, -BUTTON_PADDING)
			button:SetPoint('TOPRIGHT', f.buttons[i-2], 'BOTTOMRIGHT', 0, -BUTTON_PADDING)
		end

		rawset(t, i, button)
		return button
	end })
	f.buttons = buttons

	f.UpdateScroll = function(self, forceUpdate)
		local offset = FauxScrollFrame_GetOffset(self.scrollFrame)

		if (not forceUpdate) and (self.lastOffset == offset) then
			return; -- no need to update
		end
		self.lastOffset = offset

		local button_offset = offset * NUM_COLUMNS
		local selected = self:GetSavedValue()

		for i = 1, (self.maxRows * NUM_COLUMNS) do
			local itemIndex = i + button_offset
			if itemIndex <= #self.items then
				local button = self.buttons[i]
				button:SetText(self.items[itemIndex].name)
				button.bg:SetTexture(self.items[itemIndex].texture)
				button:SetChecked(button.bg:GetTexture() == selected) -- GetTexture() removes the (.tga)
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
			if self.items[i].texture == selected then
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
		local items = getStatusbarIDs()

		self.items = self.items or {}
		wipe(self.items)

		for i = 1, #items do
			local name = items[i]
			local texture = fetchStatusbar(name)
			if isValidStatusbar(texture) then
				self.items[#self.items + 1] = {name = name, texture = texture}
			end
		end

		table.sort(self.items, function( a, b ) return (a.name < b.name); end)

		self:Update()
	end

	LSM:RegisterCallback("LibSharedMedia_Registered", function(callback, mediaType, key)
		if mediaType == "statusbar" then
			f:UpdateMediaList()
		end
	end)

	function f:GetSavedValue()
		return assert(false, 'Hey, you forgot to set GetSavedValue for ' .. self:GetName())
	end

	function f:SetSavedValue(value)
		assert(false, 'Hey, you forgot to set SetSavedValue for ' .. self:GetName())
	end

	return f
end