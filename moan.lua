--
-- möan
--
-- Copyright (c) 2019 Mathew Mariani
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this software and associated documentation files (the "Software"), to deal in
-- the Software without restriction, including without limitation the rights to
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do
-- so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--

local moan = { _version = "0.2.0" }
moan.__index = moan

moan.scribbles = {}
moan.easing = function(p) return p end
moan.font = nil
moan.canvas = love.graphics.newCanvas(
	love.graphics.getWidth(),
	95)

local scribble = {}
scribble.__index = scribble

function scribble.new(message, t)
	local self = setmetatable({}, scribble)
	self.message = message
	self.idx = 0
	self.rate = t > 0 and 1 / t or 0
	self.progress = t > 0 and 0 or 1
	self._delay = 0
	self.length = 0
	if type(message) == "table" then
		for k, v in pairs(message) do
			if type(v) == "string" then
				self.length = self.length + #v
			end
		end
	else
		self.length = #message
	end
	return self
end

function scribble:delay(t)
	if type(t) ~= "number" then
		error("bad delay time; expected a number")
	end
	self._delay = t
	return self
end

function scribble:skippable(b)
	if type(t) ~= "boolean" then
		error("bad skippable flag; expected a boolean")
	end
	self.skippable = b
	return self
end

function scribble:onstart(func)
	self._onstart = func
	return self
end

function scribble:onupdate(func)
	self._onupdate = func
	return self
end

function scribble:oncomplete(func)
	self._oncomplete = func
	return self
end

function moan:update(dt)
	if #self <= 0 then return end
	local t = self[1]
	if t._delay > 0 then
		t._delay = t._delay - dt
		return
	end
	if t._onstart then
		t._onstart()
		t._onstart = nil
	end
	t.progress = t.progress + t.rate * dt
	local p = t.progress
	local x = p >= 1 and 1 or moan.easing(p)
	t.idx = math.floor(x * t.length)
	if t._onupdate then t._onupdate() end
	if p >= 1 then
		if t._oncomplete then
			t._oncomplete()
			t._oncomplete = nil
		end
	end
end

function moan:draw()
	if #self <= 0 then return end

	-- cache graphics state
	local old = {
		blend = love.graphics.getBlendMode(),
		canvas = love.graphics.getCanvas(),
		font = love.graphics.getFont(),
		mask = love.graphics.getColorMask(),
		scissor = love.graphics.getScissor(),
		shader = love.graphics.getShader(),
		wireframe = love.graphics.isWireframe()
	}

	-- reset the current graphics state
	love.graphics.reset()

	moan.canvas:renderTo(function()
		love.graphics.setDefaultFilter("nearest", "nearest")
		love.graphics.setFont(moan.font)
		love.graphics.clear(0.0, 0.0, 0.0, 0.0)

		local t = self[1]
		local text = nil
		if type(t.message) == "table" then
			text = {}
			for k, v in pairs(t.message) do
				if type(v) == "string" then
					local str = string.sub(v, 1, t.idx)
					table.insert(text, str)
					t.idx = t.idx - #str
				else
					table.insert(text, v)
				end
			end
		else
			text = string.sub(t.message, 1, t.idx)
		end

		local w, h = moan.canvas:getDimensions()
		local transform = love.math.newTransform(15, 10)
		local limit = w - 25
		local align = "left"

		-- draw text box
		love.graphics.setColor(0.0, 0.0, 0.0, 0.75)
		love.graphics.rectangle("fill", 5, 5, w - 10, 85, 2)
		love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
		love.graphics.printf(text, transform, limit, align)
	end)

	local w, h = love.graphics.getDimensions()
	love.graphics.draw(moan.canvas, 0, h - moan.canvas:getHeight())

	-- restore cached graphics state
	if old.blend then love.graphics.setBlendMode(old.blend) end
	if old.canvas then love.graphics.setCanvas(old.canvas) end
	if old.font then love.graphics.setFont(old.font) end
	if old.mask then love.graphics.setColorMask(old.mas) end
	if old.scissor then love.graphics.setScissor(old.scissor) end
	if old.shader then love.graphics.setShader(old.shader) end
	if old.wireframe then love.graphics.setWireframe(old.wireframe) end
end

function moan:say(message, t)
	return moan.add(self, scribble.new(message, t))
end

function moan:add(s)
	table.insert(self, s)
	return s
end

function moan:remove(idx)
	if type(idx) == "number" then
		self[idx] = self[#self]
		return table.remove(self)
	end
end

function moan:skip()
	if #self <= 0 then return end
	local t = self[1]
	if t.skippable then
		t.progress = 1
	end
end

function moan:pass()
	if #self <= 0 then return end
	local t = self[1]
	if t.progress >= 1 then
		moan.remove(self, 1)
	end
end

function moan:setFont(font)
	moan.font = font
end

local api = {
	say = function(...) return moan.say(moan.scribbles, ...) end,
	remove = function(...) return moan.remove(moan.scribbles, ...) end,
	skip = function(...) return moan.skip(moan.scribbles, ...) end,
	pass = function(...) return moan.pass(moan.scribbles, ...) end,
	update = function(...) return moan.update(moan.scribbles, ...) end,
	draw = function(...) return moan.draw(moan.scribbles, ...) end,
	setFont = function(...) return moan.setFont(moan.scribbles, ...) end
}

setmetatable(api, moan)

return api
