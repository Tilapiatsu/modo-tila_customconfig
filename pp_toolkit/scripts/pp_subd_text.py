#python
#-------------------------------------------------------------------------------
# Name:pp_subd_text
# Version: 1.0b
# Purpose: This script is designed to create subd text based on user input
#
# Author:      William Vaughan, pushingpoints.com
#
# Created:     01/07/2013
# Copyright:   (c) William Vaughan 2013
#-------------------------------------------------------------------------------

#Import os to access path module
import os

#Create a user values.  
lx.eval("user.defNew name:UserValue type:string life:momentary")
lx.eval("user.defNew TextType integer momentary")
lx.eval("user.def TextType list Standard;Sculptable;Standard2D;Sculptable2D")

#Set the label name for the popup we're going to call
lx.eval('user.def UserValue dialogname "Enter Your Text"')

#Set the user names for the values that the users will see
lx.eval("user.def UserValue username {Text}")
lx.eval("user.def TextType username {SubD Text Type}")

#The '?' before the user.value call means we are calling a popup to have the user set the value
try:
	lx.eval("?user.value UserValue")
	lx.eval("?user.value TextType")
	userResponse = lx.eval("dialog.result ?")
	
except:
	userResponse = lx.eval("dialog.result ?")
	lx.out("Thank you for pressing %s." % userResponse)
	sys.exit()
	

#Now that the user set the values, we can just query it
user_input = lx.eval("user.value UserValue ?")
text_type = lx.eval("user.value TextType ?")
lx.out('text', user_input)
lx.out('type', text_type)

#Convert all text to upper case
user_input = user_input.upper()

#Break up each letter in string into list
user_input = list(user_input)
lx.out('text', user_input)

#Get Current Scene info
Scene = lx.eval('query sceneservice scene.index ? current')
lx.out('Scene', Scene)

#Creates a new scene to protect current scene
lx.eval('scene.new')
SceneNew = lx.eval('query sceneservice scene.index ? current')
lx.out('SceneNew', SceneNew)

#Variable kerning
kerning = 0

alphalist_U = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K',
				'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V',
				'X', 'Y', 'Z']
				
alphalist_UI =  'I'

alphalist_UW =  'W'
				
#alphalist_L = map(str.lower, alphalist_U)

alphalist_N = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '@']
				
#For each character in user_input, run the for loop
for i in user_input:
	lx.out(i)
	lx.out('kerning', kerning)
	
	if text_type == "Standard":
		relativePath = os.path.join('pp_toolkit','scripts','geo')
		
	elif text_type == "Standard2D":
		relativePath = os.path.join('pp_toolkit','scripts','geo')
			
	else:
		relativePath = os.path.join('pp_toolkit','scripts','geo','mf')
	
	def alphacreate(str):
		alpha_use = i
				
		scriptPath = lx.eval("query platformservice path.path ? scripts")
		finalPath = os.path.join(scriptPath, relativePath)
		lx.out(finalPath)
		lx.eval('preset.do {%s/%s.lxl}' % (finalPath, alpha_use))	
		
		lx.eval('select.type polygon')			
		lx.eval('select.polygon add 0 face')
		lx.eval('tool.set TransformMove on')
		lx.eval('tool.attr xfrm.transform TX %f' % kerning)
		lx.eval('tool.doApply')
		lx.eval('select.drop item')	
		lx.eval('tool.set TransformMove off')
			
	if i in alphalist_U:
		alphacreate(i)
			
		# Add space for next letter in the string
		kerning += .225
		lx.out('kerning', kerning)
		
	elif i in alphalist_UI:
		alphacreate(i)
		
		# Add space for next letter in the string
		kerning += .085
		lx.out('kerning', kerning)
		
	elif i in alphalist_UW:
		alphacreate(i)
		
		lx.eval('select.type polygon')			
		lx.eval('select.polygon add 0 face')
		lx.eval('tool.set TransformMove on')
		lx.eval('tool.attr xfrm.transform TX 0.025')
		lx.eval('tool.doApply')
		lx.eval('tool.set TransformMove off')
		
		lx.eval('select.drop item')	
		
		# Add space for next letter in the string
		kerning += .265
		lx.out('kerning', kerning)
		
	elif i in alphalist_N:
		alphacreate(i)
		
		# Add space for next letter in the string
		kerning += .225
		lx.out('kerning', kerning)
		
	elif i == ' ':
					
		# Add space for next letter in the string
		kerning += .225
		lx.out('kerning', kerning)
			
	else:
		pass
	
#Select All Items and cut their contents
lx.eval('select.itemType mesh')			
lx.eval('select.type polygon')			
lx.eval('select.polygon add 0 face')	
lx.eval('select.cut')

#Delete All Items
lx.eval('select.layerTree all:1')
lx.eval('!!item.delete')

#Select Original Scene
lx.eval('scene.set %s'% Scene)	

#Create new Mesh Item and paste from clipboard	
lx.eval('item.create mesh')	
lx.eval('layer.move 1 1 0')	
lx.eval('select.paste')	

#rename mesh item and center it at the origin
lx.eval('!item.name SubD_Text mesh')
lx.eval('select.type polygon')		
lx.eval('vert.center all')	

subd_text = lx.evalN('query layerservice layer.index ? main')
lx.out('subd_layer', subd_text)

#Select Temp Scene, Close it and select original scene
lx.eval('scene.set %s'% SceneNew)	
lx.eval('!!scene.close')
lx.eval('scene.set %s'% Scene)	
lx.eval('select.layer %d'% subd_text)

#Selects any 1 point Polygons
lx.eval('select.drop polygon')
lx.eval('select.polygon add vertex psubdiv 1')
		
#This finds out how many polys are selected
polycount0 = lx.eval('query layerservice poly.N ? selected')

#If there are any found delete them
if polycount0 > 0:
	lx.eval("select.delete")		

if text_type == "Standard":
	#Give text depth
	lx.eval('select.all')
	lx.eval('tool.set *.extrude on')
	lx.eval('tool.reset poly.extrude')
	lx.eval('tool.attr poly.extrude shiftZ -0.04')
	lx.eval('tool.doApply')
	lx.eval('tool.set *.extrude off')

	lx.eval('tool.set poly.bevel on')
	lx.eval('tool.reset poly.bevel')
	lx.eval('tool.attr poly.bevel shift 0.005')
	lx.eval('tool.apply')
	lx.eval('tool.set poly.bevel off')

	lx.eval('select.drop polygon')


	#Give the text a new material
	lx.eval('material.new pp_subd_text true false')
	lx.eval('poly.setMaterial pp_subd_text {0.5295 0.5295 0.7445} 1.0 0.4 true false false')
			
if text_type == "Sculptable":
	#Give text depth
	lx.eval('select.all')
	lx.eval('tool.set *.extrude on')
	lx.eval('tool.reset poly.extrude')
	lx.eval('tool.attr poly.extrude shiftZ -0.01')
	lx.eval('tool.doApply')
	lx.eval('tool.set *.extrude off')

	lx.eval('tool.set poly.bevel on')
	lx.eval('tool.reset poly.bevel')
	lx.eval('tool.attr poly.bevel shift 0.01')
	lx.eval('tool.apply')
	lx.eval('tool.set poly.bevel off')

	lx.eval('tool.set poly.bevel on')
	lx.eval('tool.reset poly.bevel')
	lx.eval('tool.attr poly.bevel shift 0.01')
	lx.eval('tool.apply')
	lx.eval('tool.set poly.bevel off')

	lx.eval('select.drop polygon')

	#Convert to CC SubDs
	lx.eval('poly.convert face psubdiv true')

	#Give the text a new material
	lx.eval('material.new pp_subd_sculpttext true false')
	lx.eval('poly.setMaterial pp_subd_sculpttext {0.2271 0.5356 1.0} 1.0 0.4 true false false')

if text_type == "Sculptable2D":
	#Convert to CC SubDs
	lx.eval('poly.convert face psubdiv true')

	#Give the text a new material
	lx.eval('material.new pp_subd_sculpttext true false')
	lx.eval('poly.setMaterial pp_subd_sculpttext {0.2271 0.5356 1.0} 1.0 0.4 true false false')

if text_type == "Standard2D":
	#Give the text a new material
	lx.eval('material.new pp_subd_text true false')
	lx.eval('poly.setMaterial pp_subd_text {0.5295 0.5295 0.7445} 1.0 0.4 true false false')











