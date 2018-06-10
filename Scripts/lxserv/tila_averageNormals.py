
################################################################################
#
# tila_averageNormals.py
#
# Version: 1.0
#
# Author: Tilapiatsu
#
# Description: This script will average normals based on the face normals of the polygon surrounding each vertices contained in the selected polygons
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
import math
import traceback

class CmdAverageNormals(lxu.command.BasicCommand):
	ModoModes = {'VERT' : 'vertex',
				'EDGE' : 'edge',
				'POLY' : 'polygon',
				'ITEM' : 'item'}

	def __init__(self):
		lxu.command.BasicCommand.__init__(self)

		self.dyna_Add('basedOnSelectedPolygon', lx.symbol.sTYPE_BOOLEAN)
		self.basic_SetFlags (0, lx.symbol.fCMDARG_OPTIONAL)

		self.scn = modo.Scene()
		self.basedOnSelectedPolygon = False

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
				self.basedOnSelectedPolygon = self.dyna_Bool(0)
			meshSelection = self.scn.selectedByType('mesh')
			if len(meshSelection):
				sel_svc = lx.service.Selection ()

				n = 0
				for item in meshSelection:
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
						if self.getSelectionMode() == self.ModoModes['POLY']:
							selectedPolygons = item.geometry.polygons.selected

							if len(selectedPolygons)>0:
								connectedVertices = ()

								for p in selectedPolygons:
									for v in p.vertices:
										connectedVertices = connectedVertices + (v,)
								for v in connectedVertices:
									i = 0
									averageNormal = (0,0,0)
									for p in v.polygons:
										proceededPolygons = ()
										if p not in proceededPolygons:
											if self.basedOnSelectedPolygon:
												if p in selectedPolygons:
													averageNormal = self.vectorAdd(averageNormal, p.normal)
													proceededPolygons = proceededPolygons + (p,)
													i += 1
											else:
												averageNormal = self.vectorAdd(averageNormal, p.normal)
												proceededPolygons = proceededPolygons + (p,)
												i += 1

									i = float(i)

									averageNormal = self.vectorScalarMultiply(averageNormal , 1/i)
									normalMap.setNormal(averageNormal, v)

								item.geometry.setMeshEdits(lx.symbol.f_MESHEDIT_MAP_OTHER)

						# Edge component Mode
						elif self.getSelectionMode() == self.ModoModes['EDGE']:
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

							for e in selectedEdges:

								polygon_IDs = []

								if e[2] == 0:
									edge_loc.SelectEndpoints(e[1][0], e[1][1])
									for ep in xrange (edge_loc.PolygonCount()):
										polygon_IDs.append(edge_loc.PolygonByIndex(ep))
								else:
									polygon_IDs.append(e[2])

								averageNormal = (0,0,0)
								i = 0
								for p in polygon_IDs:
									polygon_loc.Select (p)

									averageNormal = self.vectorAdd(averageNormal, polygon_loc.Normal())
									i += 1
								i = float(i)
								print i
								print averageNormal
								averageNormal = self.vectorScalarMultiply(averageNormal , 1/i)
								vMaps = item.geometry.vmaps

								for v in e[1]:
									vert = item.geometry.vertices[v]
									normalMap.setNormal(averageNormal, vert)

							item.geometry.setMeshEdits(lx.symbol.f_MESHEDIT_MAP_OTHER)

						# Vert component Mode
						elif self.getSelectionMode() == self.ModoModes['VERT']:
							selectedVertices = item.geometry.vertices.selected

							if len(selectedVertices)>0:
								averageNormal = (0,0,0)
								i = 0
								for v in selectedVertices:
									proceededPolygons = ()
									for p in v.polygons:
										if p not in proceededPolygons:
											averageNormal = self.vectorAdd(averageNormal, p.normal)
											proceededPolygons = proceededPolygons + (p,)
											i += 1
									i = float(i)

									averageNormal = self.vectorScalarMultiply(averageNormal , 1/i)
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


lx.bless(CmdAverageNormals, "tila.averagenormals")

