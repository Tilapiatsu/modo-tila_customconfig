#python
#-------------------------------------------------------------------------------
# Name:pp_ebevel_cleaner
# Version: 1.3
# Purpose: This script is designed to remove ngons and 3 point polygons after an 
# edge bevel is performed. It also ends the script with the new edges selected 
# to make it easy for creating wrinkles in the topology of the mesh.
#
# Author:      William Vaughan, pushingpoints.com
#
# Created:     25/12/2013
# Copyright:   (c) William Vaughan 2013
#-------------------------------------------------------------------------------

#Makes sure all selected geo is dropped
lx.eval('select.drop vertex')
lx.eval('select.drop edge')
lx.eval('select.drop polygon')

#Checks for Poles 
layer = lx.eval('query layerservice layer.index ? main')
lx.eval('select.typeFrom vertex')
lx.eval('select.vertex add edge more 6')
pole_selection =lx.eval('query layerservice vert.N ? selected')

#If there are poles then run through these commands
if pole_selection > 0:
	lx.eval('select.expand')
	lx.eval('select.convert polygon')
	pole_polys = lx.eval('query layerservice polys ? selected')
	pole_polysN = lx.eval('query layerservice poly.N ? selected')
	lx.out('pole_polys', pole_polys)
	lx.out('pole_polysN', pole_polysN)
	
lx.out('poles', pole_selection)

#Makes sure all selected geo is dropped
lx.eval('select.drop vertex')
lx.eval('select.drop edge')
lx.eval('select.drop polygon')

# Switches to polygon component mode.
lx.eval('select.typeFrom polygon')

#Selects the newly created n-gons.
lx.eval("select.polygon add vertex bezier 4")

ngons =lx.eval('query layerservice polys ? selected')
ngonsN =lx.eval('query layerservice poly.N ? selected')
lx.out('ngons', ngons)
lx.out('ngonsN', ngonsN)

if ngonsN <= 0:
	lx.eval('dialog.setup info')
	lx.eval('dialog.title {Edge Bevels to Fix:}')
	lx.eval('dialog.msg {This mesh contains no Edge Bevels that need to be fixed.}')
	lx.eval('dialog.open')
	
	
else:
	
	# Switches to polygon component mode and converts polygon selection to edges and shrinks selection.
	lx.eval('select.typeFrom polygon')
	lx.eval('select.convert edge')
	lx.eval('select.contract')

	# Collapses edges 
	lx.eval("edge.collapse")

	#Makes sure all selected geo is dropped
	lx.eval('select.drop vertex')
	lx.eval('select.drop edge')
	lx.eval('select.drop polygon')


	for n in ngons:
		lx.eval('select.type polygon')
		lx.eval('select.element %s polygon add %s' % (layer, n))


	# Selects the edges that border the selected ngons
	lx.eval('select.boundary')

	# index of selected edges
	boundary_edges = lx.eval('query layerservice edges ? selected')
	boundary_edgesN = lx.eval('query layerservice edge.N ? selected')
	lx.out('boundary', boundary_edges)
	lx.out('boundaryN', boundary_edgesN)

	#deselects edge
	lx.eval('select.drop edge')
	lx.eval('select.drop polygon')

	#Selects the newly created 3 point polygons.
	lx.eval("select.polygon add vertex psubdiv 3")

	#If there are poles then run through these commands
	if pole_selection > 0:
		if pole_polysN == 1:
			lx.eval('select.type polygon')
			lx.eval('select.element %s polygon remove %s' % (layer, int(pole_polys)))

		if pole_polysN > 1:
			for p in pole_polys:
				lx.eval('select.type polygon')
				lx.eval('select.element %s polygon remove %s' % (layer, p))
	

	tris =lx.eval('query layerservice polys ? selected')
	trisN =lx.eval('query layerservice poly.N ? selected')
	lx.out('tris', tris)
	lx.out('trisN', trisN)


	#Makes sure all selected geo is dropped
	lx.eval('select.drop vertex')
	lx.eval('select.drop edge')
	lx.eval('select.drop polygon')

	if trisN == 1:
		lx.eval('select.type polygon')
		lx.eval('select.element %s polygon add %s' % (layer, int(tris)))

	if trisN > 1:
		for t in tris:
			lx.eval('select.type polygon')
			lx.eval('select.element %s polygon add %s' % (layer, t))
	# Switches to edge component mode and deselects edges for selection set
	lx.eval('select.convert edge')

	if boundary_edgesN == 1:
		edge = boundary_edges
		lx.eval('select.type edge')
		indicies = edge[1:-1]
		indicies = indicies.split(',')
		lx.eval("select.element %s edge remove index:%s index2:%s" %(layer, indicies[0], indicies[1]))

	if boundary_edgesN > 1:
		for edge in boundary_edges:
			lx.eval('select.type edge')
			indicies = edge[1:-1]
			indicies = indicies.split(',')
			lx.eval("select.element %s edge remove index:%s index2:%s" %(layer, indicies[0], indicies[1]))

	
	#Selects edges between the newly created 3 point polys.
	lx.eval("select.ring")

	#slice selection down the middle
	lx.eval("tool.set poly.loopSlice on")
	lx.eval("tool.reset poly.loopSlice")
	lx.eval("tool.doApply") 
	lx.eval("tool.set poly.loopSlice off")

	#Makes sure all selected geo is dropped
	lx.eval('select.drop vertex')
	lx.eval('select.drop polygon')


	# Switches to edge component mode.
	lx.eval('select.type edge')

	# Changes the action center to Local and activates the Move tool
	lx.eval('tool.set actr.local on')
	lx.eval('tool.set TransformMove on')










		

