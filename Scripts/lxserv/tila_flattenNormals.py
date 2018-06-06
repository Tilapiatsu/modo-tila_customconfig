
################################################################################
#
# tila_flattenNormals.py
#
# Version: 1.0
#
# Author: Tilapiatsu
#
# Description: This script will flatten normals based on the average of all face normals of the selected polygons
# Todo: - make it compatible with edge and vertex selection : It may change the behaviour : normal could be split ?
#		- create an area weighting feature
#
# Last Update: 22/05/2018
#
################################################################################

import lx
import lxifc
import lxu.command
import modo
import sys

class CmdFlattenNormals(lxu.command.BasicCommand):
	ModoModes = {'VERT' : 'vertex',
				'EDGE' : 'edge',
				'POLY' : 'polygon',
				'ITEM' : 'item'}

	def __init__(self):
		lxu.command.BasicCommand.__init__(self)

		self.dyna_Add('useVertexNormals', lx.symbol.sTYPE_BOOLEAN)
		self.basic_SetFlags (0, lx.symbol.fCMDARG_OPTIONAL)

		self.scn = modo.Scene()
		self.useVertexNormals = False

	def arg_UIHints (self, index, hints):
		if index == 0:
			hints.Label('Use Vertex Normal')

	@staticmethod
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

	def getModoMode(self):
		if lx.eval('select.typeFrom ' + self.ModoModes['VERT'] + ';' + self.ModoModes['EDGE'] + ';' + self.ModoModes['POLY'] + ';' + self.ModoModes['ITEM'] + ' ?'): modoMode = self.ModoModes['VERT']
		if lx.eval('select.typeFrom ' + self.ModoModes['EDGE'] + ';' + self.ModoModes['POLY'] + ';' + self.ModoModes['ITEM'] + ';' + self.ModoModes['VERT'] + ' ?'): modoMode = self.ModoModes['EDGE']
		if lx.eval('select.typeFrom ' + self.ModoModes['POLY'] + ';' + self.ModoModes['ITEM'] + ';' + self.ModoModes['VERT'] + ';' + self.ModoModes['EDGE'] + ' ?'): modoMode = self.ModoModes['POLY']
		if lx.eval('select.typeFrom ' + self.ModoModes['ITEM'] + ';' + self.ModoModes['VERT'] + ';' + self.ModoModes['EDGE'] + ';' + self.ModoModes['POLY'] + ' ?'): modoMode = self.ModoModes['ITEM']

		return modoMode

	def basic_Execute(self, msg, flags):
		if self.dyna_IsSet(0):
			self.useVertexNormals = self.dyna_Bool(0)
		if len(self.scn.selected):
			selection = self.scn.selectedByType('mesh')[0]
			if selection.type == 'mesh':
				# Create vertex normal map if non found
				vMaps = selection.geometry.vmaps
				for map in vMaps:
					if map.map_type == 1313821261:
						normalMap = map
						break
				else:
					normalMap = selection.geometry.vmaps.addVertexNormalMap()

				# Polygon component Mode
				if self.getModoMode() == self.ModoModes['POLY']:
					selectedPolygons = selection.geometry.polygons.selected

					if len(selectedPolygons)>0:
						averageNormal = (0,0,0)
						i = 0
						for p in selectedPolygons:
							print p
							if not self.useVertexNormals:
								averageNormal = self.addVector(averageNormal, p.normal)
								i += 1
							else:
								for vID in xrange(p.numVertices):
									vN = p.vertexNormal(vID)
									averageNormal = self.addVector(averageNormal, vN)
									i += 1

						i = float(i)

						averageNormal = self.scalarMultiplyVector(averageNormal , 1/i)

						for p in selectedPolygons:
							for v in p.vertices:
								normalMap.setNormal(averageNormal, v)

						selection.geometry.setMeshEdits(lx.symbol.f_MESHEDIT_MAP_OTHER)

				# Edge component Mode
				elif self.getModoMode() == self.ModoModes['EDGE']:
					lx.eval('select.convert vertex')
					lx.eval('tool.doApply')
					
					selectedVertices = selection.geometry.vertices.selected

					if len(selectedVertices)>0:
						averageNormal = (0,0,0)
						i = 0
						for v in selectedVertices:
							print v
							for p in v.polygons:
								if not self.useVertexNormals:
									averageNormal = self.addVector(averageNormal, p.normal)
									i += 1
								else:
									for vID in xrange(p.numVertices):
										vN = p.vertexNormal(vID)
										averageNormal = self.addVector(averageNormal, vN)
										i += 1

						i = float(i)

						averageNormal = self.scalarMultiplyVector(averageNormal , 1/i)
						vMaps = selection.geometry.vmaps

						for v in selectedVertices:
							normalMap.setNormal(averageNormal, v)
						selection.geometry.setMeshEdits(lx.symbol.f_MESHEDIT_MAP_OTHER)

					lx.eval('select.typeFrom edge;vertex;polygon;item;pivot;center;ptag true')

				# Vert component Mode
				elif self.getModoMode() == self.ModoModes['VERT']:

					selectedVertices = selection.geometry.vertices.selected

					if len(selectedVertices)>0:
						averageNormal = (0,0,0)
						i = 0
						for v in selectedVertices:
							print v
							for p in v.polygons:
								if not self.useVertexNormals:
									averageNormal = self.addVector(averageNormal, p.normal)
									i += 1
								else:
									for vID in xrange(p.numVertices):
										vN = p.vertexNormal(vID)
										averageNormal = self.addVector(averageNormal, vN)
										i += 1

						i = float(i)

						averageNormal = self.scalarMultiplyVector(averageNormal , 1/i)
						vMaps = selection.geometry.vmaps

						for v in selectedVertices:
							normalMap.setNormal(averageNormal, v)
						selection.geometry.setMeshEdits(lx.symbol.f_MESHEDIT_MAP_OTHER)

				# Item Mode
				else:
					self.init_message('error', 'Component mode Needed', 'Need to be in component mode')
			else:
				self.init_message('error', 'Select a mesh first', 'Select a mesh first.\nSelected type : {}'.format(selection.type))
		else:
			self.init_message('error', 'Select a mesh first', 'Select a mesh first.')

	def cmd_Query(self, index, vaQuery):
		lx.notimpl()


lx.bless(CmdFlattenNormals, "tila.flattennormals")

