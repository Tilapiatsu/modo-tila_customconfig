#python

# align_and_axis_locator.py
# Version 1.0 - Cristobal Vila - etereaestudios.com
# To “one-click” control Align and Axis for locators

# Example @align_and_axis_locator.py y false

# Defining arguments
axis = lx.args()[0] # xyz
alig = lx.args()[1] # true or false

# Change Axis
lx.eval("item.channel locator$isAxis " + axis )

# Change Align
lx.eval("item.channel locator$isAlign " + alig )