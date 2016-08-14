
local _, ns = ...
ns.Widgets = ns.Widgets or {}
local L = oUFAbu.localization

local BUTTON_HEIGHT, BUTTON_PADDING = 42, 2
local BUTTON_BORDER_SPACING = 7
local ROW_HEIGHT = BUTTON_HEIGHT + BUTTON_PADDING
local MAX_ROWS = 9

----------------------------------------------------------------
--	Add aura editBox

local createEditFrame
do
	local function editBox_OnEnterPressed(self)
		local editFrame = self:GetParent() -- either editBox or button
		local value = editFrame:GetValue()
		if editFrame:GetParent():CanAddItem(value) then
			editFrame:GetParent():AddItem(value)
			editFrame.editBox:SetNumber("")
		end
	end

	local function editBox_OnTextChanged(self, userInput)
		local editFrame = self:GetParent()
		editFrame:UpdateEditFrame()
	end

	local function addButton_OnClick(self)
		editBox_OnEnterPressed(self)
	end

	function createEditFrame(parent, desc)
		local f = ns.Widgets.Group(parent, "EditFrame", desc)

		--create text with aura info
		local text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		text:SetPoint("TOPLEFT", f, "TOPLEFT", 13, -12)
		text:SetJustifyH("LEFT")
		text:SetJustifyV("TOP")
		text:SetText(L.Auras_EnterSpellID)
		f.text = text

		--create edit box 
		local editBox = CreateFrame('EditBox', nil, f, 'InputBoxTemplate')
		editBox:SetPoint('TOPLEFT', f, 'TOPLEFT', 18, -12)
		editBox:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', -60, -12)
		editBox:SetScript('OnEnterPressed', editBox_OnEnterPressed)
		editBox:SetScript('OnTextChanged', editBox_OnTextChanged)
		editBox:SetAutoFocus(false)
		editBox:SetAltArrowKeyMode(false)
		editBox:SetMaxLetters(6)
		editBox:SetNumeric(true)	
		f.editBox = editBox

		f.GetValue = function(self)
			return self.editBox:GetNumber()
		end

		f.UpdateEditFrame = function(self)
			self:GetParent():UpdateEditFrame()
		end

		--create add button
		local addButton = CreateFrame('Button', nil, f, 'UIPanelButtonTemplate')
		addButton:SetText(ADD)
		addButton:SetSize(48, 24)
		addButton:SetPoint('LEFT', editBox, 'RIGHT', 4, 0)
		addButton:SetScript('OnClick', addButton_OnClick)
		f.addButton = addButton

		return f
	end
end

----------------------------------------------------------------
--	Create dropdown
local createDropdown
do
	local function update(self)
		local filter = self.button.filter
		UIDropDownMenu_SetSelectedValue(self, filter)
		UIDropDownMenu_SetText(self, self.menu[filter])
	end

	local function setFilter(info)
		local button = info.owner.button
		button.auraEditor:SetFilter(button.id, info.value)
	end

	function createDropdown(parent)
		local f = CreateFrame('Frame', parent:GetName().."DropDown", parent, 'UIDropDownMenuTemplate')
		f.button = parent
		f.auraEditor = parent.auraEditor
		f.menu = parent.auraEditor.DropDownMenu

		f.xOffset = 13
		f.yOffset = 22

		f.initialize = function(self, level)
			if not level then return end
			local info = UIDropDownMenu_CreateInfo()

			for i = 0, #self.menu do
				info.text = self.menu[i]
				info.value = i
				info.owner = self
				info.checked = (i == self.button.filter)
				info.func = setFilter
				info.minWidth = 150
				UIDropDownMenu_AddButton(info)
			end
		end

		f.Update = update

		UIDropDownMenu_SetWidth(f, 150)
		return f
	end
end
----------------------------------------------------------------
--	Create button
local createAuraButton
do
	local function delete_onClick(self)
		local button = self:GetParent()
		local auraEditor = button.auraEditor
		auraEditor:RemoveItem(button.id)
	end

	local function button_onEnter(self)
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint("TOPRIGHT", self, "TOPLEFT")
		GameTooltip:SetSpellByID(self.id)
		GameTooltip:Show()
		self.bg:SetColorTexture(1, 1, 1, 0.3)
	end

	local function onLeave(self)
		GameTooltip:Hide()
		local color = (self.index % 2 == 0) and 0.3 or 0.2
		self.bg:SetColorTexture(color, color, color, 0.6)

	end

	local function update(self)
		onLeave(self)
		self.text:SetFormattedText("%s (|cFFFFFFFF%d|r)", self.name, self.id)
		self.icon:SetTexture(self.texture)

		if (self.dropdown) then
			self.dropdown:Update()
		end
	end

	function createAuraButton(parent, index)
		local button = CreateFrame('Frame', parent:GetParent():GetName().."AuraButton"..index, parent)
		button:SetHeight(BUTTON_HEIGHT)
		button:EnableMouse(true)
		button:SetScript('OnEnter', button_onEnter)
		button:SetScript('OnLeave', onLeave)
		button.Update = update

		button.auraEditor = parent

		local bg = button:CreateTexture(nil, 'BACKGROUND')
		bg:SetAllPoints(button)
		button.bg = bg

		local delete = CreateFrame('Button', nil, button, 'UIPanelCloseButton')
		delete:SetSize(32, 32)
		delete:SetPoint('RIGHT', -6, 0)
		delete:SetScript('OnClick', delete_onClick)
		button.delete = delete

		local icon = button:CreateTexture(nil, 'ARTWORK')
		icon:SetPoint('LEFT', 6, 0)
		icon:SetSize(32, 32)
		icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		button.icon = icon

		local text = button:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
		text:SetPoint('LEFT', icon, 'RIGHT', 12, 0)
		button.text = text

		if button.auraEditor.DropDownMenu then
			local dropdown = createDropdown(button)
			dropdown:SetPoint('RIGHT', delete, 'LEFT', -5, 0)
			button.dropdown = dropdown
		end

		return button
	end
end
----------------------------------------------------------------

function ns.Widgets.AuraEditor(parent, title, desc)
	local f = CreateFrame('Frame', title, parent)

	local editFrame = createEditFrame(f, desc)
	editFrame:SetPoint('TOPLEFT', 0, 0)
	editFrame:SetPoint('BOTTOMRIGHT', f, "TOPRIGHT", 0, -60)
	f.editFrame = editFrame

	local backdrop = {
		bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
		edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
		edgeSize = 16,
		tile = true, tileSize = 16,
		insets = {left = 4, right = 4, top = 4, bottom = 4}
	}

	local scrollFrame = CreateFrame('ScrollFrame', '$parentFaux', f, 'FauxScrollFrameTemplate') -- including bar
	scrollFrame:SetPoint('TOPLEFT', editFrame, 'BOTTOMLEFT', 0, -4)
	scrollFrame:SetPoint('BOTTOMRIGHT')
	scrollFrame:SetScript('OnVerticalScroll', function(self, offset)
		--self:SetValue(offset)
		self.offset = math.floor(offset / ROW_HEIGHT + 0.5)
		f:UpdateScroll()
	end)
	scrollFrame:SetBackdrop(backdrop)
	scrollFrame:SetBackdropBorderColor(0.4, 0.4, 0.4)
	scrollFrame:SetBackdropColor(0, 0, 0, 0.3)
	f.scrollFrame = scrollFrame

	-- Fix the bar position
	local bar = scrollFrame.ScrollBar
	bar:ClearAllPoints()
	bar:SetPoint('TOPRIGHT', scrollFrame, -BUTTON_BORDER_SPACING, -22)
	bar:SetPoint('BOTTOMRIGHT', scrollFrame, -BUTTON_BORDER_SPACING, 22)

	local buttons = setmetatable({}, {__index = function(t, i)
		local button = createAuraButton(f, i)

		if (i == 1) then
			button:SetPoint('TOPLEFT', scrollFrame, BUTTON_BORDER_SPACING, -BUTTON_BORDER_SPACING)
			button:SetPoint('RIGHT', bar, 'LEFT', -3, 0)
		else
			button:SetPoint('TOPLEFT', f.buttons[i-1], 'BOTTOMLEFT', 0, -BUTTON_PADDING)
			button:SetPoint('TOPRIGHT', f.buttons[i-1], 'BOTTOMRIGHT', 0, -BUTTON_PADDING)
		end

		rawset(t, i, button)
		return button
	end })
	f.buttons = buttons


	f.UpdateScroll = function(self, override)
		local items = self.sortedItems
		local scrollFrame = self.scrollFrame
		-- what does the faux say
		--FauxScrollFrame_Update(frame, numItems, numToDisplay, buttonHeight, button, smallWidth, bigWidth, highlightFrame, smallHighlightWidth, bigHighlightWidth, alwaysShowScrollBar )
		FauxScrollFrame_Update(scrollFrame, #items, MAX_ROWS, ROW_HEIGHT, nil, nil, nil, nil, nil, nil, true )
		local offset = FauxScrollFrame_GetOffset(scrollFrame)
		
		if (not override) and (self.lastOffset == offset) then
			return; -- no need to update
		end
		self.lastOffset = offset

		for i = 1, MAX_ROWS do
			local itemIndex = i + offset

			if itemIndex <= #items then
				local data = items[itemIndex]
				local button = self.buttons[i]
				button.index = itemIndex
				button.id = data.id
				button.texture = data.texture
				button.name = data.name
				button.filter = data.filter
				button:Update()
				button:Show()
			else
				self.buttons[i]:Hide()
			end
		end

	end

	f.Update = function(self)
		local items = self:GetItems()
		local menu = nil
		self.sortedItems = self.sortedItems or {}
		wipe(self.sortedItems)

		for id, filter in pairs(items) do
			local name, _, texture = GetSpellInfo(id)
			if name and texture and filter then
				self.sortedItems[#self.sortedItems + 1] = { name = name, id = id, filter = filter, texture = texture}
			end
		end

		table.sort(self.sortedItems, function( a, b ) return (a.name < b.name) or (a.name == b.name and a.id < b.id); end)

		self:UpdateScroll(true)
	end

	f.AddItem = function(self, id)
		self:GetItems()[id] = self.DropDownMenu and 0 or true
		self:UpdateList()
		self:Update()
		self:UpdateEditFrame()
	end
	
	f.CanAddItem = function(self)
		local spell = self.editFrame:GetValue()
		if (spell == 0) then return; end
		
		local name = GetSpellInfo(spell)
		if (not name) then return; end

		for id, filter in pairs(self:GetItems()) do
			if (id == spell) and (filter) then
				return false
			end
		end
		return true
	end

	f.RemoveItem = function(self, id)
		if self.DropDownMenu then
			self:GetItems()[id] = nil
		else
			self:GetItems()[id] = false
		end
		self:UpdateList()
		self:Update()
		self:UpdateEditFrame()
	end

	f.SetFilter = function (self, id, value)
		self:GetItems()[id] = value
		self:UpdateList()
		self:Update()
	end

	f.UpdateEditFrame = function(self)
		local editFrame = self.editFrame

		local spell = editFrame.editBox:GetNumber()
		if spell == 0 then
			editFrame.text:SetText(L.Auras_EnterSpellID)
			self.editFrame.addButton:Disable()
			return
		end

		local name, _, icon = GetSpellInfo(spell)
		if name and icon then
			if self:CanAddItem() then
				editFrame.text:SetFormattedText("|T%s:0|t %s", icon, name)
				self.editFrame.addButton:Enable()
				return
			else
				editFrame.text:SetFormattedText(RED_FONT_COLOR_CODE .. L.Auras_AlreadyAdded.."|r")
			end
		else
			editFrame.text:SetText(RED_FONT_COLOR_CODE .. L.Auras_InvalidSpellID.."|r")
		end
		editFrame.addButton:Disable()
	end
	--------------------------------------------------------------------------------------------
	f.DropDownMenu = false

	function f:GetItems()
		return assert(false, 'Hey, you forgot to set GetItems() for ' .. self:GetName())
	end

	function f:UpdateList()
		assert(false, 'Hey, you forgot to set UpdateList() for ' .. self:GetName())
	end

	return f
end