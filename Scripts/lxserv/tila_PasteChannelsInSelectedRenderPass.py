
################################################################################
#
# tila_PasteChannelsInSelectedRenderPass.py
#
# Version:
#
# Author: Tilapiatsu
#
# Description:
#
# Last Update:
#
################################################################################

import lx, modo
import lxifc
import lxu.command
import sys


class CmdPasteChannelsInSelectedRenderPass(lxu.command.BasicCommand):
	def __init__(self):
		lxu.command.BasicCommand.__init__(self)

		self.scn = modo.Scene()
		self.renderpass_groups = self.get_renderpass_groups()
		self.current_renderpass_group = self.get_current_renderpass_group()
		self.initial_active_pass = self.get_current_renderpass()
		self.passes = []
		self.object = None

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

	def get_current_renderpass(self):
		if self.current_renderpass_group is None:
			return None
		else:
			for p in self.current_renderpass_group.passes:
				if p.active:
					return p
			else:
				return None



	def cmd_Flags(self):
		return lx.symbol.fCMD_MODEL | lx.symbol.fCMD_UNDO

	def basic_Enable(self, msg):
		return True

	def cmd_Interact(self):
		pass

	def basic_Execute(self, msg, flags):
		selection = self.scn.selected

		if len(selection) < 3:
			self.init_message("error", 'Invalid Selection Count', 'Select at least one item, and one render pass item')
			return None

		for o in selection:
			if o.type == 'render':
				rpg = o
				continue
			elif o.type == 'actionclip':
				self.passes.append(o)
				continue
			else:
				self.object = o

		for p in self.passes:
			p.active = True
			
			lx.eval('channel.paste')
			lx.eval('edit.apply')
			
			p.active = False

		if self.initial_active_pass is not None:
			self.initial_active_pass.active = True

	def cmd_Query(self, index, vaQuery):
		lx.notimpl()


lx.bless(CmdPasteChannelsInSelectedRenderPass, "tila.pastechannelsinselectedrenderpass")

