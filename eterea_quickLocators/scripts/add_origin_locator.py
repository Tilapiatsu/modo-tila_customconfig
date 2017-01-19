#python

# add_origin_locator.py
# Version 1.1 - Cristobal Vila - etereaestudios.com
# With the great help of Ylaz
# To add new customized locators at origin (0,0,0) ignoring your selections

# Example: @add_origin_locator.py circle 0.1 z true custom

# Defining arguments
myform = lx.args()[0]         # box, plane, circle, etc
mysize = float(lx.args()[1])  # size in meters
myaxis = lx.args()[2]         # axis xyz
myalig = lx.args()[3]         # align true or false
myshap = lx.args()[4]         # shape default or custom

# Enable Locators visibility, just in case it was disable
lx.eval("view3d.showLocators true")

# Create locator    
lx.eval("item.create locator")

# Apply dimensions to locator size
lx.eval("item.channel locator$size " +str(mysize))

# Apply shape, replace and solid    
lx.eval("item.channel locator$drawShape custom")
lx.eval("item.channel locator$isStyle replace")
lx.eval("item.channel locator$isSolid true")

# Define temporarily as box to introduce XYZ dimensions 
lx.eval("item.channel locator$isShape box")
lx.eval("item.channel locator$isSize.X " +str(mysize))
lx.eval("item.channel locator$isSize.Y " +str(mysize))
lx.eval("item.channel locator$isSize.Z " +str(mysize))

# Define temporarily as circle to introduce radius
lx.eval("item.channel locator$isShape circle")
lx.eval("item.channel locator$isRadius " +str(mysize * 0.5))

# Apply axis and align
lx.eval("item.channel locator$isAxis " +myaxis)
lx.eval("item.channel locator$isAlign " +myalig)

# Apply final form shape
lx.eval("item.channel locator$isShape " +myform)

# Finally, decide between default or custom shape
# I introduce this final step to “store” shape dimensions
# even if you create a Default locator and then you decide
# to change to a custom shape 
lx.eval("item.channel locator$drawShape " +myshap)