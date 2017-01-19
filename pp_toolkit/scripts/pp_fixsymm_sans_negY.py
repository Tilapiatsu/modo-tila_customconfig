#python
#-------------------------------------------------------------------------------
# Name:pp_fixsymm_sans_negY
# Version: 1.0
# Purpose: This script is designed to restore symmetry on a mesh across the X
# using the position of the verts on the -Y as a reference. No selection 
# is required.
#
# Author:      William Vaughan, pushingpoints.com
#
# Created:     01/04/2013
# Copyright:   (c) William Vaughan 2013
#-------------------------------------------------------------------------------

#Gathering symmetry state
symmetry_state = lx.eval('select.symmetryState ?')
lx.out('symmstate', symmetry_state)

#Turns Symmetry off
lx.eval('select.symmetryState none')

#Makes sure all selected geo is dropped
lx.eval('select.drop vertex')
lx.eval('select.drop edge')
lx.eval('select.drop polygon')


#Selects Verts and gets index of all verts
layer = lx.eval('query layerservice layer.index ? main')
lx.eval('select.type vertex')
verts = lx.eval('query layerservice verts ? all')

# looks for verts on +Y and selects them
for posy in verts:
	vertpos = lx.eval('query layerservice vert.pos ? %s' %posy)
	vertPOS_X,vertPOS_Y,vertPOS_Z = vertpos
	if vertPOS_Y >= -0.00000001:
		lx.eval('select.element %s vert add %s' % (layer, posy))


# looks for verts on -Y and selects them
#for posy in verts:
#	vertpos = lx.eval('query layerservice vert.pos ? %s' %posy)
#	vertPOS_X,vertPOS_Y,vertPOS_Z = vertpos
#	if vertPOS_Y <= 0.00000001:
#		lx.eval('select.element %s vert add %s' % (layer, posy))

lx.eval('select.convert polygon')

lx.eval('vert.set y 0.0')
	
lx.eval('delete')

lx.eval('tool.set *.mirror on')
lx.eval('tool.attr gen.mirror axis 1')
lx.eval('tool.attr gen.mirror cenY 0.0')
lx.eval('tool.apply')
lx.eval('tool.set *.mirror off')




#Returns Symmetry back to original state
if symmetry_state ==  "x":
	lx.eval('select.symmetryState x')

elif symmetry_state == "y":
	lx.eval('select.symmetryState y')

elif symmetry_state == "z":
	lx.eval('select.symmetryState z')

else:
	lx.eval('select.symmetryState none')
