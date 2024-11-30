local Functions = {}
local Vector2new = Vector2.new

Functions.lerp = function(Start, Goal, Time)
    return Start + (Goal - Start) * Time
end

local drawnew = Drawing.new
function Functions.create(type, props)
    local drawing = drawnew(type)

    for prop, value in props do
        setrenderproperty(drawing, prop, value)
    end

    return drawing
end

local EventLog = {}
local EventLogs = {}

EventLog.GlobalSize = 12
EventLog.Position = Vector2new(0, 36 * 2);
EventLog.Padding = 4

type EventLog = {
    --Priority: number;
    Duration: number;
    ClockAt: number;
    Text: string;
    Object: any?;
    Destroy: () -> ()
}

local function convertTransparency(transparency: number): number
    return math.clamp(1 - transparency, 0, 1)
end

twait = task.wait;
tspawn = task.spawn;

local White = Color3.new(1, 1, 1)
local Grey = Color3.new(.2, .2, .2)
local Black = Color3.new()
function EventLog:Log(Text, Duration)
    local Priority = #EventLogs + 1
    local Log = {}

    Log.Started = false
    Log.Priority = Priority
    Log.ClockAt = tick()
    Log.Duration = Duration
    Log.Text = Text
    Log.Object = Functions.create('Text', {
        ['Font'] = 2;
        ['Text'] = Text;
        ['Size'] = self.GlobalSize or 14;
        ['Color'] = White;
        ['Outline'] = true;
        ['OutlineColor'] = Black;
        ['Position'] = EventLog.Position + Vector2new(0, (EventLog.GlobalSize + 2) * Priority);
        ['Visible'] = true
    })

    local BoundOffset = Vector2new(5, 5)
    Log.Background = Functions.create('Square', {
        ['Size'] = Log.Object.TextBounds + BoundOffset;
        ['Color'] = Grey;
        ['Filled'] = true;
        ['ZIndex'] = -1;
        ['Visible'] = false;
    })

    Log.Background.Position = Log.Object.TextBounds + (BoundOffset / 2)

    tspawn(function()
        for time = 1, 20 do
            Log.Object.Transparency = time / 10;
            Log.Background.Transparency = (time / 10)
            twait()
        end
    end)

    function Log:Remove()
        tspawn(function()
            self.Destroyed = true
            for time = 1, 40 do
                Log.Object.Transparency = convertTransparency(time / 40)
                Log.Background.Transparency = convertTransparency(time / 40)
                twait()
            end
            EventLogs[Priority] = nil
            Log.Object:Remove()
            Log.Background:Remove()
            setmetatable(self, nil)
        end)
    end

    EventLogs[Priority] = Log
    return Log
end

local NerdSentences = { 'im such a skid 😜', 'math is hard 🧮', 'i speak klingon 👽', 'i wear socks with sandals 👣', 'my pocket 😎 protector brings all the nerds to the yard', 'phd in quantum mechanics from hogwarts 🎓', 'im a nerd and im proud 🤓👊', 'i mainframe 💻 for fun', 'i dream in binary 💭', 'im fluent in c++ 💻', 'my code is poetry 📝', }
local Emojis = { [1] = '😊', [2] = '😢', [3] = '😂', [4] = '❤️', [5] = '👍', [6] = '👎', [7] = '🔥', [8] = '👏', [9] = '🚀', [10] = '🤔', [11] = '😮', [12] = '😎', [13] = '😍', [14] = '😡', [15] = '👻', [16] = '👽', [17] = '🤖', [18] = '🦄', [19] = '😺', [20] = '🐶', [21] = '🐠', [22] = '🍕', [23] = '🌮', [24] = '🍰', [25] = '☕', [26] = '🍺', [27] = '🍷', [28] = '🍹', [29] = '🎵', [30] = '🎬', [31] = '🎮', [32] = '⚽', [33] = '🏀', [34] = '⚾', [35] = '🏈', [36] = '🎾', [37] = '⛳', [38] = '🏄', [39] = '⛷️', [40] = '🏂', [41] = '🚴', [42] = '🏊', [43] = '🏃', [44] = '🥾', };

local function RandomValue(Table)
    return Table[math.random(1, #Table)]
end;

game:GetService('RunService').RenderStepped:Connect(function()
    local ETC = 0
    local GlobalSize = EventLog.GlobalSize;
    local Padding = EventLog.Padding;
    local NotificationPosition = EventLog.Position;
    for Index, Log: EventLog in next, EventLogs do
        local Object = Log.Object
        local Background = Log.Background;
        if not Log.Started then
            Object.Position = NotificationPosition + Vector2new(-(Object.TextBounds.X - 2), (GlobalSize + Padding) * ETC);
            Background = Object.Position;
            Log.Started = true
        end

        ETC += 1
        Object.Position = Functions.lerp(Object.Position, NotificationPosition + Vector2new(20, (GlobalSize + Padding) * ETC), .1);
        pcall(function()
            Background.Position = Object.Position;
        end)
        if tick() - Log.ClockAt > Log.Duration then
            if not Log.Destroyed then
                Log:Remove()
            end
        end
    end
end)

return EventLog, EventLogs;
