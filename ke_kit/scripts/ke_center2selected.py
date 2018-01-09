#python#

# Center2Selected v1.0 - Kjell Emanuelsson 2017
# Places the item center to the average position of selected elements. (+ transform move tool)

import modo

poslist = []

def fn_avgpos(poslist):
	vX, vY, vZ = [], [], []
	for i in poslist:
		vX.append(i[0]), vY.append(i[1]), vZ.append(i[2])
	total = len(poslist)
	return sum(vX) / total, sum(vY) / total, sum(vZ) / total	

	
if lx.eval1('query layerservice selmode ?') != 'vertex' :
	lx.eval('select.convert vertex')
	
if lx.evalN('query layerservice verts ? selected') :
	
	# make sure layer is selected, not just active
	layer_index = lx.eval('query layerservice layers ? selected')
	layer_ID = lx.eval1('query layerservice layer.ID ? {%s}' %layer_index)
	lx.eval('select.subItem {%s} set' %layer_ID ) 

	mesh = modo.Mesh()
	selverts = mesh.geometry.vertices.selected
	for i in selverts :
		poslist.append(modo.Vector3(i.position))	
	pos = fn_avgpos(poslist)
	
	lx.eval('select.drop vertex')
	
	
else : sys.exit(": --- Selection Error : Please select vertex|edge|polygon ---")

lx.eval('select.center {%s} set' %layer_ID )
lx.eval('center.setPosition {%s} {%s} {%s}' %(pos[0], pos[1], pos[2]) )
lx.eval('select.item {%s}' %layer_ID)

lx.eval('tool.set TransformMoveItem on')

#eof