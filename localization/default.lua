local _, ns = ...
--[[
"frFR": French (France)
"deDE": German (Germany)
"enGB : English (Great Brittan) if returned, can substitute 'enUS' for consistancy
"enUS": English (America)
"itIT": Italian (Italy)
"koKR": Korean (Korea) RTL - right-to-left
"zhCN": Chinese (China) (simplified) implemented LTR left-to-right in WoW
"zhTW": Chinese (Taiwan) (traditional) implemented LTR left-to-right in WoW
"ruRU": Russian (Russia)
"esES": Spanish (Spain)
"esMX": Spanish (Mexico)
"ptBR": Portuguese (Brazil)
]]
ns.locale = GetLocale()
ns.L = {
	Shift = "Shift",
	Ctrl = "Ctrl",
	Alt = "Alt",
	Disable = "Disable",
	Button1 = "Button 1",
	Button2 = "Button 2",
	MButton = "Middle Button",
	None = "None",
	ReloadUIWarning_Desc = "You've made changes that requires a reload \n of the UI to take full effect, reload?",
	NoEffectUntilRL = "These options will not take effect until you reload the UI.",

---- PROFILES
	EnterProfileName = 'Enter Profile Name',
	AddProfile = 'Add Profile',
	Yes = 'Yes',
	No = 'No',

---- AURA PANEL
	AuraFilters = "Aura Filters",

	AuraFilterGeneralDesc = "Add filters to new auras or edit existing ones.",
	AllFrames = "All Frames",

	AuraFilterArenaDesc = "Whitelist buffs for the Arena Frames.",
	ArenaFrames = "Arena Frames",

	AuraFilterBossDesc = "Whitelist debuffs for the Boss Frames.",
	BossFrames = "Boss Frames",

	ShowAll = "Show All",
	OnlyOwn = "Only Own",
	HideOnFriendly = "Hide on Friendly",
	NeverShow = "Never Show",

---- GENERAL PANEL
	General = "Basic",

	General_ClassModule = "Enable Default Class Modules",
	General_ClassModuleTip = "Enable Blizzard modules for your class.",
	General_Party = "Enable Party Frames",
	General_PartyInRaid = "Display Party Frames in Raid",
	General_Arena = "Enable Arena Frames",
	General_Boss = "Enable Boss Frames",
	General_Castbars = "Enable Castbars",
	General_Ticks = "Display Channeling Ticks",
	General_PTimer = "Show Portrait Timers",
	General_Feedback = "Show Combat Feedback",
	General_Threat = "Enable Threat Glow",
	General_OnlyPlayer = "Only Color Player Debuffs",
	General_AuraTimer = "Show Aura Timer",
	General_AuraTimerTip = "Disable the inbuilt Aura Timer",
	General_Click = "Clickthrough frames",
	General_ClickTip = "Make the frames click through.",
	General_ModKey = 'Focus Modifier Key',
	General_ModButton = 'Focus Mouse Button',
	General_Absorb = "Enable Absorb Bar",
	General_AbsorbTip = "Display a bar showing total absorb on a unit.",
	General_ClassP = "Enable Class Portraits",
	General_ClassPTip = "Display a class icon instead of portrait on players.",
	General_Resolve = "Enable Resolve Bar",
	General_ResolveTip = "Display a Resolve bar for Tanks above the player frame.",
	General_Enrage = "Enable Warrior Enrage Bar",
	General_EnrageTip = "Display a Enrage bar for Fury Warriors above the player frame.",
	General_WSBar = "Enable Weakened Soul Bar",
	General_WSBarTip = "Display a Weakened Soul bar for Priests.",
	General_Arcane = "Enable Mage Arcane Charge",
	General_ArcaneTip = "Display a counter for Arcane Charges.",
	General_SnD = "Enable Slice and Dice bar",
	General_SnDTip = "Display a bar for Slice and Dice.",
	General_Ant = "Show Anticipation Charges",
	General_AntTip = "Display additional combopoints for Anticipation charges.",
	General_Shrooms = "Show Mushroom icons",
	General_ShroomsTip = "Display the textures around the icons, instead of just the text.",

---- TEXTURES,
	Texture = "Textures",
	Texture_Statusbar = 'Statusbar Texture',
	Texture_Frames = 'Frames',
	Texture_Path = "Custom Texture Path",

	Texture_Player = "Player Frame Style",
	Texture_Normal = 'Normal',
	Texture_NormalTip = 'Normal Player Frame',
	Texture_Rare = 'Rare',
	Texture_RareTip = 'Rare Player Frame',
	Texture_Elite = 'Elite',
	Texture_EliteTip = 'Elite Player Frame',
	Texture_RareElite = 'Rare-Elite',
	Texture_RareEliteTip = 'Rare-Elite Player Frame',
	Texture_Custom = 'Custom',
	Texture_CustomTip = 'Custom Player Frame',

		-- COLORS:
	Color_Class = "Class Color",
	Color_ClassTip = 'Use class colors',
	Color_Gradient = "Gradient color",
	Color_GradientTip ='Use a gradient from green to red',
	Color_Custom = "Custom Color",
	Color_CustomTip = 'Use a custom color',
	Color_Power = 'Power Color',
	Color_PowerTip = 'Use power type colors',

	Color_Frame = 'Frame Overlay Color',
	Color_Latency = 'Castbar Latency Color',
	Color_Backdrop = 'Bar Backdrop Color',

	Color_Health = "Health Color",
	Color_HealthCustom = 'Custom Health Color',
	Color_Power = "Power Color",
	Color_PowerCustom = 'Custom Power Color',

	Color_NameText = "Name Text Color",
	Color_NameTextCustom = "Custom Name Text Color",
	Color_HealthText = "Health Text Color",
	Color_HealthTextCustom = "Custom Health Text Color",
	Color_PowerText = "Power Text Color",
	Color_PowerTextCustom = "Custom Power Text Color",

---- FONTS
	Font = "Font",
	Font_Outline = "Outline",
	Font_ThinOutline = "Thin Outline",
	Font_ThickOutline = "Thick Outline",
	Font_OutlineMono = 'Outline Monochrome',
	Font_Number = "Number Font",
	Font_NumberSize = "Numbar Font Size",
	Font_NumberOutline = 'Number Outline Type',
	Font_Name = "Name Font",
	Font_NameSize = "Name Font Size",
	Font_NameOutline = "Name Outline Type",

---- UNITS

	Tag_Numeric = "Numeric",
	Tag_Both = "Both",
	Tag_Percent = "Percent",
	Tag_Minimal = "Minimal",
	Tag_Deficit = "Deficit",
	Tag_Disable = "Disable",
	Tag_NumericTip = "Display values as numbers",
	Tag_BothTip = "Both percentage and numbers",
	Tag_PercentTip = "Display precentages",
	Tag_MinimalTip = "Display percentages but hide when max",
	Tag_DeficitTip = "Display a deficit value",
	Tag_DisableTip = "Disable text on this frame",

	Icon_DontShow = "Don't Show",
	Icon_Left = "Icon on the left",
	Icon_Right = "Icon on the right",

	Fat = "Fat",
	Normal = "Normal",

	Top = "Top",
	Bottom = "Bottom",
	Left = "Left",

	player = "Player",
	target = "Target",
	targettarget = "Target Target",
	pet = "Pet",
	focus = "Focus",
	focustarget = "Focus Target",
	party = "Party",
	boss = "Boss",
	arena = "Arena",

	Scale = "Scale",
	Style = "Style",
	EnableAuras = 'Enable Auras',
	EnableAuraTip = 'Enable auras for this unit',
	BuffPos = 'Buff Postion',
	DebuffPos = 'Debuff Postion',

	Castbar = "Castbar",
	ShowCastbar = 'Show Castbar',
	ShowCastbarTip = 'Show Castbar for this unit',
	Width = 'Width',
	Height = "Height",
	CastbarIcon = 'Castbar Icon',
	HoriPos = 'Horizontal Offset',
	VertPos = 'Vertical Offset',

	TextHealthTag = "Health Text",
	TextPowerTag = "Power Text",

	UnitSpecific = "Unit Specific",
}