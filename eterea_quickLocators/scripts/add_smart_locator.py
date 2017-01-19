#python

# add_smart_locator.py
# Version 2.5 - etereaestudios.com
# Authors: OOZZEE aka Keith Sheppard, MonkeybrotherJr and Cristobal Vila
# With the great help of Ylaz
#
# To add new shaped-custom locators to scene depending on what is selected:
#    — If ITEM(S) are selected, add a new Locator with same Position and Rotation
#    — If COMPONENTS are selected, add a new Locator in the center of bounding box
#    — If NOTHING is selected, add a new Locator at Workplane Origin

# Example: @add_new_locator.py circle 0.1 z 1 custom

import lx

# Defining arguments
myform = lx.args()[0]         # box, plane, circle, etc
mysize = float(lx.args()[1])  # size in meters
myaxis = lx.args()[2]         # axis xyz
myalig = lx.args()[3]         # align true or false
myshap = lx.args()[4]         # shape default or custom

# Enable Locators visibility, just in case it was disable
lx.eval("view3d.showLocators true")

try:

	# Function that puts locator at workplane zero
	
	def locator_at_zero():
		lx.out("Nothing selected, creating locator at workplane 0,0,0")
		
		# ----- CUSTOM LOCATOR CREATION -----    

		# Create locator    
		lx.eval("item.create locator")
		
		# Apply dimensions to locator size
		lx.eval("item.channel locator$size " +str(mysize))
		
		# Apply shape, replace and solid    
		lx.eval("item.channel locator$drawShape custom")
		lx.eval("item.channel locator$isStyle replace")
		lx.eval("item.channel locator$isSolid true")
		
		# Define temporarily as box to introduce XYZ dimensions 
		lx.eval("item.channel locator$isShape box")
		lx.eval("item.channel locator$isSize.X " +str(mysize))
		lx.eval("item.channel locator$isSize.Y " +str(mysize))
		lx.eval("item.channel locator$isSize.Z " +str(mysize))
		
		# Define temporarily as circle to introduce radius
		lx.eval("item.channel locator$isShape circle")
		lx.eval("item.channel locator$isRadius " +str(mysize * 0.5))
		
		# Apply axis and align
		lx.eval("item.channel locator$isAxis " +myaxis)
		lx.eval("item.channel locator$isAlign " +myalig)
		
		# Apply final form shape
		lx.eval("item.channel locator$isShape " +myform)
		
		# Finally, decide between default or custom shape
		# I introduce this final step to “store” shape dimensions
		# even if you create a Default locator and then you decide
		# to change to a custom shape 
		lx.eval("item.channel locator$drawShape " +myshap)
		
		# ---------------------------------    

		lx.eval("item.matchWorkplanePos")

	scene_svc = lx.Service("sceneservice")
	layer_svc = lx.Service("layerservice")
	
	allowed_modes = ('polygon', 'edge', 'vertex')

	# Query Mode (For the IF item)
	FirstCheckModoMode = lx.eval('query layerservice selmode ?')
	
	itemtypes = ("locator","light","sunLight","camera","mesh")

	# Selected layers
	selMesh = lx.evalN("query sceneservice selection ? all")

	lx.out(FirstCheckModoMode)
	
	# If no layer and no component selected
	if len(selMesh) == 0 and not FirstCheckModoMode == 'item':
		lx.out("no component")
		locator_at_zero()
	
	# Check if current selection mode is a component mode
	if FirstCheckModoMode in allowed_modes:
	
		lx.out("component mode")
		
		for item in selMesh:
			
			scene_svc.select("item",str(item))
			itemName = scene_svc.query("item.name")
			lx.out(lx.eval("query layerservice layer.index ? %s"%item) )
		
			selected_polys = lx.eval('query layerservice poly.N ? selected')
			selected_edges = lx.eval('query layerservice edge.N ? selected')
			selected_verts = lx.eval('query layerservice vert.N ? selected')

			do_stuff = False
			
			# Check if any components in the selected component mode are selected
			if FirstCheckModoMode == 'polygon' and selected_polys > 0:
				lx.out("poly go")
				do_stuff = True
			if FirstCheckModoMode == 'edge' and selected_edges > 0:
				lx.out("edge go")
				do_stuff = True
			if FirstCheckModoMode == 'vertex' and selected_verts > 0:
				lx.out("vert go")
				do_stuff = True
			
			# If anything is selected, do this:
			if do_stuff:
				# My VertexLists
				xVerts = []
				yVerts = []
				zVerts = []
				
				# Convert selection to verts
				lx.eval("select.convert vertex")
				
				VertSelected = lx.evalN("query layerservice verts ? selected")
				
				for MyEachVert in VertSelected:
					xVertPos =  lx.eval("query layerservice vert.wpos ? {%s}" % MyEachVert)[0]
					xVerts.append(xVertPos)
					
					yVertPos =  lx.eval("query layerservice vert.wpos ? {%s}" % MyEachVert)[1]
					yVerts.append(yVertPos)
					
					zVertPos =  lx.eval("query layerservice vert.wpos ? {%s}" % MyEachVert)[2]
					zVerts.append(zVertPos)
					
				MyAveXVertPos = sum(xVerts) / len(xVerts)
				MyAveYVertPos = sum(yVerts) / len(yVerts)
				MyAveZVertPos = sum(zVerts) / len(zVerts)
				
				# ----- CUSTOM LOCATOR CREATION -----    
								
				# Create locator    
				lx.eval("item.create locator")
				
				lx.eval("!item.name %s_Locator" %itemName)
				
				# Apply dimensions to locator size
				lx.eval("item.channel locator$size " +str(mysize))
				
				# Apply shape, replace and solid    
				lx.eval("item.channel locator$drawShape custom")
				lx.eval("item.channel locator$isStyle replace")
				lx.eval("item.channel locator$isSolid true")
				
				# Define temporarily as box to introduce XYZ dimensions 
				lx.eval("item.channel locator$isShape box")
				lx.eval("item.channel locator$isSize.X " +str(mysize))
				lx.eval("item.channel locator$isSize.Y " +str(mysize))
				lx.eval("item.channel locator$isSize.Z " +str(mysize))
				
				# Define temporarily as circle to introduce radius
				lx.eval("item.channel locator$isShape circle")
				lx.eval("item.channel locator$isRadius " +str(mysize * 0.5))
				
				# Apply axis and align
				lx.eval("item.channel locator$isAxis " +myaxis)
				lx.eval("item.channel locator$isAlign " +myalig)
				
				# Apply final form shape
				lx.eval("item.channel locator$isShape " +myform)
				
				# Finally, decide between default or custom shape
				# I introduce this final step to “store” shape dimensions
				# even if you create a Default locator and then you decide
				# to change to a custom shape 
				lx.eval("item.channel locator$drawShape " +myshap)
				
				# ---------------------------------
				
				lx.eval("transform.channel pos.X {%s}" %MyAveXVertPos)
				lx.eval("transform.channel pos.Y {%s}" %MyAveYVertPos)
				lx.eval("transform.channel pos.Z {%s}" %MyAveZVertPos)
							
			# If nothing is selected, do this:
			else:
				lx.out("don't do stuff")
				locator_at_zero()    
				
	# If Selection mode is "item" mode, cycle through all selected layers and create locators
	elif FirstCheckModoMode == 'item' and len(selMesh) > 0:
		
		lx.out('item mode')
		
		locators = []
		
		# Loop through items and create locators for each
		for item in selMesh:
			
			scene_svc.select("item",str(item))
			itemName = scene_svc.query("item.name")
			itemType = scene_svc.query("item.type")
						
			# Check if currently selected item type is allowed, ignore if not
			if itemType in itemtypes:
			
				# ----- CUSTOM LOCATOR CREATION -----    
				
				# Create locator    
				lx.eval("item.create locator")
				
				# Rename locator
				lx.eval('!item.name %s_Locator' %itemName)
				
				# Apply dimensions to locator size
				lx.eval("item.channel locator$size " +str(mysize))
				
				# Apply shape, replace and solid    
				lx.eval("item.channel locator$drawShape custom")
				lx.eval("item.channel locator$isStyle replace")
				lx.eval("item.channel locator$isSolid true")
				
				# Define temporarily as box to introduce XYZ dimensions 
				lx.eval("item.channel locator$isShape box")
				lx.eval("item.channel locator$isSize.X " +str(mysize))
				lx.eval("item.channel locator$isSize.Y " +str(mysize))
				lx.eval("item.channel locator$isSize.Z " +str(mysize))
				
				# Define temporarily as circle to introduce radius
				lx.eval("item.channel locator$isShape circle")
				lx.eval("item.channel locator$isRadius " +str(mysize * 0.5))
				
				# Apply axis and align
				lx.eval("item.channel locator$isAxis " +myaxis)
				lx.eval("item.channel locator$isAlign " +myalig)
				
				# Apply final form shape
				lx.eval("item.channel locator$isShape " +myform)
				
				# Finally, decide between default or custom shape
				# I introduce this final step to “store” shape dimensions
				# even if you create a Default locator and then you decide
				# to change to a custom shape 
				lx.eval("item.channel locator$drawShape " +myshap)
				
				# ---------------------------------

				# get id of newly created locator
				locatorName = lx.eval1("query sceneservice selection ? all")

				# add locator to array
				locators.append(locatorName)
					
				# Select item by name
				lx.eval('select.subItem {%s}' % itemName)
				
				# Match position
				lx.eval('item.match item pos')
				
				# Match rotation
				lx.eval('item.match item rot')
	
		# select locators
		lx.eval("select.drop item")
		for item in locators:
			lx.eval('select.item {%s} add' % item)
	
	# If all else fails, create locator at workplane zero
	else:
		lx.out("or else what?")
		locator_at_zero()

except:
	lx.out('Exception "%s" on line: %d' % (sys.exc_value, sys.exc_traceback.tb_lineno))