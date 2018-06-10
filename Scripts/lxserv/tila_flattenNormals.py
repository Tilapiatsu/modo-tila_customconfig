
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
import math
import traceback

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
		self.currentSelectionMode = self.getSelectionMode()
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
	def vectorScalarMultiply(v, s):
		return [v[i] * s for i in range(len(v))]

	@staticmethod
	def vectorMagnitude(v):
		return math.sqrt(sum(v[i]*v[i] for i in range(len(v))))

	@staticmethod
	def vectorAdd(u, v):
		return [ u[i]+v[i] for i in range(len(u)) ]

	@staticmethod
	def vectorSub(u, v):
		return [ u[i]-v[i] for i in range(len(u)) ]

	@staticmethod
	def vectorDot(u, v):
		return sum(u[i]*v[i] for i in range(len(u)))

	def vectorNormalize(self, v):
		vmag = self.vectorMagnitude(v)
		return [ v[i]/vmag  for i in range(len(v)) ]
		
	def cmd_Flags(self):
		return lx.symbol.fCMD_MODEL | lx.symbol.fCMD_UNDO

	def basic_Enable(self, msg):
		return True

	def cmd_Interact(self):
		pass

	def getSelectionMode(self):
		return lx.eval1 ('query layerservice selmode ?')

	def basic_Execute(self, msg, flags):
		try:
			
			if self.dyna_IsSet(0):
				self.useVertexNormals = self.dyna_Bool(0)
			if len(self.scn.selected):
				sel_svc = lx.service.Selection ()

				n = 0
				for item in self.scn.selected:
					if item.type == 'mesh':
						# Create vertex normal map if non found
						vMaps = item.geometry.vmaps
						for map in vMaps:
							if map.map_type == 1313821261:
								normalMap = map
								break
						else:
							normalMap = item.geometry.vmaps.addVertexNormalMap()
							item.geometry.setMeshEdits(lx.symbol.f_MESHEDIT_MAP_OTHER)

						layer_svc = lx.service.Layer()
						layer_scan = lx.object.LayerScan(layer_svc.ScanAllocate (lx.symbol.f_LAYERSCAN_ACTIVE|lx.symbol.f_LAYERSCAN_MARKALL))
						if not layer_scan.test():
							return

						# Polygon component Mode
						if self.currentSelectionMode == self.ModoModes['POLY']:
							selectedPolygons = item.geometry.polygons.selected

							if len(selectedPolygons)>0:
								averageNormal = (0,0,0)
								i = 0
								for p in selectedPolygons:
									if not self.useVertexNormals:
										averageNormal = self.vectorAdd(averageNormal, p.normal)
										i += 1
									else:
										for vID in xrange(p.numVertices):
											vN = p.vertexNormal(vID)
											averageNormal = self.vectorAdd(averageNormal, vN)
											i += 1

								i = float(i)

								averageNormal = self.vectorScalarMultiply(averageNormal , 1/i)
								#averageNormal = self.vectorNormalize(averageNormal)

								for p in selectedPolygons:
									for v in p.vertices:
										normalMap.setNormal(averageNormal, v)

								item.geometry.setMeshEdits(lx.symbol.f_MESHEDIT_MAP_OTHER)

						# Edge component Mode
						elif self.currentSelectionMode == self.ModoModes['EDGE']:
							# lx.eval('select.convert vertex')
							# lx.eval('tool.doApply')

							edge_pkt_trans = lx.object.EdgePacketTranslation (sel_svc.Allocate (lx.symbol.sSELTYP_EDGE))
							sel_type_edge = sel_svc.LookupType (lx.symbol.sSELTYP_EDGE)

							selectedEdgeCount = sel_svc.Count(sel_type_edge)

							mesh_loc = lx.object.Mesh(layer_scan.MeshBase(n))
							if not mesh_loc.test():
								continue

							polygon_loc = lx.object.Polygon (mesh_loc.PolygonAccessor ())
							if not polygon_loc.test ():
								continue

							edge_loc = lx.object.Edge (mesh_loc.EdgeAccessor ())
							if not edge_loc.test ():
								continue

							meshmap_loc = lx.object.MeshMap (mesh_loc.MeshMapAccessor ())
							if not meshmap_loc.test ():
								continue

							if selectedEdgeCount == 0:
								# Return if there are no edges selected.
								self.init_message('error', 'No edge selected', 'select at least one edge')
								return

							selectedEdges = []
							for i in xrange(selectedEdgeCount):
								# Get a packet representing this edge.
								pkt = sel_svc.ByIndex(sel_type_edge, i)
								# Get it's verts IDs.
								points = edge_pkt_trans.Vertices(pkt)
								# Get it's polygon ID.
								polygon = edge_pkt_trans.Polygon(pkt)
								# Get it's mesh.
								mesh = edge_pkt_trans.Mesh(pkt)

								selectedEdges.append((mesh, points, polygon))

							averageNormal = (0,0,0)
							i = 0
							for e in selectedEdges:
								polygon_IDs = []

								if e[2] == 0:
									edge_loc.SelectEndpoints(e[1][0], e[1][1])
									for ep in xrange (edge_loc.PolygonCount ()):
										polygon_IDs.append(edge_loc.PolygonByIndex(ep))
								else:
									polygon_IDs.append (e[2])

								for p in polygon_IDs:
									polygon_loc.Select (p)

									if not self.useVertexNormals:
										averageNormal = self.vectorAdd(averageNormal, polygon_loc.Normal())
										i += 1
									else:
										for vID in xrange(p.numVertices):
											vN = p.vertexNormal(vID)
											averageNormal = self.vectorAdd(averageNormal, vN)
											i += 1
							i = float(i)

							averageNormal = self.vectorScalarMultiply(averageNormal , 1/i)
							#averageNormal = self.vectorNormalize(averageNormal)
							vMaps = item.geometry.vmaps

							for e in selectedEdges:
								for v in e[1]:
									vert = item.geometry.vertices[v]
									normalMap.setNormal(averageNormal, vert)
							item.geometry.setMeshEdits(lx.symbol.f_MESHEDIT_MAP_OTHER)

						# Vert component Mode
						elif self.currentSelectionMode == self.ModoModes['VERT']:

							selectedVertices = item.geometry.vertices.selected

							if len(selectedVertices)>0:
								averageNormal = (0,0,0)
								i = 0
								for v in selectedVertices:
									
									proceededPolygons = ()
									for p in v.polygons:
										if p not in proceededPolygons:
											if not self.useVertexNormals:
												averageNormal = self.vectorAdd(averageNormal, p.normal)
												proceededPolygons = proceededPolygons + (p,)
												i += 1
											else:
												for vID in xrange(p.numVertices):
													vN = p.vertexNormal(vID)
													averageNormal = self.vectorAdd(averageNormal, vN)
													proceededPolygons = proceededPolygons + (p,)
													i += 1

								i = float(i)

								averageNormal = self.vectorScalarMultiply(averageNormal , 1/i)
								#averageNormal = self.vectorNormalize(averageNormal)
								vMaps = item.geometry.vmaps

								for v in selectedVertices:
									normalMap.setNormal(averageNormal, v)
								item.geometry.setMeshEdits(lx.symbol.f_MESHEDIT_MAP_OTHER)

						# Item Mode
						else:
							self.init_message('error', 'Component mode Needed', 'Need to be in component mode')

						n += 1
			else:
				self.init_message('error', 'Select a mesh first', 'Select a mesh first.')
		except:
			lx.out(traceback.format_exc())

	def cmd_Query(self, index, vaQuery):
		lx.notimpl()


lx.bless(CmdFlattenNormals, "tila.flattennormals")

