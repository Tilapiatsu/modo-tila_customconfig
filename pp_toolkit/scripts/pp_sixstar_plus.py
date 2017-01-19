#python
#-------------------------------------------------------------------------------
# Name:pp_sixstar_plus
# Version: 1.5
# Purpose: This script is designed to find and highlight any points connected to 
# more then 5 polygons so that the user can easily see them and fix them.
#
# Author:      William Vaughan, pushingpoints.com
# Special Thanks to ylaz for selection help.
# Special Thanks to Chris O'Riley for helping work out how to not change the actual 
# mesh materials.

# Created:     01/12/2014
# Copyright:   (c) William Vaughan 2014
#-------------------------------------------------------------------------------

#Import so we can select a material by name
import lx, lxu.select

#Create Temp Selection Sets for the first time the script is run to not give 
#error when we delete them	
lx.eval("select.editSet Fix_Stars add")

#Delete the temp selection sets	
lx.eval("select.deleteSet Fix_Stars")

#Makes sure all selected geo is dropped
lx.eval('select.drop vertex')
lx.eval('select.drop edge')
lx.eval('select.drop polygon')

#Creates a variable named "layer" that = the current mesh layer
layer = lx.eval('query layerservice layer.index ? main')
# Switches to Vertex component mode.
lx.eval('select.typeFrom vertex')
# Selects any points that have more then 5 polygons connected to it.
lx.eval('select.vertex add poly more 5')
#Creates a variable named "disco_verts" that stores the indices of all verts selected
disco_verts = lx.eval('query layerservice verts ? selected')# index of verts
disco_vertsN = lx.eval('query layerservice vert.N ? selected') #vert count

#sends output to MODO Event Log. Vert index and vert selection count
lx.out('disco_verts',disco_verts)
lx.out('disco_vertsN',disco_vertsN)


# If there are no stars over 5 polygons, display a message and stop script.
if disco_verts <= 0:
	lx.eval('dialog.setup info')
	lx.eval('dialog.title {Areas to Fix:}')
	lx.eval('dialog.msg {No stars over Five polygons found in this mesh.}')
	lx.eval('dialog.open')


# If there are any 6+ stars found then start going through the commands below
else:
	#We create a new material so that we know exactly what is selected in the shader. 
	#We will delete this at the end of the script
	lx.eval("shader.create advancedMaterial")
	lx.eval("item.name pp_temp advancedMaterial")
	
	#Defines a new function named disco
	def disco():
		#creates a new variable named "center"  that looks at what points are selected
		center = lx.eval('query layerservice verts ? selected')
		#This just checks and sees what MODO outputs for the center vert #(s) 
		#note: string inside of '  ' can be anything you want... just for book keeping
		lx.out('center',center)
		#takes the selection and grows it, converts it to edge selection and then converts it to polygon selection
		lx.eval('select.expand')
		lx.eval('select.expand')
		lx.eval('select.convert edge')
		lx.eval('select.convert polygon')
		#creates a new variable named "polys" that looks at what polys are selected (this creates the stored list used later)
		polys = lx.eval('query layerservice polys ? selected')
		#This just checks and sees what MODO outputs for the poly #(s)
		lx.out('polys',polys)
		#drops selection
		lx.eval('select.drop polygon')
		# "for loop" to run through all selected polys.
		for p in polys:
			lx.eval('select.typeFrom polygon')

			# This selects the element (polygon) on the mesh named "layer" 
			#p represents items in the list as it iterates thru one poly at a time
			lx.eval('select.element %s polygon set %s' % (layer,p))
			lx.eval('select.convert vertex')
			verts = lx.eval('query layerservice verts ? selected')

			# if the center point/vert is in the selected verts, tag it (naming it 'yes')
			if center in verts:
				lx.out('yes')
				lx.eval('select.convert polygon')
				lx.eval('select.editSet yes add')
			lx.eval('select.drop vertex')    
	if disco_vertsN == 1:
		disco()

	elif disco_vertsN > 1:
		lx.eval('select.drop vertex')
		for d in disco_verts:
			lx.eval('select.element %s vertex set %s' % (layer,d))
			disco()

	#Switches to Polygon mode, drops selection, selects the 'yes' poly selection set and then deletes the selection set
	lx.eval('select.typeFrom polygon')
	lx.eval('select.drop polygon')
	lx.eval('select.useSet yes select')
	lx.eval('select.deleteSet yes')

	# Gives the selected polygons a new material
	lx.eval("select.editSet Fix_Stars add")
	lx.eval("poly.setMaterial Fix_Stars {0.0 1.0 1.0} 1.0 0.2 true false")
	lx.eval("material.new Fix_Stars true false")
	lx.eval('mask.setPTagType "Selection Set"')
	lx.eval("mask.setPTag Fix_Stars")
	
	#Select the temp material and delete it
	scene = lxu.select.SceneSelection().current()
	texture = scene.ItemLookup('pp_temp')
	id = texture.Ident()
	lx.out(id)
	lx.eval ('select.subItem %s set textureLayer;render;environment;light;camera;scene;replicator;mediaClip;txtrLocator'% id)
	lx.eval('texture.delete')
	
	# If there are stars over 5 polygons, display a message and stop script.	
	lx.eval('dialog.setup info')
	lx.eval('dialog.title {Areas to Fix:}')
	lx.eval('dialog.msg {Stars over 5 polygons found in this mesh and need to be fixed.}')
	lx.eval('dialog.open')
