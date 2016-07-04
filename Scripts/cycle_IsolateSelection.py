#!/usr/bin/env python
import lx
import modo

# You can add any tools you want to cycle through to this list.
# The first tool in the list will be the default if none of them are active.
# Or the last in the list if scrolling backwards.

tools = ('hide.sel', 'hide.invert')

scn = modo.Scene()
selection = scn.selected

if len(selection) == 0:
	scn.select(scn.items())


for tool in tools:
	lx.eval (tool)

scn.select(selection)
