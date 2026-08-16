OneElevenTimer = {}

local ADDON_NAME = "111timer"
local UPDATE_INTERVAL = 0.10
local MIN_DURATION_MINUTES = 1
local MAX_DURATION_MINUTES = 180

local DEFAULTS = {
    durations = { 5 * 60, 10 * 60, 30 * 60 },
    defaultIndex = 2,
    showCountdown = true,
    positions = {},
}

local VALID_POINTS = {
    TOP = true,
    TOPLEFT = true,
    TOPRIGHT = true,
    LEFT = true,
    CENTER = true,
    RIGHT = true,
    BOTTOM = true,
    BOTTOMLEFT = true,
    BOTTOMRIGHT = true,
}

local state = {
    started = false,
    remaining = 0,
    expired = false,
    active = false,
    inCombat = false,
    accumulator = 0,
}

local eventFrame = CreateFrame("Frame")
local reminderFrame
local countdownFrame
local countdownText
local settingsFrame
local settingsDurationEdits = {}
local settingsDefaultChecks = {}
local settingsShowCountdown
local pendingDefaultIndex = DEFAULTS.defaultIndex

local function CopyTable(source)
    local result = {}
    local key, value

    for key, value in pairs(source) do
        if type(value) == "table" then
            result[key] = CopyTable(value)
        else
            result[key] = value
        end
    end

    return result
end

local function InitialiseDatabase()
    if type(OneElevenTimerDB) ~= "table" then
        OneElevenTimerDB = CopyTable(DEFAULTS)
        return
    end

    if type(OneElevenTimerDB.durations) ~= "table" then
        OneElevenTimerDB.durations = CopyTable(DEFAULTS.durations)
    end

    local index
    for index = 1, 3 do
        local duration = tonumber(OneElevenTimerDB.durations[index])
        if not duration or duration < MIN_DURATION_MINUTES * 60 or duration > MAX_DURATION_MINUTES * 60 then
            OneElevenTimerDB.durations[index] = DEFAULTS.durations[index]
        else
            OneElevenTimerDB.durations[index] = math.floor(duration + 0.5)
        end
    end

    local defaultIndex = tonumber(OneElevenTimerDB.defaultIndex)
    if not defaultIndex or defaultIndex < 1 or defaultIndex > 3 then
        OneElevenTimerDB.defaultIndex = DEFAULTS.defaultIndex
    else
        OneElevenTimerDB.defaultIndex = math.floor(defaultIndex)
    end

    if type(OneElevenTimerDB.showCountdown) ~= "boolean" then
        OneElevenTimerDB.showCountdown = DEFAULTS.showCountdown
    end

    if type(OneElevenTimerDB.positions) ~= "table" then
        OneElevenTimerDB.positions = {}
    end
end

local function SavePosition(frame, key)
    local point, _, relativePoint, x, y = frame:GetPoint(1)

    if not point or not VALID_POINTS[point] then
        return
    end

    if not relativePoint or not VALID_POINTS[relativePoint] then
        relativePoint = point
    end

    OneElevenTimerDB.positions[key] = {
        point = point,
        relativePoint = relativePoint,
        x = math.floor((x or 0) + 0.5),
        y = math.floor((y or 0) + 0.5),
    }
end

local function RestorePosition(frame, key, point, relativePoint, x, y)
    local saved = OneElevenTimerDB.positions[key]

    frame:ClearAllPoints()
    if saved
        and VALID_POINTS[saved.point]
        and VALID_POINTS[saved.relativePoint]
        and type(saved.x) == "number"
        and type(saved.y) == "number" then
        frame:SetPoint(saved.point, UIParent, saved.relativePoint, saved.x, saved.y)
    else
        frame:SetPoint(point, UIParent, relativePoint, x, y)
    end
end

local function MakeMovable(frame, positionKey)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SavePosition(self, positionKey)
    end)
end

local function FormatDuration(seconds)
    local minutes = math.floor((seconds / 60) + 0.5)

    if minutes == 60 then
        return "1 hour"
    elseif minutes > 60 and minutes % 60 == 0 then
        return string.format("%d hours", minutes / 60)
    end

    return minutes .. " min"
end

local function FormatCountdown(seconds)
    local total = math.max(0, math.ceil(seconds))
    local hours = math.floor(total / 3600)
    local minutes = math.floor((total % 3600) / 60)
    local remainingSeconds = total % 60

    if hours > 0 then
        return string.format("%d:%02d:%02d", hours, minutes, remainingSeconds)
    end

    return string.format("%d:%02d", minutes, remainingSeconds)
end

local function IsPlayerInCombat()
    return state.inCombat or (UnitAffectingCombat("player") and true or false)
end

local function RefreshCountdown()
    if not countdownFrame or not countdownText then
        return
    end

    countdownText:SetText(FormatCountdown(state.remaining))

    if state.expired then
        countdownText:SetTextColor(1.0, 0.65, 0.0)
    elseif state.active then
        countdownText:SetTextColor(1.0, 1.0, 1.0)
    else
        countdownText:SetTextColor(0.55, 0.55, 0.55)
    end
end

local function SetCountdownVisibility()
    if not countdownFrame or not OneElevenTimerDB then
        return
    end

    if OneElevenTimerDB.showCountdown then
        countdownFrame:Show()
    else
        countdownFrame:Hide()
    end
end

local function UpdateReminderButtons()
    if not reminderFrame or not reminderFrame.durationButtons then
        return
    end

    local index
    for index = 1, 3 do
        reminderFrame.durationButtons[index]:SetText(FormatDuration(OneElevenTimerDB.durations[index]))
    end
end

local function ShowReminder()
    if IsPlayerInCombat() then
        return
    end

    UpdateReminderButtons()
    reminderFrame:Show()
end

local function StartTimer(duration)
    state.remaining = duration
    state.expired = false
    state.active = false
    state.accumulator = 0
    reminderFrame:Hide()
    RefreshCountdown()
end

local function StartDefaultTimer()
    StartTimer(OneElevenTimerDB.durations[OneElevenTimerDB.defaultIndex])
end

local function ExpireTimer()
    state.remaining = 0
    state.expired = true
    state.active = false
    RefreshCountdown()
    ShowReminder()
end

local function RefreshSettings()
    if not settingsFrame then
        return
    end

    local index
    for index = 1, 3 do
        settingsDurationEdits[index]:SetText(math.floor((OneElevenTimerDB.durations[index] / 60) + 0.5))
    end

    pendingDefaultIndex = OneElevenTimerDB.defaultIndex
    for index = 1, 3 do
        settingsDefaultChecks[index]:SetChecked(index == pendingDefaultIndex)
    end

    settingsShowCountdown:SetChecked(OneElevenTimerDB.showCountdown)
end

local function ShowSettings()
    RefreshSettings()
    settingsFrame:Show()
end

local function ToggleSettings()
    if settingsFrame:IsShown() then
        settingsFrame:Hide()
    else
        ShowSettings()
    end
end

local function ApplySettings()
    local newDurations = {}
    local index

    for index = 1, 3 do
        local minutes = tonumber(settingsDurationEdits[index]:GetText())
        if not minutes or minutes < MIN_DURATION_MINUTES or minutes > MAX_DURATION_MINUTES then
            DEFAULT_CHAT_FRAME:AddMessage(
                "|cffffcc00111 Timer:|r durations must be whole minutes from "
                    .. MIN_DURATION_MINUTES .. " to " .. MAX_DURATION_MINUTES .. "."
            )
            settingsDurationEdits[index]:SetFocus()
            settingsDurationEdits[index]:HighlightText()
            return
        end

        minutes = math.floor(minutes + 0.5)
        newDurations[index] = minutes * 60
    end

    OneElevenTimerDB.durations = newDurations
    OneElevenTimerDB.defaultIndex = pendingDefaultIndex
    OneElevenTimerDB.showCountdown = settingsShowCountdown:GetChecked() and true or false

    UpdateReminderButtons()
    SetCountdownVisibility()
    settingsFrame:Hide()
    DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00111 Timer:|r settings saved.")
end

local function ResetWindowPositions()
    OneElevenTimerDB.positions = {}
    RestorePosition(reminderFrame, "reminder", "CENTER", "CENTER", 0, 100)
    RestorePosition(countdownFrame, "countdown", "TOP", "TOP", 0, -80)
    RestorePosition(settingsFrame, "settings", "CENTER", "CENTER", 0, 0)
end

local function AddTooltip(frame, title, body)
    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(title, 1, 1, 1)
        if body then
            GameTooltip:AddLine(body, 0.8, 0.8, 0.8, true)
        end
        GameTooltip:Show()
    end)
    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

local function CreateReminderFrame()
    reminderFrame = CreateFrame("Frame", "OneElevenTimerReminderFrame", UIParent)
    reminderFrame:SetWidth(360)
    reminderFrame:SetHeight(150)
    reminderFrame:SetFrameStrata("DIALOG")
    reminderFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
    MakeMovable(reminderFrame, "reminder")
    RestorePosition(reminderFrame, "reminder", "CENTER", "CENTER", 0, 100)

    local title = reminderFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -22)
    title:SetText("Check tasks")

    local instruction = reminderFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    instruction:SetPoint("TOP", title, "BOTTOM", 0, -10)
    instruction:SetText("Choose when you want the next reminder.")

    local cog = CreateFrame("Button", nil, reminderFrame)
    cog:SetWidth(28)
    cog:SetHeight(28)
    cog:SetPoint("TOPRIGHT", -13, -13)
    cog:SetNormalTexture("Interface\\Icons\\INV_Misc_Gear_01")
    cog:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    cog:SetScript("OnClick", ToggleSettings)
    AddTooltip(cog, "111 Timer settings", "Configure durations, the default timer and countdown display.")

    reminderFrame.durationButtons = {}
    local index
    for index = 1, 3 do
        local buttonIndex = index
        local button = CreateFrame("Button", nil, reminderFrame, "UIPanelButtonTemplate")
        button:SetWidth(96)
        button:SetHeight(28)
        button:SetPoint("BOTTOMLEFT", 26 + ((index - 1) * 105), 22)
        button:SetScript("OnClick", function()
            StartTimer(OneElevenTimerDB.durations[buttonIndex])
        end)
        reminderFrame.durationButtons[index] = button
    end

    reminderFrame:Hide()
end

local function CreateCountdownFrame()
    countdownFrame = CreateFrame("Frame", "OneElevenTimerCountdownFrame", UIParent)
    countdownFrame:SetWidth(94)
    countdownFrame:SetHeight(34)
    countdownFrame:SetFrameStrata("MEDIUM")
    countdownFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    countdownFrame:SetBackdropColor(0, 0, 0, 0.75)
    MakeMovable(countdownFrame, "countdown")
    RestorePosition(countdownFrame, "countdown", "TOP", "TOP", 0, -80)

    countdownText = countdownFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    countdownText:SetPoint("CENTER", 0, 0)
    countdownText:SetText("10:00")

    countdownFrame:SetScript("OnMouseUp", function(_, button)
        if button == "RightButton" then
            ToggleSettings()
        end
    end)
    AddTooltip(
        countdownFrame,
        "111 Timer",
        "White: counting. Grey: idle. Orange: reminder due. Drag to move; right-click for settings."
    )
end

local function CreateSettingsFrame()
    settingsFrame = CreateFrame("Frame", "OneElevenTimerSettingsFrame", UIParent)
    settingsFrame:SetWidth(390)
    settingsFrame:SetHeight(310)
    settingsFrame:SetFrameStrata("DIALOG")
    settingsFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
    MakeMovable(settingsFrame, "settings")
    RestorePosition(settingsFrame, "settings", "CENTER", "CENTER", 0, 0)

    local title = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -20)
    title:SetText("111 Timer Settings")

    local close = CreateFrame("Button", nil, settingsFrame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -5, -5)

    local description = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    description:SetPoint("TOPLEFT", 28, -51)
    description:SetWidth(330)
    description:SetJustifyH("LEFT")
    description:SetText("The timer counts while moving or in combat and pauses while idle.")

    local durationHeading = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    durationHeading:SetPoint("TOPLEFT", 32, -84)
    durationHeading:SetText("Button duration (minutes)")

    local defaultHeading = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    defaultHeading:SetPoint("TOPRIGHT", -41, -84)
    defaultHeading:SetText("Default")

    local index
    for index = 1, 3 do
        local checkIndexValue = index
        local rowY = -105 - ((index - 1) * 42)

        local label = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        label:SetPoint("TOPLEFT", 34, rowY - 5)
        label:SetText("Button " .. index)

        local edit = CreateFrame("EditBox", nil, settingsFrame, "InputBoxTemplate")
        edit:SetWidth(70)
        edit:SetHeight(24)
        edit:SetPoint("TOPLEFT", 122, rowY)
        edit:SetAutoFocus(false)
        edit:SetNumeric(true)
        edit:SetMaxLetters(3)
        settingsDurationEdits[index] = edit

        local check = CreateFrame("CheckButton", nil, settingsFrame, "UICheckButtonTemplate")
        check:SetWidth(26)
        check:SetHeight(26)
        check:SetPoint("TOPRIGHT", -58, rowY + 1)
        check:SetScript("OnClick", function()
            pendingDefaultIndex = checkIndexValue
            local checkIndex
            for checkIndex = 1, 3 do
                settingsDefaultChecks[checkIndex]:SetChecked(checkIndex == pendingDefaultIndex)
            end
        end)
        settingsDefaultChecks[index] = check
    end

    settingsShowCountdown = CreateFrame("CheckButton", nil, settingsFrame, "UICheckButtonTemplate")
    settingsShowCountdown:SetWidth(26)
    settingsShowCountdown:SetHeight(26)
    settingsShowCountdown:SetPoint("TOPLEFT", 28, -232)

    local showLabel = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    showLabel:SetPoint("LEFT", settingsShowCountdown, "RIGHT", 4, 0)
    showLabel:SetText("Show draggable countdown")

    local resetPositions = CreateFrame("Button", nil, settingsFrame, "UIPanelButtonTemplate")
    resetPositions:SetWidth(132)
    resetPositions:SetHeight(24)
    resetPositions:SetPoint("BOTTOMLEFT", 28, 24)
    resetPositions:SetText("Reset positions")
    resetPositions:SetScript("OnClick", ResetWindowPositions)

    local apply = CreateFrame("Button", nil, settingsFrame, "UIPanelButtonTemplate")
    apply:SetWidth(100)
    apply:SetHeight(24)
    apply:SetPoint("BOTTOMRIGHT", -28, 24)
    apply:SetText("Apply")
    apply:SetScript("OnClick", ApplySettings)

    settingsFrame:Hide()
end

local function CreateUserInterface()
    CreateReminderFrame()
    CreateCountdownFrame()
    CreateSettingsFrame()
    UpdateReminderButtons()
    SetCountdownVisibility()
end

local function OnEvent(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 ~= ADDON_NAME then
            return
        end

        InitialiseDatabase()
        CreateUserInterface()
    elseif event == "PLAYER_LOGIN" then
        state.started = true
        state.inCombat = UnitAffectingCombat("player") and true or false
        StartDefaultTimer()
        SetCountdownVisibility()
    elseif event == "PLAYER_REGEN_DISABLED" then
        state.inCombat = true
        if state.expired and reminderFrame:IsShown() then
            reminderFrame:Hide()
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        state.inCombat = false
        if state.expired then
            ShowReminder()
        end
    end
end

local function OnUpdate(_, elapsed)
    if not state.started or state.expired then
        return
    end

    state.accumulator = state.accumulator + elapsed
    if state.accumulator < UPDATE_INTERVAL then
        return
    end

    local step = state.accumulator
    state.accumulator = 0

    local moving = (GetUnitSpeed("player") or 0) > 0
    local inCombat = IsPlayerInCombat()

    state.active = moving or inCombat

    if state.active then
        state.remaining = state.remaining - step
        if state.remaining <= 0 then
            ExpireTimer()
            return
        end
    end

    RefreshCountdown()
end

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:SetScript("OnEvent", OnEvent)
eventFrame:SetScript("OnUpdate", OnUpdate)

SLASH_ONEELEVENTIMER1 = "/111timer"
SlashCmdList.ONEELEVENTIMER = function()
    ToggleSettings()
end
