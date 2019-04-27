# möan

A fast, lightweight dialogue library for LÖVE2D.


## Installation

The [moan.lua](moan.lua?raw=1) file should be dropped into an existing project
and required by it:

```lua
local moan = require("moan")
```

The `moan.update()` function should be called at the start of each frame. As its only argument it should be given the delta seconds since the last frame.

The `moan.draw()` function should be called at end of the draw phase. As we want möan to be drawn on top of all other elements.


## Usage

Scribbles are processed asynchronously. Scribbles are started by using the `moan.say()` function. This function requires 2 arguments:

* `message` The message to be displayed
* `time` The amount of time the message should take to complete

```lua
moan.say("Hello, World!", 5)
```


## Function Reference

#### moan.say(message, time)
Starts a new Scribble with the message `message` be displayed over `time` seconds.

#### moan.pass()
Closes the current Scribble if it has been fully processed.

#### moan.skip()
Skips the current the Scribble allowing it to be passed using the `moan.pass()` function.


### Additional options

Additional options can be added when creating a scribble can be set through the use of chained methods provided through the scribble object which is returned by `moan.say()`.

```lua
moan.say("Hello, World!", 5):delay(1)
```

#### :delay(time)
The amount of time möan should wait before starting a scribble; `time` should be
a number of seconds.

#### :skippable(b)
Sets whether the current scribble can be skipped by `moan.skip()`.

#### :onstart(fn)
Sets the function `fn` to be called when the scribble starts.

#### :onupdate(fn)
Sets the function `fn` to be called each frame the scribble updates.

#### :oncomplete(fn)
Sets the function `fn` to be called once the scribble has finished.

#### :font(fnt)
Sets the current Font object to `fnt`.


## License

This library is free software; you can redistribute it and/or modify it under
the terms of the MIT license. See [LICENSE](LICENSE) for details.
