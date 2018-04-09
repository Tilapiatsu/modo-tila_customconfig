#python
#-------------------------------------------------------------------------------
# Name:pp_weight_slicer
# Version: 1.0
# Purpose: This script is designed to take selected weight vmaps and create a 
# left and right version of the weights.
#
# Author:      William Vaughan, pushingpoints.com
# Special thanks to Farfarer for help on vmap remove selection
# Created:     01/03/2014
# Copyright:   (c) William Vaughan 2014
#-------------------------------------------------------------------------------

#Makes sure all selected geo is dropped
lx.eval('select.drop vertex')
lx.eval('select.drop edge')
lx.eval('select.drop polygon')

# This is the type we want to keep selected. Available types are:
# weight        - Weight Map
# texture        - UV Map
# subweight        - Subdivision Weight (Old?)
# subvweight    - Subdivision Weight
# morph            - Relative Morph Map
# absmorph        - Absolute Morph Map
# rgb            - RGB Color Map
# rgba            - RGBA Color Map
# normal        - Vertex Normal Map
# pick            - Vertex Selection Set
# epck            - Edge Selection Set

keep_type = 'weight'

# Some map types have a different shorthand when dealing with selection.
type_to_shorthand = {    'weight' : 'wght', 
                        'texture' : 'txuv', 
                        'subweight' : 'subd', 
                        'subvweight' : 'subd', 
                        'morph' : 'morf', 
                        'absmorph' : 'spot', 
                        'normal' : 'norm', 
                        'edgepick' : 'epck', 
                    }

# Get all of the selected maps.
selected_vmaps = lx.evalN('query layerservice vmaps ? selected')

# For each selected map.
for vmap in selected_vmaps:
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

#Selects Verts and gets index of all verts
layer = lx.eval('query layerservice layer.index ? main')
lx.eval('select.type vertex')
verts = lx.eval('query layerservice verts ? all')

#Gets names of all selected weight maps and sorts them
wmap = lx.evalN('query layerservice vmaps ? selected')
sort_wmap = sorted(wmap, reverse=True)
lx.out('weightmaps', sort_wmap)

#Runs through the code below for each selected weight map
for w in sort_wmap:
	weights = lx.eval1('query layerservice vmap.name ? %s' % w)
	lx.out('weights', weights)

	lx.eval('select.vertexMap %s wght replace' %weights)
	
#copy weight values to clipboard
	lx.eval('vertMap.copy wght')

# looks for verts on +X and selects them
	for posx in verts:
		vertpos = lx.eval('query layerservice vert.pos ? %s' %posx)
		vertPOS_X,vertPOS_Y,vertPOS_Z = vertpos
		if vertPOS_X >= -0.00000001:
			lx.eval('select.element %s vert add %s' % (layer, posx))
		
	lx.eval('!!vertMap.new %s_LT wght false {0.78 0.78 0.78} 1.0' % weights)
	lx.eval('vertMap.paste wght')

	lx.eval('select.drop vertex')

# looks for verts on -X and selects them
	for posx in verts:
		vertpos = lx.eval('query layerservice vert.pos ? %s' %posx)
		vertPOS_X,vertPOS_Y,vertPOS_Z = vertpos
		if vertPOS_X <= 0.00000001:
			lx.eval('select.element %s vert add %s' % (layer, posx))
		
	lx.eval('!!vertMap.new %s_RT wght false {0.78 0.78 0.78} 1.0' % weights)
	lx.eval('vertMap.paste wght')
	
	
	lx.eval('select.drop vmap')
	lx.eval('select.drop vertex')