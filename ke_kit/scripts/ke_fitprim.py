#python#

# ke_fitprim 2.43 - Kjell Emanuelsson 2017
#
# 2.43 : Default to poly from item mode, Unitconversion fixes
# 2.41 : Added unit conversion (All SI & Imperial units + Game Units)
# 2.3  : No-Select symmetry fix 
# 2.2  : Fixed the fix...
# 2.1  : Fixed item transform compensation issue (from vert position type) 
#
# Description : Creates unit size (+length fitting modes) primitives based on different types of selection. First selected "island" is intended prim pos/size.
#				Uses modos built in primitive tool for prim settings/creation. (user argument overrides available for sides and segments values)
#				Multiple item support (only processes first two items) --> Item Selection order important <-- First item selections always first island.
#				Basic symmetry support (world axis ONLY - does not support item transform compensation or workplane symmetry: checks sym settings & then just mirrors used axis)
#
# Selections:	Nothing		 : Creates a unit prim of 25cm at mouse position. (value override argument available)
#				1 vertex	 : Unit prim at vert position, sized by shortest connected edge.
#				2 vertices	 : Prim from vert to vert, using the distance for length + shortest connected edge to initial vert for unit side sizes.
#				Edges(cont.) : Unit prim at continous edge(s) 'single island', size by total edge length. 
#				Edges(sep.)	 : Selection based island sorting of edges - fits unit between separate edge selections at closest point (if uneven lengths of edge selections) Size by distance between edge selections.			
#				Polys(cont.) : Single-island polygon(s) selection unit prim, sized by boundary/perimeter-> side size.
#				Polys(sep.)	 : Selection based island sorting of polygons - second island used to create a plane to which distance(=Height/Length) from first island is used for prim.			
#			
# Usage :		Run in command line with "@ke_fitprim.py", assign to hotkey or pie menu. With optional arguments below (with space betweeen). E.g: "ke_fitprim.py cylinder 1.0"
#				Lowercase. Argument order not important - except float values: One value = unit size. Two values = sides & segments. Three = 1st is unitsize, then sides & segments.
#				Note: Cube has three values (x,y,z), just using one for all axis for now (side), just enter it twice, as if it was sides & segments as above.
#
# Arguments :	cylinder	 : (Cube is default, does not need argument) Use cylinder to assign for cylinder creation instead.
#				sphere		 : uses sphere primitive tool instead
#				cone		 : uses cone primitive tool instead
#				float value	 : Sets the default unitsize for non-selection prims. Using floating point values: 0.25 = 25cm, 1.0 = 1m  (see above for order of float entries)
#				select		 : Selects resulting primitive afterwards (useful for additional steps in macros: auto activating move tool or something if you like)
#				norotate	 : Keeps resulting prim aligned to closest world axis.
 
from math import sqrt, pi
import re

u_args = lx.args() 

# variables 
unitsize = 0.25
userval_mode = False
userval = []

set_prim = "prim.cube"
prim_pos = [0,0,0]
length = 0
sel_count = 0
wp_center = [0,0,0]

layers = []
layer_index = []
layer_id = []
selected_verts = []
selected_edges = []
selected_polys = []
selected_index_list = []
side_sizes = []
vert_pos = []
edge_lengths = []
edgelen = []
layers = []

multilayer = False
symmetry_mode = False
default_fit = False
two_vert_fit = False
is_selection = True
single_island_mode = True
edge_island_fit = False
single_poly_fit = False
poly_island_fit = False
select = False
keepwp = False
pi_mode = False
sym_pos = False
norotate = False

# user arguments
for i in range(len(u_args)):
	if "cylinder" in u_args:
		set_prim = "prim.cylinder"
	elif "sphere" in u_args:
		set_prim = "prim.sphere"	
	elif "cone" in u_args:
		set_prim = "prim.cone"	
	if "norotate" in u_args:
		norotate = True		
	if "select" in u_args:
		select = True
	if "keepwp" in u_args:
		keepwp = True			
	else: pass
		
for nr in u_args :
	try:
		userval.append(float(nr))
	except ValueError:
		continue	

userval_check = len(userval)	
	
if userval_check == 1 :	
	unitsize = userval[0]
	
elif userval_check == 2 :	
	userval_mode = True
	userval.insert(0, unitsize)	
	
elif userval_check == 3 :
	userval_mode = True	
	unitsize = userval[0]
	
else :
	if userval_check != 0 :	
		sys.exit(": User float value input error - Aborting")
		

# Functions
def fn_dist(v1, v2):
	dist = dist = [(a - b)**2 for a, b in zip(v1, v2)]
	dist = sqrt(sum(dist))
	return dist	

	
def fn_crossproduct_coordlist(coordlist):
	x1,y1,z1 = coordlist[0][0], coordlist[0][1], coordlist[0][2]
	x2,y2,z2 = coordlist[1][0], coordlist[1][1], coordlist[1][2]	
	x3,y3,z3 = coordlist[2][0], coordlist[2][1], coordlist[2][2]
	
	v1 = [x2 - x1, y2 - y1, z2 - z1]
	v2 = [x3 - x1, y3 - y1, z3 - z1]
	
	cross_product = [v1[1] * v2[2] - v1[2] * v2[1], -1 * (v1[0] * v2[2] - v1[2] * v2[0]), v1[0] * v2[1] - v1[1] * v2[0]]	

	return cross_product


def fn_avgpos(poslist):
	posX, posY, posZ = [], [], []

	for i in poslist:
		posX.append(i[0])
		posY.append(i[1])
		posZ.append(i[2])

	avgX = sum(posX) / len(poslist)
	avgY = sum(posY) / len(poslist)
	avgZ = sum(posZ) / len(poslist)
	
	return avgX, avgY, avgZ

def fn_avg_vpos(vertlist):
	vertsinX = []
	vertsinY = []
	vertsinZ = []	
	for i in vertlist:
		vert_pos = lx.eval('query layerservice vert.wdefpos ? ' + str(i))
		vertsinX.append(vert_pos[0])
		vertsinY.append(vert_pos[1])
		vertsinZ.append(vert_pos[2])

	avgX = sum(vertsinX) / len(vertlist)
	avgY = sum(vertsinY) / len(vertlist)
	avgZ = sum(vertsinZ) / len(vertlist)
	
	return avgX, avgY, avgZ


def fn_midpoint(p1, p2):
	midP = [(p1[0]+p2[0])/2, (p1[1]+p2[1])/2, (p1[2]+p2[2])/2]
	return midP
	
	
def fn_edge_midpoint(first_island_pos1, first_island_pos2, second_island_pos):
	
	target_pos = second_island_pos
	
	# Interpolate new midpoint candidates on long edge
	mid_point_list = []
	interval = 100
	
	for i in range(1, interval):
		ival = float(i) / interval
		x = (1 - ival) * first_island_pos1[0] + ival * first_island_pos2[0] 
		y = (1 - ival) * first_island_pos1[1] + ival * first_island_pos2[1] 
		z = (1 - ival) * first_island_pos1[2] + ival * first_island_pos2[2] 
		mid_point_list.append([x, y, z])

	# pick closest candidate	
	new_mid_point = []
	
	for i in mid_point_list:
		a = fn_dist(target_pos, i)
		ins = [a, i]
		new_mid_point.append(ins)  
		
	new_mid_point.sort()
	
	distance = new_mid_point[0][0]
	newEndPos = new_mid_point[0][-1]	
	position = fn_midpoint(newEndPos, target_pos)
	
	return distance, position
	
	
def fn_sortRows(loopEdges):
	rowList = []
	vertRow = []
	
	while (len(loopEdges)-1) > 0 :
		vertRow = [loopEdges[0][0], loopEdges[0][1]]
		loopEdges.pop(0)
		rowList.append(vertRow)	
		
		for n in xrange(0, len(loopEdges)):
			i = 0 
			for edgeverts in loopEdges:
				if vertRow[0] == edgeverts[0]:
					vertRow.insert(0, edgeverts[1] )
					loopEdges.pop(i)
					break
				elif vertRow[0] == edgeverts[1]:
					vertRow.insert(0, edgeverts[0] )		
					loopEdges.pop(i)
					break
				elif vertRow[-1] == edgeverts[0]:
					vertRow.append(edgeverts[1] )		
					loopEdges.pop(i)
					break
				elif vertRow[-1] == edgeverts[1]:
					vertRow.append(edgeverts[0] )		
					loopEdges.pop(i)	
					break
				else:
					i = i + 1	
	return vertRow

	
def fn_convert_unit(sizevalue):	
	check_unit = lx.eval('pref.value units.default ?')		
	if check_unit != "meters" :
		sfactor = 1
		# SI
		if check_unit == "millimeters"	 : sfactor = 1000
		elif check_unit == "micrometers" : sfactor = 1000000
		elif check_unit == "kilometers"	 : sfactor = 0.001	
		# Imperial
		elif check_unit == "inches" : return sizevalue / 0.0254
		elif check_unit == "feet"	: return sizevalue / 0.3048
		elif check_unit == "miles"	: return sizevalue / 0.00062137
		elif check_unit == "mils"	: return sizevalue / 39370.078740157
		# Game Units	
		elif check_unit == "units" : 
			sfactor = lx.eval('pref.value units.gameScale ?')
			return sizevalue / sfactor	
		# default rest(if any?)
		else : pass
		return sizevalue * sfactor		
	else : return sizevalue			
	

# ----------------------
# Initial checks
# ----------------------	

# store og workplane to re-apply later (just one query doesn't work?)
if lx.eval('workPlane.state ?') :
	keepwp = True
	lx.setOption("queryAnglesAs", "degrees")
	wpX	 = lx.eval("workplane.edit ? 0 0 0 0 0")
	wpY	 = lx.eval("workplane.edit 0 ? 0 0 0 0")
	wpZ	 = lx.eval("workplane.edit 0 0 ? 0 0 0")
	wprX = lx.eval("workplane.edit 0 0 0 ? 0 0")
	wprY = lx.eval("workplane.edit 0 0 0 0 ? 0")
	wprZ = lx.eval("workplane.edit 0 0 0 0 0 ?")	

	
# Layers
sel_mode = lx.eval('query layerservice selmode ?')

if sel_mode != "polygon" :
	if sel_mode != "edge" :
		if sel_mode != "vertex" :
			if sel_mode == "item":
				# just gonna go ahead and default this then...
				lx.eval('select.typeFrom polygon')
				sel_mode = 'polygon'
			else :	
				sys.exit(": --- Selection Mode Error : Please select verts, edges or polygons. ---")

sel_layer = lx.eval('query layerservice layers ? selected')
layers_check = lx.eval('query layerservice layers ? fg')

if type(layers_check) == tuple : 
	layers = [i for i in layers_check]
else: 
	layers = [layers_check]
	
# symmetry check	
if lx.eval('symmetry.state ?') == True :
	symmetry_mode = True
	symmetry_axis = lx.eval('symmetry.axis ?')
	lx.eval('select.symmetryState 0')
	select = True

# ---------------------------------------------------------------------------	
# Grabbing selection indexes, vert pos's, sizes etc for processing later
# ---------------------------------------------------------------------------
for layer in layers :

	index = lx.eval1('query layerservice layer.index ? %s' %layer)
	layer_index.append(index)
	
	if sel_mode == "vertex" :
		v = lx.evalN('query layerservice verts ? selected')

		if layer == sel_layer : 
			if len(v) == 0:
				is_selection = False
				break
			
		selected_index_list.append(v)
		
		if symmetry_mode : # qnd 'de-symmetry'
			v = v[0::2]		

		selected_verts.append(v)	
		vp = []
		for i in v :
			vp.append(lx.eval('query layerservice vert.pos ? %s' %i ))
		vert_pos.append(vp)	
		
		if layer == sel_layer : # get size from initial selection shortest edge
			vertlist = lx.evalN('query layerservice vert.vertList ? %s' %selected_verts[0][0] )
			
			for i in vertlist:
				selected_edges.append( (int(selected_verts[0][0]), i) )
			
			for i in selected_edges : # couldn't use vertList indexes w/o select.e to get length...
				lx.eval('select.element %s %s add %s %s' % (sel_layer, 'edge', i[0], i[1]))

			e = lx.evalN('query layerservice edges ? selected')
			for i in e :
				edge_lengths.append( lx.eval('query layerservice edge.length ? %s' %i) )
			
			edge_lengths.sort()
			edgelen = edge_lengths[0]
	
	
	elif sel_mode == "edge" :
			
		e = lx.evalN('query layerservice edges ? selected')
		
		if layer == sel_layer : 
			if len(e) == 0:
				is_selection = False
				break
	
		selected_index_list.append(e)
		
		edgesort = []
		for i in e :
			intlist_tuple = [int(i) for i in re.findall(r'\d+', i)]
			edgesort.append(intlist_tuple)	
		
		# Sorting selected polys with world axis symmetry check
		vp = []
		sv = []
		addedges = []
		sizes = []
		
		for edge in edgesort:
			el = edge
			vps = []
			for v in edge:
				vps.append(lx.eval('query layerservice vert.wdefpos ? %s' %v))
				
			if symmetry_mode :
				for c in vps :
					if c[symmetry_axis] >= 0:
						vp.extend(vps)
						sv.extend(el)
						addedges.append(edge)
						if layer == sel_layer :
							side_sizes.append( lx.eval('query layerservice edge.length ? %s' %edge) )
						break
			else :
				vp.extend(vps)
				sv.append(el)	
				addedges.append(edge)
				if layer == sel_layer :
					side_sizes.append( lx.eval('query layerservice edge.length ? %s' %edge) )
						
		selected_edges.append(addedges)
		vert_pos.append(vp)	
		selected_verts.append(sv)
		
		
	elif sel_mode == "polygon" :
		p = lx.evalN('query layerservice polys ? selected')
		
		if layer == sel_layer : 
			if len(p) == 0:
				is_selection = False
				break

		selected_index_list.append(p)
		
		# Sorting selected polys with world axis symmetry check
		vp = []
		sv = []
		addpolys = []
		
		for i in p:
			vl = lx.evalN('query layerservice poly.vertList ? %s' %i)
			
			vps= []
			for vert in vl:
				vps.append(lx.eval('query layerservice vert.wdefpos ? %s' %vert ))	
			
			if symmetry_mode :
				for c in vps :
					if c[symmetry_axis] >= 0:
						vp.extend(vps)
						sv.append(vl)
						addpolys.extend(i)
						break
			else :
				vp.extend(vps)
				sv.append(vl)	
				addpolys.append(i)
						
		selected_polys.append(addpolys)
		vert_pos.append(vp)	
		selected_verts.append(sv)

		# using boundary for sizes, later	
		
		
	else : sys.exit(": ---> Element Selection Error - Aborting <---")	

	
# Re-selecting first selected layer 
lx.eval1('query layerservice layer.index ? %s' %sel_layer)	
	
if is_selection :	

	# multi layer mode check	
	selected_index_list = list(filter(None, selected_index_list))

	if len(selected_index_list) > 1 :
		multilayer = True

	# store for later - sel_layer (= primitive creation layer) only
	verts_all = lx.evalN('query layerservice verts ? all')

	
	# Pick process by selections
	if sel_mode == "vertex" :

		sel_count_verts = filter(None, selected_verts)
		
		if multilayer :
			for i in sel_count_verts :
				sel_count += len(i)
		else:	
			sel_count = len(sel_count_verts[0])
		
		if sel_count == 1:
			default_fit = True
		elif sel_count == 2:
			two_vert_fit = True
		else :
			default_fit = True
	
		# Select relevant elements after de-symmetry
		if symmetry_mode :
			lx.eval('select.drop vertex')	
			
			if multilayer :
				for index, verts in zip(layer_index, selected_verts):	
					lx.eval1('query layerservice layer.index ? %s' %index)	
					for i in verts :
						lx.eval('select.element %s %s add %s' % (index, 'vertex', i) )					
			else :
				for i in selected_verts[0] :
					lx.eval('select.element %s %s add %s' % (sel_layer, 'vertex', i) )

		
	elif sel_mode == "edge" :
		
		sel_count_edges = filter(None, selected_edges)
		
		if multilayer :
			for i in sel_count_edges :
				sel_count += len(i)
		else:
			sel_count = len(selected_edges[0])

		if sel_count == 1:
			default_fit = True
		else :
			edge_island_fit = True		
			
		if symmetry_mode :	
			lx.eval('select.drop edge')	
			if multilayer :
				for index, edges in zip(layer_index, selected_edges):	
					lx.eval1('query layerservice layer.index ? %s' %index)	
					for i in edges :
						lx.eval('select.element %s %s add %s %s' % (index, 'edge', i[0], i[1]) )					
			else :
				for i in selected_edges[0] :
					lx.eval('select.element %s %s add %s %s' % (sel_layer, 'edge', i[0], i[1]) )	

						
	elif sel_mode == "polygon" :
	
		# selected_polys = lx.evalN('query layerservice polys ? selected')
		symfit_polys = selected_polys
	
		sel_count_polys = filter(None, selected_polys)
		
		if multilayer :
			for i in sel_count_polys :
				sel_count += len(i)
		else:	
			sel_count = len(sel_count_polys[0])		
		
		if sel_count != 0 :
			is_selection = True
			poly_island_fit = True	

		if symmetry_mode :			
			lx.eval('select.drop polygon')		
			
			if multilayer :
				for index, polys in zip(layer_index, selected_polys):	
					lx.eval1('query layerservice layer.index ? %s' %index)	
					for i in polys :
						lx.eval('select.element %s %s add %s' % (index, 'polygon', i) )					
			else :
				for i in selected_polys[0] :
					lx.eval("select.element %s %s add %s 0 0" % (sel_layer, 'polygon', i))	

	else: 
		sys.exit(": ---> Invalid selecion - Aborting operation <---")

# --------------------------
# Sizes and wp fitting	
# --------------------------

if multilayer : # re-selecting layer again
	lx.eval1('query layerservice layer.index ? %s' %sel_layer)	
	
if not is_selection :

	# store for later - sel_layer (= primitive creation layer) only
	verts_all = lx.evalN('query layerservice verts ? all')
	
	setmousepos = []
	mouse_pos = lx.eval('query view3dservice mouse.pos ?')
	for i in mouse_pos:
		setmousepos.extend([i])	

	side_size, length = unitsize, unitsize	
	prim_pos = mouse_pos	
	
elif default_fit :

	if sel_mode == "vertex" :
		side_size, length = edgelen, edgelen			
	
	if sel_mode == "edge" :
		side_size, length = side_sizes[0], side_sizes[0]		
	
	lx.eval('workPlane.fitSelect')		

	
elif two_vert_fit :

	single_island_mode = False
	side_size = edgelen
	
	point_verts = []
	
	if multilayer :
		point_verts.append(vert_pos[0][0])
		point_verts.append(vert_pos[1][0])
	else :
		point_verts.append(vert_pos[0][0])
		point_verts.append(vert_pos[0][1])
		
	length = fn_dist(point_verts[0], point_verts[1])
		
	# using temp verts for (better) fitting wp		
	lx.eval('select.typeFrom vertex')
	lx.eval('select.drop vertex')
		
	for i in point_verts :
		lx.eval('vert.new %s %s %s' % (i[0], i[1], i[2]))
		
	verts_all_new = lx.evalN('query layerservice verts ? all')
	og_vert_set = set(verts_all)
	new_verts = [i for i in verts_all_new if not i in og_vert_set]

	lx.eval("select.element %s %s add %s 0 0" % (sel_layer, 'vertex', new_verts[0]))
	lx.eval("select.element %s %s add %s 0 0" % (sel_layer, 'vertex', new_verts[1]))

	lx.eval('workPlane.fitSelect')	
	lx.eval('vert.remove')		
	

elif edge_island_fit :	

	if multilayer : # all of first selected mesh layer always 'first island'
		
		if len(selected_edges[0]) == 1 :
			first_island = selected_edges[0][0]
		else :
			first_island = fn_sortRows(selected_edges[0])
			
		if len(selected_edges[1]) == 1 :	
			second_island = selected_edges[1][0]
		else :	
			second_island = fn_sortRows(selected_edges[1])
			
		edge_first_point = lx.eval('query layerservice vert.wdefpos ? %s' %first_island[0] )
		edge_second_point = lx.eval('query layerservice vert.wdefpos ? %s' %first_island[-1] )
		second_island_point = fn_avgpos(vert_pos[1])
		
		length, wp_center = fn_edge_midpoint(edge_first_point, edge_second_point, second_island_point)	
		side_size = sum(side_sizes)
		
		lx.eval('workPlane.fitSelect')	
		lx.eval('workPlane.edit %s %s %s' %(wp_center[0], wp_center[1], wp_center[2]))
		
		if set_prim != "prim.cube" :
			wp_offset = length * -0.5
			wp_offset = fn_convert_unit(wp_offset)
			lx.eval('workPlane.offset 1 [%f]' %wp_offset)	
			
		
	else : # same layer island sorting2
		verts_all_selected = [i for j in selected_edges[0] for i in j]	
		
		first_island = fn_sortRows(selected_edges[0])
		second_island = [i for i in verts_all_selected if i not in first_island]
		second_island = list(set(second_island))
		
		# weak sorting inconsistency fix (modo sometimes flips edge sel order?)
		if len(second_island) > len(first_island) :
			first_island, second_island = second_island, first_island
	
		if len(second_island) >= 1 : single_island_mode = False
		
		edge_first_point = lx.eval('query layerservice vert.wdefpos ? %s' %first_island[0] )
		edge_second_point = lx.eval('query layerservice vert.wdefpos ? %s' %first_island[-1] )
		side_size = fn_dist(edge_first_point, edge_second_point)

		if not single_island_mode : 

			second_island_point = fn_avg_vpos(second_island)	
	
			length, wp_center = fn_edge_midpoint(edge_first_point, edge_second_point, second_island_point)
			
			lx.eval('workPlane.fitSelect')	
			lx.eval('workPlane.edit %s %s %s' %(wp_center[0], wp_center[1], wp_center[2]))
			
		else :	
			length = side_size	
			
			lx.eval('select.convert vertex')
			lx.eval('workPlane.fitSelect')	
	
			if set_prim == "prim.cube" :
				wp_offset = length * 0.5
				wp_offset = fn_convert_unit(wp_offset)
				lx.eval('workPlane.offset 1 [%f]' %wp_offset)	
			
		
elif poly_island_fit :		

	# ------------------------	
	#	Island Sorting
	# ------------------------
	if multilayer :
		
		first_island = [i for j in selected_verts[0] for i in j]
		second_island = [i for j in selected_verts[1] for i in j]
		
		if len(second_island) > 2 :
				single_island_mode = False
				
	else :
		verts_all_selected = [i for j in selected_verts[0] for i in j]	

		first_island = [i for i in selected_verts[0][0]]	
		polyvert_list = selected_verts[0]
		
		if len(selected_polys[0]) > 1 :
			vert_count = (len(verts_all_selected) * 2)
			index_count = len(first_island)
			
			while index_count < vert_count :
				for polyverts in polyvert_list :
					index_count = index_count + 1	
					for i in polyverts :
						if i in first_island :
							for x in polyverts :
								if x not in first_island : 
									first_island.extend(polyverts) 

			second_island = [i for i in verts_all_selected if i not in first_island]
			second_island = list(set(second_island))

			# some edge case fixes - may or may not be needed...
			if len(second_island) > 2 :
				single_island_mode = False

	# Use pi for ngons (for flat cyl caps, starting at 6 to accomodate some regular ngons)
	if len(selected_verts[0][0]) >= 6 :
		pi_mode = True	
		
	# single poly size from shortest edge unless ngon
	if pi_mode == False and len(first_island) <= 4:
		single_poly_fit = True
		
		
	# ------------------------	
	#	QnD Boundary & Sizes
	# ------------------------
	
	lx.eval('select.drop edge')
	lx.eval('select.typeFrom vertex')
	lx.eval('select.drop vertex')

	# Get perimeter for sizes
	for i in first_island :
		lx.eval("select.element %s %s add %s 0 0" % (sel_layer, 'vertex', i))
	lx.eval('select.convert polygon')
	lx.eval('select.boundary')
	
	if single_poly_fit :
		edges = []
		for i in lx.evalN('query layerservice edges ? selected') :
			edges.append(lx.eval('query layerservice edge.length ? %s' % i))	
			edges.sort()
			
		perimeter = edges[0]	
	else :	
		perimeter = sum(lx.eval('query layerservice edge.length ? %s' % i)
						for i in lx.evalN('query layerservice edges ? selected'))

	lx.eval('select.drop edge')				

	if single_poly_fit :
		side_size = perimeter
	elif pi_mode :
		side_size = perimeter / pi
	else :
		side_size = perimeter / 4
		
	# ------------------------	
	#	Point2Plane - Length
	# ------------------------
	if not single_island_mode :	
	
		if multilayer :
			point_verts = vert_pos[0]
			plane_verts = vert_pos[1]
			first_point = fn_avgpos(vert_pos[0])
			
		else :
			# just getting these again...should rewrite, sometime
			first_point = fn_avg_vpos(first_island)
			
			plane_verts = [] 
			for i in second_island :
				plane_verts.append(lx.eval('query layerservice vert.wdefpos ? %s' %i ))
			
			point_verts = []
			for i in first_island :
				point_verts.append(lx.eval('query layerservice vert.wdefpos ? %s' %i ))
		
		#cross source selection 
		cross_product = fn_crossproduct_coordlist(point_verts)

		sqrLenN = cross_product[0] * cross_product[0] + cross_product[1] * cross_product[1] + cross_product[2] * cross_product[2]
		invLenN = 1.0 / sqrt( sqrLenN )
		rayDir = [cross_product[0] * invLenN, cross_product[1] * invLenN, cross_product[2] * invLenN]
		
		#cross target plane	 
		cross_product = fn_crossproduct_coordlist(plane_verts)
		
		x2,y2,z2 = plane_verts[1][0], plane_verts[1][1], plane_verts[1][2]
		x,y,z = first_point[0], first_point[1], first_point[2]
		
		sqrLenN = cross_product[0] * cross_product[0] + cross_product[1] * cross_product[1] + cross_product[2] * cross_product[2]
		
		if sqrLenN != 0 :
			invLenN = 1.0 / sqrt( sqrLenN )
			planeN = [cross_product[0] * invLenN, cross_product[1] * invLenN, cross_product[2] * invLenN]

			planeD = -( planeN[0] * x2 + planeN[1] * y2 + planeN[2] * z2 )

			d1 = planeN[0] * x + planeN[1] * y + planeN[2] * z + planeD
			d2 = planeN[0] * rayDir[0] + planeN[1] * rayDir[1] + planeN[2] * rayDir[2]
		
			if d2 == 0 :
				length = 0
			else :	
				length = -( d1 / d2 )

		# planeP = [ x + rayDir[0] * rayLen, y + rayDir[1] * rayLen, z + rayDir[2] * rayLen ] # project-align points on plane, maybe if i make the prim)

		# & in case the plane returns zero (or 2mm near) use side size 
		if length -0.001 <= 0 <= 0.001:
			length = side_size
			
	else:
		length = side_size
		
		
	# ------------------------	
	#	Fit WP
	# ------------------------
	
	if not single_island_mode :	
	
		lx.eval('select.typeFrom polygon')
		lx.eval('workPlane.fitSelect')
		wp_offset = length * 0.5
		wp_offset = fn_convert_unit(wp_offset)
		lx.eval('workPlane.offset 1 [%f]' %wp_offset)	
		
	else :
		lx.eval('select.typeFrom %s' % sel_mode)
		lx.eval('workPlane.fitSelect')	
	
		if set_prim == "prim.cube" :
			wp_offset = length * 0.5
			wp_offset = fn_convert_unit(wp_offset)
			lx.eval('workPlane.offset 1 [%f]' %wp_offset)	
		

		
		
# ---------------------------------------------
# Unit conversion
# ----------------------------------------------	

side_size = fn_convert_unit(side_size)
length = fn_convert_unit(length)
newpp = []
for i in prim_pos :
	newpp.append(fn_convert_unit(i))
prim_pos = newpp	

print "----"
print side_size, length 
print is_selection, prim_pos
	
# --------------------------------------
# Make prim (could prob tighten this up, but nah)
# --------------------------------------
if norotate :
	wX = lx.eval("workplane.edit 0 0 0 ? 0 0")
	wY = lx.eval("workplane.edit 0 0 0 0 ? 0")
	wZ = lx.eval("workplane.edit 0 0 0 0 0 ?")	
	wX = round(wX / 90) * 90
	wY = round(wY / 90) * 90
	wZ = round(wZ / 90) * 90
	lx.eval('workPlane.edit rotX:[%s] rotY:[%s] rotZ:[%s]' %(wX, wY, wZ))

lx.eval('tool.set [%s] on 0' %set_prim)
	
if set_prim == "prim.cube" :
	if userval_mode :		
		lx.eval('tool.attr [%s] segmentsX [%s]'	 %(set_prim, userval[1]) )
		lx.eval('tool.attr [%s] segmentsY [%s]'	 %(set_prim, userval[1]) )
		lx.eval('tool.attr [%s] segmentsZ [%s]'	 %(set_prim, userval[1]) )
	
	if not single_island_mode :
		if edge_island_fit or poly_island_fit :
			lx.eval('tool.setAttr [%s] cenX [%s]' %(set_prim, prim_pos[0]) )
			lx.eval('tool.setAttr [%s] cenY [%s]' %(set_prim, prim_pos[1]) )
			lx.eval('tool.setAttr [%s] cenZ [%s]' %(set_prim, prim_pos[2]) )
		else :
			lx.eval('tool.setAttr [%s] cenX [%s]' %(set_prim, prim_pos[0]) )
			lx.eval('tool.setAttr [%s] cenY [%s]' %(set_prim, prim_pos[1]) )
			lx.eval('tool.setAttr [%s] cenZ [%s]' %(set_prim, length / 2) )
		
	else :
		lx.eval('tool.setAttr [%s] cenX [%s]' %(set_prim, prim_pos[0]) )
		lx.eval('tool.setAttr [%s] cenY [%s]' %(set_prim, prim_pos[1]) )
		lx.eval('tool.setAttr [%s] cenZ [%s]' %(set_prim, prim_pos[2]) )
		
	if edge_island_fit :	
		lx.eval('tool.attr [%s] sizeX [%s]' %(set_prim, length) )
		lx.eval('tool.attr [%s] sizeY [%s]' %(set_prim, length) )
		lx.eval('tool.attr [%s] sizeZ [%s]' %(set_prim, length) )
	elif poly_island_fit :
		lx.eval('tool.attr [%s] sizeX [%s]' %(set_prim, side_size) )
		lx.eval('tool.attr [%s] sizeY [%s]' %(set_prim, length) )
		lx.eval('tool.attr [%s] sizeZ [%s]' %(set_prim, side_size) )
	else :
		lx.eval('tool.attr [%s] sizeX [%s]' %(set_prim, side_size) )
		lx.eval('tool.attr [%s] sizeY [%s]' %(set_prim, side_size) )
		lx.eval('tool.attr [%s] sizeZ [%s]' %(set_prim, length) )
	
	
if set_prim == "prim.cylinder" or set_prim == "prim.sphere" or set_prim == "prim.cone" :
	if userval_mode :	
		lx.eval('tool.attr [%s] sides %s'  %(set_prim, userval[1]) )
		lx.eval('tool.attr [%s] segments %s'  %(set_prim, userval[2]) )

	if not single_island_mode :
		if edge_island_fit :
			lx.eval('tool.setAttr [%s] cenZ 0' % set_prim )
			lx.eval('tool.setAttr [%s] cenX 0' % set_prim )
			lx.eval('tool.setAttr [%s] cenY 0' % set_prim )
			lx.eval('tool.setAttr [%s] axis y' %set_prim )
			
		elif poly_island_fit :	
			lx.eval('tool.setAttr [%s] axis y' %set_prim )
			lx.eval('tool.setAttr [%s] cenX [%s]' %(set_prim, prim_pos[0]) )
			lx.eval('tool.setAttr [%s] cenY [%s]' %(set_prim, prim_pos[1]) )
			lx.eval('tool.setAttr [%s] cenZ [%s]' %(set_prim, prim_pos[2]) )	
			
		else :
			lx.eval('tool.setAttr [%s] cenX 0' %set_prim )
			lx.eval('tool.setAttr [%s] cenY 0' % set_prim )
			lx.eval('tool.setAttr [%s] cenZ [%s]' %(set_prim, length / 2 ))
			lx.eval('tool.setAttr [%s] axis z' %set_prim )
			
	else: 
		if not is_selection :
			lx.eval('tool.setAttr [%s] axis y' %set_prim )
			lx.eval('tool.setAttr [%s] cenX [%s]' %(set_prim, prim_pos[0]) )
			lx.eval('tool.setAttr [%s] cenY [%s]' %(set_prim, prim_pos[1]) )
			lx.eval('tool.setAttr [%s] cenZ [%s]' %(set_prim, prim_pos[2]) )	
		else :	
			lx.eval('tool.setAttr [%s] cenX 0' %set_prim )
			lx.eval('tool.setAttr [%s] cenZ 0' % set_prim )
			lx.eval('tool.setAttr [%s] cenY [%s]' %(set_prim, length / 2 ))
			lx.eval('tool.setAttr [%s] axis y' %set_prim )
		
	if edge_island_fit or set_prim == "prim.sphere" :
		lx.eval('tool.attr [%s] sizeX [%s]' %(set_prim, length / 2 ))
		lx.eval('tool.attr [%s] sizeY [%s]' %(set_prim, length / 2 ))
		lx.eval('tool.attr [%s] sizeZ [%s]' %(set_prim, length / 2 ))
		
	elif poly_island_fit :
		lx.eval('tool.attr [%s] sizeX [%s]' %(set_prim, side_size / 2) )
		lx.eval('tool.attr [%s] sizeY [%s]' %(set_prim, length / 2) )
		lx.eval('tool.attr [%s] sizeZ [%s]' %(set_prim, side_size / 2) )
		
	else :	
		lx.eval('tool.attr [%s] sizeX [%s]' %(set_prim, side_size / 2 ))
		lx.eval('tool.attr [%s] sizeY [%s]' %(set_prim, side_size / 2 ))
		lx.eval('tool.attr [%s] sizeZ [%s]' %(set_prim, length / 2 ))

		
# ------------------------	
#	Finish/Cleanup
# ------------------------
lx.eval('tool.apply')
lx.eval('tool.set [%s] off 0' %set_prim)		
lx.eval('select.drop polygon')				
lx.eval('select.drop edge')		
lx.eval('select.drop vertex')				

if select :
	lx.eval('select.typeFrom vertex')
	verts_all_new = lx.evalN('query layerservice verts ? all')
	og_vert_set = set(verts_all)
	new_verts = [i for i in verts_all_new if not i in og_vert_set]
	for i in new_verts :
		lx.eval("select.element %s %s add %s 0 0" % (sel_layer, 'vertex', i))
	lx.eval('select.convert polygon')
			
			
if symmetry_mode :
	lx.eval('workPlane.reset')

	lx.eval('tool.set *.mirror on')
	lx.eval('tool.reset')
	lx.eval('tool.attr gen.mirror cenX 0.0')
	lx.eval('tool.attr gen.mirror cenY 0.0')
	lx.eval('tool.attr gen.mirror cenZ 0.0')
	
	lx.eval('tool.attr gen.mirror angle 0.0')
	lx.eval('tool.attr effector.clone flip true')
	lx.eval('tool.attr gen.mirror frot axis')
	lx.eval('tool.attr gen.mirror axis %s' %symmetry_axis)

	lx.eval('tool.apply')
	lx.eval('tool.set *.mirror off')
	
	lx.eval('select.drop vertex')				
	lx.eval('select.drop polygon')	
	
	lx.eval('select.symmetryState 1')
	lx.eval('symmetry.axis %s' %symmetry_axis)
	
else :
	lx.eval('select.typeFrom polygon')

if keepwp :
	lx.eval('workplane.edit %s %s %s %s %s %s' % (wpX, wpY, wpZ, wprX, wprY, wprZ)	)
else :
	lx.eval('workPlane.reset')
		

# eof