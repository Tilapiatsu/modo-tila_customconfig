#python

# remove_custom_colors.py
# Version 1.0 - Cristobal Vila - etereaestudios.com
# To remove colors for locators both in the 3D Viewport and Item List

# Defining arguments for default, bgplus and bgminus
myarg = lx.arg()

# Remove Draw Options (custom colors)
lx.eval("item.draw rem locator")

# Small hack to avoid a bug in 701 where you need to refresh your selection
# in order to see the changes on wire color (delete these lines if bug is fixed)
lx.eval("viewport.3dView showSelections:?+")
lx.eval("viewport.3dView showSelections:?+")

# Remove Tag Color in ItemList (optional)
lx.eval("item.editorColor " + myarg )