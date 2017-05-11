#python

import lx

selType = lx.eval1('query layerservice selmode ?')
if selType == 'item':
	lx.eval('layer.mergeMeshes true')

elif selType == 'polygon':
	lx.eval('poly.collapse')

elif selType == 'edge':
	lx.eval('edge.collapse')

elif selType == 'vertex':
	lx.eval('!vert.join true')
