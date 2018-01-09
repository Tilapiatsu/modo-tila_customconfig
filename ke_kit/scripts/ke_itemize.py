#python

# Itemize 1.0 Kjell Emanuelsson 2017
# 
# Turns element selection to a new item with position and rotation from aligned workplane.
# 
# Usage :   1. Fit Workplane to where you want the 'bottom' of your new item. 
#			2. Pick EDGES or POLYGONS that will be itemized. Connected mesh will be selected, so no need to select all. 
# 			3. The FIRST vertex selection = CENTER offset position (where your center POSITION will be) instead of workplane center.
#			   (Verts will thus also be checked in EDGE/POLY mode, so keep vert selections empty unless you want an offset center.)
#
# argument : dupe  - Run with "@ke_itemize.py dupe" if you prefer to keep the original geo too.
#
# Note : Workplane Y axis should point 'outwards'. This is the case most of the time when fitting the wp to elements.
#		 + In a few cases Y axis goes inverted : prob wont fix ;>  (Easy enough to adjust as long as you have the proper rotation.)

reset = False
offset = False
dupe = False

u_args = lx.args() 
for i in range(len(u_args)):
	if "dupe" in u_args:	
		dupe = True
	else: pass

sel_layer = lx.eval('query layerservice layers ? selected')	

if not lx.eval('workPlane.state ?') :
	sys.exit(": --- Fitted WorkPlane required : Please fit WP first to Itemize. ---")
	
	
# ------------------------------------------------------------------------------------
# Check selections / get offset Center (pos) 
# ------------------------------------------------------------------------------------
sel_mode = lx.eval('query layerservice selmode ?') 

lx.eval('select.typeFrom vertex')
sel_verts = lx.evalN('query layerservice verts ? selected')
sel_check = len(sel_verts)
		
if sel_check > 0 : 
	pos = lx.eval('query layerservice vert.wdefpos ? %s' %sel_verts[0] )
	offset = True

lx.eval('select.typeFrom %s' %sel_mode)
lx.eval('select.connect')
lx.eval('select.convert polygon')

# First vert WP offset
if offset :
	lx.eval('workplane.edit %s %s %s' %(pos[0], pos[1], pos[2]))	

lx.eval('workPlane.rotate 0 180.0')


# ------------------------------------------------------------------------------------	
# Make new item from selection  
# ------------------------------------------------------------------------------------

if not dupe :	
	lx.eval('select.cut')
else :
	lx.eval('select.copy')
	
lx.eval('layer.new')
lx.eval('select.paste')

lx.eval('query sceneservice scene.index ? current')
mesh_item = lx.evalN('query sceneservice selection ? mesh')[0]

lx.eval('select.center {%s}' %mesh_item)
lx.eval('center.matchWorkplanePos')
lx.eval('center.matchWorkplaneRot')

lx.eval('workPlane.reset')
lx.eval('select.typeFrom item')
lx.eval('tool.set actr.localAxis on')
lx.eval('tool.set TransformMoveItem on')


# eof