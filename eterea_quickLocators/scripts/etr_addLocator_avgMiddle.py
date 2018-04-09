#python

# ------------------------------------------------------------------------------------------------
# NAME: etr_addLocator_avgMiddle.py
# VERS: 1.0
# DATE: November 26, 2017
#
# MADE: Cristobal Vila, etereaestudios.com + James O'Hare aka Farfarer
#
# USES: This script will create a single locator in the center of selected components or items.
#
#		- If Verts, Edges or Polys are selected, the script will calculate the center of Bounding Box
#			with the help of an external script 'calculate_bbox.py' by James O'Hare aka Farfarer,
#			wich is a Python API script, meaning it's extremely fast, even with high volume stuff.
#
#		- If Items are selected the script will calculate the average of all Item-Centers
#			without taking into account any bounding box calculations.
#
# ------------------------------------------------------------------------------------------------

import lx
import math

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

components = ['vertex', 'edge', 'polygon']


# Define a dictionary for plural versions of selection modes
plural_dict = {
	'vertex': 'verts',
	'edge': 'edges',
	'polygon': 'polys',
	'item': 'items',
}

# Dialog with advices in case of wrong selection mode or nothing selected (just for items)
def fn_dialogAdvice():
	lx.eval('dialog.setup info')
	lx.eval('dialog.title {Eterea Add Locator to Middle of Selected}')
	lx.eval('dialog.msg {Be sure to select some Verts, Edges, Polys or Items\n\
			in order to create a Locator in the average middle position.}')
	lx.eval('dialog.open')
	sys.exit()

# Dialog with alert for when number of selected stuff is too high (just for items)
def fn_dialogCaution():
	try:
		# Set up the dialog
		lx.eval('dialog.setup yesNo')
		lx.eval('dialog.title {Eterea Add Locator to Middle of Selected}')
		lx.eval('dialog.msg {You have %s %s selected. That is a big amount\n\
				and could be slow to process. Are you sure of this?\n\
				 \n\
				Press "Yes" to Continue or "No" to Cancel... to select less.}' % (selected_N, plural_dict[mySelMode]))
		lx.eval('dialog.result ok')
		# Open the dialog and see which button was pressed
		lx.eval('dialog.open')
		result = lx.eval('dialog.result ?')
	except:
		sys.exit()

# If no 'elements' are selected, abort with advice dialog / And if more of 100, then show a caution dialog
# This is just for items, also, since when components the external script will calculate the center of whole mesh item
def fn_narrowAmount():
	if selected_N == 0:
		fn_dialogAdvice()
	elif selected_N > 100:
		fn_dialogCaution()


# -------------------------------------------------------------------------------
# PRELIMINARY STUFF
# -------------------------------------------------------------------------------

# Query Current Active Scene
lx.eval('query sceneservice scene.name ? main')

# Query Current Active Mesh
myCurrentLayerID = lx.eval('query layerservice layer.index ? main')


# -------------------------------------------------------------------------------
# IF COMPONENTS ARE SELECTED (verts, edges or polys)
# -------------------------------------------------------------------------------

if mySelMode in components:

	# Force to select your Mesh in the Item List, for when components are selected
	# although some other Item is highlighted on ItemList (a very common issue)
	myMeshID = lx.eval('query layerservice layer.id ? %s' % myCurrentLayerID)
	lx.eval('select.subItem %s set  mesh;locator' % myMeshID)
	myMeshName = lx.eval('query sceneservice selection ? mesh')


	# Query Bounding Box of selected components using external script 'calculate_bbox.py' by James O'Hare aka Farfarer
	# http://community.thefoundry.co.uk/discussion/post.aspx?f=119&t=93824&p=839842
	boundBox = lx.evalN('ffr.getbbox ? world')  # Get world space boundBox as (+X, +Y, +Z, -X, -Y, -Z)


	# Calculate average (arithmetic mean) of resulting coords to get the Center for that Bounding Box
	# http://stackoverflow.com/questions/7716331/calculating-arithmetic-mean-average-in-python
	def average(numbers):
		return float(sum(numbers)) / max(len(numbers), 1)

	avgX = average([boundBox[0], boundBox[3]])
	avgY = average([boundBox[1], boundBox[4]])
	avgZ = average([boundBox[2], boundBox[5]])

	averagePos = (avgX, avgY, avgZ)  # This is the average/center position for selected components

	# Create a locator, size 0
	lx.eval('item.create locator')
	lx.eval('item.channel locator$size 0.0')

	# Change pos for our locator to match the average
	lx.eval('transform.channel pos.X {%s}' % averagePos[0])
	lx.eval('transform.channel pos.Y {%s}' % averagePos[1])
	lx.eval('transform.channel pos.Z {%s}' % averagePos[2])


# -------------------------------------------------------------------------------
# IF ITEMS ARE SELECTED
# -------------------------------------------------------------------------------

elif mySelMode == 'item':

	# Query the selected items ID and amount, to launch dialog if none or too much are selected
	itemSelected_ID = lx.evalN('query sceneservice selection ? locator')
	selected_N = len(itemSelected_ID)

	fn_narrowAmount()

	# Create 3 empty lists to append later the X, Y and Z positions of each of our selected items
	xPos_list = []
	yPos_list = []
	zPos_list = []

	for eachItem_ID in itemSelected_ID:

		# Query World Position for our Selected Item Mesh and append X,Y,Z values to our list
		eachItem_WPos = lx.eval('query sceneservice item.worldPos ? %s' % eachItem_ID)

		xPos_list.append(eachItem_WPos[0])
		yPos_list.append(eachItem_WPos[1])
		zPos_list.append(eachItem_WPos[2])

	# Calculate average of all X,Y,Z values
	averageXpos = sum(xPos_list) / selected_N
	averageYpos = sum(yPos_list) / selected_N
	averageZpos = sum(zPos_list) / selected_N

	# Create a locator, size 0
	lx.eval('item.create locator')
	lx.eval('item.channel locator$size 0.0')

	# Change position for our locator to match the average
	lx.eval('transform.channel pos.X {%s}' % averageXpos)
	lx.eval('transform.channel pos.Y {%s}' % averageYpos)
	lx.eval('transform.channel pos.Z {%s}' % averageZpos)

else:
	fn_dialogAdvice()

# Make locators visible, just in case ;-)
lx.eval('view3d.showLocators true')

