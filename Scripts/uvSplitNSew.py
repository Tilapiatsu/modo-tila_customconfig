#python

import lx,modo


ModoModes = {'VERT' : 'vertex',
            'EDGE' : 'edge',
            'POLY' : 'polygon',
            'ITEM' : 'item'}

def getSelectionMode():
	return lx.eval1 ('query layerservice selmode ?')

if getSelectionMode() == ModoModes['POLY']:
    lx.eval('select.convert edge')
    lx.eval('uv.sewMove disco true')
elif getSelectionMode() == ModoModes['EDGE']:
    lx.eval('uv.sew disco false')
elif getSelectionMode() == ModoModes['VERT']:
    lx.eval('uv.sew disco true')
    