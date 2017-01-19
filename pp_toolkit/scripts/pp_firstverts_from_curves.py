#python
#-------------------------------------------------------------------------------
# Name:pp_firstverts_from_curves
# Version: 1.0
# Purpose: This script is designed to select the first vert in a selected curve
#
#
# Author:      William Vaughan, pushingpoints.com
#
# Created:     01/29/2014
# Copyright:   (c) William Vaughan 2014
#-------------------------------------------------------------------------------

#Get layer info
layer = lx.eval('query layerservice layer.index ? main')
polys = lx.evalN('query layerservice polys ? selected')# index of polys
polysN = lx.eval('query layerservice poly.N ? selected') #poly count
lx.out('polys', polys)
lx.out('polysN', polysN)

lx.eval('select.drop polygon')

#For each curve selected run thru these commands
for p in polys:
	#select an individual curve by its index that was stored earlier
	lx.eval('select.element %s polygon set %s' % (layer,p))
	
	#Convert curve selection to vert selection
	lx.eval('select.convert vertex')

	#Store vert info
	verts = lx.evalN('query layerservice verts ? selected')# index of verts
	vertsN = lx.eval('query layerservice vert.N ? selected') #vert count
	lx.out('verts', verts)
	lx.out('vertsN', vertsN)

	lx.eval('select.drop vertex')

	#Run thru verts and select but stop at first one
	for v in verts:
		lx.eval('select.element %s vertex set %s' % (layer,v))
		#add vert to selection set
		lx.eval('select.editSet pp_curve_verts add')
		break
		
	lx.eval('select.drop vertex')
	lx.eval('select.drop polygon')

#Select all verts in selection set created by this script	
lx.eval('select.type vertex')
lx.eval("select.useSet pp_curve_verts select")