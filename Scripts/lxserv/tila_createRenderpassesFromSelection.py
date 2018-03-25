
################################################################################
#
# tila_create_renderpasses_from_selection.py
#
# Version: 1.0
#
# Author: Tilapiatsu
#
# Description:
#
# Last Update:
#
################################################################################

import lx
import lxifc
import lxu.command
import modo
import traceback

compatibleItemType = {'MESH': 'mesh',
					  'MESH_INSTANCE': 'meshInst',
					  'REPLICATOR': 'replicator',
					  'GROUP_LOCATOR': 'groupLocator',
					  'LOCATOR': 'locator'}

class CmdMyCustomCommand(lxu.command.BasicCommand):
	def __init__(self):
		lxu.command.BasicCommand.__init__(self)

		self.dyna_Add('passgroup_name', lx.symbol.sTYPE_STRING)
		# self.basic_SetFlags (0, lx.symbol.fCMDARG_OPTIONAL)

		self.dyna_Add('trim_item_name', lx.symbol.sTYPE_BOOLEAN)
		# self.basic_SetFlags (1, lx.symbol.fCMDARG_OPTIONAL)

		self.dyna_Add('item_name_trim_separator', lx.symbol.sTYPE_STRING)
		self.basic_SetFlags (2, lx.symbol.fCMDARG_OPTIONAL)

		self.dyna_Add('item_name_trim_range', lx.symbol.sTYPE_STRING)
		self.basic_SetFlags (3, lx.symbol.fCMDARG_OPTIONAL)

		self.scn = modo.Scene()
		self.renderpass_groups = self.get_renderpass_groups()
		self.current_renderpass_group = self.get_current_renderpass_group()

		self.suffix = '_RP'

	def arg_UIHints (self, index, hints):
		if index == 0:
			hints.Label('PassGroup Name')
		if index == 1:
			hints.Label('Trim Item Name')
		if index == 2:
			hints.Label('Trim Separator')
		if index == 3:
			hints.Label('Trim Range')

	def cmd_ArgEnable (self, index):
		if self.dyna_IsSet(0):
			if self.current_renderpass_group is not None and index == 0:
				lx.throw(lx.symbol.e_CMD_DISABLED)
		if self.dyna_IsSet(1):
			if not self.dyna_Bool(1) and index > 1:
				lx.throw(lx.symbol.e_CMD_DISABLED)
		return lx.symbol.e_OK

# Command list interface.

	# This is the user-friendly name of the command as seen in the command list in MODO.
	def cmd_UserName (self):
		return 'Create renderepasses from selection'

	# This is the description of the command as seen in the command list in MODO.
	def cmd_Desc (self):
		return 'It will create one renderpass for each selected item, and toggle on the visibility of this item in the corresponding pass'

	def cmd_Flags(self):
		return lx.symbol.fCMD_MODEL | lx.symbol.fCMD_UNDO

	def basic_Enable(self, msg):
		return True

	def cmd_Interact(self):
		pass

	def get_current_pass_group(self):
		try:
			return lx.eval('group.current ? pass')
		except:
			return None

	def set_default_pass_group(self):
		lx.eval('group.current {} pass')

	def set_default_pass(self):
		lx.eval('layer.active {} type:pass')

	def get_renderpass_groups(self):
		return [modo.item.RenderPassGroup(grp) for grp in self.scn.groups if grp.type == 'render']

	def get_current_renderpass_group(self):
		if len(self.renderpass_groups) == 0:
			return None
		else:
			for rpg in self.renderpass_groups:
				if rpg.selected:
					return modo.item.RenderPassGroup(rpg)
				elif lx.eval('group.current ? pass') != '':
					return modo.item.RenderPassGroup(lx.eval('group.current ? pass'))
			else:
				return None

	def get_compatible_type(self, arr):
		compatible = []
		for o in arr:
			if o.type in compatibleItemType.values():
				compatible.append(o)

		return compatible

	def basic_Execute(self, msg, flags):
		try:

			trim_sw = self.dyna_Bool(1)
			trim_separator = self.dyna_String(2)
			trim_range = self.dyna_String(3)

			compatible_selection = self.get_compatible_type(self.scn.selected)
			if not len(compatible_selection):
				modo.dialogs.alert('No compatible item selected', 'please select at least one item of type {}'.format(self.construct_type_string()))

			# Define the current passgroup
			if self.current_renderpass_group is None:
				renderpass_group_exist = False
				for rpg in self.renderpass_groups:
					if self.dyna_String(0) == rpg.name:
						renderpass_group_exist = True
						break

				if not renderpass_group_exist: # No pass group found : create one with the name specify by the user
					self.current_renderpass_group = modo.item.RenderPassGroup(self.scn.addGroup(self.dyna_String(0),'render'))
					self.current_renderpass_group.select()
				else: # set pass group to the one founded
					self.current_renderpass_group = modo.item.RenderPassGroup(self.dyna_String(0))
					self.current_renderpass_group.select()
			

			# Create Passes Loop
			for item in compatible_selection:
				if trim_sw:
					trimed_name = self.construct_trim_name(item.name, trim_separator, trim_range)
				else:
					trimed_name = item.name

				passe_name = trimed_name + self.suffix

				if passe_name not in [passe.name for passe in self.current_renderpass_group.passes]:
					# add a passe named like the selected object
					passe = self.current_renderpass_group.addPass(passe_name)
				else:
					# Get the passe
					passe = modo.item.ActionClip(passe_name)

				visible_chan = item.channel('visible')

				# add channel to current_renderpass_group if needed
				if not self.current_renderpass_group.hasChannel(visible_chan):
					self.current_renderpass_group.addChannel(visible_chan)

				# Edit the visibility value
				passe.active = True
				visible_chan.set(True, action=passe_name)
				passe.active = False
				
		except:
			lx.out(traceback.format_exc())

	def construct_type_string(self):
		string = ''
		for val in compatibleItemType.values:
			string += '\n' + val
		return string

	def construct_trim_name(self, item_name, separator, range):
		splited_name = item_name.split(separator)

		splited_range = range.split(',')

		try:	
			for i in xrange(len(splited_range)):
				splited_range[i] = int(splited_range[i])
		except:
			lx.out(traceback.format_exc())

		trimed_name = ''
		for i in xrange(len(splited_range)):
			if splited_range[i] < len(splited_name):
				if i == 0:
					trimed_name = splited_name[splited_range[i]]
				else:
					trimed_name += separator + splited_name[splited_range[i]]

		return trimed_name


	def cmd_Query(self, index, vaQuery):
		lx.notimpl()


lx.bless(CmdMyCustomCommand, "tila.createRenderpassesFromSelection")
