#python
#-------------------------------------------------------------------------------
# Name:pp_uv2weight
# Version: 1.0
# Purpose: This script is designed to convert a UV vmap to a weightmap
#
# Author:      William Vaughan, pushingpoints.com
#
#
# Created:     01/03/2014
# Copyright:   (c) William Vaughan 2014
#-------------------------------------------------------------------------------

# Get info about the selected UVMap.
uvmap = lx.evalN('query layerservice vmaps ? selected')
uvmapN = len(lx.evalN('query layerservice vmaps ? selected'))

if uvmapN <= 0:
	lx.eval('dialog.setup info')
	lx.eval('dialog.title {PP UV2Weight U:}')
	lx.eval('dialog.msg {You must have a UV map selected to run this script.}')
	lx.eval('dialog.open')
	sys.exit()

if uvmapN > 1:
	lx.eval('dialog.setup info')
	lx.eval('dialog.title {PP UV2Weight U:}')
	lx.eval('dialog.msg {You can only have one vertex map selected to run this script.}')
	lx.eval('dialog.open')
	sys.exit()	

vmap_name = lx.eval1('query layerservice vmap.name ? %s' %uvmap)
lx.out('vmap', uvmap)
lx.out('vmap names', vmap_name)

#Create a new Weigthmap
lx.eval('!!vertMap.new %s wght false {0.78 0.78 0.78} 1.0'% vmap_name )

#Transfer UV values to Weight Values
#lx.eval('vertMap.math "WGHT[1]:%s" "TXUV[2]:%s" 1.0 0.0 direct 0 {} 1.0 0.0 direct 0' % (vmap_name, vmap_name)) #U
lx.eval('vertMap.math "WGHT[1]:%s" "TXUV[2]:%s" 1.0 0.0 component 1 {} 1.0 0.0 direct 0' % (vmap_name, vmap_name))#V

#rename Weightmap
lx.eval('select.vertexMap %s wght replace' % vmap_name)
lx.eval('vertMap.name %s2Weight wght active' % vmap_name)

# Change any 3D Viewport in scene to VertexMap shading
for w in range(lx.eval("query view3dservice view.N ?")):
    if lx.eval("query view3dservice view.type ? %s" %w) == "MO3D":
        frame = lx.evalN("query view3dservice view.frame ? %s" %w)
        lx.eval("select.viewport set viewport:%s frame:%s" %(frame[1], frame[0]))
        lx.eval("view3d.shadingStyle vmap")


