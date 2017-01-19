#python
#-------------------------------------------------------------------------------
# Name:pp_scale_tubes
# Version: 1.1
# Purpose: This script is designed to allow you to scale tubes/pipes 
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
	lx.eval('dialog.title {PP Scale Tubes:}')
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

#select all loops down the tube
lx.eval('select.ring') 

#select the Scale tool 
lx.eval('tool.set xfrm.scale on')