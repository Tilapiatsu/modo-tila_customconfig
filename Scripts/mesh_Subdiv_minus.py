#python

import lx

currSubdiv = lx.eval('mesh.patchSubdiv ?')
currPSubdiv = lx.eval('mesh.psubSubdiv ?')

currSubdiv -= 1
currPSubdiv -= 1

if currSubdiv < 1:
	currSubdiv = 1

if currPSubdiv < 1:
	currPSubdiv = 1

lx.eval('mesh.patchSubdiv %s' % currSubdiv)
lx.eval('mesh.psubSubdiv %s' % currPSubdiv)