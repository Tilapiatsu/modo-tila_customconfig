
################################################################################
#
# tila_duplicateRenderpassesGroup.py
#
# Version: 1.0
#
# Author: Tilapiatsu
#
# Description: This script wil duplicate RenderPassGroup properly : usualy, when using "item.duplicate type:group"  command in modo, the RenderPassGroup is duplicated, but the passes are actually instances of the passes in the source RenderPassGroup which is not convenient
#
# Last Update: 11/05/2018
#
################################################################################

import lx
import lxifc
import lxu.command
import modo
import traceback


class CmdMyCustomCommand(lxu.command.BasicCommand):
	def __init__(self):
		lxu.command.BasicCommand.__init__(self)

		self.scn = modo.Scene()
		self.renderpass_groups = self.get_renderpass_groups()
		self.duplicated_renderpass_group_arr = []

		#DefaultValue
		self.prefix = ''
		self.suffix = ''

	def cmd_ArgEnable (self, index):
		return lx.symbol.e_OK

# Command list interface.

	# This is the user-friendly name of the command as seen in the command list in MODO.
	def cmd_UserName (self):
		return 'Duplicate selected renderePassesGroup'

	# This is the description of the command as seen in the command list in MODO.
	def cmd_Desc (self):
		return 'It will create a duplicate af the selected RenderPassGroup With all passes contained in this RenderPassGroup'

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
			if o in self.renderpass_groups:
				compatible.append(o)

		return compatible

	def basic_Execute(self, msg, flags):
		try:

			compatible_selection = self.get_compatible_type(self.scn.selected)

			if not len(compatible_selection):  # Is any RenderPassGroup selected
				modo.dialogs.alert('No compatible item selected', 'please select at least one RenderPassGroup item')
				sys.exit()

			else:
				# Loop over all selected RenderPassGroup
				for rpg in compatible_selection:

					rpg = modo.item.RenderPassGroup(rpg)

					# Create a new RenderPassGroup With the same name and select it
					new_rpg = modo.item.RenderPassGroup(self.scn.addGroup(rpg.name,'render'))
					new_rpg.select()

					# Create a new channel for each channel that is referenced in the source RenderPassGroup
					channel_arr = []

					for channel in rpg.groupChannels:
						new_rpg.addChannel(channel)
						channel_arr.append(channel)

					# Loop over all passes
					for p in rpg.passes:
						# Create a new passe for each passe present in the source RenderPassGroup
						new_passe = new_rpg.addPass(p.name)

						#Set Channel Pass value for each pass in RenderPassGroup
						new_passe.active = True

						for channel in channel_arr:
							channel.set(p.getValue(channel), action=new_passe.name)

						new_passe.active = False

					# Append the new RenderPassGroup to a variable
					self.duplicated_renderpass_group_arr.append(new_rpg)

					new_rpg.deselect()
		except:
			lx.out(traceback.format_exc())


	def cmd_Query(self, index, vaQuery):
		lx.notimpl()


lx.bless(CmdMyCustomCommand, "tila.duplicateRenderpassesGroup")
