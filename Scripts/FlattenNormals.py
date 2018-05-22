# python
# TODO : need to suport edge and vertex selection
import modo, lx

def init_message(type='info', title='info', message='info'):
    return_result = type == 'okCancel' \
                    or type == 'yesNo' \
                    or type == 'yesNoCancel' \
                    or type == 'yesNoAll' \
                    or type == 'yesNoToAll' \
                    or type == 'saveOK' \
                    or type == 'fileOpen' \
                    or type == 'fileOpenMulti' \
                    or type == 'fileSave' \
                    or type == 'dir'
    try:
        lx.eval('dialog.setup {%s}' % type)
        lx.eval('dialog.title {%s}' % title)
        lx.eval('dialog.msg {%s}' % message)
        lx.eval('dialog.open')

        if return_result:
            return lx.eval('dialog.result ?')

    except:
        if return_result:
            return lx.eval('dialog.result ?')

scn = modo.Scene()
if len(scn.selected):
	selection = scn.selected[0]
	if selection.type == 'mesh':

		selectedPolygons = selection.geometry.polygons.selected

		def addVector(v1, v2):
			return (v1[0] + v2[0], v1[1] + v2[1], v1[2] + v2[2])

		def scalarMultiplyVector(v, s):
			return (v[0] * s, v[1] * s, v[2] * s)


		if len(selectedPolygons)>0:

			averageNormal = (0,0,0)
			i=0
			
			for p in selectedPolygons:
			 
				for vID in xrange(p.numVertices):
					vN = p.vertexNormal(vID)
					averageNormal = addVector(averageNormal, vN)
					
					i += 1
				
			i = float(i)

			averageNormal = scalarMultiplyVector(averageNormal , 1/i)

			vMaps = selection.geometry.vmaps

			for map in vMaps:
				if map.map_type == 1313821261:
					normalMap = map
					break
			else:
				normalMap = selection.geometry.vmaps.addVertexNormalMap()

			for p in selectedPolygons:
				for v in p.vertices:
					normalMap.setNormal(averageNormal, v)
					
			selection.geometry.setMeshEdits(lx.symbol.f_MESHEDIT_MAP_OTHER)
		else:
			init_message('error', 'Select at least one polygon', 'Select at least one polygon')
	else:
		init_message('error', 'Select a mesh first', 'Select a mesh first')
else:
	init_message('error', 'Select a mesh first', 'Select a mesh first')