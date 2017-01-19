#python
#-------------------------------------------------------------------------------
# Name:pp_invert_weight
# Version: 1.0
# Purpose: This script is designed to invert teh values of a weightmap
#
# Author:      William Vaughan, pushingpoints.com
#
#
# Created:     01/03/2014
# Copyright:   (c) William Vaughan 2014
#-------------------------------------------------------------------------------

#This variable is used later so that when all vmaps are deselected the 
#weight remains selected
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
lx.out('vselect', selected_vmaps)

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
			

vmapsN = len(lx.evalN('query layerservice vmaps ? selected'))
lx.out('vselectN', vmapsN)

if vmapsN <= 0:
	lx.eval('dialog.setup info')
	lx.eval('dialog.title {PP Invert Weight Map:}')
	lx.eval('dialog.msg {You must have a Weight map selected to run this script.}')
	lx.eval('dialog.open')
	sys.exit()

if vmapsN > 1:
	lx.eval('dialog.setup info')
	lx.eval('dialog.title {PP Invert Weight Map:}')
	lx.eval('dialog.msg {You can only have one Weight map selected at a time to run this script.}')
	lx.eval('dialog.open')
	sys.exit()


#Invert selected weight
lx.eval('vertMap.copy wght')
lx.eval('vertMap.new temp_invert_source wght false {0.78 0.78 0.78} 1.0')
lx.eval('vertMap.paste wght')
lx.eval('vertMap.new temp_invert_target wght false {0.78 0.78 0.78} 1.0')
lx.eval('vertMap.math "WGHT[1]:temp_invert_target" "WGHT[1]:temp_invert_source" -1.0 0.0 direct 0 {} 1.0 0.0 direct 0')
lx.eval('tool.set vertMap.setWeight on')
lx.eval('tool.attr vertMap.setWeight additive true')
lx.eval('tool.setAttr vertMap.setWeight additive true')
lx.eval('tool.setAttr vertMap.setWeight weight 1.0')
lx.eval('tool.doApply')
lx.eval('select.vertexMap temp_invert_source wght replace')
lx.eval('!vertMap.delete wght')
lx.eval('select.vertexMap temp_invert_target wght replace')
lx.eval('?vertMap.name "" wght active')



