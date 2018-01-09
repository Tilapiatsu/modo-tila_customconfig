#python#

# ke_bbox 1.0 - Kjell Emanuelsson 2017
#
# Description : Creates a bounding box (the standard one, not rotated) UV's applied (atlas). One mesh layer only for now.  *does not use primitive tool*
#
# Usage 	  : Run in command line with "@ke_bbox.py", assign to hotkey or pie menu. With optional arguments below (with space betweeen).

# Set this to False to skip uv creation:				
uvs = True

# ----------------------------
# Grab layers & selections
# ----------------------------	
lx.eval('workPlane.reset')
sel_layer = lx.eval('query layerservice layers ? selected')	

lx.eval('select.convert vertex')	
vert_index = lx.evalN('query layerservice verts ? selected')
verts_all = lx.eval('query layerservice verts ? all')

if not vert_index :
	vert_index = verts_all

	if not vert_index :
		sys.exit(": --> Layer empty? Aborting script. <--")

else :
	lx.eval('select.drop vertex')		
	lx.eval('select.drop edge')		
	lx.eval('select.drop polygon')		

lx.eval('select.typeFrom vertex')
	
	
# ------------------------------
# Get vertex positions & sizes
# ------------------------------		
		
poslist = []		
for i in vert_index :
	poslist.append(lx.eval('query layerservice vert.wdefpos ? %s' %i ))
		
posX, posY, posZ = [], [], []

for i in poslist:
	posX.append(i[0]), posY.append(i[1]), posZ.append(i[2])

posX.sort(), posY.sort(), posZ.sort()	

sizeX, sizeY, sizeZ = posX[-1] - posX[0], posY[-1] - posY[0], posZ[-1] - posZ[0]
vp = [ posX[0], posY[0], posZ[0] ]	

poly_side1 = [ [vp[0], vp[1], vp[2]], [vp[0], vp[1] + sizeY, vp[2]], 
			 [vp[0] + sizeX, vp[1] + sizeY, vp[2]], [vp[0] + sizeX, vp[1], vp[2]] ] 
			 
poly_side2 = [ [vp[0], vp[1], vp[2] + sizeZ], [vp[0], vp[1] + sizeY, vp[2] + sizeZ], 
			 [vp[0] + sizeX, vp[1] + sizeY, vp[2] + sizeZ], [vp[0] + sizeX, vp[1], vp[2] + sizeZ] ] 


# -------------------
# Make bounding box
# -------------------

for i in poly_side1:
		lx.eval('vert.new %s %s %s' % (i[0], i[1], i[2]))
for i in poly_side2:
		lx.eval('vert.new %s %s %s' % (i[0], i[1], i[2]))

verts_all_new = lx.evalN('query layerservice verts ? all')
verts_new = [i for i in verts_all_new if not i in verts_all]

poly_1 = verts_new[:4]
poly_4 = verts_new[4:]
poly_2 = poly_1[2], poly_1[3], poly_4[3], poly_4[2]
poly_3 = poly_1[0], poly_1[1], poly_4[1], poly_4[0]
poly_5 = poly_1[1], poly_1[2], poly_4[2], poly_4[1]
poly_6 = poly_1[0], poly_1[3], poly_4[3], poly_4[0]

poly_list = poly_1, poly_2, poly_3, poly_4, poly_5, poly_6

for p in poly_list:
	for i in p :
		lx.eval("select.element %s %s add %s 0 0" % (sel_layer, 'vertex', i))
	lx.eval('poly.make face 1')		

lx.eval('select.typeFrom polygon')


# -----------
# Make UVs 
# -----------
if uvs:
	lx.eval('tool.set uv.create on')
	lx.eval('tool.reset')
	lx.eval('tool.attr uv.create mode manual')
	lx.eval('tool.setAttr uv.create proj atlas')
	lx.eval('tool.apply')
	lx.eval('tool.set uv.create off')

# eof