#python

# ------------------------------------------------------------------------------------------------
# NAME: etr_getSelectedWeight.py
# VERS: 1.0
# DATE: October 18, 2017
#
# MADE: Cristobal Vila, etereaestudios.com
#
# USES:	To get the average weight on selected components. If no standard weight is selected,
# 		the script will grab the average edge weight values (only for edges)
# ------------------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------------------
# FUNCTIONS
# --------------------------------------------------------------------------------------------------

# Define initial selection mode to return back at end
def selmode(*types):
	if not types:
		types = ('vertex', 'edge', 'polygon', 'item', 'pivot', 'center', 'ptag')
	for t in types:
		if lx.eval('select.typeFrom %s;vertex;edge;polygon;item;pivot;center;ptag ?' %t):
			return t

mySelMode = selmode()


# Function to calculate the arithmetic mean (average) of a list of numbers
def mean(numbers):
	return float(sum(numbers)) / max(len(numbers), 1)


# Dialog for when user is in wrong mode or no components are selected
def fn_dialogComponent():
	lx.eval('dialog.setup info')
	lx.eval('dialog.title {Eterea Get Selected Weight(s)}')
	lx.eval('dialog.msg {- To get weight values you need to be in component mode.\n\
			- And also: at least 1 vert or 1 edge or 1 poly must be selected.\n\
			- If more than 1 vert is selected, then you will get an average value.}')
	lx.eval('dialog.open')
	sys.exit()

# Dialog for when active mesh is not selected
def fn_dialogMeshSel():
	lx.eval('dialog.setup info')
	lx.eval('dialog.title {Eterea Get Selected Weight(s)}')
	lx.eval('dialog.msg {— Only 1 active mesh is supported to get weight values.\n\
			— And be sure to select that unique mesh on Item List.}')
	lx.eval('dialog.open')
	sys.exit()


# Dialog for when user has more than 1 weight selected
def fn_dialogWeightSel():
	lx.eval('dialog.setup info')
	lx.eval('dialog.title {Eterea Get Selected Weight(s)}')
	lx.eval('dialog.msg {- Be sure to have at most 1 weight map selected.\n\
			- If no weight is selected, the script will grab the Edge/Subd Weight values.}')
	lx.eval('dialog.open')
	sys.exit()


# Dialog for when no standard weight is selected (hence, edge weight should apply)
def fn_dialogEdgeWeight():
	lx.eval('dialog.setup info')
	lx.eval('dialog.title {Eterea Get Selected Weight(s)}')
	lx.eval('dialog.msg {- To get values for Edge/Subd Weight you need to be in Edge Mode.\n\
			- And a minimum of 1 edge must be selected, of course.}')
	lx.eval('dialog.open')
	sys.exit()



# --------------------------------------------------------------------------------------------------
# SECURITY CHECKS AND PREVIOUS CONDITIONS
# --------------------------------------------------------------------------------------------------

# If not in component mode, abort with message
components = ['vertex', 'edge', 'polygon']

if mySelMode not in components:
	fn_dialogComponent()


# Query Current Active Scene and store our Current Mesh
lx.eval('query sceneservice scene.name ? main')
myCurrentMesh = lx.evalN('query sceneservice selection ? mesh')

# Abort with message in case that no mesh or more than one are selected on Item List
if len(myCurrentMesh) != 1:
	fn_dialogMeshSel()


# --------------------------------------------------------------------------------------------------
# CHECKS TO KNOW HOW MANY STANDARD WEIGHT ARE IN SCENE AND WHICH ONES (IF ANY) ARE SELECTED
# --------------------------------------------------------------------------------------------------

# Store standard weight maps on scene (not the subd one aka edge weight, which is unique and always present)
standard_Weights = lx.evalN('query layerservice vmaps ? weight')

# Define an empty list to fill later with selected standard weights
sel_std_Weights = []

# Loop to get the selected standard weights and placing them in their list
for std_weight in standard_Weights:
	weight_selState = lx.eval('query layerservice vmap.selected ? %s' % std_weight)
	if weight_selState == 1:
		sel_std_Weights.append(std_weight)

# DECISSIONS DEPENDING ON THE KING OF WEIGHT TO WORK:

# If no standard weights are selected, we will attemp to work on Subdivision Weight (storing mode)
if len(sel_std_Weights) == 0:
	weightMode = 'edgeWeight'

# If a unique standard weight is selected, lets work on it (storing mode)
elif len(sel_std_Weights) == 1:
	weightMode = 'standWeight'
	# Next is necesary for when you have various weights, to be sure the script catch the correct one
	# I think this is because some similar reasons to the usual query sceneservice we need to do on start
	lx.eval('query layerservice vmap.name ? %s' % sel_std_Weights[0])

# If more than 1 standard weight is selected. Give mesage with error
else:
	fn_dialogWeightSel()
# --------------------------------------------------------------------------------------------------

lx.out('Eterea Get Weight - Mode:', weightMode)

# --------------------------------------------------------------------------------------------------
# Now all depends on what is selected: vertices, edges or polygons,
# combined with the kind of weight (standard of edgeweight)
#
# FOR POLYGONS: all selected polys will be converted to vertices to be processed later
# 				Only standard weight is considered
# --------------------------------------------------------------------------------------------------

if mySelMode == 'polygon' and weightMode == 'standWeight':
	selPolys_N = lx.eval('query layerservice poly.N ? selected')
	if selPolys_N == 0:
		fn_dialogComponent()
	lx.eval('select.convert vertex')

elif mySelMode == 'polygon' and weightMode == 'edgeWeight':
	fn_dialogEdgeWeight()

# --------------------------------------------------------------------------------------------------
# FOR EDGES
# For Standard Weight: all selected edges will be converted to vertices to be processed later
# For Edge Weight: we will define a special case and flow
# --------------------------------------------------------------------------------------------------

if mySelMode == 'edge' and weightMode == 'standWeight':
	selEdges_N = lx.eval('query layerservice edge.N ? selected')
	if selEdges_N == 0:
		fn_dialogComponent()
	lx.eval('select.convert vertex')

# --------------------------------------------------------------------------------------------------
# Here comes the case where we need to work with EDGE WEIGHT, a different kind of shit
# --------------------------------------------------------------------------------------------------
elif mySelMode == 'edge' and weightMode == 'edgeWeight':
	selEdges_ID = lx.evalN('query layerservice edges ? selected')
	if len(selEdges_ID) == 0:
		fn_dialogEdgeWeight()

	# Create an empty list to put edgeWeight values after quering that value for each edge
	edgeWeight_list = []

	for eachEdge in selEdges_ID:
		eachEdge_wgt = lx.eval("query layerservice edge.creaseWeight ? %s" % eachEdge)

		# Could be situations where a edge has not a edge weight value, giving a string 'none' and a final error
		# For these cases we check if a number is not a float, and in that case we give a float value of '0.0'
		if not isinstance(eachEdge_wgt, float):
			eachEdge_wgt = 0.0

		edgeWeight_list.append(eachEdge_wgt)


	# Apply function to get the average edge weight, as a percent and with only 1 decimal
	avg_edgeWeight = round(mean(edgeWeight_list)*100, 1)

	# Define as user value to be displayed
	lx.eval('user.value etr_wgt_customWeight %s' % avg_edgeWeight)

	# Stop script since we already have our edge weight value
	sys.exit()

# --------------------------------------------------------------------------------------------------
# FOR VERTICES: we will arrive here no matter we have selected polys, edges or vertices
# 				and working with standard weights, because all was converted to vertices
# --------------------------------------------------------------------------------------------------

# Special case for when we are in edge weight mode, skipping with dialog
if mySelMode == 'vertex' and weightMode == 'edgeWeight':
	fn_dialogEdgeWeight()

# Store selected verts as a list
selVerts_ID = lx.evalN('query layerservice verts ? selected')

# If no verts are selected, error dialog
if len(selVerts_ID) == 0:
	fn_dialogComponent()

# Define an empty list to fill later with standard weight values of selected verts
standardWeight_list = []

# Loop to get the standard weight value for every selected vertex and adding to list
for eachVert in selVerts_ID:
	eachVert_wgt = lx.eval("query layerservice vert.vmapValue ? {%s}" % eachVert)

	# Could be situations where a vert has not a weight value, giving a string 'none' and a final error
	# For these cases we check if a number is not a float, and in that case we give a float value of '0.0'
	if not isinstance(eachVert_wgt, float):
		eachVert_wgt = 0.0

	standardWeight_list.append(eachVert_wgt)


# Apply function to get the average weight, as a percent and with only 1 decimal
avg_standardWeight = round(mean(standardWeight_list)*100, 1)

# Define as user value to be displayed
lx.eval('user.value etr_wgt_customWeight %s' % avg_standardWeight)

# Return to original state
lx.eval('select.typeFrom %s' % mySelMode)
