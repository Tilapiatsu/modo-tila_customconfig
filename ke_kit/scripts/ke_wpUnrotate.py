#python

# wpUnrotate 1.0 Kjell Emanuelsson 2017
# 
# Aligns element selection straightens/unrotates with position + 'unrotation' (rotation resets) from aligned workplane.
# 
# Usage :   1. Fit Workplane to where you want the 'bottom' 
#			2. Select any elements. Connected elements will be selected, so no need to select all. 
#
# Note : Workplane Y axis should point 'outwards'. This is the case most of the time when fitting the wp to elements.
#		 + In a few cases Y axis goes inverted : prob wont fix ;>  (Easy enough to adjust as long as you have the proper rotation.)

sel_layer = lx.eval('query layerservice layers ? selected')	
layerID = lx.eval('query layerservice layer.ID ? %s' %sel_layer )

if not lx.eval('workPlane.state ?') :
	sys.exit(": --- Fitted WorkPlane required : Please fit WP first to unrotate. ---")

# grab stuff	
lx.eval('select.connect')
lx.eval('select.convert polygon')
lx.eval('workPlane.rotate 0 180.0')

# make temp item & match wp rot/pos
lx.eval('select.cut')
lx.eval('layer.new')
lx.eval('select.paste')

lx.eval('query sceneservice scene.index ? current')
mesh_item = lx.evalN('query sceneservice selection ? mesh')[0]

lx.eval('select.center {%s}' %mesh_item)
lx.eval('center.matchWorkplanePos')
lx.eval('center.matchWorkplaneRot')
lx.eval('workPlane.reset')

lx.eval('select.typeFrom item')
lx.eval('transform.reset rotation')

# cut new mesh back into og layer
lx.eval('select.typeFrom polygon')
lx.eval('select.cut')
lx.eval('select.typeFrom item')
lx.eval('delete')
lx.eval('select.item %s' %layerID )
lx.eval('select.paste')

#eof