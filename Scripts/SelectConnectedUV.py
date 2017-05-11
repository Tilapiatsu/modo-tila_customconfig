#python

import lx

def selectConectedUV(vertex=False):
	lx.eval('!!select.3DElementUnderMouse set')

	if vertex:
		lx.eval('select.expand uv')
		lx.eval('select.expand uv')
		lx.eval('select.convert polygon')

	lx.eval('ffr.selectconnecteduv')

	if vertex:
		lx.eval('select.convert vertex')

selType = lx.eval1('query layerservice selmode ?')

if selType == 'polygon':
	p_hover = lx.eval1('query view3dservice element.over ? poly')
	p_sel = lx.evalN('query layerservice polys ? selected')
	print p_sel
	if isinstance(p_hover, str):
		selectConectedUV()
	else:
		if len(p_sel)>0:
			lx.eval('ffr.selectconnecteduv')
		else:
			lx.eval('select.all')

elif selType == 'edge':
	e_hover = lx.eval1('query view3dservice element.over ? edge')
	if isinstance(e_hover, str):
		selectConectedUV()
	else:
		lx.eval('select.all')




'''
elif selType == 'vertex':
	v_hover = lx.eval1('query view3dservice element.over ? vert')
	if isinstance(v_hover, str):
		selectConectedUV(True)
	else:
		lx.eval('select.all')
if selType == 'item':
	i_hover = lx.eval1('query view3dservice element.over ? item')
'''
