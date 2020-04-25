# Wasx
A very versatile input manager for LÖVE

<code/>
Wasx.help("function name")-- Pass in the name of the function to get more info on it. e.g. Wasx.help("buttons"). Wasx.help("all") will 

return the whole help section as a string.
</>
id = 1, 2, 3, etc...-- The number asigned to that joystick.
side = "left" or "right"-- Refers to analog sticks and triggers.
deadzone = 0-1.-- How far do you want to move the analog stick before it registers an input.
button, button2 = "a","b",... -- The button on the joystick/Gamepad you want to be pressed. You can pass in as many and you like. print(Wasx.help("buttons")) to see the the list of buttons.
keys = {key1,key2,...} -- Keys are represented by strings e.g. "space". You can also put in a number, which represents a mouse button e.g. 1,2, or 3 for middle click.
buttonIndex = -- See Wasx.help("mapKey")
TorS = "trigger" or "stick"
output = -- See Wasx.help("mapKeyAnalog")
var, info = -- See Wasx.help("index")

Input = Wasx.new(id)

Input.useGamepad = true or false -- This is set to true if an input is detected by the joystick. If a mapped key is pressed then it is set to false.


Input:angle(side, deadzone)-- Returns the specified analog sticks angle in radians.


Input:saveKeyMappings(path, fileName)-- Saves the Input.keyMappings table to the specified path. fileName will default to "default" if no name is provided. Returns Input.keyMappings as a string if no path is provided.


Input:mapKeyAnalog(TorS, side, output, keys)-- output is a number between 0 and 1 for "trigger", or is a table that looks like this {x = 0, y = 0} with the values set between -1 and 1.


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


Input:mapKey(buttonIndex, keys)-- buttonIndex is a string of the button combination you want mapped to a set of keys. e.g. "a" or "aback"


Input:buttonOnce(button, button2,...)-- Same as Input:button() but will only return true once, until the previously pressed button is unpressed.


Input:index(var, info)-- This function will link Input.data[var] to the specified input function.
e.g.
info = {
        input = "button", "buttonOnce", "buttonToggle", "trigger", "angle" or "axes",
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


Input:buttonToggle(button, button2,...)-- Starts returning false. When the specified buttons are pressed it will toggle between returning true or false. Will only toggle once, until the previously pressed button is unpressed.


Input:trigger(side)-- Returns the specified triggers in position. returns a value between 0 and 1.


Input:axes(side, deadzone)-- Returns a table with an x and y value between -1 and 1 based on the specified analog sticks position.


Input:loadKeyMappings(path, fileName)-- Loads the file at the specified path and puts it in Input.keyMappings.
