# Wasx v1.1.1
A very versatile input manager for [LÖVE](http://love2d.org) version 11.3

```lua
Wasx.help("function name")-- Pass in the name of the function to get more info on it. e.g. Wasx.help("buttons"). 
Wasx.help("all") --will return the whole help section as a string.
```
Variables
```lua
id = 1, 2, 3, etc...-- The number asigned to that joystick.
side = "left" or "right"-- Refers to analog sticks and triggers.
deadzone = 0-1.-- How far do you want to move the analog stick before it registers an input.
button, button2 = "a","b",... -- The button on the joystick/Gamepad you want to be pressed. You can pass in as many and you like. print(Wasx.help("buttons")) to see the the list of buttons.
keys = {key1,key2,...} -- Keys are represented by strings e.g. "space". You can also put in a number, which represents a mouse button e.g. 1,2, or 3 for middle click.
buttonIndex = -- See Wasx.help("mapKey")
TorS = "trigger" or "stick"
output = -- See Wasx.help("mapKeyAnalog")
var, info = -- See Wasx.help("index")
```
Usage
```lua
Input = Wasx.new(id)
```
You need to create the Input object first.

```lua
Input:updateData(dt)
```
Run this at the start of each update cycle.

```lua
Input.useGamepad = true or false 
```
This is set to true if an input is detected by the joystick. If a mapped key is pressed then it is set to false.

```lua
Input:angle(side, deadzone)
```
Returns the specified analog sticks angle in radians.

```lua
Input:saveKeyMappings(path, fileName)
```
Saves the Input.keyMappings table to the specified path. fileName will default to "default" if no name is provided. Returns Input.keyMappings as a string if no path is provided.

```lua
Input:mapKeyAnalog(TorS, side, output, keys)
```
output is a number between 0 and 1 for "trigger", or is a table that looks like this {x = 0, y = 0} with the values set between -1 and 1.

```lua
Input:vibrate(left, right, tag)
```
e.g.
```lua
left = false-- pass false or nil to skip a value.
right = {1, 0, 2}-- startingStrength, endStrength, transitionTime -- Strength values are between 0 and 1.
tag = "myCustomName"-- If you give a tag the vibration settings will go in/replace Input.activeVibrations[tag] instead of creating a new index (optional).
Input:vibrate(left, right, tag)
```

Adds vibration settings table to Input.activeVibrations
If no values are givin then Input.activeVibrations will be cleared.
Use ```Input:vibrate(tag)``` to clear only Input.activeVibrations[tag].
Use ```Input:updateData(dt)``` when using vibrations.

```lua
Input:button(button, button2,...)
```
Returns true if one of the specified buttons is being pressed.

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

```lua
Input:mapKey(buttonIndex, keys)
```
buttonIndex is a string of the button combination you want mapped to a set of keys. e.g. "a" or "aback"

```lua
Input:buttonOnce(button, button2,...)
```
Same as Input:button() but will only return true once, until the previously pressed button is unpressed.

```lua
Input:index(var, info)
```
This function will link Input.data[var] to the specified input function.

e.g.
```lua
info = {
        input = "button", "buttonOnce", "buttonToggle", "trigger", "angle" or "axes",
        keys = {"w", "space"}, -- (optional if buttons are givin)
        buttons = {"a", "b"}, -- (optional if keys are givin)
        ------- next 2 are only for analog inputs ("axes" or "trigger")
        side = "left" or "right",
        output = -- See Wasx.help("mapKeyAnalog"),
        deadzone = 0-1 -- (optional) default is 0.25 if no deadzone is givin,
}
```
input = "angle" is special, you only need to put a side.

e.g.
```lua
info = {
        input = "angle",
        side = "left" or "right",
}
```
If you make an index tied to a stick axes you can just map the rest with Input:mapKeyAnalog()

e.g.
```lua
Input:mapKeyAnalog("stick", "left", {x = 0, y = -1}, {"w"})
Input:index("move", {
        input = "axes",
        keys = {"a"},
        side = "left",
        output = {x = -1, y = 0},
})
Input:mapKeyAnalog("stick", "left",{x = 0, y = 1}, {"s"})
Input:mapKeyAnalog("stick", "left",{x = 1, y = 0}, {"d"})
```
Order does not matter.

Then pick a var that makes sense for your project
```lua
Input:index("jump", info)
```
```lua
Input:buttonToggle(button, button2,...)
```
Starts returning false. When the specified buttons are pressed it will toggle between returning true or false. Will only toggle once, until the previously pressed button is unpressed.

```lua
Input:trigger(side)
```
Returns the specified triggers in position. returns a value between 0 and 1.

```lua
Input:axes(side, deadzone)
```
Returns a table with an x and y value between -1 and 1 based on the specified analog sticks position.

```lua
Input:loadKeyMappings(path, fileName)
```
Loads the file at the specified path and puts it in Input.keyMappings.
