
################################################################################
#
# scriptname.py
#
# Version: 1
#
# Author: Tilapiatsu
#
# Description: Isolate selected item - ( hide unselected )
#
# Last Update: 05/07/2016
#
################################################################################

import lx
import lxifc
import lxu.command
import modo


class CmdTila_isolateSelection(lxu.command.BasicCommand):
	def __init__(self):
	    lxu.command.BasicCommand.__init__(self)

	    self.commands = ('hide.sel', 'hide.invert')
	    self.incompatibleItem = ('advancedMaterial',
								 'defaultShader',
								 'shaderFolder',
								 'wood',
								 'weave',
								 'val',
								 'ripples',
								 'noise',
								 'grid',
								 'dots',
								 'checker',
								 'cellular',
								 'surfGen',
								 'projectShader',
								 'matcapShader',
								 'renderOutput',
								 'projectTexture',
								 'renderOutput',
								 'defaultShader',
								 'furMaterial',
								 'vmapTexture',
								 'variationTexture',
								 'tensionTexture',
								 'process',
								 'occlusion',
								 'gradient',
								 'constant',
								 'image',
								 'imageMap',
								 'mask',
								 'unrealShader',
								 'unityShader',
								 'material',
								 'polyRender',
								 'lightMaterial',
								 'envMaterial',
								 'environment',
								 'scene')

	    self.scn = None
	    self.selection = None

	def cmd_Flags(self):
	    return lx.symbol.fCMD_MODEL | lx.symbol.fCMD_UNDO

	def basic_Enable(self, msg):
	    return True

	def cmd_Interact(self):
	    pass

	def isolateSelection(self):
	    for command in self.commands:
	        lx.eval(command)

	    self.scn.select(self.selection)

	def isPolygonSelected(self):
	    polygonIsSelected = False

	    for item in self.selection:
	        if item.type == 'mesh':
	            if len(item.geometry.polygons.selected) < 1:
	                polygonIsSelected = polygonIsSelected or False
	            else:
	                polygonIsSelected = polygonIsSelected or True

	    return polygonIsSelected

	def isEdgeSelected(self):
	    edgeIsSelected = False

	    for item in self.selection:
	        if item.type == 'mesh':
	            if len(item.geometry.edges.selected) < 1:
	                edgeIsSelected = edgeIsSelected or False
	            else:
	                edgeIsSelected = edgeIsSelected or True

	    return edgeIsSelected

	def isVertexSelected(self):
	    vertexIsSelected = False

	    for item in self.selection:
	        if item.type == 'mesh':
	            if len(item.geometry.vertices.selected) < 1:
	                vertexIsSelected = vertexIsSelected or False
	            else:
	                vertexIsSelected = vertexIsSelected or True

	    return vertexIsSelected

	def IncompatibleItemSelected(self):
	    IncompatibleSelected = False

	    for item in self.selection:
	    	for o in self.incompatibleItem:
				if item.type.split('.')[0] == o:
					IncompatibleSelected = True
					break
				else:
					continue

	    return IncompatibleSelected

	def NoCompatibleItemSelected(self):
		NoCompatibleSelected = True

		for item in self.selection:
			if item.type.split('.')[0] in self.incompatibleItem:
				continue
			else:
				NoCompatibleSelected = False
				break

			print item.name
			print NoCompatibleSelected

		return NoCompatibleSelected

	def FilterCompatible(self):
		for i in xrange(len(self.selection)):
			if self.selection[i].type.split('.')[0] in self.incompatibleItem:
				self.scn.deselect(self.selection[i])

	def basic_Execute(self, msg, flags):
	    self.scn = modo.Scene()
	    self.selection = self.scn.selected

	    if len(self.selection) == 0:
	        self.scn.select(self.scn.items())
	        self.isolateSelection()
	    else:
	        if lx.eval('select.typeFrom item;pivot;center;edge;polygon;vertex;ptag ?'):
				if self.IncompatibleItemSelected() and self.NoCompatibleItemSelected():
					self.scn.select(self.scn.items())
					self.isolateSelection()
				elif self.IncompatibleItemSelected():
					selection = self.scn.selected

					self.FilterCompatible()
					lx.eval('unhide')
					lx.eval('hide.unsel')

					self.scn.select(selection)

				else:
					lx.eval('unhide')
					lx.eval('hide.unsel')

	        elif lx.eval('select.typeFrom polygon;edge;vertex;item;pivot;center;ptag ?'):
	            if self.isPolygonSelected():
	                lx.eval('hide.unsel')
	            else:
	                lx.eval('unhide')

	        elif lx.eval('select.typeFrom edge;vertex;polygon;item;pivot;center;ptag ?'):
	            if self.isEdgeSelected():
	                lx.eval('select.expand')
	                lx.eval('select.convert polygon')
	                lx.eval('hide.unsel')
	            else:
	                lx.eval('unhide')

	        elif lx.eval('select.typeFrom vertex;edge;polygon;item;pivot;center;ptag ?'):
	            if self.isVertexSelected():
	                lx.eval('select.expand')
	                lx.eval('select.expand')
	                lx.eval('select.convert polygon')
	                lx.eval('hide.unsel')
	            else:
	                lx.eval('unhide')

	def cmd_Query(self, index, vaQuery):
	    lx.notimpl()

lx.bless(CmdTila_isolateSelection, "tila.isolateSelection")

