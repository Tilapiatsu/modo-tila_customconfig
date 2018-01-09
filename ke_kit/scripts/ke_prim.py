#python#

# ke_prim v2.1 - Kjell Emanuelsson 2017
#
# Update: 		Added "unit primitive at origo" function. Similar to ctrl-click on primitive tool in the menu, excepts it does not reset all your current values. Also actually unit sized.
#
# Description : Simple script that aligns work plane (optionally) and activates your primitive tool of choice.
#			    Nothing selected = Default primitve tool, at current scene work plane.
#				Element selected = Aligns workplane to selection and fires set primitive tool.  
#				Mouse hover w. nothing selected = Aligns workplane to element under mouse cursor and fires set primitive tool.  
#
# Usage : 		Run in command line with "@ke_prim.py", assign to hotkey or pie menu. With optional arguments below (with space betweeen). E.g: "ke_prim.py cylinder"
#
# Arguments :	cylinder 	 : (Cube is default, does not need argument) use cylinder tool
#				sphere		 : use sphere primitive tool
#				cone 		 : use cone primitive tool 
#				toroid 		 : use torus primitive tool 
#				tube 		 : use tube primitive tool 
#				pen 		 : use pen primitive tool 
#				solidsketch  : use solid sketch tool 
#				curve 		 : use curve tool 
#				bezier  	 : use bezier curve tool 
#				sketch 		 : use sketch primitive tool 
#				text 		 : use text primitive tool 
#
#				nodrop 		 : Disables deselecting initial selection before running primitive tool 
#				nomouseover  : Disables mouseover function (only no-selection & selection functions)
#				unit		 : Creates a unit primitive at 0,0,0 - without resetting segments/sides etc. (cylinder, sphere and cone for now. The rest will reset like default ctrl click)
#

is_selection = False
nodrop = False	
nomouseover = False
set_prim = "prim.cube"
selection = []
unit = False
u_args = lx.args() 

for i in range(len(u_args)):
	if "nodrop" in u_args:
		nodrop = True
	if "nomouseover" in u_args:
		nomouseover = True
	if "unit" in u_args:
		unit = True
		
	if "cylinder" in u_args:
		set_prim = "prim.cylinder"
	elif "sphere" in u_args:
		set_prim = "prim.sphere"	
	elif "cone" in u_args:
		set_prim = "prim.cone"		
	elif "toroid" in u_args:
		set_prim = "prim.toroid"		
	elif "tube" in u_args:
		set_prim = "prim.tube"	
	elif "pen" in u_args:
		set_prim = "prim.pen"	
	elif "solidsketch" in u_args:
		set_prim = "SS Default"	
	elif "curve" in u_args:
		set_prim = "prim.curve"	
	elif "bezier" in u_args:
		set_prim = "prim.bezier"	
	elif "sketch" in u_args:
		set_prim = "prim.sketch"	
	elif "text" in u_args:
		set_prim = "prim.text"	
		

if unit and set_prim == "prim.cube":   # coz cannot nest the cube sizes for some reason
	lx.eval('tool.set "%s" on 0' %set_prim)
	lx.eval('tool.reset "%s" ' %set_prim)
	lx.eval('tool.apply')
	lx.eval('tool.set "%s" off 0' %set_prim)
	sys.exit()	
	
elif unit: 
	if "prim.sphere" or "prim.cylinder" or "prim.cone" in set_prim :
		lx.eval('tool.set "%s" on 0' %set_prim)
		lx.eval('tool.attr "%s" cenX 0' %set_prim)
		lx.eval('tool.attr "%s" cenY 0' %set_prim)
		lx.eval('tool.attr "%s" cenZ 0' %set_prim)
		lx.eval('tool.attr "%s" axis y' %set_prim)	
		lx.eval('tool.attr "%s" sizeX 0.5' %set_prim)
		lx.eval('tool.attr "%s" sizeY 0.5' %set_prim)	
		lx.eval('tool.attr "%s" sizeZ 0.5' %set_prim)	
		lx.eval('tool.apply')
		
	else :	
		lx.eval('tool.set "%s" on' %set_prim)
		lx.eval('tool.reset "%s" ' %set_prim)
		lx.eval('tool.apply')		

	lx.eval('tool.set "%s" off 0' %set_prim)

	sys.exit()	

	
sel_mode = lx.eval('query layerservice selmode ?')

if sel_mode == "vertex" :
	selection = lx.evalN('query layerservice verts ? selected')
	
elif sel_mode == "edge" :
	selection = lx.evalN('query layerservice edges ? selected')
	
elif sel_mode == "polygon" :
	selection = lx.evalN('query layerservice polys ? selected')
	
if len(selection) > 0:
		is_selection = True		

		
if not is_selection :
	if not nomouseover :
		try : 
			lx.eval('select.3DElementUnderMouse add')
			
			if sel_mode == "vertex" :
				selection = lx.evalN('query layerservice verts ? selected')
			
			elif sel_mode == "edge" :
				selection = lx.evalN('query layerservice edges ? selected')
				
			elif sel_mode == "polygon" :
				selection = lx.evalN('query layerservice polys ? selected')
				
			if len(selection) > 0:
				is_selection = True		
				
		except : 
			pass	

		
if is_selection:
	lx.eval('workPlane.fitSelect')
	if not nodrop:
		lx.eval('select.drop vertex')
		lx.eval('select.drop edge')
		lx.eval('select.drop polygon')
	
	
lx.eval('tool.set "%s" on' %set_prim)
# eof	