local _, ns = ...
ns.Widgets = ns.Widgets or {}

-----------------------------------------------------------------------
--		Group

local backdrop = {
  bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
  edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
  edgeSize = 16,
  tile = true, tileSize = 16,
  insets = {left = 4, right = 4, top = 4, bottom = 4}
}

function ns.Widgets.Group(parent, name, subtitle)
	local f = CreateFrame('Frame', parent:GetName()..name, parent, BackdropTemplateMixin and 'BackdropTemplate')
	f:SetBackdrop(backdrop)
	f:SetBackdropBorderColor(0.4, 0.4, 0.4)
	f:SetBackdropColor(0, 0, 0, 0.3)

	f.SetText = function(self, text)
		if (not self.text) then
			local t = f:CreateFontString(nil, 'BACKGROUND', 'GameFontNormal')
			t:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 5, 0)
			t:SetText(subtitle)
			self.text = t
		end
		self.text:SetText(text)
	end
	if subtitle then
		f:SetText(subtitle)
	end

	return f
end

-----------------------------------------------------------------------
--		Checkbutton

function ns.Widgets.CheckButton(parent, name)
	local b = CreateFrame('CheckButton', nil, parent, 'InterfaceOptionsCheckButtonTemplate')
	b.Text:SetText(name)

	b.SetDisabled = function(self, disable)
		if disable then
			self:Disable()
			_G[self:GetName() .. 'Text']:SetFontObject('GameFontDisable')
		else
			self:Enable()
			_G[self:GetName() .. 'Text']:SetFontObject('GameFontHighlight')
		end
	end

	b.OnClick = function(self, enable)
		if self:GetChecked() then
			self:OnEnableSetting(enable and true or false)
		else
			self:OnEnableSetting(false)
		end
		self:Update()
	end

	b.OnEnter = function(self)
		if self.tooltip then
			GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
			GameTooltip:SetText(self.tooltip)

	        if self.smallTip then
	            GameTooltip:AddLine(self.smallTip, 1, 1, 1)
	            GameTooltip:Show()
	        end
		end
	end

	b.OnLeave = function(self)
		if GameTooltip:IsOwned(self) then
			GameTooltip:Hide()
		end
	end

	b.Update = function(self)
		self:SetChecked(self:IsSettingEnabled())
	end

	b:SetScript('OnClick', b.OnClick)
	b:SetScript('OnEnter', b.OnEnter)
	b:SetScript('OnLeave', b.OnLeave)
--------------------------------------------------------------------------------------
	function b:OnEnableSetting(enable)
		assert(false, 'Hey you forgot to implement OnEnableSetting for a CheckButton')
	end

	function b:IsSettingEnabled()
		return assert(false, 'Hey you forgot to implement IsSettingEnabled for a CheckButton')
	end

	return b
end

-----------------------------------------------------------------------
--		Dropdown

function ns.Widgets.Dropdown(parent, name, width, items)
	local f = CreateFrame('Frame', name, parent, 'UIDropDownMenuTemplate')
	UIDropDownMenu_SetWidth(f, width)
	f.items = items

	local text = f:CreateFontString(nil, 'BACKGROUND', 'GameFontNormal')
	text:SetPoint('BOTTOMLEFT', f, 'TOPLEFT', 21, 0)
	text:SetText(name)
	f.titleText = text

	f.xOffset = 13
	f.yOffset = 22

	f.initialize = function(self)
		local saved = self:GetSavedValue()
		for i = 1, #self.items do
			local item = self.items[i]
     		local info = UIDropDownMenu_CreateInfo();
			info.text = item.text or item.value
			info.checked = (saved == item.value)
			--info.minWidth = width doesnt really work
			info.func = function()
				self:SetSavedValue(item.value)
				self:Update()
			end

			if item.tooltip then
				info.tooltipTitle = item.text or item.value
				info.tooltipText = item.tooltip
				info.tooltipOnButton = true
			end
			UIDropDownMenu_AddButton(info)
		end
	end

	--[[ Update Methods ]]--
	function f:SetSavedValue(value)
		assert(false, 'Hey you forgot to implement SetSavedValue')
	end

	function f:GetSavedValue()
		assert(false, 'Hey you forgot to implement GetSavedValue')
	end

	function f:GetSavedText()
		local value = self:GetSavedValue()
		for i = 1, #self.items do
			if self.items[i].value == value then
				return self.items[i].text or value
			end
		end
		return value
	end

	function f:Update()
		UIDropDownMenu_SetSelectedValue(self, self:GetSavedValue())
		UIDropDownMenu_SetText(self, self:GetSavedText())
	end

	return f
end

-----------------------------------------------------------------------
--		Slider
local sID = 1
function ns.Widgets.Slider(parent, name, low, high, step)
	local f = CreateFrame('Slider', "AbuOptionsSliderTemplate"..sID, parent, 'OptionsSliderTemplate')
	f:SetMinMaxValues(low, high)
	f:SetValueStep(step)
	f:EnableMouseWheel(true)
	sID = sID + 1

	local nameText = _G[f:GetName() .. 'Text']
	nameText:SetText(name)
	nameText:SetFontObject('GameFontNormalLeft')
	nameText:ClearAllPoints()
	nameText:SetPoint('BOTTOMLEFT', f, 'TOPLEFT')

	_G[f:GetName() .. 'Low']:SetText('')
	_G[f:GetName() .. 'High']:SetText('')

	local text = f:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall')
	text:SetJustifyH('RIGHT')
	text:SetPoint('BOTTOMRIGHT', f, 'TOPRIGHT')
	f.valText = text

	--[[ Frame Events ]]--

	f.OnValueChanged = function(self, value, userInput)
		if (value == self.lastValue) then return; end
		self.lastValue = value

		local min = self:GetMinMaxValues()
		local step = self:GetValueStep()
		local value = min + floor((value - min) / step + 0.5) * step

		if not(self.dontSaveValue) then
			self:SetSavedValue(value)
		end
		self:Update(value)
	end

	f.OnMouseWheel = function(self, direction)
		local step = self:GetValueStep() *  direction
		local minVal, maxVal = self:GetMinMaxValues()

		if step > 0 then
			self:SetValue(min(self:GetValue() + step, maxVal))
		else
			self:SetValue(max(self:GetValue() + step, minVal))
		end
	end

	f.OnEnter = function(self)
		if not GameTooltip:IsOwned(self) and self.tooltip then
			GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
			GameTooltip:SetText(self.tooltip)
		end
	end

	f.OnLeave = function(self)
		if GameTooltip:IsOwned(self) then
			GameTooltip:Hide()
		end
	end

	f:SetScript('OnMouseWheel', f.OnMouseWheel)
	f:SetScript('OnValueChanged', f.OnValueChanged)
	f:SetScript('OnEnter', f.OnEnter)
	f:SetScript('OnLeave', f.OnLeave)

	--[[ Update Methods ]]--

	function f:SetSavedValue(value)
		assert(false, 'Hey, you forgot to set SetSavedValue')
	end

	function f:GetSavedValue()
		assert(false, 'Hey, you forgot to set GetSavedValue')
	end

	function f:Update(value)
		local value = value or self:GetSavedValue()
		self.dontSaveValue = true 
		self:SetValue(value)	-- only set the position of the slider
		self.dontSaveValue = nil
		if self.GetFormattedText then
			self.valText:SetText(self:GetFormattedText(value))
		else
			self.valText:SetFormattedText('%d',value)
		end
	end

	return f
end

-----------------------------------------------------------------------
--		Colorselector

function ns.Widgets.ColorSelector(parent, hasOpacity)
	local f = CreateFrame('Button', nil, parent)
	f.hasOpacity = hasOpacity
	f:SetWidth(18)
	f:SetHeight(18)

	if hasOpacity then
		f.swatchFunc = function()
			local r, g, b = ColorPickerFrame:GetColorRGB()
			local a = 1 - OpacitySliderFrame:GetValue()
			f:SetColor(r, g, b, a)
		end

		f.opacityFunc = f.swatchFunc

		f.cancelFunc = function()
			local prev = ColorPickerFrame.previousValues
			f:SetColor(prev.r, prev.g, prev.b, 1 - prev.opacity)
		end
	else
		f.swatchFunc = function()
			f:SetColor(ColorPickerFrame:GetColorRGB())
		end
		f.cancelFunc = function()
			f:SetColor(ColorPicker_GetPreviousValues())
		end
	end

	local nt = f:CreateTexture(nil, 'OVERLAY')
	nt:SetTexture([[Interface\ChatFrame\ChatFrameColorSwatch]])
	nt:SetAllPoints(f)
	f:SetNormalTexture(nt)

	local bg = f:CreateTexture(nil, 'BACKGROUND')
	bg:SetWidth(16)
	bg:SetHeight(16)
	bg:SetColorTexture(1, 1, 1)
	bg:SetPoint('CENTER')
	f.bg = bg

	f.SetText = function(self, text)
		if (not self.text) then
			local text = f:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
			text:SetPoint('LEFT', self, 'RIGHT', 4, 0)
			self.text = text
		end
		self.text:SetText(text)
	end

	--[[ Frame Events ]]--

	f.OnClick = function(self)
		if ColorPickerFrame:IsShown() then
			ColorPickerFrame:Hide()
		else
			self.r, self.g, self.b, self.opacity = self:GetColor()
			self.opacity = 1 - (self.opacity or 1)

			OpenColorPicker(self)
			ColorPickerFrame:SetFrameStrata('TOOLTIP')
			ColorPickerFrame:Raise()
		end
	end

	f.OnEnter = function(self)
		local color = _G['NORMAL_FONT_COLOR']
		self.bg:SetVertexColor(color.r, color.g, color.b)
	end

	f.OnLeave = function(self)
		local color = _G['HIGHLIGHT_FONT_COLOR']
		self.bg:SetVertexColor(color.r, color.g, color.b)
	end

	f.Update = function(self)
		local r, g, b = self:GetColor()
		self:GetNormalTexture():SetVertexColor(r, g, b)
	end

	f.SetColor = function(self, r, g, b, a)
		self:GetNormalTexture():SetVertexColor(r, g, b)
		self:OnSetColor(r, g, b, a)
	end

	--[[ Update Methods ]]--

	function f:OnSetColor(r, g, b, a)
		assert(false, 'Hey, you forgot to implement OnSetColor for')
	end

	function f:GetColor(r, g, b, a)
		return assert(false, 'Hey, you forgot to implement GetColor')
	end


	f:SetScript('OnClick', f.OnClick)
	f:SetScript('OnEnter', f.OnEnter)
	f:SetScript('OnLeave', f.OnLeave)

	return f
end