#python
import modo, lx
import os, sys

rootPath = ''

lx.eval('dialog.setup dir')
lx.eval('dialog.title "Open Path"')
lx.eval('dialog.msg "Select path to process."')
lx.eval('dialog.result "%s"' % rootPath)

try:  # output folder dialog
	lx.eval('dialog.open')
except:
	sys.exit()
else:
	root = lx.eval1('dialog.result ?')
	obj_settings = lx.eval('user.value sceneio.obj.import.units ?')
	obj_static = lx.eval('user.value sceneio.obj.import.static ?')
	lx.eval('user.value sceneio.obj.import.units centimeters')
	lx.eval('user.value sceneio.obj.import.static false')

	for dirname, dirnames, filenames in os.walk(root):
		
		for f in filenames:
			filepath = os.path.join(dirname, f)
			ext = os.path.splitext(filepath)[1]
			if ext.lower() == '.obj':
				lx.out('importing {}'.format(f))
				lx.eval('!!scene.open "{}" import'.format(filepath))

			else:
				pass
		else:
			lx.out('No file of type "obj" found')

	lx.eval('user.value sceneio.obj.import.units {}'.format(obj_settings))
	lx.eval('user.value sceneio.obj.import.static {}'.format(obj_static))