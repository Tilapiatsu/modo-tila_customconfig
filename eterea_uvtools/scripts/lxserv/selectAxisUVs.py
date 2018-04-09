#!/usr/bin/env python

# To install this plugin, simply copy this file (selectAxisUVs.py) into folder called "lxserv" in your modo scripts folder (and restart modo, if it's open).
# If you are unsure where your modo scripts folder is, you can open modo, then select System > Open User Scripts Folder.
# If there is no folder called "lxserv" in your MODO Scripts folder, simply create one and then put this file in there.
# Once MODO has been restarted, you can run the command via ffr.selectaxisuv
# 
# Any issues, please drop me a line at jamesohare@gmail.com.
# 
# James O'Hare
# www.farfarer.com

import lx
import lxifc
import lxu.command
import lxu.select
import math

# Traceback will give me more detailed errors inside of try: except: blocks using except: lx.out(traceback.format_exc()).
import traceback

#_______________________________________________________________________________________________________________________ VISITORS

# This is a visitor - which is a class which we can tell MODO to run for every edge of a given mark mode from within the main command.
class SelectEdges (lxifc.Visitor):
	# Initialisation of the visitor, this is essentially it's constructor, where we tell it to do things with the paramaters given to it.
	# In this case, it's to store within itself a reference to all of the paramaters given to it so that they can be used in the vis_Evaluate() method (which is the meat of the visitor's work).
	# vis_Evaluate() is run on every element the visitor is told to enumerate over.
	# In this case, it's the variable "edge_loc", which is automatically set to select the next edge to enumerate over before it is run. This is also the variable we tell the visitor to enumerate over inside the main command.
	# We could do a for loop inside the main function that would do pretty much the same thing, but visitors are built specifically for this function and are faster, especially when there are a large number of elements to enumerate over.
	def __init__ (self, edge_loc, polygon_loc, uvmap_ID, angles, tolerance, polygon_mark_mode, sel_svc, sel_type_edge, edge_pkt_trans, mesh_loc, deselect):
		self.edge_loc = edge_loc			# Edge Accessor. This is the variable the visitor has been told to enumerate over and so this will be set to select each edge in the mesh for each run of vis_Evaluate().
		self.polygon_loc = polygon_loc		# Polygon Accessor.
		self.uvmap_ID = uvmap_ID			# This is the internal MeshMapID of the UV map. We use this to read the values of the map.
		self.angles = angles				# These are the angles which we'll check against.
		self.tolerance = tolerance			# This is the tolerance angle which we'll check against.
		self.polygon_mark_mode = polygon_mark_mode	# The mark mode we made earlier, we'll use this to ensure we don't select edges of polygons that are hidden or locked.
		self.sel_svc = sel_svc				# The selection service.
		self.sel_type_edge = sel_type_edge		# The selection type.
		self.edge_pkt_trans = edge_pkt_trans	# The edge packet translation.
		self.mesh_loc = mesh_loc			# The mesh itself.
		self.deselect = deselect			# Whether we're deselecting or not.

		# Here we set up other values the visitor will need, but hasn't been passed in.

		# This is a storage object, when passing arrays of information to/from MODO in the PythonAPI, these act as an intermediary between Python and MODO to store them in.
		# It holds 2 float values - which we'll use to hold UV coordinates. The arguments being 'f' for float ('float' will work fine, too) and 2 being the size of the array.
		self.uv_value = lx.object.storage ('f', 2)

	# This is the main function of the visitor.
	# The variable edge_loc will select each edge in turn and then this function is executed each time.
	def vis_Evaluate (self):

		try:
			# So we start here with an egdge selected by edge_loc.
			# The plan is this:
			# 	Get the UV coordinates for the edge's verts for each of it's polygons...
			# 	...if the angle between the vert UVs is within the tolerance value of the axis, select the edge.
			# 	But it's not as entirely simple as that because of discontinuous values for vertices per-polygon, which I'll document as it's handled.
			# In general, there are probably more efficient ways to do this and there are definitely optimisations in the code that could be done, but it's fairly straightforward so let's stick with it.

			# A holder for polygon IDs where we need to deselect discontinuous edges.
			deselect_disco_polys = []

			# Get the IDs of the two points the edge is between.
			edge_endpoints = self.edge_loc.Endpoints ()

			# Get the polygons that share by this edge and store their IDs...
			# ...only if they are not locked or hidden - we're not interested in those...
			# ...and only if they are selected if the user specified that.
			edge_polygon_count = self.edge_loc.PolygonCount ()
			edge_polygons = []

			point_1_polygon_UV_values = []
			point_2_polygon_UV_values = []

			for ep in xrange (edge_polygon_count):
				# Get the polygon ID for this polygon...
				polygon_ID = self.edge_loc.PolygonByIndex (ep)
				# ...and select it using the polygon accessor.
				self.polygon_loc.Select (polygon_ID)

				# Get the UV values for this polygon for edge point 1.
				self.polygon_loc.MapEvaluate (self.uvmap_ID, edge_endpoints[0], self.uv_value)
				point_1_polygon_UV_values.append (self.uv_value.get ())

				# Get the UV values for this polygon for edge point 2.
				self.polygon_loc.MapEvaluate (self.uvmap_ID, edge_endpoints[1], self.uv_value)
				point_2_polygon_UV_values.append (self.uv_value.get ())

				# Check to see if it passes the mark mode test.
				if self.polygon_loc.TestMarks (self.polygon_mark_mode):
					edge_polygons.append (polygon_ID)

			# Test whether this edge has discontinuous values or not.
			# Basically whether the number of times the first value is in the array is the same as the length of the array.
			# We do this for both points.
			edge_is_continuous = (point_1_polygon_UV_values.count(point_1_polygon_UV_values[0]) == len(point_1_polygon_UV_values) and point_2_polygon_UV_values.count(point_2_polygon_UV_values[0]) == len(point_2_polygon_UV_values))

			# Now iterate through the polygons we've listed.
			for polygon_ID in edge_polygons:
				self.polygon_loc.Select (polygon_ID)

				# And get the UV values of the vertices for the vertices for this polygon.
				# MapEvaluate will give us either the discontinuous value for the vertex at this polygon or the continuous value at the vertex.
				# We could test here for discontinuity by seeing if MapValue raises an exception, if it does, we know it's not discontinuous.
				# But that seems more complex than it's worth.
				polygon_UV_values = []
				for point_ID in edge_endpoints:
					# This is where the storage object comes into play. We feed it into MapEvaluate, which stores the map values in the storage object.
					# We also feed it the uvmap_ID, so it knows which map to return values for.
					# And the point_ID, so it knows which vertex to return the value for.
					self.polygon_loc.MapEvaluate (self.uvmap_ID, point_ID, self.uv_value)
					# And we then retrieve those values as a tuple, using get(), and store them in our list.
					polygon_UV_values.append (self.uv_value.get ())

				# Now get the angle between the two UV values.

				# Starting by getting the vector between the two points.
				# And normalizing it.
				# We'll only go further if it's non-zero.
				uv_edge = (	polygon_UV_values[1][0] - polygon_UV_values[0][0], polygon_UV_values[1][1] - polygon_UV_values[0][1])
				uv_edge_length = uv_edge[0]**2 + uv_edge[1]**2
				if uv_edge_length != 0.0:
					uv_edge_length = 1.0 / math.sqrt (uv_edge_length)
					uv_edge = (uv_edge[0] * uv_edge_length, uv_edge[1] * uv_edge_length)

					for angle in self.angles:
						# Get the dot product of the two vectors.
						# The closer that is to 1, the closer they perfectly oppose each other.
						# The closer that is to -1, the closer they perfectly match each other.
						# Going to make that absolute because at either end of that range the angles are parallel.
						# Also clamping it -1 to 1 because acos will throw an error if it is outside of that range.
						dot = math.acos (max (-1, min (1, abs (angle[0] * uv_edge[0] + angle[1] * uv_edge[1]))))
						if dot < self.tolerance:
							# Here we figure out whether we want to create a packet using the discontinuous edge or the continuous edge.
							# That basically means do we use the whole edge or just the edge at this polygon.
							if edge_is_continuous or self.edge_loc.IsBorder ():
								# We pass 0 for a continuous edge - meaning it is not associated with any polygon.
								edge_select_polygon_ID = 0
							else:
								edge_select_polygon_ID = polygon_ID

							pkt = self.edge_pkt_trans.Packet (edge_endpoints[0], edge_endpoints[1], edge_select_polygon_ID, self.mesh_loc)
							if self.deselect:
								# If we're deselecting, then deselect this edge.
								# This is where it gets tricky.
								# Deselecting an edge by disco value when the edge is selected via non-disco values means that this will have no effect on the selection.
								# So we'll have to deselect the non-disco version and reselect it all as disco.
								# Then deselect the original disco part.
								# But we'll do that after all polygons for this point have been processed so it doesn't get in it's own way.

								# If we're deselecting it via non-disco, go ahead.
								if edge_select_polygon_ID == 0:
									self.sel_svc.Deselect (self.sel_type_edge, pkt)
								else:
									# Otherwise store the polygon ID and we'll process that later.
									deselect_disco_polys.append (polygon_ID)
							else:
								# Otherwise select it.
								self.sel_svc.Select (self.sel_type_edge, pkt)

			# Here we wrangle the deselection of disco polygons.
			if len(deselect_disco_polys) > 0:
				# First deselect the non-disco edge.
				non_disco_pkt = self.edge_pkt_trans.Packet (edge_endpoints[0], edge_endpoints[1], 0, self.mesh_loc)
				self.sel_svc.Deselect (self.sel_type_edge, non_disco_pkt)
				for ep in xrange (edge_polygon_count):
					# Then, for each polygon this edge has, select the disco value for this polygon.
					# Only if that polygon is not in our list to deselect.
					polygon_ID = self.edge_loc.PolygonByIndex (ep)
					if polygon_ID not in deselect_disco_polys:
						disco_pkt = self.edge_pkt_trans.Packet (edge_endpoints[0], edge_endpoints[1], polygon_ID, self.mesh_loc)
						self.sel_svc.Select (self.sel_type_edge, disco_pkt)

		except:
			# If anything fails in the above try: statement, then this will output a nice error to the event log with line number and error.
			lx.out (traceback.format_exc ())


#______________________________________________________________________________________________ VALUEHINTS

# This bit is required to give friendly names to the values when shown in the options dialog.
class OptionPopup (lxifc.UIValueHints):
	def __init__ (self, items):
		self._items = items

	def uiv_Flags (self):
		return lx.symbol.fVALHINT_POPUPS

	def uiv_PopCount (self):
		return len(self._items[0])

	def uiv_PopUserName (self,index):
		return self._items[1][index]

	def uiv_PopInternalName (self,index):
		return self._items[0][index]



#______________________________________________________________________________________________ COMMAND

# The command itself.
class SelectAxisUV_Cmd (lxu.command.BasicCommand):

#______________________________________________________________________________________________ SETUP AND INITIALISATION

# Command arguments.

	# Initialisation for the command.
	def __init__ (self):
		# This sets up the command.
		lxu.command.BasicCommand.__init__ (self)

		# Add an integer argument for the command, with the argument name axis.
		# This will determine the axis. 0 will be U, 1 will be V, 2 will be a custom angle, 3 will be the same as currently selected edges.
		self.dyna_Add ('axis', lx.symbol.sTYPE_INTEGER)

		# Add an integer argument for the command, with the argument name select.
		# This will determine the selection mode. 0 will be set, 1 will be add, 2 will be remove.
		self.dyna_Add ('select', lx.symbol.sTYPE_INTEGER)
		# Set the argument with index 1 (i.e. the select argument) to be optional, meaning it doesn't have to be set for the command to run.
		self.basic_SetFlags (1, lx.symbol.fCMDARG_OPTIONAL)

		# Add an boolean argument for the command, with the argument name ineselection.
		# This will determine whether we only affect the current selection or not.
		self.dyna_Add ('inselection', lx.symbol.sTYPE_BOOLEAN)
		# Set the argument with index 2 (i.e. the select argument) to be optional, meaning it doesn't have to be set for the command to run.
		self.basic_SetFlags (2, lx.symbol.fCMDARG_OPTIONAL)

		# Add a tolerance argument for the command, with the argument name tolerance.
		self.dyna_Add ('tolerance', lx.symbol.sTYPE_ANGLE)
		# Set the argument with index 3 (i.e. the tolerance argument) to be optional, meaning it doesn't have to be set for the command to run.
		self.basic_SetFlags (3, lx.symbol.fCMDARG_OPTIONAL)

		# Add an angle argument for the command, with the argument name angle.
		# This will determine the custom angle which we will use if the axis argument is set to 2.
		self.dyna_Add ('angle', lx.symbol.sTYPE_ANGLE)
		# Set the argument with index 4 (i.e. the angle argument) to be optional, meaning it doesn't have to be set for the command to run.
		self.basic_SetFlags (4, lx.symbol.fCMDARG_OPTIONAL)

		# NOTE:
		# 	Arguments of type ANGLE are handled as radian floats internally, but MODO displays them to the user as degrees and they are set as degrees from the command arguments.
		# 	Remember you will need to handle default values for optional arguments if they're not set.

	# Labels for the arguments in the options dialog, with the hint index in the order the arguments are defined in __init__.
	def arg_UIHints (self, index, hints):
		if index == 0:
			hints.Label ('Axis')
		if index == 1:
			hints.Label ('Selection Mode')
		if index == 2:
			hints.Label ('In Selection Only')
		if index == 3:
			hints.Label ('Tolerance Angle')
		if index == 4:
			hints.Label ('Custom Angle')

	# Disable input to certain fields in the options dialog depending on the current choices.
	def cmd_ArgEnable (self, index):
		# All this does is disable input into the custom angle field (index of 5) if the axis (index of 0) isn't set to custom (value of 2).
		if self.dyna_IsSet (0):
			if self.dyna_Int (0) != 2 and index == 4:
				lx.throw (lx.symbol.e_CMD_DISABLED)
		return lx.symbol.e_OK

	# Show drop-down options for the multi-choice arguments - the axis and select modes, in our case.
	# In essence, these simply give nice friendly names to the arguments when the options popup is shown, in this case it's the integer arguments.
	# The arguments and their friendly labels are sent to the OptionPopup class as a list of two tuples;
	# one containing the "internal" name, which gets passed to the command as the argument value and the other with the respective "friendly" name.
	def arg_UIValueHints (self, index):
		if index == 0:
			return OptionPopup ([(0, 1, 2, 3), ('U', 'V', 'Custom', 'Similar to Selected Edges')])
		if index == 1:
			return OptionPopup ([(0, 1, 2), ('Set', 'Add', 'Deselect')])

# Command list interface.

	# This is the user-friendly name of the command as seen in the command list in MODO.
	def cmd_UserName (self):
 		return 'Select Aligned UVs'

 	# This is the description of the command as seen in the command list in MODO.
 	def cmd_Desc (self):
 		return 'Select the UVs that are aligned to a given axis within a given threshhold angle.'

# Command form interface.

 	# If this command is assigned to a button, this is the text it will show on the button.
 	# We can query the arguments set for it here and that will change the text on the button.
	def basic_ButtonName (self):
		try:
			button_name = ''

			if self.dyna_IsSet(0):
				axis = self.dyna_Int (0, 0)
			else:
				axis = 0

			if self.dyna_IsSet(1):
				select_mode = self.dyna_Int (1, 0)
			else:
				select_mode = 0

			if self.dyna_IsSet(2):
				in_selection = self.dyna_Bool (2, 0)
			else:
				in_selection = False

			if self.dyna_IsSet(3):
				tolerance = self.dyna_Float (3, math.radians(5.0))
			else:
				tolerance = math.radians(5.0)

			if self.dyna_IsSet(4):
				custom_angle = self.dyna_Float (4, -0.0)
			else:
				custom_angle = -0.0

			if select_mode == 0:
				button_name += 'Select'
			elif select_mode == 1:
				button_name += 'Add'
			elif select_mode == 2:
				button_name += 'Deselect'
			else:
				button_name += 'Select'

			if axis == 0:
				button_name += ' U'
			elif axis == 1:
				button_name += ' V'
			elif axis == 2:
				if custom_angle == -0.0:
					button_name += ' Custom'
				else:
					button_name += ' %.1f' % math.degrees (custom_angle)
			elif axis == 3:
				button_name += ' Similar'

			if in_selection:
				button_name += ' In Selection'

			button_name += ' ~%.1f' % math.degrees (tolerance)

			return button_name
		except:
			return 'Select Axis UVs'

 	# If this command is assigned to a button, this is the tooltip it will show when hovered over.
 	# Like the button name, we can query the arguments set for it here and that will change the text for the tooltip.
 	def cmd_Tooltip (self):

 		try:
			tooltip = ''

			if self.dyna_IsSet(0):
				axis = self.dyna_Int (0, 0)
			else:
				axis = 0

			if self.dyna_IsSet(1):
				select_mode = self.dyna_Int (1, 0)
			else:
				select_mode = 0

			if self.dyna_IsSet(2):
				in_selection = self.dyna_Bool (2, 0)
			else:
				in_selection = False

			if self.dyna_IsSet(3):
				tolerance = self.dyna_Float (3, math.radians(5.0))
			else:
				tolerance = math.radians(5.0)

			if self.dyna_IsSet(4):
				custom_angle = self.dyna_Float (4, -0.0)
			else:
				custom_angle = -0.0

			if select_mode == 0:
				tooltip += 'Select edges'
			elif select_mode == 1:
				tooltip += 'Add to edge selection'
			elif select_mode == 2:
				tooltip += 'Deselect edges'

			if axis == 0:
				tooltip += ' aligned to the U axis'
			elif axis == 1:
				tooltip += ' aligned to the V axis'
			elif axis == 2:
				if custom_angle == -0.0:
					tooltip += ' aligned to a custom axis'
				else:
					tooltip += ' aligned to %.1f degrees' % math.degrees (custom_angle)
			elif axis == 3:
				tooltip += ' aligned similarly to the current edge selection'

			if in_selection:
				tooltip += ' but only within the current selection'

			tooltip += ' within a tolerance of %.1f degrees.' % math.degrees (tolerance)

			return tooltip
		except:
 			return 'Select the UVs that are aligned to a given axis within a given threshhold angle.'

 	# The help URL of the command, this is the URL the user is sent to if they hit F1 then select the button this command is assigned to.
 	def cmd_Help (self):
 		return 'http://www.farfarer.com/'

# Command internal functions.

 	# The "flags" of the command, these tell MODO what effects the command is expected to have.
 	# In this case, it changes things in the scene, so MODEL is set, and it should be undoable, so UNDO is set.
 	# MODEL commands should ALWAYS be undoable. Bad things happen if they aren't.
	def cmd_Flags (self):
		return lx.symbol.fCMD_MODEL | lx.symbol.fCMD_UNDO

	# This is a sort of "pre-flight check" for the main Execute command.
	# I'm not using it, but MODO throws a "not implemented" error into the event log if I don't put a stub here.
	def cmd_Interact (self):
		pass

	# This determines whether the command should be allowed to run by returning true or false.
	# This will also grey-out the button in the UI if it is disabled.
	def basic_Enable (self, msg):
		# These seem a little flaky in pyAPI, so I'm just returning true here.
		return True

	# This one is one I've added, which will pop up an error dialog with an error message.
	def errorDialog (self, error, title='Error'):
		# Set up file dialog.
		lx.eval ('dialog.setup error')
		lx.eval ('dialog.title {%s}' % title)
		lx.eval ('dialog.msg {%s}' % error)
		lx.eval ('+dialog.open')
#_______________________________________________________________________________________________ MAIN FUNCTION EXECUTION

	# This is where the actual meat of the command goes.
	def basic_Execute (self, msg, flags):

		try:

		# Some early checks and settings.

			# UV MAP SELECTED?
			# Early out if no UV map is selected.

			selected_uv_name = ''

			# We want to deal with the current selection, so we need a selection service.
			# This allows us to read and alter the current item/component selection as presented to the user.

			# We'll also deal with some accessors for a mesh a little further down - or rather, above here in the visitors code - which have a Select() method and these are unrelated to actual selection...
			# ...(for them it's more like "set yourself to return information about the component I've asked you to select").
			sel_svc = lx.service.Selection ()

			# And we want to set up a vertex map packet translation object - these let us get information about selected vertex map "packets" that we get from the selection service.
			# We pass these packets into the translation object and it will give us information about the selected vertex map it represents.
			# In this instance, we want to know; it's type (to check it's a UV map) and it's name (so we know which UV map it is).
			# These also work in reverse - you can pass it a vertex map and it will return a packet. We can then pass that packet to the selection service to have it select (or deselect) it.
			vmap_pkt_trans = lx.object.VMapPacketTranslation (sel_svc.Allocate (lx.symbol.sSELTYP_VERTEXMAP))
			sel_type_vmap = sel_svc.LookupType (lx.symbol.sSELTYP_VERTEXMAP)

			# We want to select edges, so let's set that up using the selection service.
			# And we want to set up an edge packet translation object - these let us pass in edges and get a packet returned that we can give to the selection service.
			# This also works in reverse - we can get an edge packet from the selection service and pass it in to the translation to find out information about the edge it represents.
			edge_pkt_trans = lx.object.EdgePacketTranslation (sel_svc.Allocate (lx.symbol.sSELTYP_EDGE))
			sel_type_edge = sel_svc.LookupType (lx.symbol.sSELTYP_EDGE)

			# Go through all of the selected vertex maps.
			for i in xrange(sel_svc.Count (sel_type_vmap)):
				# Get a packet representing this map.
				pkt = sel_svc.ByIndex (sel_type_vmap, i)
				# If the type of this packet is UV...
				if vmap_pkt_trans.Type (pkt) == lx.symbol.i_VMAP_TEXTUREUV:
					# ...get it's name and then break out of this loop.
					selected_uv_name = vmap_pkt_trans.Name (pkt)
					break
			else:
				# If we've got here, the for loop has terminated without breaking out, so we've not got a UV map selected.
				self.errorDialog ('Please select a UV map to operate on.', 'No UV Map Selected')
				return

			# Pull up the layer service, this will let us scan over the mesh layers.
			layer_svc = lx.service.Layer ()

			# The layer_scan item will pull up the layers as determined in ScanAllocate.
			# In this case it's any ACTIVE layers, which means any layers that are editable at the moment (i.e. that are foreground layers).
			# The MARKALL flag also ensures that the elements' mark modes will be flagged so we can test against them.
			layer_scan = lx.object.LayerScan (layer_svc.ScanAllocate (lx.symbol.f_LAYERSCAN_ACTIVE | lx.symbol.f_LAYERSCAN_MARKALL))
			if not layer_scan.test ():
				return

			# Get the number of layers the scan has found. If it's less than 1, then return - as there are no active layers.
			layer_count = layer_scan.Count ()
			if layer_count < 1:
				return

			# Sort out mark modes we'll need. These are the flags for the elements, such as selected, hidden, locked and up to 8 custom ones.
			# We can use this mode when we run the visitor later, so it will only enumerate over elements that match these mark modes.
			# These are most easily generated by the mesh service, so start one up.
			mesh_svc = lx.service.Mesh ()

			# The first paramater are modes that must be set, the second are modes that must not be set.
			# Here, we are specifying that they must not have hidden or locked modes set.
			# Mark modes are space separated strings.
			mark_mode_visible_unlocked = mesh_svc.ModeCompose (None, '%s %s' % (lx.symbol.sMARK_LOCK, lx.symbol.sMARK_HIDE))
			mark_mode_selected_visible_unlocked = mesh_svc.ModeCompose (lx.symbol.sMARK_SELECT, '%s %s' % (lx.symbol.sMARK_LOCK, lx.symbol.sMARK_HIDE))

			# Get current selection mode.
			current_sel_mode = lx.eval1 ('query layerservice selmode ?')

		# Get argument values.

			# AXIS

			# Get the axis argument value, if it's set.
			axis = 0
			if self.dyna_IsSet (0):
				axis = self.attr_GetInt (0)
				# Return if the axis value isn't valid. Again, we shouldn't get here, but it's good practice to handle these things.
				if axis < 0 or axis > 3:
					self.errorDialog ('Please specify a valid axis selection.', 'No Valid Axis Set')
					return
			else:
				# Otherwise return early. We shouldn't get here but it's good practise to handle these things.
				self.errorDialog ('Please specify an axis.', 'No Axis Set')
				return


			# SELECTION MODE

			# Default to set selection.
			select_mode = 0
			if self.dyna_IsSet (1):
				select_mode = self.attr_GetInt (1)
				# Return if the select mode isn't valid. Again, we shouldn't get here, but it's good practice to handle these things.
				if select_mode < 0 or select_mode > 2:
					self.errorDialog ('Please specify a valid selection mode.', 'No Valid Selection Mode Set')
					return


			# IN SELECTION ONLY

			# Default to everything.
			in_selection_only = False
			if self.dyna_IsSet (2):
				in_selection_only = (self.attr_GetInt (2) == 1)

			# Set the mark mode to use for the edge visitor depending on whether we want to only alter edges which are currently selected and we're in edge mode.
			# This will mean that the visitor will only be called on edges that match this mark mode.
			# Or to use for the polygons inside the edge visitor depending on whether we want to only alter edges which are currently in selected polygons and we're in polygon mode.
			polygon_mark_mode = mark_mode_visible_unlocked
			edge_mark_mode = mark_mode_visible_unlocked
			if in_selection_only:
				if current_sel_mode == 'edge':
					edge_mark_mode = mark_mode_selected_visible_unlocked
				elif current_sel_mode == 'polygon':
					polygon_mark_mode = mark_mode_selected_visible_unlocked


			# TOLERANCE

			# Default tolerance to 5 degrees.
			tolerance = math.radians (5.0)
			if self.dyna_IsSet (3):
				# Although if it's defined in the arguments, use that instead.
				tolerance = self.attr_GetFlt (3)


			# ANGLE
			angles = ()
			if axis == 0:
				# If axis is 1 (i.e. U axis) set vector that points along the U axis.
				angles = ((1.0, 0.0),)
			elif axis == 1:
				# If axis is 1 (i.e. V axis) set vector that points along the V axis.
				angles = ((0.0, 1.0),)
			elif axis == 2:
				# If axis is 2 (i.e. custom) get the custom angle value.
				# Which is argument index 4.
				if self.dyna_IsSet (4):
					# Here we use a bit of trig to construct a unit vector from the supplied angle.
					angle = self.attr_GetFlt (4)
					angles = ((-math.sin (angle), -math.cos (angle)),)
				else:
					# Return if it's not set. Shouldn't get here, you know the drill.
					self.errorDialog ('Please specify a custom angle value.', 'No Angle Value')
					return
			elif axis == 3:
				# If axis is 3 (i.e. similar to selected edges) get the angles of the currently selected edges.
				# We can't just iterate over all selected layers here, because there might be discontinuous selections.
				# So we'll call upon the selection service to give us the currently selected edges and from that we can
				# ...work out the polygons the edge selection is attached to.
				# Once we have those details, we can get a list of the UV angles of those edges.
				# Which we'll add to this master list which contains all of the angles we've gathered from each layer.
				selected_edge_angles = []

				# Here we get the edge selection packets from the selection service.
				# And we pull out the information we need from them.
				selected_edge_count = sel_svc.Count (sel_type_edge)

				if selected_edge_count == 0:
					# Return if there are no edges selected.
					self.errorDialog ('Please select some edges to get angles from.', 'No Edges Selected')
					return

				selected_edges = []
				for i in xrange (selected_edge_count):
					# Get a packet representing this edge.
					pkt = sel_svc.ByIndex (sel_type_edge, i)
					# Get it's verts IDs.
					points = edge_pkt_trans.Vertices (pkt)
					# Get it's polygon ID.
					polygon = edge_pkt_trans.Polygon (pkt)
					# Get it's mesh.
					mesh = edge_pkt_trans.Mesh (pkt)

					selected_edges.append ((mesh, points, polygon))

				# This is a storage object, when passing arrays of information to/from MODO in the PythonAPI, these act as an intermediary between Python and MODO to store them in.
				# It holds 2 float values - which we'll use to hold UV coordinates. The arguments being 'f' for float ('float' will work fine, too) and 2 being the size of the array.
				uv_value = lx.object.storage ('f', 2)

				# Now iterate over all of the layers the layerscan found.
				for n in xrange (layer_count):

					# Get the mesh from the layer.
					# This is the MeshBase - the original mesh in the scene - so we cannot edit the mesh itself from here. We would need to use MeshEdit (n) for that.
					mesh_loc = lx.object.Mesh (layer_scan.MeshBase (n))
					if not mesh_loc.test ():
						continue
		 
		 			# Quick out if there are no polys in this layer.
		 			polygon_count = mesh_loc.PolygonCount ()
					if polygon_count == 0:
						continue
					
					# Get a polygon accessor from the mesh.
					polygon_loc = lx.object.Polygon (mesh_loc.PolygonAccessor ())
					if not polygon_loc.test ():
						continue

					# Get an edge accessor from the mesh.
					edge_loc = lx.object.Edge (mesh_loc.EdgeAccessor ())
					if not edge_loc.test ():
						continue

					# Get a meshmap (i.e. vertex map) accessor from the mesh.
					meshmap_loc = lx.object.MeshMap (mesh_loc.MeshMapAccessor ())
					if not meshmap_loc.test ():
						continue

					# Check that the selected UV map exists for this mesh layer.
					try:
						meshmap_loc.SelectByName (lx.symbol.i_VMAP_TEXTUREUV, selected_uv_name)
					except:
						# That check has asserted, so it has failed to select the UV map on this layer - meaning it doesn't have it.
						continue
					else:
						# That check was a success, meaning this layer has the UV map and it's now selected by the meshmap accessor.

						# Now get the internal ID of the UV map, which we will use to pull up the values from the elements later on.
						uvmap_ID = meshmap_loc.ID ()

						# Now go over the list of selected edges we made earlier.
						for selected_edge in selected_edges:
							# If the mesh for that edge is the same as this one...
							if mesh_loc.TestSameMesh (selected_edge[0]):
								# Get a list of the polygon IDs we want to get UVs for.
								polygon_IDs = []

								if selected_edge[2] == 0:
									# Polygon ID is 0 - which means it's not a disco selection.
									# In that case, add each polygon this edge has.
									edge_loc.SelectEndpoints (selected_edge[1][0], selected_edge[1][1])
									for ep in xrange (edge_loc.PolygonCount ()):
										polygon_IDs.append (edge_loc.PolygonByIndex (ep))
								else:
									# Otherwise just use the polgyon ID of the disco selection.
									polygon_IDs.append (selected_edge[2])

								# Now, for each polygon, get the UV values for the edge's points and work out, then store the angle.
								for polygon_ID in polygon_IDs:
									polygon_loc.Select (polygon_ID)

									polygon_loc.MapEvaluate (uvmap_ID, selected_edge[1][0], uv_value)
									point_1_UV = uv_value.get ()

									# Get the UV values for this polygon for edge point 2.
									polygon_loc.MapEvaluate (uvmap_ID, selected_edge[1][1], uv_value)
									point_2_UV = uv_value.get ()

									# Get the vector for this UV edge and normalize it.
									# Store it only if it isn't zero length.
									uv_edge = (	point_2_UV[0] - point_1_UV[0], point_2_UV[1] - point_1_UV[1])
									uv_edge_length = uv_edge[0]**2 + uv_edge[1]**2
									if uv_edge_length != 0.0:
										uv_edge_length = 1.0 / math.sqrt (uv_edge_length)
										uv_edge = (uv_edge[0] * uv_edge_length, uv_edge[1] * uv_edge_length)
										selected_edge_angles.append (uv_edge)

				# Pass the angles of the selected UVs in as the angles value.
				angles = tuple (selected_edge_angles)

		# If we've got here, things are probably all set up right. Now to get on with the actual command.

			# Drop the current edge selection if selection mode is "set" (0).
			if select_mode == 0:
				sel_svc.Clear (sel_type_edge)

			# Figure out if we're deselecting rather than selecting.
			deselect = False
			if select_mode == 2:
				deselect = True

		# Iterate over all of the active layers the scan found.

			for n in xrange (layer_count):

				# Get the mesh from the layer.
				# This is the MeshBase - the original mesh in the scene - so we cannot edit the mesh itself from here. We would need to use MeshEdit (n) for that.
				mesh_loc = lx.object.Mesh (layer_scan.MeshBase (n))
				if not mesh_loc.test ():
					continue
	 
	 			# Quick out if there are no polys in this layer.
	 			polygon_count = mesh_loc.PolygonCount ()
				if polygon_count == 0:
					continue
				
				# Get a polygon accessor from the mesh.
				polygon_loc = lx.object.Polygon (mesh_loc.PolygonAccessor ())
				if not polygon_loc.test ():
					continue

				# Get an edge accessor from the mesh.
				edge_loc = lx.object.Edge (mesh_loc.EdgeAccessor ())
				if not edge_loc.test ():
					continue

				# Get a meshmap (i.e. vertex map) accessor from the mesh.
				meshmap_loc = lx.object.MeshMap (mesh_loc.MeshMapAccessor ())
				if not meshmap_loc.test ():
					continue

				# Check that the selected UV map exists for this mesh layer.
				try:
					meshmap_loc.SelectByName (lx.symbol.i_VMAP_TEXTUREUV, selected_uv_name)
				except:
					# That check has asserted, so it has failed to select the UV map on this layer - meaning it doesn't have it.
					continue
				else:
					# That check was a success, meaning this layer has the UV map and it's now selected by the meshmap accessor.

					# Now get the internal ID of the UV map, which we will use to pull up the values from the elements later on.
					uvmap_ID = meshmap_loc.ID ()

					# Run over the edges, enumerating over only the edges that match the given mark mode.
					# The 0 here is where we can pass a monitor to log progress for very time intensive operations. But you can pass 0 just to leave out the monitor.
					# We also pass in all the variables that the visitor will need to run.
					visitor = SelectEdges (edge_loc, polygon_loc, uvmap_ID, angles, tolerance, polygon_mark_mode, sel_svc, sel_type_edge, edge_pkt_trans, mesh_loc, deselect)
					edge_loc.Enumerate (edge_mark_mode, visitor, 0)
			# End the layerscan.
			layer_scan.Apply ()

			# Drop us into edge mode if we weren't before.
			if current_sel_mode != 'edge':
				lx.eval ('select.type edge')

		except:
			lx.out (traceback.format_exc ())

#________________________________________________________________________________________ BLESS FUNCTION AS MODO COMMAND

# Tell MODO to make the class we've just defined (SelectAxisUV) run using the command "ffr.selectaxisuv".
lx.bless (SelectAxisUV_Cmd, 'ffr.selectaxisuv')