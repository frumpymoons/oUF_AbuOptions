std = "lua51"
max_line_length = 150
ignore = {
    "11./SLASH_.*", -- Setting an undefined (Slash handler) global variable
    "11./BINDING_.*", -- Setting an undefined (Keybinding header) global variable
    "113/LE_.*", -- Accessing an undefined (Lua ENUM type) global variable
    "113/NUM_LE_.*", -- Accessing an undefined (Lua ENUM type) global variable
    "211/L", -- Unused local variable "L"
    "212", -- Unused argument.
    "411", -- Redefining a local variable.
    "421", -- Shadowing a local variable.
    "412", -- Redefining a local variable.
    "43.", -- Shadowing an upvalue, an upvalue argument, an upvalue loop variable.
    "542", -- An empty if branch
}
globals = {
    "ACCEPT",
    "ADD",
    "ADDON_DISABLED",
    "ALT_KEY",
    "BackdropTemplateMixin",
    "CANCEL",
    "CloseDropDownMenus",
    "ColorPicker_GetPreviousValues",
    "ColorPickerFrame",
    "CreateFont",
    "CreateFrame",
    "CTRL_KEY",
    "CUSTOM_CLASS_COLORS",
    "DELETE",
    "DISABLE",
    "FauxScrollFrame_GetOffset",
    "FauxScrollFrame_OnVerticalScroll",
    "FauxScrollFrame_Update",
    "floor",
    "format",
    "GameFontHighlight",
    "GameTooltip",
    "GetSpecialization",
    "GetSpecializationInfo",
    "GetSpellInfo",
    "KEY_BUTTON1",
    "KEY_BUTTON2",
    "KEY_BUTTON3",
    "LibStub",
    "max",
    "min",
    "NEW",
    "NONE",
    "OpacitySliderFrame",
    "OpenColorPicker",
    "oUF_AbuPlayer",
    "oUF_AbuPlayerCastbar",
    "oUF",
    "oUFAbu",
    "PanelTemplates_GetSelectedTab",
    "PanelTemplates_SetNumTabs",
    "PanelTemplates_SetTab",
    "PanelTemplates_Tab_OnClick",
    "PanelTemplates_TabResize",
    "PanelTemplates_UpdateTabs",
    "RAID_CLASS_COLORS",
    "RED_FONT_COLOR_CODE",
    "ReloadUI",
    "RESET",
    "SHIFT_KEY",
    "STATICPOPUP_NUMDIALOGS",
    "StaticPopup_Show",
    "string",
    "UIDropDownMenu_AddButton",
    "UIDropDownMenu_CreateInfo",
    "UIDROPDOWNMENU_MENU_VALUE",
    "UIDropDownMenu_SetSelectedValue",
    "UIDropDownMenu_SetText",
    "UIDropDownMenu_SetWidth",
    "UnitClass",
    "wipe",
    "WOW_PROJECT_CLASSIC",
    "WOW_PROJECT_ID",
}