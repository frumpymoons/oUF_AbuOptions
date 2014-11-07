local TabPanel = {}
_G.oUFAbuOptions = oUFAbuOptions or {}

--[[
	Tabs
--]]

local function tab_OnClick(self)
	local parent = self:GetParent()

	--update tab selection
	PanelTemplates_Tab_OnClick(self, parent)
	PanelTemplates_UpdateTabs(parent)

	--hide any visible panels/tabs
	for i, tab in pairs(parent.tabs) do
		if tab ~= self then
			tab.panel:Hide()
			tab.sl:Hide()
			tab.sr:Hide()
		end
	end

	--show the top of the panel texture from our tab
	self.sl:Show()
	self.sr:Show()

	--show selected tab's panel
	self.panel:Show()
end

function TabPanel:CreateTab(parent, id, name, panel)
	parent.tabs = parent.tabs or {}

	local t = CreateFrame('Button', parent:GetName() .. 'Tab' .. (#parent.tabs + 1), parent, 'OptionsFrameTabButtonTemplate')
	table.insert(parent.tabs, t)

	t.panel = panel
	t.id = id
	t:SetText(name)
	t:SetScript('OnClick', tab_OnClick)

	--this is the texture that makes up the top border around the main panel area
	--its here because each tab needs one to create the illusion of the tab popping out in front of the player
	t.sl = t:CreateTexture(nil, 'BACKGROUND')
	t.sl:SetTexture([[Interface\OptionsFrame\UI-OptionsFrame-Spacer]])
	t.sl:SetPoint('BOTTOMRIGHT', t, 'BOTTOMLEFT', 11, -6)
	t.sl:SetPoint('BOTTOMLEFT', parent, 'TOPLEFT', 16, -(34 + t:GetHeight() + 7))

	t.sr = t:CreateTexture(nil, 'BACKGROUND')
	t.sr:SetTexture([[Interface\OptionsFrame\UI-OptionsFrame-Spacer]])
	t.sr:SetPoint('BOTTOMLEFT', t, 'BOTTOMRIGHT', -11, -6)
	t.sr:SetPoint('BOTTOMRIGHT', parent, 'TOPRIGHT', -16, -(34 + t:GetHeight() + 11))

	--place the new tab
	--if its the first tab, anchor to the main frame
	--if not, anchor to the right of the last tab
	local numTabs = #parent.tabs
	if numTabs > 1 then
		t:SetPoint('TOPLEFT', parent.tabs[numTabs - 1], 'TOPRIGHT', -8, 0)
		t.sl:Hide()
		t.sr:Hide()
	else
		t:SetPoint('TOPLEFT', parent, 'TOPLEFT', 12, -34)
		t.sl:Show()
		t.sr:Show()
	end
	t:SetID(numTabs)

	--adjust tab sizes and other blizzy required things
	PanelTemplates_TabResize(t, 0)
	PanelTemplates_SetNumTabs(parent, numTabs)

	--display the first tab, if its not already displayed
	PanelTemplates_SetTab(parent, 1)

	--place the panel associated with the tab
	parent.panelArea:Add(panel)

	return t
end

--[[
	main frame content area
--]]

local function panelArea_Add(self, panel)
	panel:SetParent(self)
	panel:SetAllPoints(self)

	if self:GetParent():GetCurrentPanel() == panel then
		panel:Show()
	else
		panel:Hide()
	end
end

local function panelArea_Create(parent)
	local f = CreateFrame('Frame', parent:GetName() .. '_PanelArea', parent, 'OmniCC_TabPanelTemplate')
	f:SetPoint('TOPLEFT', 4, -56)
	f:SetPoint('BOTTOMRIGHT', -4, 4)
	f.Add = panelArea_Add

	parent.panelArea = f
	return f
end

--[[
	the main frame
--]]

local function optionsPanel_GetCurrentPanel(self)
	return self.tabs[PanelTemplates_GetSelectedTab(self)].panel
end

local function optionsPanel_GetTabById(self, tabId)
	for i, tab in pairs(self.tabs) do
		if tab.id == tabId then
			return tab
		end
	end
end

local function optionsPanel_GetCurrentTab(self)
	return self.tabs[PanelTemplates_GetSelectedTab(self)]
end

local function title_Create(parent, text, subtext, icon)
	local title = parent:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	title:SetPoint('TOPLEFT', 16, -15)

	if icon then
		title:SetFormattedText('|T%s:%d|t %s', icon, 32, name)
	else
		title:SetText(text)
	end

	if subtext then
		local subTitle = parent:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
		subTitle:SetPoint('BOTTOMLEFT', title, 'BOTTOMRIGHT', 4, 0)
		subTitle:SetTextColor(0.8, 0.8, 0.8)
		subTitle:SetText(subtext)
	end
end

function TabPanel:CreateTabPanel(parent, title, subtitle)
	parent.GetCurrentPanel = optionsPanel_GetCurrentPanel

	title_Create(parent, title, subtitle)
	panelArea_Create(parent)

	return parent
end

oUFAbuOptions.TabPanel = TabPanel;