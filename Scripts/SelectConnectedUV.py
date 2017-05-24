#python

import lx

def selectConectedUV():
	lx.eval('!!select.3DElementUnderMouse set')
	lx.eval('ffr.selectconnecteduv')

selType = lx.eval1('query layerservice selmode ?')

if selType == 'polygon':
	p_hover = lx.eval1('query view3dservice element.over ? poly')
	p_sel = lx.evalN('query layerservice uv ? selected')
	if isinstance(p_hover, str):
		selectConectedUV()
	else:
		if len(p_sel)>0:
			lx.eval('ffr.selectconnecteduv')
		else:
			lx.eval('select.all')

elif selType == 'edge':
	lx.eval('select.type polygon')
	e_hover = lx.eval1('query view3dservice element.over ? poly')
	if isinstance(e_hover, str):
		selectConectedUV()
	else:
		lx.eval('select.all')

elif selType == 'vertex':
	lx.eval('select.type polygon')
	v_hover = lx.eval1('query view3dservice element.over ? poly')
	if isinstance(v_hover, str):
		selectConectedUV()
	else:
		lx.eval('select.all')
'''
if selType == 'item':
	i_hover = lx.eval1('query view3dservice element.over ? item')
'''
