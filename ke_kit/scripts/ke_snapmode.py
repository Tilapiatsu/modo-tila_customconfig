#python

# ke_snapmode - Kjell Emanuelsson 2017
#
# Quick script to switch between snap presets OR create these snap presets (and apply) if they do not exist, 
# since I got sick of 'loosing' my presets each version / backup fails whatnot. Simple enough to modify if you want other setups!
# 
# Specify which snapping mode as an argument:  vertex, grid, element or elementgrid. e.g: "@ke_snapmode.py grid"
# (pretty self explanatory what each one does?)

import modo

u_args = lx.args() 
lx = lx.eval 

vertex_mode = False
element_mode = False
grid_mode = False
element_grid_mode = False
transform_tool = False
rotate_tool = False
scale_tool = False

for i in range(len(u_args)):
	if "vertex" in u_args:
		vertex_mode = True
	elif "grid" in u_args:
		grid_mode = True
	elif "elementgrid" in u_args:
		element_grid_mode = True
	elif "element" in u_args:
		element_mode = True	
	else : pass	


lx('tool.snapState enable:1')

# check transform tool to reapply later to avoid appliying translation values
if lx('tool.set TransformMove ?') == "on" :
	transform_tool = True
if lx('tool.set TransformRotate ?') == "on" :
	rotate_tool = True
elif lx('tool.set TransformScale ?') == "on" :
	scale_tool = True

lx('tool.drop')


if vertex_mode :

	if lx('tool.snapPresetList global SnapVertex') :
		lx('tool.doApply')
	
	else :
		lx('tool.snapPresetAdd global SnapVertex')
		lx('tool.snapType global vertex 1')
		lx('tool.doApply')
		
		
elif element_mode :

	if lx('tool.snapPresetList global SnapElement') :
		lx('tool.doApply')
	
	else :
		lx('tool.snapPresetAdd global SnapElement')
		lx('tool.snapType global vertex 1')
		lx('tool.snapType global edge 1')
		lx('tool.snapType global edgeCenter 1')
		lx('tool.snapType global polygon 1')
		lx('tool.snapType global polygonCenter 1')
		lx('tool.doApply')
		
		
elif grid_mode :

	if lx('tool.snapPresetList global SnapGrid') :
		lx('tool.doApply')
	
	else :
		lx('tool.snapPresetAdd global SnapGrid')
		lx('tool.snapType global grid 1')
		lx('tool.doApply')

		
elif element_grid_mode :

	if lx('tool.snapPresetList global SnapElementGrid') :
		lx('tool.doApply')
	
	else :
		lx('tool.snapPresetAdd global SnapElementGrid')
		lx('tool.snapType global grid 1')
		lx('tool.snapType global vertex 1')
		lx('tool.snapType global edge 1')
		lx('tool.snapType global edgeCenter 1')
		lx('tool.snapType global polygon 1')
		lx('tool.snapType global polygonCenter 1')
		lx('tool.doApply')			
		
else : sys.exit(": No SnapMode Argument / Unhandled script error. Aborting.")		


lx('tool.drop')

if transform_tool :
	lx('tool.set TransformMove on')
if rotate_tool :	
	lx('tool.set TransformRotate on')
elif scale_tool :	
	lx('tool.set TransformScale on')
	
