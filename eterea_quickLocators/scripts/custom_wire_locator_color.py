#python

# custom_wire_locator_color.py
# Version 1.1 - Cristobal Vila - etereaestudios.com
# To apply a custom wire color to selected Locator in 3D Viewport and/or Item List, depending on arguments

# Defining arguments for Red, Green, Blue and ItemList Color
redvalue = lx.args()[0]
greenvalue = lx.args()[1]
bluevalue = lx.args()[2]
itemlistcolor = lx.args()[3]

# Assign Draw Options
# Pass this step in case the locator has Draw Options already assigned
# Necessary to avoid an script error
try:
   lx.eval("!!item.draw add locator")
except:
   pass

# Enable draw options (just in case it could be disabled)    
lx.eval("item.channel locator$enable true")

# Assign our custom color
lx.eval("item.channel locator$wireOptions user")
lx.eval("item.channel locator$wireColor { %s %s %s }" % (redvalue, greenvalue, bluevalue) )

# Small hack to avoid a bug in 701 where you need to refresh your selection
# in order to see the changes on wire color (delete these lines if bug is fixed)
lx.eval("viewport.3dView showSelections:?+")
lx.eval("viewport.3dView showSelections:?+")

# Assign our custom Item List color
lx.eval("item.editorColor " +itemlistcolor)