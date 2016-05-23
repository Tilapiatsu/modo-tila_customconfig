#python

# Version 1.3
# Improved splits that were getting randomly nudged when they shouldn't have been.

# Version 1.2
# Improved the detection of split direction. Should see less mini-splits at acute angles now.
# Improved the handling of split direction. Splits should now be guaranteed to go in a perpendicular direction to the average edge direction.
# Improved the splits of right angle corners, should stay closer to right angles now.

# Version 1.1
# Added vertex level split. Splits all edges of selected vertices.

# Version 1.0
# Splits UVs of selected edges or boundaries of selected polygons.

import lx
import lxifc
import lxu.command
import lxu.select
import math
import random

# import traceback

#_______________________________________________________________________________________________________________________ VISITORS

class MarkEdges(lxifc.Visitor):
	def __init__(self, edge_loc, mark_mode):
		self.edge_loc = edge_loc
		self.mark_mode = mark_mode

	def vis_Evaluate(self):
		self.edge_loc.SetMarks(self.mark_mode)

class MarkPointEdges(lxifc.Visitor):
	def __init__(self, point_loc, edge_loc, mark_mode_to_split):
		self.point_loc = point_loc
		self.edge_loc = edge_loc
		self.mark_mode_to_split = mark_mode_to_split

	def vis_Evaluate(self):
		point_edges = self.point_loc.EdgeCount()
		for e in xrange(point_edges):
			self.edge_loc.Select(self.point_loc.EdgeByIndex(e))
			self.edge_loc.SetMarks(self.mark_mode_to_split)

class MarkPolyBorder(lxifc.Visitor):
	def __init__(self, edge_loc, polygon_loc, mark_mode_selected, mark_mode_to_split):
		self.edge_loc = edge_loc
		self.polygon_loc = polygon_loc
		self.mark_mode_selected = mark_mode_selected
		self.mark_mode_to_split = mark_mode_to_split

	def vis_Evaluate(self):
		edge_polygons = self.edge_loc.PolygonCount()
		selected_polygons = 0
		for p in xrange(edge_polygons):
			self.polygon_loc.Select(self.edge_loc.PolygonByIndex(p))
			if not self.polygon_loc.TestMarks(self.mark_mode_selected) == lx.symbol.e_FALSE:
				selected_polygons += 1
		if selected_polygons != 0 and selected_polygons != edge_polygons:
			self.edge_loc.SetMarks(self.mark_mode_to_split)

class SplitEdges(lxifc.Visitor):
	def __init__(self, edge_loc, point_loc, polygon_loc, uvmap_ID, mark_mode_to_split, mark_mode_moved, distance, selection_mode, mark_mode_selected):
		self.edge_loc = edge_loc
		self.point_loc = point_loc
		self.polygon_loc = polygon_loc
		self.uvmap_ID = uvmap_ID
		self.mark_mode_to_split = mark_mode_to_split
		self.mark_mode_moved = mark_mode_moved
		self.distance = distance
		self.selection_mode = selection_mode
		self.mark_mode_selected = mark_mode_selected

		self.uv_value = lx.object.storage('f', 2)
		self.previous_point_uvs_list = {}

		self.polygon_UV_values = {}

		self.root2 = math.sqrt(2.0)

	def vis_Evaluate(self):
		if not self.edge_loc.TestMarks(self.mark_mode_moved):
			self.edge_loc.SetMarks(self.mark_mode_moved)
			edge_endpoints = self.edge_loc.Endpoints()

			edge_ID = self.edge_loc.ID()

			edge_polygon_count = self.edge_loc.PolygonCount()
			edge_polygons = []
			for ep in xrange(edge_polygon_count):
				edge_polygons.append(self.edge_loc.PolygonByIndex(ep))

			for point_ID in edge_endpoints:
				self.point_loc.Select(point_ID)

				# Don't split this vertex if we're in vertex mode and the vertex isn't selected.
				if self.selection_mode == 'vertex' and not self.point_loc.TestMarks(self.mark_mode_selected):
					continue

				point_index = self.point_loc.Index()
				point_polygon_count = self.point_loc.PolygonCount()

				# CHECK IF POINT IS CONTINUOUS.
				point_UV_values = []
				for edge_polygon in edge_polygons:
					self.polygon_loc.Select(edge_polygon)
					self.polygon_loc.MapEvaluate(self.uvmap_ID, point_ID, self.uv_value)
					point_UV_values.append(self.uv_value.get())

				if point_UV_values.count(point_UV_values[0]) == len(point_UV_values):
					# IT IS CONTINUOUS.

					# GET THE VALUES THAT HAVE BEEN SET FOR THIS VERTEX ALREADY. IF IT EXISTS.
					# if self.previous_point_uvs_list.has_key(point_ID):
					# 	previous_point_uvs = self.previous_point_uvs_list[point_ID]
					# else:
					# 	previous_point_uvs = []
					# 	previous_point_uvs.append(point_UV_values[0])

					base_UV = point_UV_values[0]

					point_edges = []
					for pe in xrange(self.point_loc.EdgeCount()):
						point_edges.append(self.point_loc.EdgeByIndex(pe))

					for edge_polygon in edge_polygons:

						checked_edges = []
						checked_edges.append(edge_ID)

						no_connected_edge = True
						connected_uv_edge = (0.0, 0.0)

						outer_list = []
						inner_list = []
						outer_list.append(edge_polygon)

						# Here we walk around the polygons of the vertex and then find the next edge we want to split the UVs along.
						# If we get through all of the polygons without finding one, there is no next edge, that's a special case for splitting.
						internal_edges = []

						while len(outer_list):

							for polygon in outer_list:
								self.polygon_loc.Select(polygon)
								inner_list.append(polygon)
								outer_list.remove(polygon)

								for point_edge in point_edges:
									if point_edge not in checked_edges:
										try:
											self.polygon_loc.EdgeIndex(point_edge)
										except BaseException:
											continue
										else:
											checked_edges.append(point_edge)
											self.edge_loc.Select(point_edge)

											selected_edge_endpoints = self.edge_loc.Endpoints()
											if selected_edge_endpoints[0] == point_ID:
												other_point_ID = selected_edge_endpoints[1]
											else:
												other_point_ID = selected_edge_endpoints[0]

											# GET UV VALUES FOR THIS EDGE'S POINTS
											self.polygon_loc.MapEvaluate(self.uvmap_ID, point_ID, self.uv_value)
											uv_v0 = self.uv_value.get()
											self.polygon_loc.MapEvaluate(self.uvmap_ID, other_point_ID, self.uv_value)
											uv_v1 = self.uv_value.get()

											uv_edge = (uv_v1[0] - uv_v0[0], uv_v1[1] - uv_v0[1])

											if self.edge_loc.TestMarks(self.mark_mode_to_split):
												no_connected_edge = False
												connected_uv_edge = uv_edge

											else:
												internal_edges.append (uv_edge)

												self.polygon_loc.MapEvaluate(self.uvmap_ID, other_point_ID, self.uv_value)
												other_uv = self.uv_value.get()

												for ep in xrange(self.edge_loc.PolygonCount()):
													polygon_ID = self.edge_loc.PolygonByIndex(ep)
													if polygon_ID not in inner_list and polygon_ID not in outer_list:
														self.polygon_loc.Select(polygon_ID)
														self.polygon_loc.MapEvaluate(self.uvmap_ID, point_ID, self.uv_value)
														base_point_uv = self.uv_value.get()
														self.polygon_loc.MapEvaluate(self.uvmap_ID, other_point_ID, self.uv_value)
														other_point_uv = self.uv_value.get()
														if base_point_uv == base_UV and other_point_uv == other_uv:
															outer_list.append(polygon_ID)

						# ONLY SPLIT IF THERE IS A DISCONTINUITY
						if len(inner_list) < point_polygon_count:
							# GET UV VALUES FOR THIS EDGE'S POINTS
							if edge_endpoints[0] == point_ID:
								other_point_ID = edge_endpoints[1]
							else:
								other_point_ID = edge_endpoints[0]

							self.polygon_loc.Select(edge_polygon)
							self.polygon_loc.MapEvaluate(self.uvmap_ID, point_ID, self.uv_value)
							uv_v0 = self.uv_value.get()
							self.polygon_loc.MapEvaluate(self.uvmap_ID, other_point_ID, self.uv_value)
							uv_v1 = self.uv_value.get()

							# GET UNIT LENGTH VECTOR OF UV EDGE
							uv_edge = (uv_v1[0] - uv_v0[0], uv_v1[1] - uv_v0[1])
							uv_edge_length = uv_edge[0]**2 + uv_edge[1]**2
							if uv_edge_length == 0.0:
								# Unit length +U +V.
								uv_edge_norm = (0.0, 0.0)
							else:
								uv_edge_length = math.sqrt(uv_edge_length)
								uv_edge_norm = (uv_edge[0] / uv_edge_length, uv_edge[1] / uv_edge_length)

							uv_edge_centre = ((uv_v0[0] + uv_v1[0]) / 2,(uv_v0[1] + uv_v1[1]) / 2)

							# THERE IS ONLY ONE EDGE, NEED TO MOVE ORTHOGONAL FROM THE UV EDGE
							if no_connected_edge:
								# BUILD BBOX SO WE KNOW WHICH DIRECTION TO SHIFT THE VERTS' UV POSITIONS

								bbox = [0.0,0.0,0.0,0.0]
								centre_vector = (0.0, 0.0)

								self.polygon_loc.Select(edge_polygon)

								# GET AVERAGE UV VALUE FOR THIS POLYGON
								for v in xrange(self.polygon_loc.VertexCount()):
									polygon_point_ID = self.polygon_loc.VertexByIndex(v)
									self.polygon_loc.MapEvaluate(self.uvmap_ID, polygon_point_ID, self.uv_value)
									uv = self.uv_value.get()
									if v == 0:
										bbox[0] = uv[0]
										bbox[1] = uv[0]
										bbox[2] = uv[1]
										bbox[3] = uv[1]
									else:
										bbox[0] = min(uv[0], bbox[0])
										bbox[1] = max(uv[0], bbox[1])
										bbox[2] = min(uv[1], bbox[2])
										bbox[3] = max(uv[1], bbox[3])

								poly_average_centre_U = (bbox[0] + bbox[1]) / 2
								poly_average_centre_V = (bbox[2] + bbox[3]) / 2

								origin_to_poly_centre = (poly_average_centre_U - uv_edge_centre[0], poly_average_centre_V - uv_edge_centre[1])

								centre_vector = (centre_vector[0] + origin_to_poly_centre[0], centre_vector[1] + origin_to_poly_centre[1])

								# WORK OUT NEW UV VALUE
								centre_vector_length = centre_vector[0]**2 + centre_vector[1]**2
								if centre_vector_length == 0.0:
									# Unit length +U +V.
									centre_vector = (1.0, 1.0)
								else:
									centre_vector_length = math.sqrt(centre_vector_length)
									centre_vector = (centre_vector[0] / centre_vector_length, centre_vector[1] / centre_vector_length)

								#lx.out('%s %s Centre Vector: %s, %s' % (point_index, polygon_temp, centre_vector[0], centre_vector[1]))

								U_sign = cmp(centre_vector[0], 0.0)
								V_sign = cmp(centre_vector[1], 0.0)

								uv = (base_UV[0] + abs(uv_edge_norm[1]) * self.distance * U_sign, base_UV[1] + abs(uv_edge_norm[0]) * self.distance * V_sign)

								# WE'RE MOVING THIS POINT TO THE SAME PLACE AS A PREVIOUS ONE, MAKING IT CONTINUOUS AGAIN. NUDGE IT A LITTLE.
								# if uv in previous_point_uvs:
								# 	temp_uv = uv
								# 	iters = 0
								# 	while temp_uv in previous_point_uvs and iters < 20:
								# 		random_nudge = (0.0000005 + random.random() * 0.00001) * cmp(random.random() * 2 - 1, 0.0)
								# 		temp_uv = (uv[0] + random_nudge, uv[1] + random_nudge)
								# 		iters += 1
								# 	# lx.out('Nudging UV of %s, took %s iterations.' % (point_index, iters))
								# 	uv = temp_uv
								# previous_point_uvs.append(uv)

								# self.uv_value.set(uv)

								# APPLY NEW UV VALUES FOR THESE POLYGONS AT THIS POINT
								for inner_polygon in inner_list:
									point_UV_value = (point_ID, uv)
									if not inner_polygon in self.polygon_UV_values:
										self.polygon_UV_values[inner_polygon] = []
									self.polygon_UV_values[inner_polygon].append(point_UV_value)
									# self.polygon_loc.Select(inner_polygon)
									# self.polygon_loc.SetMapValue(point_ID, self.uvmap_ID, self.uv_value)

							# THERE ARE TWO EDGES, AVERAGE THEIR VECTORS TO GET THE MOVEMENT DIRECTION
							else:
								# GET UNIT LENGTH VECTOR OF SELECTED UV EDGE
								uv_edge_length = connected_uv_edge[0]**2 + connected_uv_edge[1]**2
								if uv_edge_length == 0.0:
									connected_uv_edge_norm = (0.0, 0.0)
								else:
									uv_edge_length = math.sqrt(uv_edge_length)
									connected_uv_edge_norm = (connected_uv_edge[0] / uv_edge_length, connected_uv_edge[1] / uv_edge_length)

								#lx.out('%s %s Connected: %s, %s' % (point_index, polygon_temp, connected_uv_edge_norm[0], connected_uv_edge_norm[1]))
								# ADD TO ORIGINAL UV EDGE VECTOR AND NORMALIZE

								connected_dot = connected_uv_edge_norm[0] * uv_edge_norm[0] + connected_uv_edge_norm[1] * uv_edge_norm[1]

								uv_edge_combined_norm = (connected_uv_edge_norm[0] + uv_edge_norm[0], connected_uv_edge_norm[1] + uv_edge_norm[1])

								uv_edge_length = uv_edge_combined_norm[0]**2 + uv_edge_combined_norm[1]**2
								if uv_edge_length == 0.0:
									uv_edge_combined_norm = (0.0, 0.0)
								else:
									uv_edge_length = math.sqrt(uv_edge_length)
									uv_edge_combined_norm = (uv_edge_combined_norm[0] / uv_edge_length, uv_edge_combined_norm[1] / uv_edge_length)

								#lx.out('%s %s Combined: %s, %s' % (point_index, polygon_temp, uv_edge_combined_norm[0], uv_edge_combined_norm[1]))

								# HERE WE WORK OUT THE AVERAGE VECTOR FROM THE VERTEX TO IT'S POLYGONS' CENTRES
								# THIS TELLS US WHICH DIRECTION TO MOVE THE UV VERTEX IN
								centre_vector = (0.0, 0.0)
								if len(internal_edges) > 0:
									smallest_dot = 2
									smallest_dot_vector = (0.0, 0.0)
									for internal_edge in internal_edges:
										# GET UNIT LENGTH VECTOR OF UV EDGE
										internal_edge_length = internal_edge[0]**2 + internal_edge[1]**2
										if internal_edge_length == 0.0:
											internal_edge_norm = (0.0, 0.0)
										else:
											internal_edge_length = math.sqrt(internal_edge_length)
											internal_edge_norm = (internal_edge[0] / internal_edge_length, internal_edge[1] / internal_edge_length)
										
										dot = internal_edge_norm[0] * uv_edge_combined_norm[0] + internal_edge_norm[1] * uv_edge_combined_norm[1]
										if abs(dot - smallest_dot) < 0.1:
											smallest_dot_vector = (smallest_dot_vector[0] + internal_edge_norm[0], smallest_dot_vector[1] + internal_edge_norm[1])
										elif dot < smallest_dot:
											smallest_dot = dot
											smallest_dot_vector = internal_edge_norm

										# centre_vector = (centre_vector[0] + internal_edge_norm[0], centre_vector[1] + internal_edge_norm[1])

									# dot = centre_vector[0] * uv_edge_combined_norm[0] + centre_vector[1] * uv_edge_combined_norm[1]
									# if smallest_dot < dot:
									centre_vector = smallest_dot_vector
								else:
									bbox = [0.0,0.0,0.0,0.0]
									for inner_polygon in inner_list:
										self.polygon_loc.Select(inner_polygon)

										# GET AVERAGE UV VALUE FOR THIS POLYGON
										for v in xrange(self.polygon_loc.VertexCount()):
											polygon_point_ID = self.polygon_loc.VertexByIndex(v)
											self.polygon_loc.MapEvaluate(self.uvmap_ID, polygon_point_ID, self.uv_value)
											uv = self.uv_value.get()
											if v == 0:
												bbox[0] = uv[0]
												bbox[1] = uv[0]
												bbox[2] = uv[1]
												bbox[3] = uv[1]
											else:
												bbox[0] = min(uv[0], bbox[0])
												bbox[1] = max(uv[0], bbox[1])
												bbox[2] = min(uv[1], bbox[2])
												bbox[3] = max(uv[1], bbox[3])

										poly_average_centre_U = (bbox[0] + bbox[1]) / 2
										poly_average_centre_V = (bbox[2] + bbox[3]) / 2

										origin_to_poly_centre = (poly_average_centre_U - base_UV[0], poly_average_centre_V - base_UV[1])

										origin_to_poly_centre_length = origin_to_poly_centre[0]**2 + origin_to_poly_centre[1]**2
										if origin_to_poly_centre_length == 0.0:
											origin_to_poly_centre = (0.0, 0.0)
										else:
											origin_to_poly_centre_length = math.sqrt(origin_to_poly_centre_length)
											origin_to_poly_centre = (origin_to_poly_centre[0] / origin_to_poly_centre_length, origin_to_poly_centre[1] / origin_to_poly_centre_length)

										centre_vector = (centre_vector[0] + origin_to_poly_centre[0], centre_vector[1] + origin_to_poly_centre[1])

								# WORK OUT NEW UV VALUE
								centre_vector_length = centre_vector[0]**2 + centre_vector[1]**2
								if centre_vector_length == 0.0:
									# Unit length +U +V.
									# lx.out('Defaulting to +U+V.')
									centre_vector = (0.70710678118654752440084436210485, 0.70710678118654752440084436210485)
									U_sign = 1
									V_sign = 1

								else:
									centre_vector_length = math.sqrt(centre_vector_length)
									centre_vector = (centre_vector[0] / centre_vector_length, centre_vector[1] / centre_vector_length)

									# lx.out('%s %s Centre Vector: %s, %s' % (point_index, polygon_temp, centre_vector[0], centre_vector[1]))

									U_sign = cmp(centre_vector[0], 0.0)
									V_sign = cmp(centre_vector[1], 0.0)

								if uv_edge_combined_norm == (0.0, 0.0):
									uv = (base_UV[0] + abs(uv_edge_norm[1]) * self.distance * U_sign, base_UV[1] + abs(uv_edge_norm[0]) * self.distance * V_sign)

								else:
									if abs(connected_dot) < 0.00001:
										# Right angle check. If it's at a right angle, then expand it at a right angle.
										uv_edge_combined_norm = (uv_edge_combined_norm[0] * self.root2, uv_edge_combined_norm[1] * self.root2)
									uv = (base_UV[0] + abs(uv_edge_combined_norm[0]) * self.distance * U_sign, base_UV[1] + abs(uv_edge_combined_norm[1]) * self.distance * V_sign)

								# WE'RE MOVING THIS POINT TO THE SAME PLACE AS A PREVIOUS ONE, MAKING IT CONTINUOUS AGAIN. NUDGE IT A LITTLE.
								# if uv in previous_point_uvs:
								# 	temp_uv = uv
								# 	iters = 0
								# 	while temp_uv in previous_point_uvs and iters < 20:
								# 		# random_nudge = (0.0000005 + random.random() * 0.00001) * cmp(random.random() * 2 - 1, 0.0)
								# 		# temp_uv = (uv[0] + random_nudge, uv[1] + random_nudge)
								# 		iters += 1
								# 	lx.out('Nudging UV of %s, took %s iterations.' % (point_index, iters))
								# 	uv = temp_uv
								# previous_point_uvs.append(uv)

								# self.uv_value.set(uv)

								# lx.out('%s %s UV Shift: %s, %s' % (point_index, polygon_temp, uv[0] - base_UV[0], uv[1] - base_UV[1]))

								# APPLY NEW UV VALUES FOR THESE POLYGONS AT THIS POINT
								for inner_polygon in inner_list:
									# self.polygon_loc.Select(inner_polygon)
									# self.polygon_loc.SetMapValue(point_ID, self.uvmap_ID, self.uv_value)
									point_UV_value = (point_ID, uv)
									if not inner_polygon in self.polygon_UV_values:
										self.polygon_UV_values[inner_polygon] = []
									self.polygon_UV_values[inner_polygon].append(point_UV_value)

					# self.previous_point_uvs_list[point_ID] = previous_point_uvs


#_______________________________________________________________________________________________________________________ GET TEXEL DENSITY

class EdgeSplit_UV_Cmd(lxu.command.BasicCommand):

#______________________________________________________________________________________________ SETUP AND INITIALISATION

	def __init__(self):
		lxu.command.BasicCommand.__init__(self)
		self.dyna_Add('distance', lx.symbol.sTYPE_FLOAT)
		self.basic_SetFlags(0, lx.symbol.fCMDARG_OPTIONAL)

	def cmd_UserName(self):
 		return 'Split UVs'

 	def cmd_Desc(self):
 		return 'Split the UVs of the selected edges.'

 	def cmd_Tooltip(self):
 		return 'Split the UVs of the selected edges.'

 	def cmd_Help(self):
 		return 'http://www.farfarer.com/'

	def basic_ButtonName(self):
		return 'Split UVs'
 
	def cmd_Flags(self):
		return lx.symbol.fCMD_MODEL | lx.symbol.fCMD_UNDO

	def cmd_Interact(self):
		pass

	def basic_Enable(self, msg):
		# Disabling this as listeners don't really work with Python API yet.

		# if lx.eval1('vertMap.list type:txuv ?') == '_____n_o_n_e_____':
		# 	return False

		# selection_mode = lx.eval1('query layerservice selmode ?')
		# if selection_mode != 'edge' and selection_mode != 'polygon':
		# 	return False

		return True

#_______________________________________________________________________________________________ MAIN FUNCTION EXECUTION

	def basic_Execute(self, msg, flags):
		# Early out if no UV map is selected.
		selected_uv_name = lx.eval1('vertMap.list type:txuv ?')
		if selected_uv_name == '_____n_o_n_e_____':
			return

		# Early out if not in edge or polygon mode.
		selection_mode = lx.eval1('query layerservice selmode ?')
		if selection_mode != 'vertex' and selection_mode != 'edge' and selection_mode != 'polygon':
			return

		layer_svc = lx.service.Layer()
		layer_scan = lx.object.LayerScan(layer_svc.ScanAllocate(lx.symbol.f_LAYERSCAN_EDIT))
		if not layer_scan.test():
			return

		if self.dyna_IsSet(0):
			distance = self.attr_GetFlt(0)
		else:
			distance = 0.0000005 # This seems to be about the smallest you can get while having it reliably split.

		# Sort out mark modes we'll need.
		mesh_svc = lx.service.Mesh()

		mark_mode_selected = mesh_svc.ModeCompose(lx.symbol.sMARK_SELECT, None)

		mark_mode_moved = mesh_svc.ModeCompose('user4', None)
		mark_mode_clear_moved = mesh_svc.ModeCompose(None, 'user4')

		mark_mode_to_split = mesh_svc.ModeCompose('user3', None)
		mark_mode_clear_to_split = mesh_svc.ModeCompose(None, 'user3')

		for n in xrange(layer_scan.Count()):

			mesh_loc = lx.object.Mesh(layer_scan.MeshEdit(n))
			if not mesh_loc.test():
				continue
 
 			polygon_count = mesh_loc.PolygonCount()
			if polygon_count == 0:	# Quick out if there are no polys in this layer.
				continue
			
			polygon_loc = lx.object.Polygon(mesh_loc.PolygonAccessor())
			if not polygon_loc.test():
				continue

			edge_loc = lx.object.Edge(mesh_loc.EdgeAccessor())
			if not edge_loc.test():
				continue

			point_loc = lx.object.Point(mesh_loc.PointAccessor())
			if not point_loc.test():
				continue

			meshmap_loc = lx.object.MeshMap(mesh_loc.MeshMapAccessor())
			if not meshmap_loc.test():
				continue

			# If selected UV map exists for this layer.
			try:
				meshmap_loc.SelectByName(lx.symbol.i_VMAP_TEXTUREUV, selected_uv_name)
			except:
				pass
			else:
				uvmap_ID = meshmap_loc.ID()

				# Clear existing marks.
				visitor = MarkEdges(edge_loc, mark_mode_clear_moved)
				edge_loc.Enumerate(mark_mode_moved, visitor, 0)

				visitor = MarkEdges(edge_loc, mark_mode_clear_to_split)
				edge_loc.Enumerate(mark_mode_to_split, visitor, 0)

				if selection_mode == 'vertex':
					# Find and mark the edges that are on the border of the polygon selection.
					visitor = MarkPointEdges(point_loc, edge_loc, mark_mode_to_split)
					point_loc.Enumerate(mark_mode_selected, visitor, 0)

				elif selection_mode == 'edge':
					# Find and mark the selected edges.
					visitor = MarkEdges(edge_loc, mark_mode_to_split)
					edge_loc.Enumerate(mark_mode_selected, visitor, 0)

				elif selection_mode == 'polygon':
					# Find and mark the edges that are on the border of the polygon selection.
					visitor = MarkPolyBorder(edge_loc, polygon_loc, mark_mode_selected, mark_mode_to_split)
					edge_loc.Enumerate(lx.symbol.iMARK_ANY, visitor, 0)

				# Get the values to assign to split UVs.
				visitor = SplitEdges(edge_loc, point_loc, polygon_loc, uvmap_ID, mark_mode_to_split, mark_mode_moved, distance, selection_mode, mark_mode_selected)
				edge_loc.Enumerate(mark_mode_to_split, visitor, 0)

				# Split the UVs.
				# This has to be done in a second pass because, if it was done in the previous pass, the transform values would get distorted because of any previous edits we've made to the UVs at those verts.
				uv_value = lx.object.storage ('f', 2)
				for polygon_ID, point_value in visitor.polygon_UV_values.iteritems():
					polygon_loc.Select(polygon_ID)
					for p in xrange(len(point_value)):
						uv_value.set(point_value[p][1])
						polygon_loc.SetMapValue(point_value[p][0], uvmap_ID, uv_value)

				# Clear the marks I made.
				visitor = MarkEdges(edge_loc, mark_mode_clear_moved)
				edge_loc.Enumerate(mark_mode_moved, visitor, 0)

				visitor = MarkEdges(edge_loc, mark_mode_clear_to_split)
				edge_loc.Enumerate(mark_mode_to_split, visitor, 0)

				layer_scan.SetMeshChange(n, lx.symbol.f_MESHEDIT_MAP_UV | lx.symbol.f_MESHEDIT_MAP_CONTINUITY)
		layer_scan.Apply()

#________________________________________________________________________________________ BLESS FUNCTION AS MODO COMMAND

lx.bless(EdgeSplit_UV_Cmd, 'ffr.uvSplit')