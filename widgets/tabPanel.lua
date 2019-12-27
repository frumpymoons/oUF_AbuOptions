
local _, ns = ...
ns.Widgets = ns.Widgets or {}

---------------------------------------------------------------
--		Adding tabs

local function addTab(self, name, panel)
	self.tabs = self.tabs or {}

	local t = CreateFrame('Button', self:GetName() .. 'Tab' .. (#self.tabs + 1), self, 'OptionsFrameTabButtonTemplate')
	table.insert(self.tabs, t)

	t.panel = panel
	t:SetText(name)
	t:SetScript('OnClick', function(self)
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
	end)

	--this is the texture that makes up the top border around the main panel area
	--its here because each tab needs one to create the illusion of the tab popping out in front of the player
	t.sl = t:CreateTexture(nil, 'BACKGROUND')
	t.sl:SetTexture([[Interface\OptionsFrame\UI-OptionsFrame-Spacer]])
	t.sl:SetPoint('BOTTOMRIGHT', t, 'BOTTOMLEFT', 11, -6)
	t.sl:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 16, -(34 + t:GetHeight() + 7))

	t.sr = t:CreateTexture(nil, 'BACKGROUND')
	t.sr:SetTexture([[Interface\OptionsFrame\UI-OptionsFrame-Spacer]])
	t.sr:SetPoint('BOTTOMLEFT', t, 'BOTTOMRIGHT', -11, -7)
	t.sr:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', -16, -(34 + t:GetHeight() + 7))

	--place the new tab
	--if its the first tab, anchor to the main frame
	--if not, anchor to the right of the last tab
	local numTabs = #self.tabs
	if numTabs > 1 then
		t:SetPoint('TOPLEFT', self.tabs[numTabs - 1], 'TOPRIGHT', -8, 0)
		t.sl:Hide()
		t.sr:Hide()
	else
		t:SetPoint('TOPLEFT', self, 'TOPLEFT', 12, -34)
		t.sl:Show()
		t.sr:Show()
	end
	t:SetID(numTabs)

	--adjust tab sizes and other blizzy required things
	PanelTemplates_TabResize(t, 0)
	PanelTemplates_SetNumTabs(self, numTabs)

	--display the first tab, if its not already displayed
	PanelTemplates_SetTab(self, 1)

	--place the panel associated with the tab
	self.panelArea:Add(panel)

	panel:SetScript('OnShow', function(self)
		if self.Create then
			self:Create()
			self.Create = nil
		end
		if self.Update then
			self:Update()
		end
	end)

	return t
end

---------------------------------------------------------------
--		Main Frame

function ns.Widgets.TabPanel(parent, text, icon)

	parent.GetCurrentTab = function(self)
		return self.tabs[PanelTemplates_GetSelectedTab(self)].panel
	end

	parent.AddTab = addTab

	-- Create Title
	local title = parent:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	title:SetPoint('TOPLEFT', 16, -15)
	if icon then
		title:SetFormattedText('|T%s:%d|t %s', icon, 32, text)
	else
		title:SetText(text)
	end

	-- Panel Area
	local panelArea = CreateFrame('Frame', parent:GetName() .. '_PanelArea', parent, 'OmniCC_TabPanelTemplate')
	panelArea:SetPoint('TOPLEFT', 4, -56)
	panelArea:SetPoint('BOTTOMRIGHT', -4, 4)
	panelArea.Add = function(self, panel)
		panel:SetParent(self)
		panel:SetAllPoints(self)

		if self:GetParent():GetCurrentTab() == panel then
			panel:Show()
		else
			panel:Hide()
		end
	end
	parent.panelArea = panelArea

	return parent
end