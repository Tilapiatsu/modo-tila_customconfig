#!/usr/bin/env python
import lx

# You can add any tools you want to cycle through to this list.
# The first tool in the list will be the default if none of them are active.
# Or the last in the list if scrolling backwards.
tools = (('full', 'off'))

num_tools = len (tools)

backwards = False
args = lx.args ()
if len (args) > 0:
    backwards = (args[0].lower() == 'prev')

active_tool = -1

for tool_idx in xrange (num_tools):
    if lx.eval('view3d.rayGL ?') ==  tools[tool_idx]:
        active_tool = tool_idx
        break

next_tool = active_tool

if backwards:
    next_tool = (active_tool - 1) % num_tools
else:
    next_tool = (active_tool + 1) % num_tools

try:
    lx.eval ('!!view3d.rayGL %s' % tools[next_tool])
except:
    pass