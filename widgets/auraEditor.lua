--[[--------------------------------------------------------------------
	An aura filter widget
			oUFAbuOptions.AuraEditor:New(parent, title)
	Required:
			AuraEditor:GetItems() 
				A table of auras	
	Optional:
			AuraEditor:GetDDMenu()
				A dropdownmenu of filter or no filters

	Required:
			AuraEditor:Load(desc)
				
				When the functions are set.

	TODO: Stop creating a billion buttons
--]]-------------------------------------------------------------------
local _, ns = ...

_G['oUFAbuOptions'] = oUFAbuOptions or {}

local AuraEditor = LibStub('Classy-1.0'):New('Frame')
oUFAbuOptions.AuraEditor = AuraEditor

local PADDING = 2
local ROW_HEIGHT = 40
local SCROLL_STEP = ROW_HEIGHT + PADDING
local WIDTH, HEIGTH = 348, 400

------------------------[[	Dropdown 	]]--------------------------
local DropDownFilter = LibStub('Classy-1.0'):New('Frame'); DropDownFilter:Hide()

do
	local function Dropdown_SetFilter( info, buttID )
		info.owner.items[buttID] = info.value
		info.owner:SetSavedValue(info.value, info.owner.ddmenu[info.value])
		info.owner.auraeditor:UpdateList()
	end

	function DropDownFilter:New(parent, items, ddmenu)
		local dd = CreateFrame('Frame', parent:GetName().."DropDownFilter", parent, 'UIDropDownMenuTemplate')
		local buttID
		dd.ddmenu = ddmenu
		dd.items = items
		dd.auraeditor = parent.auraeditor

		dd.SetSavedValue = function(self, value, text)
			UIDropDownMenu_SetSelectedValue(self, value or "UNKNOWN")
			UIDropDownMenu_SetText(self, text or value)
		end

		dd.GetSavedValue = function(self)
			buttID = parent:GetID()
			return self.items[buttID]
		end

		dd.GetSavedText = function(self)
			return self.menu[self:GetSavedValue()] or "uncows"
		end


		UIDropDownMenu_Initialize(dd, function(dd, level)
			if not level then return end
			local info = UIDropDownMenu_CreateInfo()
			local items = dd.items
			local ddmenu = dd.ddmenu

			buttID = dd:GetParent():GetID()
			for i = 0, #ddmenu do
				info.text = ddmenu[i]
				info.value = i
				info.owner = dd
				info.checked = (i == items[buttID])
				info.arg1 = buttID --	
				info.func = Dropdown_SetFilter
				UIDropDownMenu_AddButton(info)
			end
		end)

		UIDropDownMenu_SetWidth(dd, 160)
		dd:SetScript('OnShow', dd.UpdateStuff)
		return dd
	end
end

function DropDownFilter:UpdateStuff()
	UIDropDownMenu_SetSelectedValue(self, self:GetSavedValue())
	UIDropDownMenu_SetText(self, self:GetSavedText())
end

function DropDownFilter:UpdateList()

end

-----------------[[		The aura button 	]]----------------------

local AuraButton = LibStub('Classy-1.0'):New('Frame')
do
	local buttcount = 1
	function AuraButton:New(parent, onRemove, altColor)
		local b = self:Bind(CreateFrame('Frame', parent:GetParent():GetName()..'AuraButton'..buttcount, parent))
		b.auraeditor = parent.auraeditor
		buttcount = buttcount + 1
		b:SetHeight(ROW_HEIGHT)
		b:EnableMouse(true)
		b:SetScript('OnEnter', b.OnEnter)
		b:SetScript('OnLeave', b.OnLeave)

		local bg = b:CreateTexture(nil, 'BACKGROUND')
		bg:SetAllPoints(b)
		b.altColor = altColor
		b.bg = bg

		local deleteButton = CreateFrame('Button', nil, b, 'UIPanelCloseButton')
		deleteButton:SetSize(32, 32)
		deleteButton:SetPoint('RIGHT', -6, 0)
		deleteButton:SetScript('OnClick', onRemove)
		b.deleteButton = deleteButton
		b:OnLeave()

		local icon = b:CreateTexture(nil, "ARTWORK")
		icon:SetPoint("LEFT", 6, 0)
		icon:SetSize(32, 32)
		icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		b.icon = icon

		local text = b:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
		text:SetPoint('LEFT', icon, 'RIGHT', 12, 0)
		b.text = text

		-- If there is no dropdown menu we dont need a dropdown
		if (type(b:GetDDMenu()) == "table") then
			local filter = DropDownFilter:New(b, b:GetItems(), b:GetDDMenu())
			filter:SetPoint('RIGHT', deleteButton, 'LEFT', -5, 0)
			filter:SetWidth(200)
			b.filter = filter
		end

		return b
	end
end
function AuraButton:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPRIGHT", self, "TOPLEFT")
	GameTooltip:SetSpellByID(self:GetID())
	GameTooltip:Show()
	self.bg:SetTexture(1, 1, 1, 0.3)
end

function AuraButton:OnLeave()
	GameTooltip:Hide()
	if self.altColor then
		self.bg:SetTexture(0.2, 0.2, 0.2, 0.6)
	else
		self.bg:SetTexture(0.3, 0.3, 0.3, 0.6)
	end
end

function AuraButton:SetID(id)
	self.id = id
end

function AuraButton:GetID()
	return self.id
end

function AuraButton:GetDDMenu()
	return self:GetParent():GetParent():GetParent():GetDDMenu()
end

function AuraButton:GetItems()
	return self:GetParent():GetParent():GetParent():GetItems()
end
------------------------[[	add aura frame 	]]--------------------------

local EditFrame = LibStub('Classy-1.0'):New('Frame')

do 
	local function editBox_OnEnterPressed(self)
		local parent = self:GetParent()
		if parent:CanAddItem() then
			parent:AddItem(parent:GetValue())
			parent.edit:SetNumber("")
			parent.auraeditor:UpdateList()
		end
	end

	local function editBox_OnTextChanged(self, userInput)
		local parent = self:GetParent()
		parent:UpdateAddButton()

		--if not userInput then return end
		local spell = self:GetNumber()
		if spell == 0 then
			parent.text:SetText(parent.text_Enter)
			return
		end

		local name, _, icon = GetSpellInfo(spell)
		if name and icon then
			parent.text:SetFormattedText("|T%s:0|t %s", icon, name)
		else
			parent.text:SetText(RED_FONT_COLOR_CODE .. parent.text_Invalid .. "|r")
		end
	end

	local function addButton_OnClick(self)
		editBox_OnEnterPressed(self)
	end

	function EditFrame:New(parent, desc, text_Enter, text_Invalid)
		--create parent frame
		local f = self:Bind(oUFAbuOptions.Group:New(desc, parent))
		f.auraeditor = parent
		f.text_Enter = text_Enter
		f.text_Invalid = text_Invalid

		--create text with aura info
		local text = f:CreateFontString('EditFrameFontString', "OVERLAY", "GameFontHighlight")
		text:SetPoint("TOPLEFT", f, "TOPLEFT", 13, -12)
		text:SetJustifyH("LEFT")
		text:SetJustifyV("TOP")
		text:SetText(f.text_Enter)
		f.text = text

		--create edit box 
		local editBox = CreateFrame('EditBox', 'EditFrameEditBox', f, 'InputBoxTemplate')
		editBox:SetPoint('TOPLEFT', f, 'TOPLEFT', 18, -12)
		editBox:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', -60, -12)
		editBox:SetScript('OnEnterPressed', editBox_OnEnterPressed)
		editBox:SetScript('OnTextChanged', editBox_OnTextChanged)
		editBox:SetAutoFocus(false)
		editBox:SetAltArrowKeyMode(false)
		editBox:SetMaxLetters(6)
		editBox:SetNumeric(true)	
		f.edit = editBox
		
		--create add button
		local addButton = CreateFrame('Button', 'EditFrameAdd', f, 'UIPanelButtonTemplate')
		addButton:SetText(ADD)
		addButton:SetSize(48, 24)
		addButton:SetPoint('LEFT', editBox, 'RIGHT', 4, 0)
		addButton:SetScript('OnClick', addButton_OnClick)
		f.add = addButton
		
		return f
	end
end

function EditFrame:GetValue()
	return self.edit:GetNumber()
end

function EditFrame:AddItem()
	self.auraeditor:AddItem(self:GetValue())
end

function EditFrame:CanAddItem()
	return self.auraeditor:CanAddItem(self:GetValue())
end

function EditFrame:UpdateAddButton()
	self.auraeditor:UpdateAddButton()
end

function EditFrame:RemoveItem()
	self.auraeditor:RemoveItem(self:GetID())
end

------------------------[[	 AuraPanel 	]]--------------------------

function AuraEditor:New(parent, title, desc, text_Enter, text_Invalid)
	local f = self:Bind(CreateFrame('Frame', title, parent))

	-- Editbox
	local editFrame = f:CreateEditFrame(desc, text_Enter, text_Invalid)
	editFrame:SetPoint('TOPLEFT', 0, 0)
	editFrame:SetPoint('BOTTOMRIGHT', f, "TOPRIGHT", 0, -60)
	f.editFrame = editFrame

	-- List
	local group = oUFAbuOptions.Group:New("", f)
	group:SetPoint('TOPLEFT', f, 'TOPLEFT', 0, -64)
	group:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 0)

	local scrollFrame = f:CreateScrollFrame()
	scrollFrame:SetPoint('TOPLEFT', editFrame, 'BOTTOMLEFT', 7, -10)
	scrollFrame:SetPoint('BOTTOMLEFT', f, 'BOTTOMLEFT', 7, 8)
	f.scrollFrame = scrollFrame

	local scrollChild = f:CreateScrollChild()
	scrollFrame:SetScrollChild(scrollChild)
	f.scrollChild = scrollChild

	local scrollBar = f:CreateScrollBar()
	scrollBar:SetPoint('TOPRIGHT',  editFrame, 'BOTTOMRIGHT', -7, -10)
	scrollBar:SetPoint('BOTTOMRIGHT', -7, 6)
	scrollBar:SetWidth(16)
	f.scrollBar = scrollBar

	local auraButton_OnDelete = function(b) 
		f:RemoveItem(b:GetParent():GetID()) 
		f:UpdateList()
	end

	f.buttons = setmetatable({}, {__index = function(t, i)
		local altcolor = (i % 2 == 0)
		local button = AuraButton:New(scrollChild, auraButton_OnDelete, altcolor)
		if i > 1 then
			local prevButton = t[i-1]
			button:SetPoint('TOPLEFT', prevButton, 'BOTTOMLEFT', 0, -PADDING)
			button:SetPoint('TOPRIGHT', prevButton, 'BOTTOMRIGHT', 0, -PADDING)
		else
			button:SetPoint('TOPLEFT')
			button:SetPoint('TOPRIGHT')
		end
		t[i] = button
		return button
	end})
	f:SetWidth(590)

	scrollFrame:SetSize(WIDTH, HEIGTH)
	f:SetScript('OnShow', self.OnShow)

	return f
end

function AuraEditor:OnSizeChanged()
	self:UpdateScrollFrameSize()
end

do
	local function scrollFrame_OnSizeChanged(self)
		local scrollChild = self:GetParent().scrollChild
		scrollChild:SetWidth(self:GetWidth())

		local scrollBar  = self:GetParent().scrollBar
		local scrollMax = max(scrollChild:GetHeight() - self:GetHeight(), 0)
		scrollBar:SetMinMaxValues(0, scrollMax)
		scrollBar:SetValue(0)
	end

	local function scrollFrame_OnMouseWheel(self, delta)
		local scrollBar = self:GetParent().scrollBar
		local min, max = scrollBar:GetMinMaxValues()
		local current = scrollBar:GetValue()

		if IsShiftKeyDown() and (delta > 0) then
		   scrollBar:SetValue(min)
		elseif IsShiftKeyDown() and (delta < 0) then
		   scrollBar:SetValue(max)
		elseif (delta < 0) and (current < max) then
		   scrollBar:SetValue(current + SCROLL_STEP)
		elseif (delta > 0) and (current > 1) then
		   scrollBar:SetValue(current - SCROLL_STEP)
		end
	end

	function AuraEditor:CreateScrollFrame()
		local scrollFrame = CreateFrame('ScrollFrame', self:GetName().."ScrollFrame", self)
		scrollFrame:EnableMouseWheel(true)
		scrollFrame:SetScript('OnSizeChanged', scrollFrame_OnSizeChanged)
		scrollFrame:SetScript('OnMouseWheel', scrollFrame_OnMouseWheel)

		return scrollFrame
	end

	function AuraEditor:UpdateScrollFrameSize()
		local w, h = self:GetSize()
		w = w - 12
		h = h - 145

		if self.scrollBar:IsShown() then
			w = w - (self.scrollBar:GetWidth() + 4)
		end
		self.scrollFrame:SetSize(w, h)
	end
end

do
	local function scrollBar_OnValueChanged(self, value)
		local scrollFrame = self:GetParent().scrollFrame
		scrollFrame:SetVerticalScroll(value)
	end

	function AuraEditor:CreateScrollBar()
		local scrollBar = CreateFrame('Slider', self:GetName().."Slider", self)

		local bg = scrollBar:CreateTexture(nil, 'BACKGROUND')
		bg:SetAllPoints(true)
		bg:SetTexture(0, 0, 0, 0.5)

		local thumb = scrollBar:CreateTexture(nil, 'OVERLAY')
		thumb:SetTexture([[Interface\Buttons\UI-ScrollBar-Knob]])
		thumb:SetSize(25, 25)
		scrollBar:SetThumbTexture(thumb)

		scrollBar:SetOrientation('VERTICAL')

		scrollBar:SetScript('OnValueChanged', scrollBar_OnValueChanged)
		return scrollBar
	end
end

function AuraEditor:CreateScrollChild()
	local scrollChild = CreateFrame('Frame', self:GetName().."ScrollChild")
	scrollChild:SetWidth(self.scrollFrame:GetWidth())
	self.scrollFrame:SetScrollChild(scrollChild)

	scrollChild.auraeditor = self
	return scrollChild
end

function AuraEditor:CreateEditFrame(desc, text_Enter, text_Invalid)
	return EditFrame:New(self, desc, text_Enter, text_Invalid)
end


function AuraEditor:OnShow()
	self:UpdateValues()
end
------------------------[[	 Functions 	]]--------------------------
local pool = {}
local sortedItems = {}
local sortFunc = function(a, b)
	return a.name < b.name or (a.name == b.name and a.id < b.id)
end
-- thanks phanx
function AuraEditor:UpdateValues()
	local items = self:GetItems()
	local ddmenu = self:GetDDMenu()
	for i = #sortedItems, 1, -1 do
		pool[tremove(sortedItems, i)] = true
	end

	for id, filter in pairs(items) do
		local name, _, icon = GetSpellInfo(id)
		if name and icon and filter then
			local t = next(pool) or {}
			pool[t] = nil
			t.name = name
			t.icon = icon
			t.id = id
			t.filter = filter
			tinsert(sortedItems, t)
		end
	end
	table.sort(sortedItems, sortFunc)

	if #sortedItems > 0 then
		for i, t in ipairs (sortedItems) do
			local button = self.buttons[i]
			button:SetID(t.id)
			button.text:SetFormattedText("%s (|cFFFFFFFF%d|r)",  t.name, t.id)
			button.icon:SetTexture(t.icon)
			if (button.filter) then
				button.filter:SetSavedValue(t.filter, ddmenu[t.filter])
			end
			button:Show()
		end
		for i = #sortedItems + 1, #self.buttons do
			self.buttons[i]:Hide()
		end
	else
		for i = 1, #self.buttons do
			self.buttons[i]:Hide()
		end
	end

	local scrollHeight = #sortedItems * (ROW_HEIGHT + PADDING) - PADDING
	local scrollMax = max(scrollHeight - self.scrollFrame:GetHeight(), 0)

	local scrollBar = self.scrollBar
	scrollBar:SetMinMaxValues(0, scrollMax)
	scrollBar:SetValue(min(scrollMax, scrollBar:GetValue()))
	if scrollMax > 0 then
		self.scrollBar:Show()
	else
		self.scrollBar:Hide()
	end
	self.scrollChild:SetHeight(scrollHeight)
	self:UpdateScrollFrameSize()

	for i = 1, #oUF.objects do
		oUF.objects[i]:UpdateAllElements("OptionsRefresh")
	end
end

function AuraEditor:AddItem(auraToAdd, index)
	if self:HasDropdown() then
		self:GetItems()[auraToAdd] = 0
	else
		self:GetItems()[auraToAdd] = true
	end
	self:UpdateValues()
	self:UpdateAddButton()
end

function AuraEditor:RemoveItem(auraToRemove)
	if self:HasDropdown() then
		self:GetItems()[auraToRemove] = nil
	else
		self:GetItems()[auraToRemove] = false
	end
	self:UpdateValues()
	self:UpdateAddButton()
end

function AuraEditor:CanAddItem()
	local spell = self.editFrame.edit:GetNumber()
	local name, _, icon = GetSpellInfo(spell)
	if spell == 0 or not name then
		return false
	end

	for id, filter in pairs(self:GetItems()) do
		if id == spell and filter then
			return false
		end
	end

	return true
end

function AuraEditor:UpdateAddButton()
	if self:CanAddItem() then
		self.editFrame.add:Enable()
	else
		self.editFrame.add:Disable()
	end
end

function AuraEditor:HasDropdown()
	return type(self:GetDDMenu()) == "table"
end

function AuraEditor:UpdateList()
	assert(false, "No update function")
end

------------------------------------------------------------------------------
function AuraEditor:GetItems()
	assert(false, 'Hey, you forgot to set GetItems() for ' .. self:GetName())
end

function AuraEditor:GetDDMenu()
	return false
end