#python

# ----------------------------------------------------------------------------------------------------------------
# NAME: etr_lastShape_toSelected.py
# VERS: 1.0
# DATE: December 4, 2017
#
# MADE: Cristobal Vila, etereaestudios.com
#
# USES: To transfer the shape, sizes & colors from the last selected Locator to all other selected ones
# ---------------------------------------------------------------------------------------------------------------


# -------------------------------------------------------------------------------
# FUNCTIONS
# -------------------------------------------------------------------------------

# Query selection mode
def fn_selmode(*types):
	if not types:
		types = ('vertex', 'edge', 'polygon', 'item', 'pivot', 'center', 'ptag')
	for t in types:
		if lx.eval('select.typeFrom %s;vertex;edge;polygon;item;pivot;center;ptag ?' %t):
			return t

mySelMode = fn_selmode()


# Dialog with advices in case of wrong selection mode or nothing selected
def fn_dialogAdvice():
	lx.eval('dialog.setup info')
	lx.eval('dialog.title {Eterea Last Locator Shape to Selected}')
	lx.eval('dialog.msg {Be sure to select at least 2 Locators in order to transfer \n\
			the shape, sizes & colors from the last selected one to others.}')
	lx.eval('dialog.open')
	sys.exit()


# Dialog with advices in case other types of items are selected
def fn_dialogOnlyLocators():
	lx.eval('dialog.setup info')
	lx.eval('dialog.title {Eterea Last Locator Shape to Selected}')
	lx.eval('dialog.msg {You selected other types of Item that are not Locators. \n\
			And you need to select ONLY LOCATORS in order to transfer \n\
			the shape, sizes & colors from the last selected one to others.}')
	lx.eval('dialog.open')
	sys.exit()


# -------------------------------------------------------------------------------
# PRELIMINAR
# -------------------------------------------------------------------------------

# Query Current Active Scene
lx.eval('query sceneservice scene.name ? main')

# If not in Item mode, stop the script
if mySelMode != 'item':
	fn_dialogAdvice()

# Query the selected items ID and amount, to launch dialog if less than 2 are selected
itemsSelected_ID = lx.evalN('query sceneservice selection ? locator')
selected_N = len(itemsSelected_ID)

if selected_N < 2:
	fn_dialogAdvice()

# Create empty list to append later the types of selected items
itemTypes_list = []


# Query the type of item for each selected one to append in our list
for each_item in itemsSelected_ID:
	itemType = lx.eval('query sceneservice item.type ? %s' % each_item)
	itemTypes_list.append(itemType)


# If any item is not a locator, stop the script
if any(item != 'locator' for item in itemTypes_list):
	fn_dialogOnlyLocators()


# If we arrive here we have at least 2 items selected and all are Locators.
# Lets start:


# -------------------------------------------------------------------------------------
# MAIN STUFF - STORE SETTINGS from last selected Locator
# -------------------------------------------------------------------------------------

# Drop selection so that we can work on one item at a time
lx.eval('select.drop item')

# Re-select the last selected item, in order to query all kind of info related to it
lx.eval('select.item {%s} set' % itemsSelected_ID[-1])

# Store the size and drawShape of last selected locator
last_size = lx.eval('item.channel locator$size ?')
last_drawShape = lx.eval('item.channel locator$drawShape ?')

# If shape is 'custom' we need to store lots of parameters: style, shape, size, offset, etc
if last_drawShape == 'custom':

	last_isStyle = lx.eval('item.channel locator$isStyle ?')
	last_isShape = lx.eval('item.channel locator$isShape ?')
	last_isSolid = lx.eval('item.channel locator$isSolid ?')
	last_isAlign = lx.eval('item.channel locator$isAlign ?')
	last_isAxis = lx.eval('item.channel locator$isAxis ?')
	last_isShape = lx.eval('item.channel locator$isShape ?')

	last_isOffsetX = lx.eval('item.channel locator$isOffset.X ?')
	last_isOffsetY = lx.eval('item.channel locator$isOffset.Y ?')
	last_isOffsetZ = lx.eval('item.channel locator$isOffset.Z ?')

	last_isRadius = lx.eval('item.channel locator$isRadius ?')

	last_isSizeX = lx.eval('item.channel locator$isSize.X ?')
	last_isSizeY = lx.eval('item.channel locator$isSize.Y ?')
	last_isSizeZ = lx.eval('item.channel locator$isSize.Z ?')


# Try to access to wireOptions (no way to query this, AFAIK)
# If there is wireOptions, return TRUE, if not return FALSE with a silent error
try:
	lx.eval('!!item.channel locator$wireOptions ?')
	drawOptions = True

except:
	drawOptions = False


# If drawOption exists we need to query wire options, and color for 'custom' cases
if drawOptions == True:

	last_wireOptions = lx.eval('item.channel locator$wireOptions ?')

	if last_wireOptions == 'user':
		last_wireColor = lx.eval('item.channel locator$wireColor ?')

	last_fillOptions = lx.eval('item.channel locator$fillOptions ?')

	if last_fillOptions == 'user':
		last_fillColor = lx.eval('item.channel locator$fillColor ?')


# -------------------------------------------------------------------------------------
# MAIN STUFF - APPLY SETTINGS to other selected locators
# -------------------------------------------------------------------------------------

# For loop excluding the last item with Python Slice notation
for locator in itemsSelected_ID[:-1]:

	# Select one by one and change size and draw shape state
	lx.eval('select.item {%s} set' % locator)
	lx.eval('item.channel locator$size %s' % last_size)
	lx.eval('item.channel locator$drawShape %s' % last_drawShape)

	# If shape was 'custom' we need to apply lots of parameters: style, shape, size, offset, etc
	if last_drawShape == 'custom':
		lx.eval('item.channel locator$isStyle %s' % last_isStyle)
		lx.eval('item.channel locator$isSolid %s' % last_isSolid)
		lx.eval('item.channel locator$isAlign %s' % last_isAlign)
		lx.eval('item.channel locator$isAxis %s' % last_isAxis)
		lx.eval('item.channel locator$isShape %s' % last_isShape)

		lx.eval('item.channel locator$isOffset.X %s' % last_isOffsetX)
		lx.eval('item.channel locator$isOffset.Y %s' % last_isOffsetY)
		lx.eval('item.channel locator$isOffset.Z %s' % last_isOffsetZ)

		# Set shape to Circle temporarily (to avoid errors, since radius is not ever available)
		lx.eval('item.channel locator$isShape circle')
		lx.eval('item.channel locator$isRadius %s' % last_isRadius)

		# Set shape to Box temporarily (to avoid errors, since XYZ sizes are not ever available)
		lx.eval('item.channel locator$isShape box')
		lx.eval('item.channel locator$isSize.X %s' % last_isSizeX)
		lx.eval('item.channel locator$isSize.Y %s' % last_isSizeY)
		lx.eval('item.channel locator$isSize.Z %s' % last_isSizeZ)

		# Change shape back to the one saved inside our variable
		lx.eval('item.channel locator$isShape %s' % last_isShape)

	# If drawOption was true we need to apply wire options, and color for 'custom' cases
	if drawOptions == True:

		try:
			lx.eval('!!item.draw add locator')
		except:
			pass		

		lx.eval('item.channel locator$wireOptions %s' % last_wireOptions)

		if last_wireOptions == 'user':
			lx.eval('item.channel locator$wireColor {%s}' % last_wireColor)

		lx.eval('item.channel locator$fillOptions %s' % last_fillOptions)

		if last_fillOptions == 'user':
			lx.eval('item.channel locator$fillColor {%s}' % last_fillColor)

	# If drawOption was not true we need to remove it from others
	elif drawOptions == False:
		try:
			lx.eval('!!item.draw rem locator')
		except:
			pass		

# -------------------------------------------------------------------------------------
# END - Select again all locators
# -------------------------------------------------------------------------------------

for locator in itemsSelected_ID:
	lx.eval('select.item {%s} add' % locator)
