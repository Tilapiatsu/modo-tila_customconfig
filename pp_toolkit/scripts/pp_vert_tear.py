#python
#-------------------------------------------------------------------------------
# Name:pp_vert_tear
# Version: 1.0
# Purpose: This script is designed to tear a single vertex away from an 
# intersection. Steps: Select a poly, select a vert, run script.
#
# Author:      William Vaughan, pushingpoints.com
#
# Created:     01/18/2014
# Copyright:   (c) William Vaughan 2014
#-------------------------------------------------------------------------------

# Get layer info
layer = lx.eval('query layerservice layer.index ? main')

#get selected vert info
lx.eval('select.typeFrom vertex')
vert = lx.eval('query layerservice verts ? selected')
lx.out('vert', vert)

#get poly info
lx.eval('select.typeFrom polygon')
poly = lx.eval('query layerservice polys ? selected')

#separate the polygon's verts from the mesh making it discontinuous 
lx.eval('lock.unsel')
lx.eval('cut')
lx.eval('paste')

lx.eval('select.typeFrom vertex')

#Move the selected vert a small amount so it wont merge later
lx.eval('tool.set TransformMove on')
lx.eval('tool.attr xfrm.transform TX -0.00001')
lx.eval('tool.attr xfrm.transform TY 0.00001')
lx.eval('tool.attr xfrm.transform TZ 0.00001')
lx.eval('tool.doApply')
lx.eval('tool.set TransformMove off')

#merge all points on object except the one that is going to be torn off
lx.eval('select.drop vertex')
lx.eval('!!vert.merge auto false 0.001 false true')

#select the newly created vert and turn on Transform tool
lx.eval('select.vertex add edge equal 2')
lx.eval('tool.set TransformMove on')

lx.eval('unlock' )



