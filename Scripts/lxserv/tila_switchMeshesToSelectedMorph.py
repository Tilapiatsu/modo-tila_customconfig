
################################################################################
#
# tila_switchMeshesToSelectedMorph.py
#
# Version: 1.0
#
# Author: Tilapiatsu
#
# Description: Select a morph map of a mesh item and run this command, the selected morphmap will be switched with none morphed mesh
#
# Last Update: 20/06/2018
#
################################################################################

import lx
import lxifc
import lxu.command
import modo
import traceback
import sys


class CmdSwitchMeshesToSelectedMorph(lxu.command.BasicCommand):
	def __init__(self):
		lxu.command.BasicCommand.__init__(self)

		self.dyna_Add('selectedItemOnly', lx.symbol.sTYPE_BOOLEAN)
		self.basic_SetFlags(0, lx.symbol.fCMDARG_OPTIONAL)

		self.scn = None
		self.selectedItemOnly = False
		self.initialSelection = None
		self.debug = False

	def arg_UIHints (self, index, hints):
		if index == 0:
			hints.Label('selected Mesh Only')
	
	def cmd_UserName (self):
 		return 'Switch Mesh to selected morph map'

	def cmd_Desc (self):
 		return 'switch the selected morph map with the "undeformed" version of the mesh'

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

	def cmd_Flags(self):
		return lx.symbol.fCMD_MODEL | lx.symbol.fCMD_UNDO

	def basic_Enable(self, msg):
		return True

	def cmd_Interact(self):
		pass

	def printLog(self, message):
		if self.debug:
			lx.out('SwitchMshToSelectedMorph : {}'.format(message))

	def getSelectedMorphMap(self):
		try:
			morphMapName = lx.eval('vertMap.name ? morf active')
			if morphMapName is not None:
				return morphMapName
		except:
			self.init_message("error", "No morphmMap selected",
							  "Please slelect one morph map first")
			return None

	def switchMorphMaps(self, morphMapName):
		if self.selectedItemOnly:
			meshSelection = [self.initialSelection[0]]
		else:
			meshSelection = self.scn.items('mesh')
		i = 0
		for item in meshSelection:
			item.select(replace=True)
			vmaps = item.geometry.vmaps
			morphMaps = vmaps.morphMaps

			if morphMapName not in [m.name for m in morphMaps]:
				self.printLog('morphMap {} not in {} item'.format(morphMapName, item.name))
				continue

			for map in morphMaps:
				if map.name == morphMapName:
					# self.printLog('morphMap {} found in {}'.format(morphMapName, item.name))
					lx.eval('select.vertexMap {} morf replace'.format(morphMapName))
					lx.eval('select.vertexMap {} morf 3'.format(morphMapName))
					# self.breakDialog('About to morph')
					lx.eval('vertMap.applyMorph {} 1.0'.format(morphMapName))
					# self.breakDialog('About to SelectMorph')
					lx.eval('select.vertexMap {} morf replace'.format(morphMapName))
					# self.breakDialog('About to fixMorph')
					lx.eval('vertMap.applyMorph {} -2.0'.format(morphMapName))

			for map in morphMaps:
				if map.name != morphMapName:
					self.printLog('Fixing morphMap {} found in {}'.format(map.name, item.name))
					try:
						lx.eval('!select.vertexMap {} morf replace'.format(map.name))
						lx.eval('!vertMap.applyMorph {} 1.0'.format(morphMapName))
						lx.eval('!select.vertexMap {} morf 3'.format(map.name))
					except RuntimeError:
						self.printLog('Skipping absolute morphMap {} found in {}'.format(map.name, item.name))
						continue
						# lx.eval('!select.vertexMap {} spot replace'.format(map.name))
						# lx.eval('!vertMap.applyMorph {} 1.0'.format(morphMapName))
						# lx.eval('!select.vertexMap {} spot 3'.format(map.name))
			i += 1
		else:
			self.initialSelection[0].select(replace=True)
			lx.eval('select.vertexMap {} morf 3'.format(morphMapName))

	@staticmethod
	def breakPoint(i, number):
		if i == number:
			sys.exit()

	def breakDialog(self, message):
		if self.debug:
			self.init_message('info', 'info', message)

	def basic_Execute(self, msg, flags):
		try:
			if self.scn != modo.Scene():
				self.scn = modo.Scene()

			if self.dyna_IsSet(0):
				self.selectedItemOnly = self.dyna_Bool(0)

			self.initialSelection = [self.scn.selectedByType('mesh')[0]]

			morphMapName = self.getSelectedMorphMap()

			if morphMapName is None:
				self.printLog('No morphMap found')
				return

			self.switchMorphMaps(morphMapName)
		except:
			lx.out(traceback.format_exc())

	def cmd_Query(self, index, vaQuery):
		lx.notimpl()


lx.bless(CmdSwitchMeshesToSelectedMorph, "tila.switchMeshesToSelectedMorph")
