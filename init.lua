local object = require "gears.object"
local timer = require "gears.timer"

local somodoro = { mt = {} }

function somodoro:begin()
	if not self.timer.started then
		self.elapsed = 0
		self.timer:start()
		self:emit_signal("somodoro::begin")
		self:emit_signal("somodoro::update")
	end
end

function somodoro:pause()
	self.timer:stop()
	self:emit_signal("somodoro::pause")
end

function somodoro:resume()
	self.timer:start()
	self:emit_signal("somodoro::resume")
end

function somodoro:toggle()
	self:emit_signal("somodoro::toggle")
	if self.timer.started then
		self:pause()
	elseif self.elapsed == 0 or self.elapsed >= self.seconds then
		self:begin()
	else
		self:resume()
	end
end

function somodoro:finish()
	if self.elapsed ~= self.seconds then
		self.timer:stop()
		self.elapsed = self.seconds
		self:emit_signal("somodoro::finish")
	end
end

local function new(args)
	args = args or {
	}
	args.minutes = args.minutes or 25
	local ret = object {
		class = somodoro,
	}
	ret.seconds = args.minutes * 60
	ret.elapsed = 0
	ret.timer = timer {
		timeout = 1,
		callback = function()
			ret.elapsed = ret.elapsed + 1;
			if ret.elapsed >= ret.seconds then
				ret:finish()
			end
			ret:emit_signal("somodoro::update")
		end
	}
	return ret
end

function somodoro.mt:__call(...)
	return new(...)
end

return setmetatable(somodoro, somodoro.mt)
