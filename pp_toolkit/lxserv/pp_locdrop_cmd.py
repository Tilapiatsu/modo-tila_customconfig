#!/usr/bin/env python
#-------------------------------------------------------------------------------
# Name:pp_loc_drop_command
# Version: 1.0
# Purpose: This command is designed to create new locators with custom settings 
# at the location of selected verts and is based off of my script of the same name
#
# Author:      William Vaughan, pushingpoints.com
#
# Created:     01/12/2014
# Copyright:   (c) William Vaughan 2013
#-------------------------------------------------------------------------------

import lx
import lxifc
import lxu.command
import lxu.select
import traceback

#The UiValueHints class will manage the list and it's items
#http://sdk.luxology.com/wiki/Pop-up_List_Choice

class Popup (lxifc.UIValueHints):

	#def defines a new function
	def __init__(self, list_data):
		#The data to display is stored here. Self is the object we will pass to the function.
		self.list = list_data
		
	def uiv_Flags (self):
		#This can be multiple flags but this one is just saying we're creating a popup
		return lx.symbol.fVALHINT_POPUPS
		
	def uiv_PopCount (self):
		#simply returns the number of items in the list#
		return len (self.list)
		
	def uiv_PopInternalName (self, index):
		#this function returns the internal name of each option in the list
		#It's the value that will be returned when the custom command is queried
		return self.list[index][0]
			
	def uiv_PopUserName (self, index):
		#this function returns the user name of each option in the list#
		return self.list[index][1]
		
#The custom command class ... need more commenting here

class Command (lxu.command.BasicCommand):

	def __init__(self):

		lxu.command.BasicCommand.__init__(self)
		#These are the arguments for the ui
		#The order they are listed is the order the appear in the ui and they are
		#assigned a number that you can call later
		self.dyna_Add ('Locator Name', lx.symbol.sTYPE_STRING)  #0
		self.dyna_Add ('Shape', lx.symbol.sTYPE_STRING)  #1
		self.dyna_Add ('Label', lx.symbol.sTYPE_STRING)   #2
		self.dyna_Add ('Solid', lx.symbol.sTYPE_BOOLEAN)  #3
		self.dyna_Add ('Align to View', lx.symbol.sTYPE_BOOLEAN)  #4
		self.dyna_Add ('Axis', lx.symbol.sTYPE_AXIS)  #5
		self.dyna_Add ('Size X', lx.symbol.sTYPE_DISTANCE)  #6
		self.dyna_Add ('Size Y', lx.symbol.sTYPE_DISTANCE)  #7
		self.dyna_Add ('Size Z', lx.symbol.sTYPE_DISTANCE)  #8
		self.dyna_Add ('Radius', lx.symbol.sTYPE_DISTANCE)  #9
		self.dyna_Add ('Wireframe Color', lx.symbol.sTYPE_COLOR)  #10
		self.dyna_Add ('Fill Color', lx.symbol.sTYPE_COLOR)  #11


	def arg_UIValueHints (self, index):
	
		#This list will be used to populate the type popup. The list is two tuples. The first
		#is the internal name and the second is the name the user will see in the pop-up.
		
		list_data = [('standard', 'Standard'),('box', 'Box'), ('pyramid', 'Pyramid'), ('rhombus', 'Rhombus'), ('cylinder', 'Cylinder'),
		('cone', 'Cone'), ('sphere', 'Sphere'), ('plane', 'Plane'), ('circle', 'Circle')]
		
		#This uses the Popup class created above for the Locator Shape option
		if index == 1:
			return Popup (list_data)
	
	def cmd_DialogFormatting (self):
			#the dash between the 2 and the 3  and the 9 and the 10 creates a horizontal divider line
			#the {} GANGS THE ATTRIBUTES INTO  ONE GROUP. This is for Size xyz
			return "0 1 2 - 3 4 5 {6 7 8} 9 - 10 11"
	
	def cmd_DialogInit (self):

		#These set the default value for the arguments	
		self.attr_SetString (0, 'CNTRL')
		self.attr_SetString (1, 'standard')
		self.attr_SetString (6, '0.0250')
		self.attr_SetString (7, '0.0250')
		self.attr_SetString (8, '0.0250')
		self.attr_SetString (9, '0.0250')
		self.attr_SetString (10, '1.0, 0.0, 0.0')
		self.attr_SetString (11, '0.0, 0.0, 0.0')
			
		
	def cmd_Flags(self):
		#Makes this command undoable
		#To create the vertical line = ALT + 124
		return lx.symbol.fCMD_MODEL | lx.symbol.fCMD_UNDO
	
	
	def cmd_UserName(self):
 		return 'Locator Drop'

 	def cmd_Desc(self):
 		return 'Creates a custom locator at the location of each selected vertex.'

 	def cmd_Tooltip(self):
 		return 'Creates a custom locator at the location of each selected vertex.'

 	def cmd_Help(self):
 		return 'http://www.pushingpoints.com/'

	def basic_ButtonName(self):
		return 'Locator Drop'

	def cmd_Interact(self):
		pass
	
	
	
#MAIN FUNCTION EXECUTION
	
	def basic_Execute (self, msg, flags):
	
		#The command will be enabled if at least 1 vert is selected.
		vertcount = lx.eval('select.count vertex ?')
		lx.out('vertcount', vertcount)
		
		#If no verts are selected display this dialog and exit command
		if vertcount <= 0:
			lx.eval('dialog.setup info')
			lx.eval('dialog.title {PP Locator Drop:}')
			lx.eval('dialog.msg {You must have at least one vertex selected to run this script.}')
			lx.eval('+dialog.open')
			return
	
		#reads the user values from the arguments		
		locator = self.dyna_String (0)
		shape = self.dyna_String (1)
		label = self.dyna_String (2)
		solid = self.dyna_String (3)
		align = self.dyna_String (4)
		axis = self.dyna_String (5)
		sizeX = self.dyna_Float (6)
		sizeY = self.dyna_Float (7)
		sizeZ = self.dyna_Float (8)
		radius = self.dyna_Float (9)
		wcolor = self.dyna_String (10)
		fcolor = self.dyna_String (11)
		
		lx.out ('locator name', locator)
		lx.out ('shape', shape)
		lx.out ('label', label)
		lx.out ('solid', solid)
		lx.out ('align', align)
		lx.out ('axis', axis)
		lx.out ('x', sizeX)
		lx.out ('y', sizeX)
		lx.out ('z', sizeX)
		lx.out ('radius', radius)		
		lx.out ('wireframe color', wcolor)
		lx.out ('fill color', fcolor)
	

		try:
			#All my regular code
			#pass
			layer = lx.eval('query layerservice layer.index ? main')
			verts = lx.evalN('query layerservice verts ? selected')# index of verts
			vertsN = lx.eval('query layerservice vert.N ? selected') #vert count
			lx.out('verts', verts)
			lx.out('vertsN', vertsN)
	
			#Now that the user set the values, we can just query it
			lx.out('text', locator)
			lx.out('type', shape)

			num = 1
			
			#for each vert create a locator and move the locator to the vert position
			for v in verts:
				#store vert position
				vertpos = lx.eval('query layerservice vert.pos ? %s' %v)
				vertPOS_X,vertPOS_Y,vertPOS_Z = vertpos
	
				#create locator and rename it to user input
				layer = lx.eval('item.create locator')
				layer = lx.eval('!!item.name %s_%s locator'% (locator, num))
	
				num += +1
	
				#move locator
				layer = lx.eval('transform.channel pos.Z %f'%vertPOS_Z)
				layer = lx.eval('transform.channel pos.Y %f'%vertPOS_Y)
				layer = lx.eval('transform.channel pos.X %f'%vertPOS_X)
				
				if shape == "standard":
					lx.eval('item.channel locator$size %f' %sizeX)
		
					#switch back to vert mode for next vert in list
					lx.eval('select.typeFrom vertex')
				
				elif shape == "box":
		
					#customize locator
					lx.eval('item.channel locator$drawShape custom')
					lx.eval('item.channel locator$isStyle replace')
					lx.eval('item.channel locator$isShape %s' %shape)
					lx.eval('item.help add label "%s"' %label)					
					lx.eval('item.channel locator$isSolid %s' %solid)					
					lx.eval('item.channel locator$isAlign %s' %align)
					lx.eval('item.channel locator$isAxis %s' %axis)
					lx.eval('item.channel locator$isSize.X %f' %sizeX)
					lx.eval('item.channel locator$isSize.Y %f' %sizeY)
					lx.eval('item.channel locator$isSize.Z %f' %sizeZ)
					#lx.eval('item.channel locator$isRadius %f' %radius)
					
					lx.eval('item.draw add locator')	
					lx.eval('item.channel locator$wireOptions user')				
					lx.eval('item.channel locator$wireColor {%s}' %wcolor)
					
					lx.eval('item.channel locator$fillOptions user')				
					lx.eval('item.channel locator$fillColor {%s}' %fcolor)
				
					#switch back to vert mode for next vert in list
					lx.eval('select.typeFrom vertex')
					
				elif shape == "pyramid":
					
					#customize locator
					lx.eval('item.channel locator$drawShape custom')
					lx.eval('item.channel locator$isStyle replace')
					lx.eval('item.channel locator$isShape %s' %shape)
					lx.eval('item.help add label "%s"' %label)					
					lx.eval('item.channel locator$isSolid %s' %solid)					
					lx.eval('item.channel locator$isAlign %s' %align)
					lx.eval('item.channel locator$isAxis %s' %axis)
					lx.eval('item.channel locator$isSize.X %f' %sizeX)
					lx.eval('item.channel locator$isSize.Y %f' %sizeY)
					lx.eval('item.channel locator$isSize.Z %f' %sizeZ)
					#lx.eval('item.channel locator$isRadius %f' %radius)
					
					lx.eval('item.draw add locator')	
					lx.eval('item.channel locator$wireOptions user')				
					lx.eval('item.channel locator$wireColor {%s}' %wcolor)
					
					lx.eval('item.channel locator$fillOptions user')				
					lx.eval('item.channel locator$fillColor {%s}' %fcolor)	
					
					#switch back to vert mode for next vert in list
					lx.eval('select.typeFrom vertex')

					
				elif shape == "rhombus":
					
					#customize locator
					lx.eval('item.channel locator$drawShape custom')
					lx.eval('item.channel locator$isStyle replace')
					lx.eval('item.channel locator$isShape %s' %shape)
					lx.eval('item.help add label "%s"' %label)					
					lx.eval('item.channel locator$isSolid %s' %solid)					
					lx.eval('item.channel locator$isAlign %s' %align)
					lx.eval('item.channel locator$isAxis %s' %axis)
					lx.eval('item.channel locator$isSize.X %f' %sizeX)
					lx.eval('item.channel locator$isSize.Y %f' %sizeY)
					lx.eval('item.channel locator$isSize.Z %f' %sizeZ)
					#lx.eval('item.channel locator$isRadius %f' %radius)
					
					lx.eval('item.draw add locator')	
					lx.eval('item.channel locator$wireOptions user')				
					lx.eval('item.channel locator$wireColor {%s}' %wcolor)
					
					lx.eval('item.channel locator$fillOptions user')				
					lx.eval('item.channel locator$fillColor {%s}' %fcolor)					
				
					#switch back to vert mode for next vert in list
					lx.eval('select.typeFrom vertex')
					
				elif shape == "cylinder":
					
					#customize locator
					lx.eval('item.channel locator$drawShape custom')
					lx.eval('item.channel locator$isStyle replace')
					lx.eval('item.channel locator$isShape %s' %shape)
					lx.eval('item.help add label "%s"' %label)					
					lx.eval('item.channel locator$isSolid %s' %solid)					
					lx.eval('item.channel locator$isAlign %s' %align)
					lx.eval('item.channel locator$isAxis %s' %axis)
					
					if axis == 'x':
						lx.eval('item.channel locator$isSize.X %f' %sizeX)
					elif axis == 'y':
						lx.eval('item.channel locator$isSize.Y %f' %sizeY)
					else:
						lx.eval('item.channel locator$isSize.Z %f' %sizeZ)
						
					lx.eval('item.channel locator$isRadius %f' %radius)
					
					lx.eval('item.draw add locator')	
					lx.eval('item.channel locator$wireOptions user')				
					lx.eval('item.channel locator$wireColor {%s}' %wcolor)
					
					lx.eval('item.channel locator$fillOptions user')				
					lx.eval('item.channel locator$fillColor {%s}' %fcolor)					
				
					#switch back to vert mode for next vert in list
					lx.eval('select.typeFrom vertex')
					
				elif shape == "cone":
					
					#customize locator
					lx.eval('item.channel locator$drawShape custom')
					lx.eval('item.channel locator$isStyle replace')
					lx.eval('item.channel locator$isShape %s' %shape)
					lx.eval('item.help add label "%s"' %label)					
					lx.eval('item.channel locator$isSolid %s' %solid)					
					lx.eval('item.channel locator$isAlign %s' %align)
					lx.eval('item.channel locator$isAxis %s' %axis)
					
					if axis == 'x':
						lx.eval('item.channel locator$isSize.X %f' %sizeX)
					elif axis == 'y':
						lx.eval('item.channel locator$isSize.Y %f' %sizeY)
					else:
						lx.eval('item.channel locator$isSize.Z %f' %sizeZ)
						
					lx.eval('item.channel locator$isRadius %f' %radius)
					
					lx.eval('item.draw add locator')	
					lx.eval('item.channel locator$wireOptions user')				
					lx.eval('item.channel locator$wireColor {%s}' %wcolor)
					
					lx.eval('item.channel locator$fillOptions user')				
					lx.eval('item.channel locator$fillColor {%s}' %fcolor)					
				
					#switch back to vert mode for next vert in list
					lx.eval('select.typeFrom vertex')
					
				elif shape == "sphere":
					
					#customize locator
					lx.eval('item.channel locator$drawShape custom')
					lx.eval('item.channel locator$isStyle replace')
					lx.eval('item.channel locator$isShape %s' %shape)
					lx.eval('item.help add label "%s"' %label)					
					lx.eval('item.channel locator$isSolid %s' %solid)					
					lx.eval('item.channel locator$isAlign %s' %align)
					lx.eval('item.channel locator$isAxis %s' %axis)
						
					lx.eval('item.channel locator$isRadius %f' %radius)
					
					lx.eval('item.draw add locator')	
					lx.eval('item.channel locator$wireOptions user')				
					lx.eval('item.channel locator$wireColor {%s}' %wcolor)
					
					lx.eval('item.channel locator$fillOptions user')				
					lx.eval('item.channel locator$fillColor {%s}' %fcolor)					
				
					#switch back to vert mode for next vert in list
					lx.eval('select.typeFrom vertex')

				elif shape == "plane":
						
					#customize locator
					lx.eval('item.channel locator$drawShape custom')
					lx.eval('item.channel locator$isStyle replace')
					lx.eval('item.channel locator$isShape %s' %shape)
					lx.eval('item.help add label "%s"' %label)					
					lx.eval('item.channel locator$isSolid %s' %solid)					
					lx.eval('item.channel locator$isAlign %s' %align)
					lx.eval('item.channel locator$isAxis %s' %axis)
					
					if axis == 'x':
						lx.eval('item.channel locator$isSize.Y %f' %sizeY)
						lx.eval('item.channel locator$isSize.Z %f' %sizeZ)
					elif axis == 'y':
						lx.eval('item.channel locator$isSize.X %f' %sizeX)
						lx.eval('item.channel locator$isSize.Z %f' %sizeZ)
					else:
						lx.eval('item.channel locator$isSize.X %f' %sizeX)
						lx.eval('item.channel locator$isSize.Y %f' %sizeY)
						
					#lx.eval('item.channel locator$isRadius %f' %radius)
					
					lx.eval('item.draw add locator')	
					lx.eval('item.channel locator$wireOptions user')				
					lx.eval('item.channel locator$wireColor {%s}' %wcolor)
					
					lx.eval('item.channel locator$fillOptions user')				
					lx.eval('item.channel locator$fillColor {%s}' %fcolor)				
				
					#switch back to vert mode for next vert in list
					lx.eval('select.typeFrom vertex')
					
				elif shape == "circle":
						
					#customize locator
					lx.eval('item.channel locator$drawShape custom')
					lx.eval('item.channel locator$isStyle replace')
					lx.eval('item.channel locator$isShape %s' %shape)
					lx.eval('item.help add label "%s"' %label)					
					lx.eval('item.channel locator$isSolid %s' %solid)					
					lx.eval('item.channel locator$isAlign %s' %align)
					lx.eval('item.channel locator$isAxis %s' %axis)
						
					lx.eval('item.channel locator$isRadius %f' %radius)
					
					lx.eval('item.draw add locator')	
					lx.eval('item.channel locator$wireOptions user')				
					lx.eval('item.channel locator$wireColor {%s}' %wcolor)
					
					lx.eval('item.channel locator$fillOptions user')				
					lx.eval('item.channel locator$fillColor {%s}' %fcolor)				
				
					#switch back to vert mode for next vert in list
					lx.eval('select.typeFrom vertex')
								
	
		except:
			lx.out(traceback.format_exc())
	
#This final command registers it as a plug in
lx.bless (Command, "pp.LocatorDrop")