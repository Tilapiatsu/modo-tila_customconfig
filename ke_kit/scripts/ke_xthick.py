#python#

# ke_xthick 1.0 (extract and thicken) - Kjell Emanuelsson 2017
#
# Description: Extracts selected polygons and thickens them - automatically setting the shifted distance to the shortest edge length 
# 			   OR sets shift to the distance to the second selection island (via point to plane calculation) 
#			   Selection order important - first island is the intended operation, second is distance. 
#			   With multiple items selected, order is important : first mesh is op, second is distance.
#			   NOTE : Symmetry is not supported. it will restore symmetry to avoid dupe polys, but selection treated as above (if islands) 
#					  Work plane will be retained also.
# Usage:	   Run in command line with "@ke_xthick.py", assign to hotkey or pie menu. With optional arguments below (with space betweeen)
#
# Arguments:   basic    : Only extract and thicken - no island sorting - only shortest edge length for shift value.
#			   endselect : Does not fully select resulting polygons / leaves ends of polys selected (from the extrude) 	

from math import sqrt, pi

u_args = lx.args() 

layers = []
layer_index = []
layer_id = []
selected_verts = []
selected_polys = []
selected_index_list = []
side_sizes = []
vert_pos = []
multilayer = False
layers = []
is_selection = True
single_island_mode = True
select = True
noplane = False
basic = False
keepwp = False
symmetry_mode = False
offset = 0

for i in range(len(u_args)):
	if "endselect" in u_args:
		select = False
	if "basic" in u_args:
		basic = True
	else:pass

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

# wp check
if lx.eval('workPlane.state ?') :
	keepwp = True
	lx.setOption("queryAnglesAs", "degrees")
	wpX  = lx.eval("workplane.edit ? 0 0 0 0 0")
	wpY  = lx.eval("workplane.edit 0 ? 0 0 0 0")
	wpZ  = lx.eval("workplane.edit 0 0 ? 0 0 0")
	wprX = lx.eval("workplane.edit 0 0 0 ? 0 0")
	wprY = lx.eval("workplane.edit 0 0 0 0 ? 0")
	wprZ = lx.eval("workplane.edit 0 0 0 0 0 ?")		
	
# symmetry check	
if lx.eval('symmetry.state ?') == True :
	symmetry_mode = True
	lx.eval('select.symmetryState 0')

	
# Selection Check
sel_mode = lx.eval('query layerservice selmode ?')

if not sel_mode == "polygon" :
	sys.exit(": ---> Element Selection Error - Polygon Selection only <---")	

if basic :	
	if len(lx.evalN('query layerservice polys ? selected')) < 1 :
		sys.exit()
		
if not basic :	
	# Layers
	sel_layer = lx.eval('query layerservice layers ? selected')
	layers_check = lx.eval('query layerservice layers ? fg')

	if type(layers_check) == tuple : 
		layers = [i for i in layers_check]
	else: 
		layers = [layers_check]
		
		
	# ---------------------------------------------------------------------------	
	# grabbing selection indexes, vert pos's, sizes etc for processing later
	# ---------------------------------------------------------------------------

	for layer in layers :

		index = lx.eval1('query layerservice layer.index ? %s' %layer)
		layer_index.append(index)
		
		p = lx.evalN('query layerservice polys ? selected')
		
		if layer == sel_layer : 
			if len(p) == 0:
				is_selection = False
				break

		selected_index_list.append(p)
		
		vp = []
		sv = []
		addpolys = []
		
		for i in p:
			vl = lx.evalN('query layerservice poly.vertList ? %s' %i)
			
			vps= []
			for vert in vl:
				vps.append(lx.eval('query layerservice vert.wdefpos ? %s' %vert ))	
			
			vp.extend(vps)
			sv.append(vl)	
			addpolys.append(i)
						
		selected_polys.append(addpolys)
		vert_pos.append(vp)	
		selected_verts.append(sv)


	# Re-selecting first selected layer 
	lx.eval1('query layerservice layer.index ? %s' %sel_layer)	
		
	if is_selection :	

		# multi layer mode check	
		selected_index_list = list(filter(None, selected_index_list))

		if len(selected_index_list) > 1 :
			multilayer = True

		# store for later - sel_layer (= primitive creation layer) only
		verts_all = lx.evalN('query layerservice verts ? all')

	else: 
		sys.exit(": ---> Invalid selecion - Aborting operation <---")

		
	lx.eval1('query layerservice layer.index ? %s' %sel_layer)	

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
		
		#cross source selection (point)
		cross_product = fn_crossproduct_coordlist(point_verts)

		sqrLenN = cross_product[0] * cross_product[0] + cross_product[1] * cross_product[1] + cross_product[2] * cross_product[2]
		invLenN = 1.0 / sqrt( sqrLenN )
		rayDir = [cross_product[0] * invLenN, cross_product[1] * invLenN, cross_product[2] * invLenN]
		
		#cross target plane  (plane)
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
				offset = 0
			else :	
				offset = -( d1 / d2 )

		# & in case the plane returns zero (or 2mm near) use side size 
		if offset -0.001 <= 0 <= 0.001:
			noplane = True
			
			
	else: 
		noplane = True
		
	if noplane:	
		# get offset from shortest connected edge
		edges = []
		lx.eval('select.convert edge')
		for i in lx.evalN('query layerservice edges ? selected') :	
			edges.append(lx.eval('query layerservice edge.length ? %s' % i))
		edges.sort()

		if edges[1] != 0 :
			offset = edges[0]
		else :
			sys.exit(": Edge Length error!? - Aborting")
			
		
	# ----------------
	# reselect polys
	# ----------------

	if not multilayer :
		lx.eval('select.typeFrom vertex')
		lx.eval('select.drop vertex')			

		for vert in first_island:
			lx.eval('select.element %s vertex add %s' % (layers[0] , vert))
		lx.eval('select.convert polygon')
		polys = lx.evalN('query layerservice polys ? selected')
		for poly in polys:
			if poly not in selected_polys[0]:
				lx.eval('select.element %s polygon remove %s' % (layers[0] , poly))
			
	else: 
		lx.eval('select.typeFrom polygon')
		lx.eval('select.drop polygon')
		for i in selected_polys[0] :
			lx.eval('select.element %s polygon add %s' % (layers[0] , i) )

if basic :
	# get offset from shortest connected edge
	edges = []
	lx.eval('select.convert edge')
	for i in lx.evalN('query layerservice edges ? selected') :	
		edges.append(lx.eval('query layerservice edge.length ? %s' % i))
	edges.sort()

	if edges[1] != 0 :
		offset = edges[0]
	else :
		sys.exit(": Edge Length error!? - Aborting")			
	
	lx.eval('select.typeFrom polygon')
		
# ---------------------------		
# Op - extract and thicken
# ---------------------------

lx.eval('copy')	
lx.eval('paste')
lx.eval('tool.set Thicken on')
lx.eval('tool.setAttr poly.smshift shift %s' %offset)	
lx.eval('tool.doApply')
lx.eval('tool.set Thicken off')
if select :
	lx.eval('select.connect')
# else :
	# lx.eval('select.drop polygon')		

	
# ------------------------	
#	Finish/Cleanup
# ------------------------
	
lx.eval('select.drop edge')		
lx.eval('select.drop vertex')				
lx.eval('select.typeFrom polygon')

if symmetry_mode :
	lx.eval('select.symmetryState 1')
	
if keepwp :
	lx.eval('workplane.edit %s %s %s %s %s %s' % (wpX, wpY, wpZ, wprX, wprY, wprZ)  )

	
# eof