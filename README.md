# Somodoro - Awesome WM Pomodoro Timer

A Pomodoro timer module built with Awesome WM's `gears` library, providing a clean event-driven interface.

## 📦 Installation

### Method 1: Direct Copy
Copy `somodoro.lua` to your Awesome WM config directory (usually `~/.config/awesome/`).

### Method 2: As a Component
```lua
-- In your rc.lua
local somodoro = require("somodoro")
```

## 🚀 Quick Start

```lua
-- Create a default 25-minute pomodoro timer
local timer = somodoro()

-- Create a custom duration timer
local timer = somodoro { minutes = 30 }

-- Start the timer
timer:begin()

-- Toggle pause/resume
timer:toggle()
```

## 📚 API Documentation

### Constructor

#### `somodoro { minutes = 25 }`
Creates a new Pomodoro timer instance.

**Parameters:**
- `minutes` (number, optional): Timer duration in minutes, defaults to 25
- `timeout` (number, optional): Timer precision in seconds, defaults to 1
- `on_finish` (function, optional): Callback function when timer completes

**Example:**
```lua
local timer = somodoro {
    minutes = 30,
    timeout = 0.5,  -- Update every 0.5 seconds
    on_finish = function()
        naughty.notify({ text = "Time's up! Take a break! 🍅" })
    end
}
```

### Instance Methods

#### `timer:begin()`
Starts the timer. Does nothing if already running.

```lua
timer:begin()
-- Emits signals: somodoro::begin, somodoro::update
```

#### `timer:pause()`
Pauses the timer.

```lua
timer:pause()
-- Emits signal: somodoro::pause
```

#### `timer:resume()`
Resumes a paused timer.

```lua
timer:resume()
-- Emits signal: somodoro::resume
```

#### `timer:toggle()`
Toggles between start/pause/resume states.

```lua
timer:toggle()
-- Emits signal: somodoro::toggle
-- Also emits based on state: somodoro::begin, somodoro::pause, or somodoro::resume
```

#### `timer:finish()`
Forcefully completes the timer (stops and sets progress to 100%).

```lua
timer:finish()
-- Emits signals: somodoro::finish, somodoro::update
```

#### `timer:reset()`
Resets the timer to its initial state.

```lua
timer:reset()
-- Emits signals: somodoro::reset, somodoro::update
```

#### `timer:get_progress()`
Gets the current progress (0.0 - 1.0).

```lua
local progress = timer:get_progress()
print(string.format("Progress: %.0f%%", progress * 100))
```

#### `timer:get_remaining()`
Gets the remaining time in seconds.

```lua
local remaining = timer:get_remaining()
local minutes = math.floor(remaining / 60)
local seconds = math.floor(remaining % 60)
print(string.format("Remaining: %d:%02d", minutes, seconds))
```

#### `timer:get_state()`
Gets the current timer state.

**Returns:**
- `"running"`: Timer is running
- `"paused"`: Timer is paused
- `"finished"`: Timer has completed

```lua
local state = timer:get_state()
if state == "running" then
    print("⏱️ Timer is running")
elseif state == "finished" then
    print("✅ Timer finished!")
end
```

### Signals

Somodoro is built on Awesome WM's signal system. You can easily listen to various events:

| Signal | Trigger |
|--------|---------|
| `somodoro::begin` | Timer starts |
| `somodoro::pause` | Timer pauses |
| `somodoro::resume` | Timer resumes |
| `somodoro::toggle` | Toggle is called (before any state change) |
| `somodoro::finish` | Timer completes |
| `somodoro::reset` | Timer resets |
| `somodoro::update` | Timer updates (every second by default) |

**Example:**
```lua
-- Listen to update events
timer:connect_signal("somodoro::update", function()
    local progress = timer:get_progress()
    local remaining = timer:get_remaining()
    -- Update your UI
    my_widget:set_text(string.format("%d:%02d", 
        math.floor(remaining / 60), 
        math.floor(remaining % 60)
    ))
    my_progressbar:set_value(progress)
end)

-- Listen to finish events
timer:connect_signal("somodoro::finish", function()
    naughty.notify({
        title = "Pomodoro",
        text = "Time's up! 🍅",
        timeout = 5
    })
    -- Play a sound
    awesome.spawn("paplay /usr/share/sounds/freedesktop/stereo/complete.oga")
end)
```

## 💡 Use Cases

### 1. Status Bar Integration
```lua
-- Create a text clock widget
local timer_widget = wibox.widget.textbox()
timer:connect_signal("somodoro::update", function()
    local remaining = timer:get_remaining()
    local minutes = math.floor(remaining / 60)
    local seconds = math.floor(remaining % 60)
    timer_widget:set_text(string.format("%02d:%02d", minutes, seconds))
end)

-- Click to toggle
timer_widget:buttons(gears.table.join(
    awful.button({}, 1, function() timer:toggle() end),
    awful.button({}, 3, function() timer:reset() end)
))
```

### 2. Progress Bar Display
```lua
local progressbar = wibox.widget.progressbar()
progressbar:set_max_value(1)

timer:connect_signal("somodoro::update", function()
    progressbar:set_value(timer:get_progress())
end)
```

### 3. Multiple Timers Management
```lua
-- Work timer
local work_timer = somodoro { minutes = 25 }
-- Break timer
local break_timer = somodoro { minutes = 5 }

work_timer:connect_signal("somodoro::finish", function()
    break_timer:begin()
end)
```

### 4. Color-coded Status
```lua
timer:connect_signal("somodoro::update", function()
    local state = timer:get_state()
    local color = ""
    if state == "running" then
        color = "#00ff00"  -- Green
    elseif state == "paused" then
        color = "#ffff00"  -- Yellow
    elseif state == "finished" then
        color = "#ff0000"  -- Red
    end
    timer_widget:set_color(color)
end)
```

## 🔧 Advanced Configuration

### Custom Update Frequency
```lua
-- Update every 0.1 seconds (more precise but more resource-intensive)
local timer = somodoro {
    minutes = 25,
    timeout = 0.1
}
```

### Chainable API
```lua
somodoro { minutes = 25 }
    :connect_signal("somodoro::finish", function() print("Done!") end)
    :begin()
```

### Custom Notification System
```lua
local timer = somodoro {
    minutes = 25,
    on_finish = function()
        -- Send notification
        naughty.notify({
            title = "🍅 Pomodoro Complete",
            text = "Great job! Take a 5-minute break.",
            timeout = 10
        })
        -- Run a command
        awesome.spawn("notify-send 'Pomodoro' 'Time to rest!'")
    end
}
```

## 🎯 Complete Example

Here's a complete working example you can add to your `rc.lua`:

```lua
-- Create the timer
local pomodoro = require("somodoro")
local my_timer = pomodoro { minutes = 25 }

-- Create widgets
local timer_text = wibox.widget.textbox()
local timer_progress = wibox.widget.progressbar()
timer_progress:set_max_value(1)
timer_progress:set_color("#4CAF50")

-- Update widgets
my_timer:connect_signal("somodoro::update", function()
    local remaining = my_timer:get_remaining()
    local mins = math.floor(remaining / 60)
    local secs = math.floor(remaining % 60)
    timer_text:set_text(string.format("%02d:%02d", mins, secs))
    timer_progress:set_value(my_timer:get_progress())
end)

-- Handle finish
my_timer:connect_signal("somodoro::finish", function()
    timer_text:set_color("#FF5722")
    naughty.notify({ text = "Pomodoro finished! 🎉" })
end)

-- Mouse controls
local timer_container = wibox.widget {
    {
        timer_text,
        timer_progress,
        layout = wibox.layout.fixed.vertical
    },
    buttons = gears.table.join(
        awful.button({}, 1, function() my_timer:toggle() end),
        awful.button({}, 3, function() my_timer:reset() end)
    ),
    widget = wibox.container.background
}

-- Add to your wibox
my_wibox:setup {
    layout = wibox.layout.align.horizontal,
    { -- Left
        layout = wibox.layout.fixed.horizontal,
        timer_container,
    },
    nil, -- Middle
    nil  -- Right
}
```

## 📝 License

MIT License - Free to use and modify.

## 🤝 Contributing

Issues and Pull Requests are welcome!

## 📖 Related Resources

- [Awesome WM Documentation](https://awesomewm.org/doc/)
- [Pomodoro Technique](https://francescocirillo.com/pages/pomodoro-technique)

---

**Stay focused and productive! 🍅✨**
