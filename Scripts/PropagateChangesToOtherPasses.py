# python

import modo, lx

scn = modo.Scene()

selection = scn.selected

rpg = None
passe = None
obj = None


for o in selection:
	if o.type == 'render':
		rpg = o
		continue
	elif o.type == 'actionclip':
		passe=o
		continue
	else:
		obj = o
	
for p in rpg.items:
	
	if p.type != 'actionclip':
		continue
	
	if p.name == passe.name:
		continue
		
	p.active = True
	
	lx.eval('channel.paste')
	lx.eval('edit.apply')
	
	p.active = False
	
