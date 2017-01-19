#python

# custom_fill_locator_color.py
# Version 1.1 - Cristobal Vila - etereaestudios.com
# To apply a custom fill color to selected Locator in 3D Viewport and/or Item List, depending on arguments

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

# Make solid (just in case it would be only wired)    
# Pass this step in case the locator has no Shape Options assigned
# Necessary to avoid an script error
try:
   lx.eval("!!item.channel locator$isSolid true")
except:
   pass

# Assign our custom color
lx.eval("item.channel locator$fillOptions user")
lx.eval("item.channel locator$fillColor { %s %s %s }" % (redvalue, greenvalue, bluevalue) )

# Assign our custom Item List color
lx.eval("item.editorColor " +itemlistcolor)