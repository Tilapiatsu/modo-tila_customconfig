#!/usr/bin/env python
 
import lx
import lxifc
import lxu.command
# import traceback

#_______________________________________________________________________________________________________________________ VISITORS

class ListWeightMaps (lxifc.Visitor):
	def __init__ (self, meshmap_fore, meshmap_back):
		self.meshmap_fore = meshmap_fore
		self.meshmap_back = meshmap_back

		self.meshmap_IDs = []

	def vis_Evaluate (self):
		# try:
		# Gather a list of the map IDs that are shared by both the foreground and the background meshes.
		meshmap_name = self.meshmap_fore.Name ()
		if meshmap_name.startswith (lx.symbol.sVMAP_ITEMPREFIX):
			try:
				self.meshmap_back.SelectByName (lx.symbol.i_VMAP_WEIGHT, meshmap_name)
			except:
				# lx.out('Couldn\'t find meshmap %s in background mesh, ignoring it.' % meshmap_name)
				pass
			else:
				self.meshmap_IDs.append ((self.meshmap_fore.ID (), self.meshmap_back.ID ()))

		# except:
		# 	lx.out(traceback.format_exc())



class CopyWeights (lxifc.Visitor):
	def __init__ (self, point_fore, point_back, polygon_back, meshmap_IDs):
		self.point_fore = point_fore
		self.point_back = point_back
		self.polygon_back = polygon_back
		self.meshmap_IDs = meshmap_IDs

		self.position = lx.object.storage ('f', 3)
		self.position.set ((0.0,0.0,0.0))
		self.weight = lx.object.storage ('f', 1)
		self.weight.set ((1.0,))

	def vis_Evaluate (self):
		# try:
		point_fore_pos = self.point_fore.Pos ()
		self.position.set (point_fore_pos)

		# Find the nearest background polygon to the foreground polygon.
		try:
			closest = self.polygon_back.Closest (1000.0, self.position)
		except:
			# lx.out('Couldn\'t find the closest polygon.')
			pass
		else:
			# Set up holders for the distance and default the closest point ID.
			distance_nearest = float('inf')
			closest_point = self.polygon_back.VertexByIndex (0)

			# Find the vertex of the background polygon that is nearest to the foreground vertex.
			polygon_back_point_count = self.polygon_back.VertexCount ()
			for v in xrange(polygon_back_point_count):
				point_back_ID = self.polygon_back.VertexByIndex (v)
				self.point_back.Select (point_back_ID)
				point_back_pos = self.point_back.Pos ()

				# Deal with squared distances - saves having to use sqrt.
				pos_delta = (point_back_pos[0] - point_fore_pos[0], point_back_pos[1] - point_fore_pos[1], point_back_pos[2] - point_fore_pos[2])
				distance = pos_delta[0]*pos_delta[0] + pos_delta[1]*pos_delta[1] + pos_delta[2]*pos_delta[2]

				if distance < distance_nearest:
					distance_nearest = distance
					closest_point = point_back_ID

			# Select the nearest background vertex, then copy it's value for each weight map over to the foreground vertex.
			self.point_back.Select (closest_point)
			for meshmap_ID_pair in self.meshmap_IDs:
				self.point_back.MapEvaluate (meshmap_ID_pair[1], self.weight)
				self.point_fore.SetMapValue (meshmap_ID_pair[0], self.weight)

		# except:
		# 	lx.out(traceback.format_exc())



class CopyWeights_Cmd(lxu.command.BasicCommand):

#______________________________________________________________________________________________ SETUP AND INITIALISATION

	def __init__(self):
		lxu.command.BasicCommand.__init__(self)

	def cmd_UserName(self):
 		return 'Transfer Weights'

 	def cmd_Desc(self):
 		return 'Transfer all shared weight maps values from background mesh to foreground mesh based on vertex proximity.'

 	def cmd_Tooltip(self):
 		return 'Transfer all shared weight maps values from background mesh to foreground mesh based on vertex proximity.'

 	def cmd_Help(self):
 		return 'http://www.farfarer.com/'

	def basic_ButtonName(self):
		return 'Transfer Weights'
 
	def cmd_Flags(self):
		return lx.symbol.fCMD_MODEL | lx.symbol.fCMD_UNDO

	def basic_Enable(self, msg):
		return True

	def cmd_Interact(self):
		pass

#_______________________________________________________________________________________________ MAIN FUNCTION EXECUTION

	def basic_Execute(self, msg, flags):
		# try:
		# Grab the active and background layers.
		layer_svc = lx.service.Layer ()

		# Get the two layers.
		layer_scan = lx.object.LayerScan (layer_svc.ScanAllocate (lx.symbol.f_LAYERSCAN_ALL | lx.symbol.f_LAYERSCAN_WRITEMESH | lx.symbol.f_LAYERSCAN_MARKALL))
		if not layer_scan.test ():
			return
		layer_scan_count = layer_scan.Count ()
		if layer_scan_count != 2:
			return

		# Work out which is the primary active layer (destination) and which is the background layer (source).
		primary_layer_index = -1
		background_layer_index = -1
		for layer in xrange(layer_scan_count):
			if layer_scan.GetState (layer) == (lx.symbol.f_LAYERSCAN_PRIMARY | lx.symbol.f_LAYERSCAN_ACTIVE):
				primary_layer_index = layer

			elif layer_scan.GetState (layer) == lx.symbol.f_LAYERSCAN_BACKGROUND:
				background_layer_index = layer

		# Early out if a foreground and a background layer have not been found.
		if primary_layer_index == -1 or background_layer_index == -1:
			return

		# Grab the meshes.
		mesh_fore = lx.object.Mesh (layer_scan.MeshEdit (primary_layer_index))
		mesh_back = lx.object.Mesh (layer_scan.MeshBase (background_layer_index))
		if not mesh_fore.test () or not mesh_back.test ():
			return

		# Early out if either of the layers are empty.
		if mesh_fore.PolygonCount () == 0 or mesh_back.PolygonCount () == 0:
			return

		# Grab the accessors needed.
		point_fore = lx.object.Point (mesh_fore.PointAccessor ())
		point_back = lx.object.Point (mesh_back.PointAccessor ())
		if not point_fore.test () or not point_back.test ():
			return

		polygon_back = lx.object.Polygon (mesh_back.PolygonAccessor ())
		if not point_back.test ():
			return

		meshmap_fore = lx.object.MeshMap (mesh_fore.MeshMapAccessor ())
		meshmap_back = lx.object.MeshMap (mesh_back.MeshMapAccessor ())
		if not meshmap_fore.test () or not meshmap_back.test ():
			return

		# Get a list of the weight maps shared by the foreground and the background meshes.
		visitor = ListWeightMaps (meshmap_fore, meshmap_back)
		meshmap_fore.FilterByType (lx.symbol.i_VMAP_WEIGHT)
		meshmap_fore.Enumerate (lx.symbol.iMARK_ANY, visitor, 0)
		meshmap_IDs = tuple(visitor.meshmap_IDs)
		meshmap_fore.FilterByType (0)

		# Go through each point and copy the values of each weight map from the background mesh to the foreground mesh.
		visitor = CopyWeights (point_fore, point_back, polygon_back, meshmap_IDs)
		point_fore.Enumerate (lx.symbol.iMARK_ANY, visitor, 0)

		# Apply changes.
		layer_scan.SetMeshChange (primary_layer_index, lx.symbol.f_MESHEDIT_MAP_OTHER | lx.symbol.f_MESHEDIT_MAP_CONTINUITY)
		
		layer_scan.Apply ()

		# except:
		# 	lx.out(traceback.format_exc())

#________________________________________________________________________________________ BLESS FUNCTION AS MODO COMMAND

lx.bless (CopyWeights_Cmd, 'ffr.copyweights')