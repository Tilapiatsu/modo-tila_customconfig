#python#

# QuickPaste 1.0 - Kjell Emanuelsson 2018  (Hacky subd version - Makes a temp copy of subd/psubd surfaces, freezes, and uses that for placement. Not ideal, but maths hard...)
#
# Select POLYS to copy and point your mouse at intended target poly to align to. Source polys should be oriented "straight up" in Y axis. (or expect them to be handled as such)
# 	1. Select polys. 2. Mouse over mesh element to align to.
#
# 	WP option:       Fit workplane beforehand for destination. Also, for manual placement control, edges and what not?)  *Does not work with "target" argument*
#	Multiple layers: Select as many layers as you want (to use for targets). Pasted elements will all be in the source layer.
#	Sel-set:         Pasted elements are added to a selection set for quick access later.
#
#	Argument :  target  -  Will paste to the selected layer (under mouse) instead of source layer.
#				fit     -  Will fit pasted geo to the center of target element (instead of mouse position)
#
# Note: Script uses the MODO Paste Tool: It is currently limited/bugged as item with transforms will offset pasted elements (item not at 0,0,0 for ex.). 
#       I'm just using a temp layer to work around this for now. Not optimal: Hopefully the foundry adresses this so I can remove the workaround.


from math import ceil

u_args = lx.args() 

paste_to_target = False
mouse_offset = True
verbose = False
wpfitted = False
vl = []
subhack = True
verbose = True

for i in range(len(u_args)):
	if "target" in u_args:
		paste_to_target = True
	if "fit" in u_args:
		mouse_offset = False
	else : pass	


def fn_height(vertindices):
	posY = []
	for v in vertindices :
		posY.append( lx.eval('query layerservice vert.wdefpos ? %s' %v )[1] )
	posY.sort()	
	return posY[-1] - posY[0]

if verbose : print "------------------" # Event log separator	

	
# --------------------------------------------------------------------
# Get Source and store copy
# --------------------------------------------------------------------	

selmode = lx.eval('query layerservice selmode ?') 
if selmode != 'polygon' :
	sys.exit(": Selection Mode error: Please use POLYGON selection.")

	
fg_layers = lx.evalN('query sceneservice selection ? mesh')
	
for layer in fg_layers :
	index = lx.eval1('query layerservice layer.index ? {%s}' %layer)
	polys = lx.evalN('query layerservice polys ? selected')	
	if len(polys) != 0 :
		sel_layer = index
		layer_ID  = layer
		break
		
if len(polys) == 0 :
	sys.exit(": --- Selection error: Nothing Selected? ---")		

lx.eval('select.copy')
lx.eval('select.drop polygon')

if verbose : print "sel_layer:", sel_layer, "  layer_ID:", layer_ID, "  fg_layers:", fg_layers


# --------------------------------------------------------------------
# Get mouse over element for WP fitting / OR use existing fitted WP
# --------------------------------------------------------------------

# WP fitting
if not lx.eval('workPlane.state ?') : 
	try : lx.eval('select.3DElementUnderMouse set')
	except : sys.exit(": --- No selected mesh or active layer under mouse. Aborting. ---")
	
	if subhack : 
		# lx.eval('select.connect') # might be (too) bad for complex meshes...
		lx.eval('select.expand')
		
		lx.eval('select.copy')
		lx.eval('layer.new')
		lx.eval('select.paste')
		lx.eval('poly.freeze face false 2 true true true true 5.0 false Morph')
		new_layer = lx.eval('query layerservice layers ? selected')	
		new_ID = lx.eval1('query layerservice layer.ID ? {%s}' %new_layer)
		
		# redo selection with nice fitting...
		try : lx.eval('select.3DElementUnderMouse set')
		except : sys.exit(": --- No selected mesh or active layer under mouse. Aborting. ---")
	
		
		lx.eval('workplane.fitSelect')
		if mouse_offset :
			wp_offset = lx.eval('query view3dservice mouse.hitPos ?')
			lx.eval('workplane.edit %s %s %s' %(wp_offset[0], wp_offset[1], wp_offset[2]))
			
		# lx.eval('select.type polygon')
		lx.eval('select.all')
		lx.eval('delete')	
	
	else :
		lx.eval('workplane.fitSelect')
		if mouse_offset :
			wp_offset = lx.eval('query view3dservice mouse.hitPos ?')
			lx.eval('workplane.edit %s %s %s' %(wp_offset[0], wp_offset[1], wp_offset[2]))
	
		
else : paste_to_target = False
	

if subhack :  # Back to paste tool copying
	lx.eval('select.drop item')
	
	lx.eval('select.type polygon')
	lx.eval1('query layerservice layer.ID ? {%s}' %sel_layer) 
	lx.eval('select.subItem {%s} set' %layer_ID ) 
	
	for i in polys :
		lx.eval('select.element %s %s add %s' % (sel_layer, 'polygon', i) )
	lx.eval('select.copy')
		
		
# Get (height) offset
for p in polys :
	vl.extend(lx.evalN('query layerservice poly.vertList ? %s' %p))
	
h_offset = fn_height(vl) / 2
h_offset = ceil(h_offset * 1000.0) / 1000.0

if verbose : print "Polys:", p,"  Vertlist:", vl,"   H_offset:", h_offset


# Get target layer
if paste_to_target:	
	for layer in fg_layers :
		index = lx.eval1('query layerservice layer.index ? {%s}' %layer)
		targetpoly = lx.evalN('query layerservice polys ? selected')
		if len(polys) != 0 :
			target_ID = layer
			if verbose : print "Target Layer:", layer, "(%s)" %index
			break	


# item transform compensation workaround temp layer - part 1/2
if not subhack :
	lx.eval('layer.new')
	lx.eval('select.paste') # needed for paste.tool - avoiding empty layer issues
	new_layer = lx.eval('query layerservice layers ? selected')	
	new_ID = lx.eval1('query layerservice layer.ID ? {%s}' %new_layer)
	lx.eval('select.subItem {%s} set' %new_ID ) 

if subhack : # back to workaround layer
	lx.eval('select.drop item')
	lx.eval('select.subItem {%s} set' %new_ID ) 
	lx.eval('select.paste') # needed for paste.tool - avoiding empty layer issues
	
	
# --------------------------------------------------------------------	
# Paste selection using paste tool
# --------------------------------------------------------------------

lx.eval('tool.set paste.tool on')
lx.eval('tool.reset')
lx.eval('tool.attr paste.tool cenY {%f}' %h_offset)
lx.eval('tool.apply')	
lx.eval('tool.set paste.tool off 0')
lx.eval('workPlane.reset')

# removing temp layer - part 2/2
lx.eval('select.copy')
lx.eval('select.typeFrom item')
lx.eval('delete')

if paste_to_target and target_ID != layer_ID :
	lx.eval('select.subItem {%s} set' %target_ID ) 
	lx.eval('select.typeFrom polygon')
	lx.eval('select.paste')
	# back to source	
	lx.eval('select.subItem {%s} set' %layer_ID ) 

else :	
	# paste back into og layer
	lx.eval('select.subItem {%s} set' %layer_ID ) 
	lx.eval('select.typeFrom polygon')
	lx.eval('select.paste')

# add to selset
lx.eval('select.editSet keQuickPastePolys add keQuickPastePolys')

# reselect fg layers
if len(fg_layers) > 1 :
	for i in fg_layers :
		lx.eval('select.subItem {%s} set' %i) 
	
# ...and re-select og mesh for further pasting
lx.eval('select.drop polygon')

for i in polys :
	lx.eval('select.element %s %s add %s' % (sel_layer, 'polygon', i) )
	

#eof	