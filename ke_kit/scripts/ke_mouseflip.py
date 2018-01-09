#python

# ke_MouseFlip v1.0 - Kjell Emanuelsson 2018
#
# Selection	 : Flips your selected & connected polygons based on the mouse pointer position in relation to your selection and your viewport orientation:
# 			  If viewport is X-Y with your mouse position on the left or right side of the viewport screen , the flip will be on the X world axis. Up/Down will be Y. 
# 			  If viewport is Z-Y , left/right will be Z & up/down will be Y. and so on.
# +Fitted WP : Flips your selections in the Y axis of the fitted Workplane, for more specific angles. (Ignores mouse position)			  
#
# - Requires element selection. Will select connected elements.
# - Supports *world axis* symmetry. 
# - Axis override argument ovverides, if you want unique hotkeys per axis and wp (for pie menu).
#
# Known issue: If you undo, the WP might be locked to preferred angle. you can just reset wp to unlock. 
#
# use: "@ke_MouseFlip.py"   
#
# arguments:  x,y or z  : e.g: "@ke_MouseFlip.py x" to flip in x axis. (replace x with y or z for other axis.) (Ignores mouse position)


import math

axis = 9 
flip = "factX"
maxpos = False
vertlist = []
vX, vY, vZ = [], [], []
symmetry_mode = False
pos_poly = []
neg_poly = []
wp_fitted = False
setFixed = False
verbose = True

u_args = lx.args() 

for i in range(len(u_args)):
	if   "x" in u_args : axis = 0
	elif "y" in u_args : axis = 1	
	elif "z" in u_args : axis = 2				
	else: pass
	
# -------------------------------------------
# Check selections, screen values, mouse pos
# -------------------------------------------

sel_layer = lx.eval('query layerservice layers ? selected')	
selmode =  lx.eval('query layerservice selmode ?') 
mouse_pos = lx.eval('query view3dservice mouse.pixel ? first')


# check WP
if lx.eval('workPlane.state ?') : 
	wp_fitted = True
	axis = 1	
		
		
# symmetry check
if lx.eval('symmetry.state ?') :
	if not wp_fitted :
		symmetry_mode = True
		symmetry_axis = lx.eval('symmetry.axis ?')
		lx.eval('select.symmetryState 0')
	else :
		sys.exit(": --- Symmetry mode only supported in World Axis / Unfitted WP ---")
			
	
sel_mode = lx.eval('query layerservice selmode ?')

if sel_mode == "vertex" :
	selection = lx.evalN('query layerservice verts ? selected')
	
elif sel_mode == "edge" :
	selection = lx.evalN('query layerservice edges ? selected')
	
elif sel_mode == "polygon" :
	selection = lx.evalN('query layerservice polys ? selected')
	
if len(selection) == 0 : 
	sys.exit(": --- Selection error: Nothing Selected? ---")
else :
	lx.eval('select.connect')
	lx.eval('select.convert polygon')

polys = lx.evalN('query layerservice polys ? selected')


# ------------------------------------
# symmetry workaround
# ------------------------------------

if symmetry_mode :
	
	# sort positive & negative axis sides (de-symmetrize)
	for p in polys :
		is_positive = False
		vl = []
		vl.extend(lx.evalN('query layerservice poly.vertList ? %s' %p))
		for j in vl:
			vp = []
			vp.append(lx.eval('query layerservice vert.wdefpos ? %s' %j ))
		for v in vp :
			if v[symmetry_axis] >= 0:
				is_positive = True
				break
		
		if not is_positive :
			neg_poly.append(p)
		if is_positive :
			pos_poly.append(p)
	
	if len(neg_poly) == 0 or len(pos_poly) == 0 :
		sys.exit(": --- Symmetry Mode Active, but no symmetry polys were found on the opposite axis. Aborting. ---")
		
	else :
		# use temp selection sets to delete symmetry side (to avoid new/jumbled poly id's after delete)
		lx.eval('select.drop polygon')
		 
		for i in pos_poly :
			lx.eval('select.element %s %s add %s' % (sel_layer, 'polygon', i) )
			lx.eval('select.editSet pos_poly_ss add pos_poly_ss')
		
		lx.eval('select.drop polygon')
		
		for i in neg_poly :
			lx.eval('select.element %s %s add %s' % (sel_layer, 'polygon', i) )
		lx.eval('delete') 
		
		lx.eval('select.useSet pos_poly_ss select')
		
		# re-do after de-symmetry for new id's
		polys = lx.evalN('query layerservice polys ? selected') 

	

# --------------------------------------------------------------------------------------	
# get axis/mirror directions
# --------------------------------------------------------------------------------------	

vl = []
for i in polys :
	vl.extend(lx.evalN('query layerservice poly.vertList ? %s' %i))
vertlist = list(set(vl))

for i in vertlist :
	vp = lx.eval('query layerservice vert.wdefpos ? %s' %i )
	vX.append(vp[0])
	vY.append(vp[1])
	vZ.append(vp[2])

total = len(vertlist)	
avgX = sum(vX) / total
avgY = sum(vY) / total
avgZ = sum(vZ) / total

	
if not wp_fitted :	

	# Get main axis : Mouse pos on WP centered on selection ("local")
	lx.eval('workPlane.edit %s %s %s' %(avgX, avgY, avgZ))		
	if lx.eval('pref.value workplane.lock ?') == "unlocked" :
		lx.eval('pref.value workplane.lock locked')
		setFixed = True
		
	local_mouse_pos = lx.eval('query view3dservice mouse.pos ?')
	
	lx.eval('workPlane.reset')
	if setFixed : lx.eval('pref.value workplane.lock unlocked')
	
	# Get flip direction : ( "world" Mouse pos vs selection pos) 
	world_mouse_pos = lx.eval('query view3dservice mouse.pos ?')
	
	# Sort for largest axis on 1st mouse pos for main axis
	dX = abs(local_mouse_pos[0])
	dY = abs(local_mouse_pos[1])
	dZ = abs(local_mouse_pos[2])
	
	axis_dic = { '0':dX, '1':dY, '2':dZ }
	pick_axis = sorted(axis_dic, key=axis_dic.__getitem__)
	axis = int(pick_axis[-1])
	
	if verbose : 
		print "--------"
		print "dXYZ:", dX,dY,dZ, "   Axis:", axis, pick_axis,axis_dic
		print "LMousePos:", local_mouse_pos, "   AvgXYZ:", avgX,avgY,avgZ
		print "WMousePos:", world_mouse_pos, "    vXYZ:", vX[-1],vY[-1],vZ[-1]
		

# --------------------------------------------------------------------------------------	
# Run Scale Tool to Flip
# --------------------------------------------------------------------------------------	

lx.eval('tool.set *.mirror on')
lx.eval('tool.attr gen.mirror axis %i' %axis)
lx.eval('tool.attr gen.mirror angle 0.0')
lx.eval('tool.attr gen.mirror frot axis')

if not wp_fitted :
	lx.eval('tool.attr gen.mirror cenX %s' %avgX )
	lx.eval('tool.attr gen.mirror cenY %s' %avgY )
	lx.eval('tool.attr gen.mirror cenZ %s' %avgZ )
else :
	lx.eval('tool.attr gen.mirror cenX 0.0')
	lx.eval('tool.attr gen.mirror cenY 0.0')
	lx.eval('tool.attr gen.mirror cenZ 0.0')

lx.eval('tool.attr effector.clone flip true')
lx.eval('tool.attr effector.clone replace true')
lx.eval('tool.attr effector.clone source active')

lx.eval('tool.doApply')
lx.eval('tool.set *.mirror off')

for i in polys :
	lx.eval('select.element %s %s add %s' % (sel_layer, 'polygon', i) )

# tried "stretch" too. nothing works 100%.
	
# lx.eval('tool.set Transform on')
# lx.eval('tool.attr xfrm.transform negScale true')
# lx.eval('tool.set center.auto on')
# lx.eval('tool.attr center.auto cenX {%s}' %avgX)
# lx.eval('tool.attr center.auto cenY {%s}' %avgY)
# lx.eval('tool.attr center.auto cenZ {%s}' %avgZ)

# if axis == 0 :
	# lx.eval('tool.attr xfrm.transform SX -1.0')
	# lx.eval('tool.attr xfrm.transform SY 1.0')
	# lx.eval('tool.attr xfrm.transform SZ 1.0')
	
# elif axis == 1 :
	# lx.eval('tool.attr xfrm.transform SX 1.0')
	# lx.eval('tool.attr xfrm.transform SY -1.0')
	# lx.eval('tool.attr xfrm.transform SZ 1.0')

# elif axis == 2 :
	# lx.eval('tool.attr xfrm.transform SX 1.0')
	# lx.eval('tool.attr xfrm.transform SY 1.0')
	# lx.eval('tool.attr xfrm.transform SZ -1.0')	

# lx.eval('tool.doApply')
# lx.eval('poly.flip')
# lx.eval("tool.drop")


if wp_fitted :
	lx.eval('workPlane.reset')
	

# and mirror tool if symmetry is on
if symmetry_mode :

	lx.eval('tool.set *.mirror on')
	lx.eval('tool.attr gen.mirror axis %i' %symmetry_axis)
	lx.eval('tool.attr gen.mirror angle 0.0')
	lx.eval('tool.attr gen.mirror frot axis')

	lx.eval('tool.attr gen.mirror cenX 0.0')
	lx.eval('tool.attr gen.mirror cenY 0.0')
	lx.eval('tool.attr gen.mirror cenZ 0.0')

	lx.eval('tool.attr effector.clone flip true')
	lx.eval('tool.attr effector.clone replace false')

	lx.eval('tool.attr effector.clone merge false')

	lx.eval('tool.attr effector.clone source active')
	lx.eval('tool.doApply')
	lx.eval('tool.set *.mirror off')
	
	lx.eval('select.drop polygon')
	lx.eval('select.symmetryState 1')
	lx.eval('symmetry.axis %s' %symmetry_axis )
	lx.eval('select.clearSet pos_poly_ss type:polygon')	
	
#eof	
	