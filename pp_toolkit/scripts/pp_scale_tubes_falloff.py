#python
#-------------------------------------------------------------------------------
# Name:pp_scale_tubes_falloff
# Version: 1.1
# Purpose: This script is designed to allow you to scale tubes/pipes along 
# their length with falloff
#
# Author:      William Vaughan, pushingpoints.com
#
#
# Created:     01/03/2014
# Copyright:   (c) William Vaughan 2014
#-------------------------------------------------------------------------------

lx.eval('select.type polygon') 

#Creates a variable named "layer" that = the current layer
layer = lx.eval('query layerservice layer.index ? main')

polysN = lx.eval('query layerservice poly.N ? selected') #vert count

if polysN <= 0:
	lx.eval('dialog.setup info')
	lx.eval('dialog.title {PP Scale Tubes Falloff:}')
	lx.eval('dialog.msg {You must have at least one polygon selected to run this script.}')
	lx.eval('dialog.open')
	sys.exit()

#Turn on the Selection Falloff option
lx.eval('tool.set falloff.selection on') 
lx.eval('tool.set actr.local on') 

#regardless of selection type convert it to Edges and expand the selection
lx.eval('select.convert edge')

#store selected edges 
selected_edges = lx.eval('query layerservice edges ? selected')

lx.eval('select.drop edge')

#Get Segment count

for edge in selected_edges:
	r_indicies = edge[1:-1]
	r_indicies = r_indicies.split(',')
	lx.eval("select.element %s edge add index:%s index2:%s" %(layer, r_indicies[0], r_indicies[1]))
	break
	
lx.eval('select.ring') 

#store selected edges
ring_edgesN = lx.eval('query layerservice edge.N ? selected')
lx.out('ringcount', ring_edgesN)

lx.eval('select.drop edge')

#re-select original edges

for Fedge in selected_edges:
	f_indicies = Fedge[1:-1]
	f_indicies = f_indicies.split(',')
	lx.eval("select.element %s edge add index:%s index2:%s" %(layer, f_indicies[0], f_indicies[1]))
	
#select all loops down the tube
lx.eval('select.ring') 

#remove original edges from selection
for Redge in selected_edges:
	lx.eval('select.type edge')
	indicies = Redge[1:-1]
	indicies = indicies.split(',')
	lx.eval("select.element %s edge remove index:%s index2:%s" %(layer, indicies[0], indicies[1]))

#use the segment count gathered earlier to set the falloff of weightmap	
lx.eval('tool.attr falloff.selection steps %d' % (ring_edgesN / 2)) 

#select the Scale tool 
lx.eval('tool.set xfrm.scale on')