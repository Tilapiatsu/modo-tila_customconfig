#python

import modo
import lx


if lx.eval('select.typeFrom item;pivot;center;edge;polygon;vertex;ptag ?'):
	lx.eval('layer.mergeMeshes true')

elif lx.eval('select.typeFrom polygon;edge;vertex;item;pivot;center;ptag ?'):
	lx.eval('poly.collapse')

elif lx.eval('select.typeFrom edge;vertex;polygon;item;pivot;center;ptag ?'):
	lx.eval('edge.collapse')

elif lx.eval('select.typeFrom vertex;edge;polygon;item;pivot;center;ptag ?'):
	lx.eval('vert.join true')
