---
name: Wow WOTLK AIO
description: API Definition for writing AIO plugins (which are lua plugins in the Wow WOTLK 3.3.5 client)
---

## API DOCUMENTATION

-- AIO is required this way due to server and client differences with require function
local AIO = AIO or require("AIO")

-- Returns true if we are on server side, false if we are on client side
isServer = AIO.IsServer()

-- Returns true if we are on main lua state, true if we are on client side
isMainState = AIO.IsMainState()

-- Returns AIO version - note the type is not guaranteed to be a number
version = AIO.GetVersion()

-- Adds the file at given path to files to send to players if called on server side in main state.
-- The addon code is trimmed according to settings in AIO.lua.
-- The addon is cached on client side and will be updated only when needed.
-- Returns false on client side and true on server side. By default the
-- path is the current file's path and name is the file's name
-- 'path' is relative to worldserver.exe but an absolute path can also be given.
-- You should call this function only on startup to ensure everyone gets the same
-- addons and no addon is duplicate.
added = AIO.AddAddon([path, name])
-- The way this is designed to be used is at the top of an addon file so that the
-- file is added and not run if we are on server, and just run if we are on client:
if AIO.AddAddon() then
return
end

-- Similar to AddAddon - Adds 'code' to the addons sent to players. The code is trimmed
-- according to settings in AIO.lua. The addon is cached on client side and will
-- be updated only when needed. 'name' is an unique name for the addon, usually
-- you can use the file name or addon name there. Do note that short names are
-- better since they are sent back and forth to indentify files.
-- The function only exists on server side. Only on main lua state.
-- You should call this function only on startup to ensure everyone gets the same
-- addons and no addon is duplicate.
AIO.AddAddonCode(name, code)

-- Triggers the handler function that has the name 'handlername' from the handlertable
-- added with AIO.AddHandlers(name, handlertable) for the 'name'.
-- Can also trigger a function registered with AIO.RegisterEvent(name, func)
-- All triggered handlers have parameters handler(player, ...) where varargs are
-- the varargs in AIO.Handle or msg.Add
-- This function is a shorthand for AIO.Msg():Add(name, handlername, ...):Send()
-- For efficiency favour creating messages once and sending them rather than creating
-- them over and over with AIO.Handle().
-- The server side version.
AIO.Handle(player, name, handlername[, ...])
-- The client side version.
AIO.Handle(name, handlername[, ...])

-- Only on main lua state.
-- Adds a table of handler functions for the specified 'name'. When a message like:
-- AIO.Handle(name, "HandlerName", ...) is received, the handlertable["HandlerName"]
-- will be called with player and varargs as parameters.
-- Returns the passed 'handlertable'.
-- AIO.AddHandlers uses AIO.RegisterEvent internally, so same name can not be used on both.
handlertable = AIO.AddHandlers(name, handlertable)

-- Only on main lua state.
-- Adds a new callback function that is called if a message with the given
-- name is recieved. All parameters the sender sends in the message will
-- be passed to func when called.
-- Example message: AIO.Msg():Add(name, ...):Send()
-- AIO.AddHandlers uses AIO.RegisterEvent internally, so same name can not be used on both.
AIO.RegisterEvent(name, func)

-- Adds a new function that is called when the initial message is sent to the player.
-- The function is called before sending and the initial message is passed to it
-- along with the player if available: func(msg[, player])
-- In the function you can modify the passed msg and/or return a new one to be
-- used as initial message. Only on server side. Only on main lua state.
-- This can be used to send for example initial values (like player stats) for the addons.
-- If dynamic loading is preferred, you can use the messaging API to request the values
-- on demand also.
AIO.AddOnInit(func)

-- Key is a key for a variable in the global table \_G.
-- The variable is stored when the player logs out and will be restored
-- when he logs back in before the addon codes are run.
-- These variables are account bound.
-- Only exists on client side and you should call it only once per key.
-- All saved data is saved to client side.
AIO.AddSavedVar(key)

-- Key is a key for a variable in the global table \_G.
-- The variable is stored when the player logs out and will be restored
-- when he logs back in before the addon codes are run.
-- These variables are character bound.
-- Only exists on client side and you should call it only once per key.
-- All saved data is saved to client side.
AIO.AddSavedVarChar(key)

-- Makes the addon frame save it's position and restore it on login.
-- If char is true, the position saving is character bound, otherwise account bound.
-- Only exists on client side and you should call it only once per frame.
-- All saved data is saved to client side.
AIO.SavePosition(frame[, char])

-- AIO message class:
-- Creates and returns a new AIO message that you can append stuff to and send to
-- client or server. Example: AIO.Msg():Add("MyHandlerName", param1, param2):Send(player)
-- These messages handle all client-server communication.
msg = AIO.Msg()

-- The name is used to identify the handler function on receiving end.
-- A handler function registered with AIO.RegisterEvent(name, func)
-- will be called on receiving end with the varargs.
function msgmt:Add(name, ...)

-- Appends messages to eachother, returns self
msg = msg:Append(msg2)

-- Sends the message, returns self
-- Server side version - sends to all players passed
msg = msg:Send(player, ...)
-- Client side version - sends to server
msg = msg:Send()

-- Returns true if the message has something in it
hasmsg = msg:HasMsg()

-- Returns the message as a string
msgstr = msg:ToString()

-- Erases the so far built message and returns self
msg = msg:Clear()

-- Assembles the message string from added and appended data. Mainly for internal use.
-- Returns self
msg = msg:Assemble()
