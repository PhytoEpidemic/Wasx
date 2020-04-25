
local Wasx = {
	_VERSION     = 'Wasx v1.0.0',
	_DESCRIPTION = 'A very versatile input manager for LÖVE',
	_URL         = 'https://github.com/PhytoEpidemic/Wasx',
	_LICENSE     = [[
MIT LICENSE

Copyright (c) 2020 Cherubim, Lucas Alshouse

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]],
	pathToThisFile = (...):gsub("%.", "/") .. ".lua",
}

Wasx.mt = {
	__eq = function(o1, o2) 
		for key,item in ipairs(o1) do
			if not o2[key] then
				return false
			elseif not o2[key] == item then
				return false
			end
		end
		for key,item in ipairs(o2) do
			if not o1[key] then
				return false
			elseif not o1[key] == item then
				return false
			end
		end
		return true
	end,
	__tostring = function(o)
		local st = ""
		for _,item in ipairs(o) do
			st = st..item
		end
		return st
	end,
}

local sq2 = math.sqrt(2)

Wasx.vec2mt = {
	__add = function(o1, o2)
		local new = {x = 0, y = 0}
		local length = math.abs(o1.x+o2.x)+math.abs(o1.y+o2.y)
		if length >= 1 then
			new.x = new.x+(o1.x+o2.x)/length*sq2
			new.y = new.y+(o1.y+o2.y)/length*sq2
		else
			new.x = new.x+(o1.x+o2.x)*length*sq2
			new.y = new.y+(o1.y+o2.y)*length*sq2
		end
		return new
	end,
}

Wasx.keyMapMT = {
	__tostring = function(t)
		local cart     
		local autoref  
		local function isemptytable(t) return next(t) == nil end
		local function basicSerialize (o)
			local so = tostring(o)
			if type(o) == "number" or type(o) == "boolean" then
				return so
			else
				return string.format("%q", so)
			end
		end
		local function addtocart (value, name, indent, saved, field)
			indent = indent or ""
			saved = saved or {}
			field = field or name
			cart = cart .. indent .. field
			if type(value) ~= "table" then
				cart = cart .. " = " .. basicSerialize(value) .. ";\n"
			else
				if saved[value] then
					cart = cart .. " = {}; -- " .. saved[value] 
					.. " (self reference)\n"
					autoref = autoref ..  name .. " = " .. saved[value] .. ";\n"
				else
					saved[value] = name
					if isemptytable(value) then
						cart = cart .. " = {};\n"
					else
						cart = cart .. " = {\n"
						for k, v in pairs(value) do
							k = basicSerialize(k)
							local fname = string.format("%s[%s]", name, k)
							field = string.format("[%s]", k)
							addtocart(v, fname, indent .. "   ", saved, field)
						end
						cart = cart .. indent .. "};\n"
					end
				end
			end
		end
		name = "Mappings"
		cart, autoref = "", ""
		addtocart(t, name, indent)
		return cart .. autoref
	end,
}

function Wasx.new(id)
	
	local self = {}
	
	self.data = {}
	
	self.toggles = {}
	
	self.toggleSet = {}
	
	self.held = {}
	
	self.keyMappings = {
		data = {},
		buttons = {},
		angle = {left = {}, right = {}},
		analog = {trigger = {left = {}, right = {}}, stick = {left = {}, right = {}}},
	}
	
	setmetatable(self.keyMappings, Wasx.keyMapMT)
	
	self.id = id
	
	self.useGamepad = false
	
	local joysticks = love.joystick.getJoysticks()
	
	if joysticks[id] then
		self.joystick = joysticks[id]
	else
		self.joystick = false
	end
	
	for key,item in pairs(Wasx) do
		if not self[key] then
			self[key] = item
		end
	end
	
	self.__index = self
	
	return self
end

function Wasx:isConnected()
	if self.joystick then
		if self.joystick:isConnected( ) then
			return true
		else
			self.joystick = false
			return false
		end
	else
		local joysticks = love.joystick.getJoysticks()
		if joysticks[self.id] then
			self.joystick = joysticks[id]
			return true
		else
			return false
		end
	end
end

function Wasx:mapKey(buttonIndex,keys)
	if type(buttonIndex) ~= "string" then
		return error("Bad argument #1. Expected string, got: "..type(buttonIndex))
	end
	if type(keys) ~= "table" then
		return error("Bad argument #2. Expected table, got: "..type(keys))
	end
	local pass = false
	for _,key in ipairs(keys) do
		pass = true
	end
	if not pass then
		return error("Bad argument #4. Must be a numbered table.")
	end
	for index,key in ipairs(keys) do
		if type(key) ~= "string" then
			return error("Bad argument #4. Must be a numbered table filled with only strings. Index: "..tostring(index).." Expected string, got: "..type(key))
		end
	end
	self.keyMappings["buttons"][buttonIndex] = keys
	
end

function Wasx:mapKeyAnalog(TorS,side,output,keys)
	if type(TorS) ~= "string" then
		return error("Bad argument #1. Expected string, got: "..type(TorS))
	end
	if TorS ~= "trigger" and TorS ~= "stick" then
		return error([[Bad argument #1. Expected "trigger" or "stick", got: "]]..TorS..[["]])
	end
	if type(side) ~= "string" then
		return error("Bad argument #2. Expected string, got: "..type(side))
	end
	if TorS == "stick" then
		if type(output) ~= "table" then
			return error("Bad argument #3. Expected table, got: "..type(output))
		end
		if not output["x"] or not output["x"] then
			return error([[Bad argument #3. Expected table with indexes "x" and "y".]])
		end
		if type(output["x"]) ~= "number" then
			return error([[Bad argument #3. Expected number for index "x", got: ]]..type(output["x"]))
		end
		if type(output["y"]) ~= "number" then
			return error([[Bad argument #3. Expected number for index "y", got: ]]..type(output["y"]))
		end
		setmetatable(output,self.vec2mt)
	end
	if TorS == "trigger" then
		if type(output) ~= "number" then
			return error("Bad argument #3. Expected number, got: "..type(output))
		end
	end
	if type(keys) ~= "table" then
		return error("Bad argument #4. Expected table, got: "..type(keys))
	end
	local pass = false
	for _,key in ipairs(keys) do
		pass = true
	end
	if not pass then
		return error("Bad argument #4. Must be a numbered table.")
	end
	for index,key in ipairs(keys) do
		if type(key) ~= "string" and type(key) ~= "number" then
			return error("Bad argument #4. Must be a numbered table filled with only strings and/or numbers. Index: "..tostring(index).." Expected string, got: "..type(key))
		end
	end
	setmetatable(keys,self.mt)
	self.keyMappings["analog"][TorS][side][tostring(keys)] = {keys = keys,output = output}
end

function Wasx:saveKeyMappings(path,name)
	local data = tostring(self.keyMappings)
	name = name or "default"
	if path then
		if type(path) ~= "string" then
			return error("Bad argument #1. Expected string or nil, got: "..type(path))
		end
		if not love.filesystem.getInfo(path, "directory") then
			if not love.filesystem.createDirectory(path) then
				return error([[Bad argument #1. Unable to create directory: "]]..path..[["]])
			end
		end
		love.filesystem.write(path.."/"..name, "local "..data.."return Mappings")
	else
		return data
	end
end

function Wasx:loadKeyMappings(path,name)
	if type(path) ~= "string" then
		return error("Bad argument #1. Expected string, got: "..type(path))
	end
	if not love.filesystem.getInfo(path, "directory") then
		return error([[Bad argument #1. Could not find directory: "]]..path..[["]])
	end
	if type(name) ~= "string" then
		return error("Bad argument #2. Expected string, got: "..type(name))
	end
	if not love.filesystem.getInfo(path.."/"..name, "file") then
		return error([[Bad argument #2. Could not find file: "]]..path.."/"..name..[["]])
	end
	local dataChunk, err = love.filesystem.load(path.."/"..name)
	if err then
		return error(err)
	end
	self.keyMappings = dataChunk()
	setmetatable(self.keyMappings, self.keyMapMT)
	for lr,LR in pairs(self.keyMappings["analog"]["stick"]) do
		for i,index in pairs(LR) do
			setmetatable(index["output"], self.vec2mt)
		end
	end
end

function Wasx:isDown(buttonIndex,...)
	local isDown = false
	if self:isConnected() then
		isDown = self.joystick:isGamepadDown(...)
	end
	if self.keyMappings["buttons"][buttonIndex] then	
		for _,key in ipairs(self.keyMappings["buttons"][buttonIndex]) do
			if type(key) == "string" then
				if love.keyboard.isDown(key) then
					self.useGamepad = false
					return true
				end
			else
				if love.mouse.isDown(key) then
					self.useGamepad = false
					return true
				end
			end
		end
	end
	if isDown then
		self.useGamepad = true
	end
	return isDown
end

function Wasx:keyOverride(TorS,side)
	if self.keyMappings["analog"][TorS][side] then	
		local move = false
		for _,map in pairs(self.keyMappings["analog"][TorS][side]) do
			local keyDown = false
			for _,key in ipairs(map["keys"]) do
				if type(key) == "string" then
					if love.keyboard.isDown(key) then
						keyDown = true
					end
				else
					if love.mouse.isDown(key) then
						keyDown = true
					end
				end
			end
			if keyDown then
				if move then
					move = move+map["output"]
					break
				else
					move = map["output"]
				end
			end
		end
		if move then
			self.useGamepad = false
			return move
		else
			return false
		end
	else
		return false
	end
end

function Wasx:axes(side,deadzone)			
	if type(side) ~= "string" then
		return error("Bad argument #1. Expected string, got: "..type(side))
	end
	deadzone = deadzone or 0.25
	if type(deadzone) ~= "number" then
		return error("Bad argument #2. Expected number, got: "..type(deadzone))
	end
	local keyOverride = self:keyOverride("stick",side)
	if keyOverride then
		return keyOverride
	end
	if self:isConnected() then
		local s = {}
		s.ax = self.joystick:getGamepadAxis(side.."x")
		s.ay = self.joystick:getGamepadAxis(side.."y")
		local extent = math.sqrt(math.abs(s.ax * s.ax) + math.abs(s.ay * s.ay))
		local angle = math.atan2(s.ay, s.ax)
		if (extent < deadzone) then
			s.x, s.y = 0, 0
		else
			extent = math.min(1, (extent - deadzone) / (1 - deadzone))
			s.x, s.y = extent * math.cos(angle), extent * math.sin(angle)
		end
		s.ax = nil
		s.ay = nil
		if s.x > 0 or s.y > 0 then
			self.useGamepad = true
		end
		return s
	else
		return false
	end
end

function Wasx:angle(side,deadzone)
	if type(side) ~= "string" then
		return error("Bad argument #1. Expected string, got: "..type(side))
	end
	deadzone = deadzone or 0.25
	if type(deadzone) ~= "number" then
		return error("Bad argument #2. Expected number, got: "..type(deadzone))
	end
	if not self:isConnected() then
		return false
	end
	local ax = self.joystick:getGamepadAxis(side.."x")
	local ay = self.joystick:getGamepadAxis(side.."y")
	local extent = math.sqrt(math.abs(ax * ax) + math.abs(ay * ay))
	local angle = math.atan2(ay, ax)
	for var,_ in pairs(self.keyMappings.angle[side]) do
		if (extent < deadzone) then
			self.data[var] = 0
		else
			self.data[var] = angle
		end
	end
	if (extent < deadzone) then
		return 0
	else
		self.useGamepad = true
		return angle
	end
end

function Wasx:trigger(side)
	if type(side) ~= "string" then
		return error("Bad argument #1. Expected string, got: "..type(side))
	end
	local keyOverride = self:keyOverride("trigger",side)
	if keyOverride then
		return keyOverride
	end
	if self:isConnected() then
		local act = self.joystick:getGamepadAxis("trigger"..side)
		if act > 0 then
			self.useGamepad = true
		end
		return act
	else
		return false
	end
end

function Wasx:button(...)
	local buttons = {...}
	if type(buttons[1]) == "table" then
		buttons = buttons[1]		
	end
	for index,key in ipairs(buttons) do
		if type(key) ~= "string" then
			return error("Bad argument #"..tostring(index)..". Expected string, got: "..type(key))
		end
	end
	setmetatable(buttons,self.mt)
	local buttonIndex = tostring(buttons)
	local isDown = self:isDown(buttonIndex,...)
	return isDown
end

function Wasx:buttonOnce(...)
	local buttons = {...}
	if type(buttons[1]) == "table" then
		buttons = buttons[1]		
	end
	for index,key in ipairs(buttons) do
		if type(key) ~= "string" then
			return error("Bad argument #"..tostring(index)..". Expected string, got: "..type(key))
		end
	end
	setmetatable(buttons,self.mt)
	local buttonIndex = tostring(buttons)
	local isDown = self:isDown(buttonIndex,...)
	if self.held[buttonIndex] then
		if self.held[buttonIndex] == buttons then
			if not isDown then
				self.held[buttonIndex] = nil
			end
			return false
		end
	elseif isDown then
		self.held[buttonIndex] = buttons
	end
	return isDown
end

function Wasx:buttonToggle(...)
	local buttons = {...}
	if type(buttons[1]) == "table" then
		buttons = buttons[1]		
	end
	for index,key in ipairs(buttons) do
		if type(key) ~= "string" then
			return error("Bad argument #"..tostring(index)..". Expected string, got: "..type(key))
		end
	end
	setmetatable(buttons,self.mt)
	local buttonIndex = tostring(buttons)
	local isDown = self:isDown(buttonIndex,...)
	if self.toggles[buttonIndex] then
		if self.toggles[buttonIndex] == buttons then
			if not isDown then
				self.toggles[buttonIndex] = nil
			end
			return self.toggleSet[buttonIndex]
		end
	elseif isDown then
		self.toggles[buttonIndex] = buttons
		if not self.toggleSet[buttonIndex] then
			self.toggleSet[buttonIndex] = true
		else
			self.toggleSet[buttonIndex] = 
			self.toggleSet[buttonIndex] == false
		end
	end
	return self.toggleSet[buttonIndex] or false
end

local indexInputs = {
	"button",
	"buttonOnce",
	"buttonToggle",
	"trigger",
	"angle",
	"axes",
}

local indexMT = {
	__index = function(t,i)
		for _,item in ipairs(t) do
			if item == i then
				return true
			end
		end
		return false
	end,
	__tostring = function(o)
		local st = ""
		for i,item in ipairs(o) do
			local spacer = [[]]
			if i == #o then
				spacer = [[ or ]]
			elseif i > 1 then
				spacer = [[, ]]
			end
			st = st..spacer..[["]]..item..[["]]
		end
		return st
	end,
}

setmetatable(indexInputs,indexMT)

function Wasx:index(var,info)
	if type(info) ~= "table" then
		return error("Bad argument #2. Expected table, got: "..type(info))
	elseif type(info.input) ~= "string" then
		return error([[Bad argument #2, index["input"]. Expected string, got: ]]..type(info.input))
	end
	if not indexInputs[info.input] then
		return error([[Bad argument #2, index["input"]. Expected string (]]..tostring(indexInputs)..[[) got: "]]..info.input..[["]])
	end
	
	self.data[var] = true
	if info.buttons then
		setmetatable(info.buttons, self.mt)
		info.buttonIndex = tostring(info.buttons)
	end
	self.keyMappings.data[var] = info
	if info.keys and info.buttons then
		return self:mapKey(info.buttonIndex, info.keys)
	elseif info.keys and info.output then
		if info.input == "trigger" then
			if not info.side then
				return error([[When useing input = "trigger" you must include side = "left or "right".]])
			elseif type(info.side) ~= "string" then
				return error([[Bad argument #2, index["side"]. Expected string, got: ]]..type(info.side))
			elseif info.side ~= "left" and info.side ~= "right" then
				return error([[Bad argument #2 index["side"]. Expected string "right" or "left", got: "]]..info.side..[["]])
			end
			return self:mapKeyAnalog("trigger", info.side, info.output, info.keys)
		elseif info.input == "axes" then
			if not info.side then
				return error([[When useing input = "axes" you must include side = "left or "right".]])
			elseif type(info.side) ~= "string" then
				return error([[Bad argument #2, index["side"]. Expected string, got: ]]..type(info.side))
			elseif info.side ~= "left" and info.side ~= "right" then
				return error([[Bad argument #2, index["side"]. Expected string "right" or "left", got: "]]..info.side..[["]])
			end
			return self:mapKeyAnalog("stick", info.side, info.output, info.keys)
		end
	elseif info.keys then
		return self:mapKey(var, info.keys)
	elseif info.input == "angle" then
		if not info.side then
			return error([[When useing input = "angle" you must include side = "left or "right".]])
		elseif type(info.side) ~= "string" then
			return error([[Bad argument #2, index["side"]. Expected string, got: ]]..type(info.side))
		elseif info.side ~= "left" and info.side ~= "right" then
			return error([[Bad argument #2, index["side"]. Expected string "right" or "left", got: "]]..info.side..[["]])
		end
		self.keyMappings.angle[info.side][var] = true
	else
		return error([[NO MAPPINGS!!! See Wasx.help("index")]])
	end
end

function Wasx:updateData()
	for var,info in pairs(self.keyMappings.data) do
		local pass
		if info.buttons then
			pass = info.buttons
		elseif info.keys then
			pass = var
		end
		if info.input == "button" then
			self.data[var] = self:button(pass)
		elseif info.input == "buttonOnce" then
			self.data[var] = self:buttonOnce(pass)
		elseif info.input == "buttonToggle" then
			self.data[var] = self:buttonToggle(pass)
		elseif info.input == "angle" then
			self.data[var] = self:angle(info.side,info.deadzone)
		elseif info.input == "axes" then
			self.data[var] = self:axes(info.side,info.deadzone)
		elseif info.input == "trigger" then
			self.data[var] = self:trigger(info.side)
		end
	end
end

local help = {
	help = [[
Wasx.help("function name")-- Pass in the name of the function to get more info on it. e.g. Wasx.help("buttons"). Wasx.help("all") will return the whole help section as a string.

id = 1, 2, 3, etc...-- The number asigned to that joystick.
side = "left" or "right"-- Refers to analog sticks and triggers.
deadzone = 0-1.-- How far do you want to move the analog stick before it registers an input.
button, button2 = "a", "b", ... -- The button on the joystick/Gamepad you want to be pressed. You can pass in as many as you like. print(Wasx.help("buttons")) to see the the list of buttons.
keys = {key1, key2, ...} -- Keys are represented by strings e.g. "space". You can also put in a number, which represents a mouse button e.g. 1, 2, or 3 for middle click.
buttonIndex = -- See Wasx.help("mapKey")
TorS = "trigger" or "stick"
output = -- See Wasx.help("mapKeyAnalog")
var, info = -- See Wasx.help("index")

Input = Wasx.new(id)

Input.useGamepad = true or false -- This is set to true if an input is detected by the joystick. If a mapped key is pressed then it is set to false.


---functions---


Input:axes(side, deadzone)
Input:angle(side, deadzone)
Input:trigger(side)
Input:button(button, button2,...)
Input:buttonOnce(button, button2,...)
Input:buttonToggle(button, button2,...)
Input:mapKey(buttonIndex, keys)
Input:mapKeyAnalog(TorS, side, output, keys)
Input:index(var, info)
Input:updateData()
Input:saveKeyMappings(path, fileName)
Input:loadKeyMappings(path, fileName)

	]],
	axes = [[
Input:axes(side, deadzone)-- Returns a table with an x and y value between -1 and 1 based on the specified analog sticks position.
	 ]],
	angle = [[
Input:angle(side, deadzone)-- Returns the specified analog sticks angle in radians.
	 ]],
	trigger = [[
Input:trigger(side)-- Returns the specified triggers in position. returns a value between 0 and 1.
	 ]],
	 index = [[
Input:index(var, info)-- This function will link Input.data[var] to the specified input function.
e.g.
info = {
	input = ]]..tostring(indexInputs)..[[, 
	keys = {"w", "space"}, -- (optional if buttons are givin)
	buttons = {"a", "b"}, -- (optional if keys are givin)
	------- next 2 are only for analog inputs ("axes" or "trigger")
	side = "left" or "right",
	output = -- See Wasx.help("mapKeyAnalog"),
	deadzone = 0-1 -- (optional) default is 0.25 if no deadzone is givin,
}

input = "angle" is special, you only need to put a side.
e.g.
info = {
	input = "angle",
	side = "left" or "right",
}

If you make an index tied to a stick axes you can just map the rest with Input:mapKeyAnalog()
e.g.
Input:mapKeyAnalog("stick", "left", {x = 0, y = -1}, {"w"})
Input:index("move", {
	input = "axes",
	keys = {"a"},
	side = "left",
	output = {x = -1, y = 0},
})
Input:mapKeyAnalog("stick", "left",{x = 0, y = 1}, {"s"})
Input:mapKeyAnalog("stick", "left",{x = 1, y = 0}, {"d"})
Order does not matter.

Input:index("jump", info)
	 ]],
	 mapKey = [[
Input:updateData()-- Updates all the variables in Input.data.
	 ]],
	mapKey = [[
Input:mapKey(buttonIndex, keys)-- buttonIndex is a string of the button combination you want mapped to a set of keys. e.g. "a" or "aback"
	 ]],
	mapKeyAnalog = [[
Input:mapKeyAnalog(TorS, side, output, keys)-- output is a number between 0 and 1 for "trigger", or is a table that looks like this {x = 0, y = 0} with the values set between -1 and 1.
	 ]],
	saveKeyMappings = [[
Input:saveKeyMappings(path, fileName)-- Saves the Input.keyMappings table to the specified path. fileName will default to "default" if no name is provided. Returns Input.keyMappings as a string if no path is provided.
	]],
	loadKeyMappings = [[
Input:loadKeyMappings(path, fileName)-- Loads the file at the specified path and puts it in Input.keyMappings.
	]],
	buttonOnce = [[
Input:buttonOnce(button, button2,...)-- Same as Input:button() but will only return true once, until the previously pressed button is unpressed.
	 ]],
	buttonToggle = [[
Input:buttonToggle(button, button2,...)-- Starts returning false. When the specified buttons are pressed it will toggle between returning true or false. Will only toggle once, until the previously pressed button is unpressed.
	 ]],
	button = [[
Input:button(button, button2,...)-- Returns true if one of the specified buttons is being pressed.

"a"-- Bottom face button (A).
"b"-- Right face button (B).
"x"-- Left face button (X).
"y"-- Top face button (Y).
"back"-- Back/Select button.
"guide"-- Guide/Home button.
"start"-- Start button.
"leftstick"-- Left stick click button.
"rightstick"-- Right stick click button.
"leftshoulder"-- Left bumper.
"rightshoulder"-- Right bumper.
"dpup"-- D-pad up.
"dpdown"-- D-pad down.
"dpleft"-- D-pad left.
"dpright"-- D-pad right.
	]],
}

function Wasx.help(funct)
	funct = funct or "help"
	if type(funct) ~= "string" then
		return error("Bad argument #1. Expected string, got: "..type(funct)..[[. Try Wasx.help("all")]])
	end
	if funct == "all" then
		local h = ""
		local cut = string.find(help.help,"functions")
		h = h..string.sub(help.help,1,cut-4)
		for item,info in pairs(help) do
			if item ~= "help" then
				h = h..info.."\n\n"
			end
		end
		return h
	end
	if help[funct] then
		return help[funct]
	else
		return error([[No help for "]]..tostring(funct)..[[" exists. Try Wasx.help("all")]])
	end
end
 
return Wasx