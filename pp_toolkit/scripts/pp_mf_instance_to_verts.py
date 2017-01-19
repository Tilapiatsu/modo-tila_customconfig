#python
#-------------------------------------------------------------------------------
# Name:pp_mf_instance_to_verts
# Version: 1.0
# Purpose: This script is designed to create instances of the desired mf item 
# at the location of selected verts.
#
# Make sure all other items are not visible and select verts where you want 
# instances to be created
#
# Author:      William Vaughan, pushingpoints.com
#
# Created:     01/28/2014
# Copyright:   (c) William Vaughan 2014
#-------------------------------------------------------------------------------

### Have the item you want instanced in the background and the selected verts
### you want to clone to in the foreground

#Get selected vert info
layer = lx.eval('query layerservice layer.index ? main')
verts = lx.evalN('query layerservice verts ? selected')# index of verts
vertsN = lx.eval('query layerservice vert.N ? selected') #vert count
lx.out('verts', verts)
lx.out('vertsN', vertsN)

lx.eval('layer.swap')

#Get selected mesh info
selmesh = lx.eval('query sceneservice selection ? mesh')
lx.out('selected mesh', selmesh)

#for each vert in selection above create an instance and move to vert location
for v in verts:
	
	#store individual vert position
	vertpos = lx.eval('query layerservice vert.pos ? %s' %v)
	vertPOS_X,vertPOS_Y,vertPOS_Z = vertpos
		
	#selected original mesh item
	layer = lx.eval('select.item {%s} set' % selmesh)
	lx.eval('@SDF_BoolDD.pl 4100')
	
	#create instance 
	lx.eval('@SDF_BoolDD.pl 4020')

#stores the newly created instances to run the a placement loop below	
lx.eval('select.item {%s} set' % selmesh)
lx.eval('select.itemInstances')
meshinst = lx.evalN('query sceneservice selection ? meshInst')
meshinstN = lx.eval('query sceneservice meshInst.N ?')
lx.out('meshinst', meshinst)
lx.out('meshinstN', meshinstN)

vertnumber = 0

# for each instance use the position of one of the verts for its new location
for i in meshinst:
	
	#store individual vert position
	vertpos = lx.eval('query layerservice vert.pos ? %s' %verts[vertnumber])
	vertPOS_X,vertPOS_Y,vertPOS_Z = vertpos
	
	layer = lx.eval('select.item {%s} set' % i)

	#move Instance
	layer = lx.eval('transform.channel pos.Z %f'%vertPOS_Z)
	layer = lx.eval('transform.channel pos.Y %f'%vertPOS_Y)
	layer = lx.eval('transform.channel pos.X %f'%vertPOS_X)
		
	#set the instance to allow deformations	
	lx.eval('item.channel meshInst$allowDeform true')
	
	vertnumber += 1
	
	#Drop selection
	lx.eval('select.drop item')	
