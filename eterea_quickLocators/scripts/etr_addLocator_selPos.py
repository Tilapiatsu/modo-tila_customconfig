#python

# ------------------------------------------------------------------------------------------------
# NAME: etr_addLocator_selPos.py
# VERS: 1.0
# DATE: November 26, 2017
#
# MADE: Cristobal Vila, etereaestudios.com
#
# USES: This script will create locators at selected stuff positions:
#		- If Verts are selected, as many locators at same world positions
#		- If Edges are selected, as many locators on each edge-center and accordingly oriented
#		- If Polys are selected, as many locators on each poly-center and accordingly oriented
#		- If Items are selected, as many locators on each item position with same rotation and scale
#
# ------------------------------------------------------------------------------------------------

import modo # Because some parts are using TD-SDK (for Item placement)

# -------------------------------------------------------------------------------
# QUERY SELECTION MODE AND RELATIVE STUFF
# -------------------------------------------------------------------------------

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

# Create an empty list to add created locators, later
locatorsList = []


# -------------------------------------------------------------------------------
# FUNCTIONS
# -------------------------------------------------------------------------------

# Dialog for when user is in wrong mode. And some advices
def fn_dialogAdvice():
	lx.eval('dialog.setup info')
	lx.eval('dialog.title {Eterea Add Locators to Selected Positions}')
	lx.eval('dialog.msg {Be sure to select some Verts, Edges, Polys or Items\n\
			in order to create new Locators at those positions.}')
	lx.eval('dialog.open')
	sys.exit()


# Dialog with alert for when number of selected stuff is too high
def fn_dialogCaution():
	try:
		# Set up the dialog
		lx.eval('dialog.setup yesNo')
		lx.eval('dialog.title {Eterea Add Locators to Selected Positions}')
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
# No matter those 'elements' are verts, edges, polys or items
def fn_narrowAmount():
	if selected_N == 0:
		fn_dialogAdvice()
	elif selected_N > 100:
		fn_dialogCaution()


# Function to recover our original Workplane (because we will reset it and use intermediate workplanes in EDGE and POLY cases)
def fn_recover_WP():
	# This first part is for when our workplane was 'dynamic' or 'free', to avoid ending with a workplane aligned to 0,0,0 and NOT dynamic.
	if abs(wp_cenX) == 0.0 and abs(wp_cenY) == 0.0 and abs(wp_cenZ) == 0.0 and abs(wp_rotX) == 0.0 and abs(wp_rotY) == 0.0 and abs(wp_rotZ) == 0.0:
		lx.eval('workPlane.reset')
	# This second part is for when our workplane was aligned to any selection.
	else:
		lx.eval('workPlane.fitSelect')
		lx.eval('workPlane.edit %s %s %s %s %s %s' % (wp_cenX, wp_cenY, wp_cenZ, wp_rotX, wp_rotY, wp_rotZ))


# Function with common procedures por EDGES and POLYS
def fn_edgePoly_Procedure():
	lx.eval('workPlane.fitSelect')

	# Create a locator, size 0
	lx.eval('item.create locator')
	lx.eval('item.channel locator$size 0.0')

	# Match workplane position and rotation
	lx.eval('matchWorkplanePos')
	lx.eval('matchWorkplaneRot')

	# Get ID of new locator and add to list
	locatorID = lx.eval1('query sceneservice selection ? all')
	locatorsList.append(locatorID)

	# Return to our original mesh item and component mode
	lx.eval('select.subItem %s set  mesh;locator' % myMeshID)
	lx.eval('select.drop %s' % mySelMode)



# -------------------------------------------------------------------------------
# PRELIMINAR STUFF
# -------------------------------------------------------------------------------

# Get position and rotation for our Workplane
lx.setOption( 'queryAnglesAs', 'degrees' )
wp_cenX = lx.eval('workPlane.edit cenX:?')
wp_cenY = lx.eval('workPlane.edit cenY:?')
wp_cenZ = lx.eval('workPlane.edit cenZ:?')
wp_rotX = lx.eval('workPlane.edit rotX:?')
wp_rotY = lx.eval('workPlane.edit rotY:?')
wp_rotZ = lx.eval('workPlane.edit rotZ:?')

# Query Current Active Scene
lx.eval('query sceneservice scene.name ? main')

# Query Current Active Mesh
myCurrentLayerID = lx.eval('query layerservice layer.index ? main')

# Force to select your Mesh in the Item List, for when components are selected
# although some other Item is highlighted on ItemList (a very common issue)
if mySelMode in components:
	myMeshID = lx.eval('query layerservice layer.id ? %s' % myCurrentLayerID)
	lx.eval('select.subItem %s set  mesh;locator' % myMeshID)
	myMeshName = lx.eval('query sceneservice selection ? mesh')


# -------------------------------------------------------------------------------
# IF VERTS ARE SELECTED
# -------------------------------------------------------------------------------

if mySelMode == 'vertex':

	# Query the selected verts ID and amount
	vertSelected_ID = lx.evalN('query layerservice verts ? selected')
	selected_N = len(vertSelected_ID)

	fn_narrowAmount()

	for eachVert in vertSelected_ID:
		xVertPos = lx.eval('query layerservice vert.wpos ? {%s}' % eachVert)[0]
		yVertPos = lx.eval('query layerservice vert.wpos ? {%s}' % eachVert)[1]
		zVertPos = lx.eval('query layerservice vert.wpos ? {%s}' % eachVert)[2]

		# Create a locator, size 0
		lx.eval('item.create locator')
		lx.eval('item.channel locator$size 0.0')

		# Change pos for our locator to match the vert
		lx.eval('transform.channel pos.X {%s}' %xVertPos)
		lx.eval('transform.channel pos.Y {%s}' %yVertPos)
		lx.eval('transform.channel pos.Z {%s}' %zVertPos)

		# Get ID of new locator and add to list
		locatorID = lx.eval1('query sceneservice selection ? all')
		locatorsList.append(locatorID)

# -------------------------------------------------------------------------------
# IF EDGES ARE SELECTED
# -------------------------------------------------------------------------------

elif mySelMode == 'edge':

	# Query the selected edges ID and amount
	edgeSelected_ID = lx.evalN('query layerservice edges ? selected')
	selected_N = len(edgeSelected_ID)

	fn_narrowAmount()

	lx.eval('select.drop edge')
	lx.eval('workPlane.reset')

	for eachEdge_ID in edgeSelected_ID:

		# Iterate through edges to fit our workplane
		indices = eachEdge_ID[1:-1]
		indices = indices.split(',')
		lx.eval('select.element %s edge set index:%s index2:%s' % (myCurrentLayerID, indices[0], indices[1]))

		fn_edgePoly_Procedure()

	# Once the loop is done, recover our workplane
	fn_recover_WP()


# -------------------------------------------------------------------------------
# IF POLYS ARE SELECTED
# -------------------------------------------------------------------------------

elif mySelMode == 'polygon':

	# Query the selected polys ID and amount
	polySelected_ID = lx.evalN('query layerservice polys ? selected')
	selected_N = len(polySelected_ID)

	fn_narrowAmount()

	lx.eval('select.drop polygon')
	lx.eval('workPlane.reset')

	for eachPoly_ID in polySelected_ID:

		# Iterate through polys to fit our workplane
		lx.eval('select.element %s polygon set %s' % (myCurrentLayerID, eachPoly_ID))

		fn_edgePoly_Procedure()

	# Once the loop is done, recover our workplane
	fn_recover_WP()


# -------------------------------------------------------------------------------
# IF ITEMS ARE SELECTED
# -------------------------------------------------------------------------------

elif mySelMode == 'item':

	# For these parts we will use TD-SDK

	scene = modo.Scene()
	itemSelected_ID = scene.selected
	selected_N = len(itemSelected_ID)

	fn_narrowAmount()

	for eachItem_ID in itemSelected_ID:

		# NOTE: Using worldMatrix(4) to get World Rotation gives us bad results when item is also scaled.
		# For that reason I used wrotMatrix(3) just for Rotation. See these posts:
		# http://community.foundry.com/discuss/topic/136620/convert-3x3-matrix-to-rotx-roty-rotz-solved
		# http://community.foundry.com/discuss/topic/136730/how-to-get-world-item-position-and-scale-using-td-sdk

		worldMatrix4 = modo.Matrix4(eachItem_ID.channel('worldMatrix').get())
		wrotMatrix3 = modo.Matrix3(eachItem_ID.channel('wrotMatrix').get())

		eachItem_P = worldMatrix4.position
		eachItem_R = wrotMatrix3.asEuler(degrees=True, order='zxy')
		eachItem_S = worldMatrix4.scale()
		# eachItem_R = worldMatrix4.asEuler(degrees=True, order='zxy') # This gives bad results when item is also Scaled

		# Create a locator, size 0
		lx.eval('item.create locator')
		lx.eval('item.channel locator$size 0.0')

		# Change pos, rot and scale for our locator to match the item
		lx.eval('transform.channel pos.X {%s}' % eachItem_P[0])
		lx.eval('transform.channel pos.Y {%s}' % eachItem_P[1])
		lx.eval('transform.channel pos.Z {%s}' % eachItem_P[2])
		lx.eval('transform.channel rot.X {%s}' % eachItem_R[0])
		lx.eval('transform.channel rot.Y {%s}' % eachItem_R[1])
		lx.eval('transform.channel rot.Z {%s}' % eachItem_R[2])
		lx.eval('transform.channel scl.X {%s}' % eachItem_S[0])
		lx.eval('transform.channel scl.Y {%s}' % eachItem_S[1])
		lx.eval('transform.channel scl.Z {%s}' % eachItem_S[2])

		# Get ID of new locator and add to list
		locatorID = lx.eval1('query sceneservice selection ? all')
		locatorsList.append(locatorID)

# -------------------------------------------------------------------------------
# If not in component or item mode
# -------------------------------------------------------------------------------

else:
	fn_dialogAdvice()

# -------------------------------------------------------------------------------
# Make locators visible and select them
# -------------------------------------------------------------------------------
lx.eval('view3d.showLocators true')
lx.eval('select.drop item')
for item in locatorsList:
	lx.eval('select.item {%s} add' % item)