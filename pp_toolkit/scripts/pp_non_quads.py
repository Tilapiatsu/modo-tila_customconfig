 #python
#-------------------------------------------------------------------------------
# Name:pp_non_quads
# Version: 1.5
# Purpose: This script is designed to remove any 1 and 2 point polygons and to
# highlight any 3 point polygons as well as Ngons so that the user can easily see
# them and fix them.
#
# Author:      William Vaughan, pushingpoints.com
# Special Thanks to ylaz for query selection help.
# Special Thanks to Chris O'Riley for helping work out how to not change the actual 
# mesh materials.
#
# Created:     01/12/2014
# Copyright:   (c) William Vaughan 2014
#-------------------------------------------------------------------------------

#Import so we can select a material by name
import lx, lxu.select

# This makes sure the user is in polygon component mode and then drops the selection
lx.eval('select.type polygon')
lx.eval('select.drop polygon')

#Create Temp Selection Sets for the first time the script is run to not give 
#error when we delete them	
lx.eval("select.editSet Fix_Tris add")
lx.eval("select.editSet Fix_Ngons add")

#Delete the temp selection sets	
lx.eval("select.deleteSet Fix_Tris")
lx.eval("select.deleteSet Fix_Ngons")

# This makes sure the user is in polygon component mode
lx.eval('select.type polygon')

#Selects 1 point, 2 point, 3 point ploys as well as n-gons and finds out if there are any there.
lx.eval("select.polygon add vertex psubdiv 1")
lx.eval("select.polygon add vertex psubdiv 2")
lx.eval("select.polygon add vertex psubdiv 3")
lx.eval("select.polygon add vertex bezier 4")
polycount = lx.eval('query layerservice poly.N ? selected')

# If there are only quads, display a message and stop script.
if polycount == 0:
	lx.eval('dialog.setup info')
	lx.eval('dialog.title {Polygons to Fix:}')
	lx.eval('dialog.msg {This is an all-quad mesh.}')
	lx.eval('dialog.open')

# If there are any issues then start going through the commands below
else:
	#We create a new material so that we know exactly what is selected in the shader. 
	#We will delete this at the end of the script
	lx.eval("shader.create advancedMaterial")
	lx.eval("item.name pp_temp advancedMaterial")

	#Selects any 1 and 2 point Polygons
	lx.eval('select.drop polygon')
	lx.eval('select.polygon add vertex psubdiv 1')
	lx.eval("select.polygon add vertex psubdiv 2")

	#This finds out how many polys are selected
	polycount0 = lx.eval('query layerservice poly.N ? selected')

	#If there are any found delete them
	if polycount0 > 0:
		lx.eval("select.delete")
		
	#this drops the selected polygons
	else:
		lx.eval('select.drop polygon')

	#Selects any 3 point polygons in your mesh
	lx.eval("select.polygon add vertex psubdiv 3")

	#This finds out how many polys are selected
	polycount3 = lx.eval('query layerservice poly.N ? selected')

	if polycount3 > 0:
		# Gives the selected 3 point polygons a new material and selection set
		lx.eval("select.editSet Fix_Tris add")
		lx.eval("poly.setMaterial Fix_Tris {1.0 0.0 1.0} 1.0 0.2 true false false")
		lx.eval("material.new Fix_Tris true false")
		lx.eval('mask.setPTagType "Selection Set"')
		lx.eval("mask.setPTag Fix_Tris")
		lx.eval('select.drop polygon')

	else:
		lx.eval('select.drop polygon')

	#Selects any Ngons in your mesh
	lx.eval("select.polygon add vertex bezier 4")

	#This finds out how many polys are selected
	polycount4 = lx.eval('query layerservice poly.N ? selected')

	if polycount4 > 0:
		# Gives the selected Ngons a new material and selection set
		lx.eval("select.editSet Fix_Ngons add")
		lx.eval("poly.setMaterial Fix_Ngons {0.0 1.0 0.0} 1.0 0.2 true false")
		lx.eval("material.new Fix_Ngons true false")
		lx.eval('mask.setPTagType "Selection Set"')
		lx.eval("mask.setPTag Fix_Ngons")
		lx.eval('select.drop polygon')

	else:
		lx.eval('select.drop polygon')

	#Selects any 3 point polygons and ngons in your mesh again
	lx.eval("select.polygon add vertex psubdiv 3")
	lx.eval("select.polygon add vertex bezier 4")

	#Select the temp material and delete it
	scene = lxu.select.SceneSelection().current()
	texture = scene.ItemLookup('pp_temp')
	id = texture.Ident()
	lx.out(id)
	lx.eval ('select.subItem %s set textureLayer;render;environment;light;camera;scene;replicator;mediaClip;txtrLocator'% id)
	lx.eval('texture.delete')

	#Gives number of polys that need to be fixed
	selected_polycount = lx.eval('query layerservice poly.N ? selected')
	lx.eval('dialog.setup info')
	lx.eval('dialog.title {Polygons to Fix:}')
	lx.eval('dialog.msg {This mesh contains %s non-quad polygons that need to be fixed.}' % (selected_polycount))
	lx.eval('dialog.open')
	
	
	
