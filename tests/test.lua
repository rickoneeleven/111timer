math.mod = math.mod or math.fmod

local frames = {}
local namedFrames = {}
local now = 0
local playerSpeed = 0
local playerInCombat = false

local function NewObject(name)
    local object = {
        name = name,
        shown = true,
        scripts = {},
        fontStrings = {},
        point = { "CENTER", nil, "CENTER", 0, 0 },
    }

    function object:SetWidth(value) self.width = value end
    function object:SetHeight(value) self.height = value end
    function object:SetFrameStrata(value) self.strata = value end
    function object:SetBackdrop(value) self.backdrop = value end
    function object:SetBackdropColor(...) self.backdropColour = { ... } end
    function object:SetMovable(value) self.movable = value end
    function object:EnableMouse(value) self.mouseEnabled = value end
    function object:SetClampedToScreen(value) self.clamped = value end
    function object:RegisterForDrag(...) self.dragButtons = { ... } end
    function object:RegisterEvent(value) self.events = self.events or {}; self.events[value] = true end
    function object:SetScript(script, callback) self.scripts[script] = callback end
    function object:StartMoving() self.moving = true end
    function object:StopMovingOrSizing() self.moving = false end
    function object:ClearAllPoints() self.point = nil end
    function object:SetPoint(point, relativeTo, relativePoint, x, y)
        if type(relativeTo) == "number" then
            self.point = { point, UIParent, point, relativeTo, relativePoint }
        else
            self.point = { point, relativeTo or UIParent, relativePoint or point, x or 0, y or 0 }
        end
    end
    function object:GetPoint() return unpack(self.point) end
    function object:Show() self.shown = true end
    function object:Hide() self.shown = false end
    function object:IsShown() return self.shown end
    function object:SetText(value) self.text = tostring(value) end
    function object:GetText() return self.text or "" end
    function object:SetTextColor(...) self.textColour = { ... } end
    function object:SetJustifyH(value) self.justify = value end
    function object:SetNormalTexture(value) self.normalTexture = value end
    function object:SetHighlightTexture(...) self.highlightTexture = { ... } end
    function object:SetAutoFocus(value) self.autoFocus = value end
    function object:SetNumeric(value) self.numeric = value end
    function object:SetMaxLetters(value) self.maxLetters = value end
    function object:SetFocus() self.focused = true end
    function object:HighlightText() self.highlighted = true end
    function object:SetChecked(value) self.checked = value and true or false end
    function object:GetChecked() return self.checked end
    function object:CreateFontString(fontName)
        local fontString = NewObject(fontName)
        table.insert(self.fontStrings, fontString)
        return fontString
    end

    return object
end

UIParent = NewObject("UIParent")

function CreateFrame(kind, name, parent, template)
    local frame = NewObject(name)
    frame.kind = kind
    frame.parent = parent
    frame.template = template
    table.insert(frames, frame)
    if name then
        namedFrames[name] = frame
        _G[name] = frame
    end
    return frame
end

function GetTime() return now end
function GetUnitSpeed() return playerSpeed end
function UnitAffectingCombat() return playerInCombat end

GameTooltip = {
    SetOwner = function() end,
    SetText = function() end,
    AddLine = function() end,
    Show = function() end,
    Hide = function() end,
}

DEFAULT_CHAT_FRAME = {
    messages = {},
    AddMessage = function(self, message) table.insert(self.messages, message) end,
}

SlashCmdList = {}

local function AssertEqual(actual, expected, label)
    if actual ~= expected then
        error(label .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
    end
end

local function Advance(eventFrame, seconds, speed)
    playerSpeed = speed or 0
    local index
    for index = 1, seconds do
        now = now + 1
        eventFrame.scripts.OnUpdate(eventFrame, 1)
    end
end

dofile("111timer.lua")

local eventFrame = frames[1]
eventFrame.scripts.OnEvent(eventFrame, "ADDON_LOADED", "111timer")

local reminder = namedFrames.OneElevenTimerReminderFrame
local countdown = namedFrames.OneElevenTimerCountdownFrame
local settings = namedFrames.OneElevenTimerSettingsFrame
local countdownValue = countdown.fontStrings[1]

eventFrame.scripts.OnEvent(eventFrame, "PLAYER_LOGIN")

AssertEqual(OneElevenTimerDB.durations[1], 300, "first default duration")
AssertEqual(OneElevenTimerDB.durations[2], 600, "second default duration")
AssertEqual(OneElevenTimerDB.durations[3], 1800, "third default duration")
AssertEqual(OneElevenTimerDB.defaultIndex, 2, "default duration index")
AssertEqual(countdownValue.text, "10:00", "fresh login countdown")
AssertEqual(reminder.shown, false, "fresh login reminder visibility")

Advance(eventFrame, 20, 0)
AssertEqual(countdownValue.text, "10:00", "idle time does not count")

Advance(eventFrame, 5, 7)
AssertEqual(countdownValue.text, "9:55", "movement counts")

Advance(eventFrame, 15, 0)
AssertEqual(countdownValue.text, "9:40", "activity tail counts")
Advance(eventFrame, 5, 0)
AssertEqual(countdownValue.text, "9:40", "timer pauses after activity tail")

OneElevenTimerDB.durations[2] = 60
eventFrame.scripts.OnEvent(eventFrame, "PLAYER_LOGIN")
Advance(eventFrame, 61, 7)
AssertEqual(countdownValue.text, "0:00", "timer reaches zero")
AssertEqual(reminder.shown, true, "out-of-combat expiry shows reminder")

playerInCombat = true
eventFrame.scripts.OnEvent(eventFrame, "PLAYER_REGEN_DISABLED")
AssertEqual(reminder.shown, false, "entering combat hides visible reminder")
playerInCombat = false
eventFrame.scripts.OnEvent(eventFrame, "PLAYER_REGEN_ENABLED")
AssertEqual(reminder.shown, true, "hidden reminder returns after combat")

reminder.durationButtons[3].scripts.OnClick()
AssertEqual(countdownValue.text, "30:00", "duration button starts selected timer")
AssertEqual(reminder.shown, false, "duration button dismisses reminder")

eventFrame.scripts.OnEvent(eventFrame, "PLAYER_LOGIN")
playerInCombat = true
eventFrame.scripts.OnEvent(eventFrame, "PLAYER_REGEN_DISABLED")
Advance(eventFrame, 61, 0)
AssertEqual(reminder.shown, false, "combat expiry queues reminder")
playerInCombat = false
eventFrame.scripts.OnEvent(eventFrame, "PLAYER_REGEN_ENABLED")
AssertEqual(reminder.shown, true, "queued reminder appears after combat")

SlashCmdList.ONEELEVENTIMER()
AssertEqual(settings.shown, true, "slash command opens settings")

local settingsEdits = {}
local settingsChecks = {}
local applyButton
local _, frame
for _, frame in ipairs(frames) do
    if frame.parent == settings and frame.kind == "EditBox" then
        table.insert(settingsEdits, frame)
    elseif frame.parent == settings and frame.kind == "CheckButton" then
        table.insert(settingsChecks, frame)
    elseif frame.parent == settings and frame.text == "Apply" then
        applyButton = frame
    end
end

settingsEdits[1]:SetText("6")
settingsEdits[2]:SetText("12")
settingsEdits[3]:SetText("25")
settingsChecks[1].scripts.OnClick()
settingsChecks[4]:SetChecked(false)
applyButton.scripts.OnClick()

AssertEqual(OneElevenTimerDB.durations[1], 360, "settings save first duration")
AssertEqual(OneElevenTimerDB.durations[2], 720, "settings save second duration")
AssertEqual(OneElevenTimerDB.durations[3], 1500, "settings save third duration")
AssertEqual(OneElevenTimerDB.defaultIndex, 1, "settings save nominated default")
AssertEqual(countdown.shown, false, "settings hide optional countdown")

eventFrame.scripts.OnEvent(eventFrame, "PLAYER_LOGIN")
AssertEqual(countdownValue.text, "6:00", "login uses configured default")

print("111timer behavioural tests passed")
