#python
import modo
import lx

scn = modo.Scene()

selection = scn.selected

for o in selection:
	if o.type == 'groupLocator':
		newName = o.name
		o.name += '_new'
		for c in o.children():
			c.setParent()
			c.name = newName
		scn.select(o)
		lx.eval('delete')

