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
	-- COLORS:
	ColorClass = "Class Color",
	ColorClassTip = 'Use class colors',
	ColorGradient = "Gradient color",
	ColorGradientTip ='Use a gradient from green to red',
	ColorCustom = "Custom Color",
	ColorCustomTip = 'Use a custom color',
	ColorPower = 'Power Color',
	ColorPowerTip = 'Use power type colors',

	HealthColorMode = "Health Color",
	HealthColorCustom = 'Custom Health Color',
	PowerColorMode = "Power Color",
	PowerColorCustom = 'Custom Power Color',

	HealthTextColorMode = "Health Text Color",
	HealthTextColorCustom = "Custom Health Text Color",
	PowerTextColorMode = "Power Text Color",
	PowerTextColorCustom = "Custom Power Text Color",

	NameTextColorMode = "Name Text Color",
	NameTextColorCustom = "Custom Name Text Color",

	--generalpanel
	EnterProfileName = 'Enter Profile Name',
	AddProfile = 'Add Profile',
	Yes = 'Yes',
	No = 'No',
	ReloadUIWarning_Desc = "You've made changes that requires a reload \n of the UI to take full effect, reload?",

	--aurapanel
	AuraFilters = 'Aura Filters',

	AuraFilterBossDesc = "Whitelist debuffs for the Boss Frames.",
	AuraFilterGeneralDesc = "Add filters to new auras or edit existing ones.",
	AuraFilterArenaDesc = "Whitelist buffs for the Arena Frames.",

	InvalidSpellID = "That is a invalid Spell ID!",
	TypeSpellID = "Type in a Spell ID",

	BossFrames = "Boss Frames",
	ArenaFrames = "Arena Frames",
	AllFrames = "All Frames",

	ShowAll = "Show All",
	OnlyOwn = "Only Own",
	HideOnFriendly = "Hide on Friendly",
	NeverShow = "Never Show",

	-- basic,
	Shift = "Shift",
	Ctrl = "Ctrl",
	Alt = "Alt",
	Disable = "Disable",
	Button1 = "Button 1",
	Button2 = "Button 2",
	MButton = "Middle Button",
	General = "General",
	NoEffectUntilRL = "These options will not take effect until you reload the UI.",
	EnablePartyFrames = "Enable Party Frames",
	ShowPartyInRaid = "Display Party Frames in Raid",
	EnableArena = "Enable Arena Frames",
	EnableBoss = "Enable Boss Frames",
	EnableCastbars = "Enable Castbars",
	DisplayChannelTicks = "Display Channeling Ticks",
	ShowPortraitTimer = "Show Portrait Timers",
	ShowCBFeedback = "Show Combat Feedback",
	EnableThreatGlow = "Enable Threat Glow",
	OnlyColorPlayer = "Only Color Player Debuffs",
	ShowAuraTimer = "Show Aura Timer",
	ShowAuraTimerTip = "Disable the inbuilt Aura Timer",
	ClickthroughFrames = "Clickthrough frames",
	ClickthroughFramesTip = "Make the frames click through.",
	FocusModKey = 'Focus Modifier Key',
	FocusModButton = 'Focus Mouse Button',
	EnableAbsorbBar = "Enable Absorb Bar",
	EnableAbsorbBarTip = "Display a bar showing total absorb on a unit.",
	EnableClassPortait = "Enable Class Portraits",
	EnableClassPortaitTip = "Display a class icon instead of portrait on players.",
	EnableResolve = "Enable Resolve Bar",
	EnableResolveTip = "Display a Resolve bar for Tanks above the player frame.",
	EnableEnrageBar = "Enable Warrior Enrage Bar",
	EnableEnrageBarTip = "Display a Enrage bar for Fury Warriors above the player frame.",
	EnableWSBar = "Enable Weakened Soul Bar",
	EnableWSBarTip = "Display a Weakened Soul bar for Priests.",
	EnableArcCharge = "Enable Mage Arcane Charge",
	EnableArcChargeTip = "Display a counter for Arcane Charges.",
	EnableSnD = "Enable Slice and Dice bar",
	EnableSnDTip = "Display a bar for Slice and Dice.",
	EnableAnticipation = "Show Anticipation Charges",
	EnableAnticipationTip = "Display additional combopoints for Anticipation charges.",

	-- font,
	Font = "Font",
	None = "None",
	ThinOutline = "ThinOutline",
	Outline = "Outline",
	ThickOutline = "Thick Outline",
	OutlineMono = 'Outline Monochrome',
	NumFont = "Number Font",
	NumFontSize = "Numbar Font Size",
	NumFontOutline = 'Number Outline Type',
	NameFont = "Name Font",
	NameFontSize = "Name Font Size",
	NameFontOutline = "Name Outline Type",

	-- texture,
	StatusBarTex = 'Statusbar Texture',
	Frames = 'Frames',
	FrameColor = 'Frame Overlay Color',
	LatencyColor = 'Castbar Latency Color',

	BackdropColor = 'Bar Backdrop Color',
	Reset = "Reset",
	PlayerTex = "Player Frame Style",
	Path = "Path for Custom Texture",

	PlayerTexNormal = 'Normal',
	PlayerTexNormalTip = 'Normal Player Frame',
	PlayerTexRare = 'Rare',
	PlayerTexRareTip = 'Rare Player Frame',
	PlayerTexElite = 'Elite',
	PlayerTexEliteTip = 'Elite Player Frame',
	PlayerTexRareElite = 'Rare-Elite',
	PlayerTexRareEliteTip = 'Rare-Elite Player Frame',
	PlayerTexCustom = 'Custom',
	PlayerTexCustomTip = 'Custom Player Frame',

	Textures = "Textures",

	-- Units,
	TagNumeric = "Numeric",
	TagBoth = "Both",
	TagPercent = "Percent",
	TagMinimal = "Minimal",
	TagDeficit = "Deficit",
	TagDisable = "Disable",
	TagNumericTip = "Display values as numbers",
	TagBothTip = "Both percentage and numbers",
	TagPercentTip = "Display precentages",
	TagMinimalTip = "Display percentages but hide when max",
	TagDeficitTip = "Display a deficit value",
	TagDisableTip = "Disable text on this frame",

	DontShow = "Don't Show",
	IconOnLeft = "Icon on the left",
	IconOnRight = "Icon on the right",

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
	HoriPos = 'Horizontal Position',
	VertPos = 'Vertical Position',

	TextHealthTag = "Health Text",
	TextPowerTag = "Power Text",

	UnitSpecific = "Unit Specific",
}