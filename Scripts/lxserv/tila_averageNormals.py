
################################################################################
#
# tila_flattenNormals.py
#
# Version: 1.0
#
# Author: Tilapiatsu
#
# Description: This script will flatten normals based on the average of all face normals of the selected polygons
# Todo: - make it compatible with edge and vertex selection
#		- create an area weighting feature
#
# Last Update: 22/05/2018
#
################################################################################

import lx
import lxifc
import lxu.command
import modo

class CmdAverageNormals(lxu.command.BasicCommand):
	def __init__(self):
		lxu.command.BasicCommand.__init__(self)

		self.scn = modo.Scene()
		self.useVertexNormals = False

	def init_message(type='info', title='info', message='info'):
		return_result = type == 'okCancel' \
						or type == 'yesNo' \
						or type == 'yesNoCancel' \
						or type == 'yesNoAll' \
						or type == 'yesNoToAll' \
						or type == 'saveOK' \
						or type == 'fileOpen' \
						or type == 'fileOpenMulti' \
						or type == 'fileSave' \
						or type == 'dir'
		try:
			lx.eval('dialog.setup {%s}' % type)
			lx.eval('dialog.title {%s}' % title)
			lx.eval('dialog.msg {%s}' % message)
			lx.eval('dialog.open')

			if return_result:
				return lx.eval('dialog.result ?')

		except:
			if return_result:
				return lx.eval('dialog.result ?')
	@staticmethod
	def addVector(v1, v2):
		return (v1[0] + v2[0], v1[1] + v2[1], v1[2] + v2[2])

	@staticmethod
	def scalarMultiplyVector(v, s):
		return (v[0] * s, v[1] * s, v[2] * s)
		
	def cmd_Flags(self):
		return lx.symbol.fCMD_MODEL | lx.symbol.fCMD_UNDO

	def basic_Enable(self, msg):
		return True

	def cmd_Interact(self):
		pass

	def basic_Execute(self, msg, flags):
		if len(self.scn.selected):
			selection = self.scn.selectedByType('mesh')[0]
			if selection.type == 'mesh':

				selectedPolygons = selection.geometry.polygons.selected

				if len(selectedPolygons)>0:

					vMaps = selection.geometry.vmaps
					for map in vMaps:
						if map.map_type == 1313821261:
							normalMap = map
							break
					else:
						normalMap = selection.geometry.vmaps.addVertexNormalMap()

					connectedVertices = ()

					for p in selectedPolygons:
						print p
						for v in p.vertices:
							connectedVertices = connectedVertices + (v,)
					for v in connectedVertices:
						print v
						i = 0
						averageNormal = (0,0,0)
						for p in v.polygons:
							self.addVector(averageNormal, p.normal)
							i += 1
						i = float(i)

						averageNormal = self.scalarMultiplyVector(averageNormal , 1/i)

						normalMap.setNormal(averageNormal, v)
								

					selection.geometry.setMeshEdits(lx.symbol.f_MESHEDIT_MAP_OTHER)
				else:
					self.init_message('error', 'Select at least one polygon', 'Select at least one polygon')
			else:
				self.init_message('error', 'Select a mesh first', 'Select a mesh first.\nSelected type : {}'.format(selection.type))
		else:
			self.init_message('error', 'Select a mesh first', 'Select a mesh first.')

	def cmd_Query(self, index, vaQuery):
		lx.notimpl()


lx.bless(CmdAverageNormals, "tila.averagenormals")

