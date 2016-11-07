#python

import lx

currSubdiv = lx.eval('mesh.patchSubdiv ?')
currPSubdiv = lx.eval('mesh.psubSubdiv ?')

currSubdiv += 1
currPSubdiv += 1

if currSubdiv > 100:
	currSubdiv = 100

if currPSubdiv > 100:
	currPSubdiv = 100

lx.eval('mesh.patchSubdiv %s' % currSubdiv)
lx.eval('mesh.psubSubdiv %s' % currPSubdiv)