GameMaker Lua Chips
=====

###About Lua Chips###
 - This is a chips challenge clone, written primarily in Lua, which was implemented into GameMaker.
 - I use a heavily modified version of [GM Lua] (https://code.google.com/p/gmlua/), looking at what I now know about Lua, the implementation is pretty dodgy, and doesn't really interface with GameMaker very well at all.

![alt tag](http://i.imgur.com/T7kTSbS.jpg)

###What version of GameMaker?###
 - This was written in Version 8, since it uses GM API, it will ONLY compile in Version 8.

###How close to the original is this?###
 - It's a pretty close clone, however I am fairly sure there are some missing features that I never got around to implementing, I don't think I ever thin walls for example.

###Fun Fact###
 - It only has one room, and one line of GML, that line of GML loads GM Lua.
 - return external_call(external_define("gmLua.dll", "Init", dll_cdecl, ty_real, 0));