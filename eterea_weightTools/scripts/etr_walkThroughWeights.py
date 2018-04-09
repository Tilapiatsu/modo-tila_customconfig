#python

# etr_WeightMaths.py
# Script to perform quick math operations between 2 Weight Maps
#
# WORK IN PROGRESS...
#
# Cristobal Vila, etereaestucios.com, February 2014

# ---------------------------------------------------------------------------------
# PURGE PROCESS - To leave only Weight Maps selected. From William Vaughan's script
# ---------------------------------------------------------------------------------

# This variable is used later so that when all vmaps are deselected the weight remains selected
keep_type = 'weight'

# Some map types have a different shorthand when dealing with selection.
type_to_shorthand =	{	'weight' : 'wght',
						'texture' : 'txuv',
						'subweight' : 'subd',
						'subvweight' : 'subd',
						'morph' : 'morf',
						'absmorph' : 'spot',
						'normal' : 'norm',
						'edgepick' : 'epck',
					}


# Query ID for Maps selected after purge (could be weights, subd, uv, morphs...)
sel_before_purgeID = lx.evalN('query layerservice vmaps ? selected')
lx.out('ID for all Vertex Maps selected before purge:', sel_before_purgeID)


# -------------------------------------------------------------------------------
# PURGE START - Deselect any non-weight map that is selected (subd, uv, morph...)
# -------------------------------------------------------------------------------

# For each selected map.
for vmap in sel_before_purgeID:
	# Get it's type.
	vmap_type = lx.eval1('query layerservice vmap.type ? %s' % vmap)
	if vmap_type != keep_type:
		# If it's type doesn't match the type we want to keep selected, deselect it.
		vmap_name = lx.eval1('query layerservice vmap.name ? %s' % vmap)
		if vmap_type in type_to_shorthand:
			# If the selection command uses a different shorthand for this type, use that instead.
			lx.eval('select.vertexMap {%s} %s remove' % (vmap_name, type_to_shorthand[vmap_type]))
		else:
			# Otherwise we're fine using the raw type.
			lx.eval('select.vertexMap {%s} %s remove' % (vmap_name, vmap_type))


# -------------------------------------------------------------------------------------------
# PURGE COMPLETE - Now we only have Weight Maps selected. Evaluate number of selected Weights 
# -------------------------------------------------------------------------------------------

# Get number of selected Weight Maps
sel_after_purgeN = len(lx.evalN('query layerservice vmaps ? selected'))
lx.out('Number of selected Weight Maps:', sel_after_purgeN)


# Abort script with a message if less or more than 1 Weight Map are selected
if sel_after_purgeN != 1:
	lx.eval('dialog.setup info')
	lx.eval('dialog.title {Eterea Weight Maths}')
	lx.eval('dialog.msg {You must have ONE Weight Maps selected, no less, no more.}')
	lx.eval('dialog.open')
	sys.exit()

# -------------------------------------------------------------------------------------------
# QUERY THE ID and NAME of our Weight Map
# -------------------------------------------------------------------------------------------

# Query ID for Weight Map selected after purge
sel_after_purgeID = lx.evalN('query layerservice vmaps ? selected')
lx.out('ID for Weight Map selected after purge:', sel_after_purgeID)

weight_A_name = lx.eval('query layerservice vmap.name ? %s' % sel_after_purgeID)
lx.out('Name for Weight Map selected after purge:', weight_A_name)

