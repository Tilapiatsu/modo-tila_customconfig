#python

# ke_MouseMirror v1.0 - Kjell Emanuelsson 2018
#
# Mirrors selected mesh (select edges or polys) towards mouse pointer locally - meaning next to the bounding box (on relevant axis, as indicated by axis gizmo down left) 
# Tip: dont place mouspoint *too* close to selection, pref a bit outside selection bbox. 
# Basic world axis symmetry support.
#
# Option: Fit workplane beforehand for custom angles. (mouse placement not important)
#
# Known issue: If you undo, the WP might be locked to preferred angle. reset wp to unlock. 
#
# Argument: world  - Mirrors along world axis instead of locally.


import re

axis = 9 # NEIN / mousepos axis
xmax, ymax, zmax = True, True, True
maxpos = False
world = False
wpfitted = False
symmetry_mode = False
vertlist = []
vX, vY, vZ = [], [], []
vertpos = []
og_polys = []
og_poly_sel = []
symcheck = False
verbose = False
setFixed = False
u_args = lx.args() 

for i in range(len(u_args)):

	if "world" in u_args:
		world = True
	else: pass


def fn_getVieportWP():	
	view_srv = lx.service.View3Dport()
	current_view = lx.object.View3D(view_srv.View(view_srv.Current()))
	view_axis = current_view.WorkPlane()[:1]
	if view_axis == (2L,)   : wp = "view_XY"
	elif view_axis == (1L,) : wp = "view_XZ"
	elif view_axis == (0L,) : wp = "view_ZY"
	return wp	

	
def fn_checksym_edges() :		
	
	if symmetry_mode :
		# shouldmaybe  just refactor these to one vert check for both...
		lx.eval('select.convert vertex')
		verts = lx.evalN('query layerservice verts ? selected')
		
		neg_vert = []
		pos_vert = []
		
		# sort positive & negative axis sides (de-symmetrize)
		for i in verts :
		
			is_positive = False

			v = lx.eval('query layerservice vert.pos ? %s' %i )
			
			if v[symmetry_axis] >= 0:
				is_positive = True
		
			if not is_positive :
				neg_vert.append(i)
			if is_positive :
				pos_vert.append(i)
		
		if len(neg_vert) == 0 or len(pos_vert) == 0 :
			sys.exit(": --- Symmetry Mode Active, but no symmetry polys were found on the opposite axis. Aborting. ---")
			
		else :
			# use temp selection sets to delete symmetry side (to avoid new/jumbled poly id's after delete)
			lx.eval('select.drop vertex')
			 
			for i in pos_vert :
				lx.eval('select.element %s %s add %s' % (sel_layer, 'verts', i) )

		lx.eval('select.convert edge')
			
	else : pass
	
	
def fn_checksym() :		
	global symcheck
	polys = lx.evalN('query layerservice polys ? selected')
	
	if symmetry_mode :
		
		neg_poly = []
		pos_poly = []
		
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
			symcheck = True		
		
	else : pass
			
	return polys		
		
# ---------------------------------------
# Check selections, WP, symmetry & stuff
# ---------------------------------------

sel_layer = lx.eval('query layerservice layers ? selected') 
selmode =  lx.eval('query layerservice selmode ?') 
og_polys = lx.evalN('query layerservice polys ? all')


# symmetry check	
if lx.eval('symmetry.state ?') == True :
	symmetry_mode = True
	symmetry_axis = lx.eval('symmetry.axis ?')
	lx.eval('select.symmetryState 0')


if world:
			
	lx.eval('workPlane.reset')
	
	if selmode != 'polygon' :
		sys.exit(": Selection not supported in world axis mode: Select polygons.")
		
	else :
		p = lx.evalN('query layerservice polys ? selected')
		if len(p) != 0 :
			lx.eval('select.connect')
		else : sys.exit(": Selection error: Nothing Selected.")		
	
	
else :

	# selection mode -> mirror type 
	if selmode == 'edge' :
	
		if len(lx.evalN('query layerservice edges ? selected')) == 0 :
			sys.exit(": Selection error: Nothing Selected.") 
			
		lx.eval('select.typeFrom polygon')
		if len(lx.evalN('query layerservice polys ? selected')) != 0 :
			lx.eval('select.connect')
		
		lx.eval('select.typeFrom edge')
		
		if symmetry_mode :
			# Silly just to save initial selection for sel.connect..
			e = lx.evalN('query layerservice edges ? selected')
			og_edges = []
			for i in e :
				intlist_tuple = [int(i) for i in re.findall(r'\d+', i)]
				og_edges.append(intlist_tuple)	
				
			fn_checksym_edges()
			
		lx.eval('workPlane.fitSelect')
		
		if symmetry_mode :
			for i in og_edges : #reselecting due to symcheck
				lx.eval('select.element %s %s add %s %s' % (sel_layer, 'edge', i[0], i[1]))
		
		lx.eval('select.connect')
		lx.eval('select.convert polygon')
		
		og_poly_sel = fn_checksym()
		
		for i in og_poly_sel :
			lx.eval('select.element %s %s add %s' % (sel_layer, 'polygon', i) )
		
	elif selmode == 'polygon' :
		p = lx.evalN('query layerservice polys ? selected')
		if len(p) != 0 :
			lx.eval('select.connect')
			p = fn_checksym()
			
		else : sys.exit(": Selection error: Nothing Selected.") 
			
	else : sys.exit(": Selection not supported in local mirror mode: Select polys or edges.")	
	
	if lx.eval('workPlane.state ?') :
		wpfitted = True
		axis = 1

	
	
# --------------------------------------------------------------------------------------	
# get axis/mirror directions
# --------------------------------------------------------------------------------------	

if not wpfitted :	


	vl = []
	for i in p :
		vl.extend(lx.evalN('query layerservice poly.vertList ? %s' %i))
	vertlist = list(set(vl))

	for i in vertlist :
		vp = lx.eval('query layerservice vert.wdefpos ? %s' %i )
		vX.append(vp[0])
		vY.append(vp[1])
		vZ.append(vp[2])
	
	if axis == 9 : # if axis is NEIN; set axis by mouse_pos (2 querys)
		total = len(vertlist)	
		avgX = sum(vX) / total
		avgY = sum(vY) / total
		avgZ = sum(vZ) / total
		
		
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
		
	vX.sort()
	vY.sort()
	vZ.sort()	

	# set flip direction based on 2nd mouse sample ("world")
	if not world :
		if axis == 0 :
			cenY = vY[0] 
			cenZ = vZ[0] 
			if world_mouse_pos[0] >= vX[-1] :
				cenX = vX[-1]  
			else :
				cenX = vX[0]  
				
		elif axis == 1 :		
			cenX = vX[0] 
			cenZ = vZ[0] 
			if world_mouse_pos[1] >= vY[-1] :
				cenY = vY[-1]  
			else :
				cenY = vY[0]  
			
		elif axis == 2 :		
			cenY = vY[0] 
			cenX = vX[0] 
			if world_mouse_pos[2] >= vZ[-1] :
				cenZ = vZ[-1]  
			else :
				cenZ = vZ[0]
				
	else : cenX, cenY, cenZ = 0, 0, 0				
		
		
# -----------------------------		
# Run mirror tool
# -----------------------------		

lx.eval('tool.set *.mirror on')
lx.eval('tool.attr gen.mirror axis %i' %axis)
lx.eval('tool.attr gen.mirror angle 0.0')
lx.eval('tool.attr gen.mirror frot axis')

if not wpfitted :
	lx.eval('tool.attr gen.mirror cenX %s' %cenX )
	lx.eval('tool.attr gen.mirror cenY %s' %cenY )
	lx.eval('tool.attr gen.mirror cenZ %s' %cenZ )
else :
	lx.eval('tool.attr gen.mirror cenX 0.0')
	lx.eval('tool.attr gen.mirror cenY 0.0')
	lx.eval('tool.attr gen.mirror cenZ 0.0')

lx.eval('tool.attr effector.clone flip true')
lx.eval('tool.attr effector.clone replace false')

if selmode == 'edge':
	lx.eval('tool.attr effector.clone merge true')
	lx.eval('tool.attr effector.clone dist 0.01') # fixes small WP bugged fittings, not all...
else :
	lx.eval('tool.attr effector.clone merge false')
	# lx.eval('tool.attr effector.clone dist 0.0') # disabled?

lx.eval('tool.attr effector.clone source active')
lx.eval('tool.doApply')
lx.eval('tool.set *.mirror off')


# select mirrored polys
lx.eval('select.drop polygon')
all_polys = lx.evalN('query layerservice polys ? all')
new_polys = [i for i in all_polys if i not in og_polys]
for i in new_polys :
	lx.eval('select.element %s %s add %s' % (sel_layer, 'polygon', i) )
	
if symcheck :
	lx.eval('select.useSet pos_poly_ss select')	

if selmode == 'edge' :
	lx.eval('select.connect')
	lx.eval('workPlane.reset')

if symmetry_mode and not world:
	# Run mirror tool...again!
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


if symmetry_mode :

	lx.eval('select.symmetryState 1')
	lx.eval('symmetry.axis %s' %symmetry_axis )
	lx.eval('select.clearSet pos_poly_ss type:polygon')	
		
#eof	