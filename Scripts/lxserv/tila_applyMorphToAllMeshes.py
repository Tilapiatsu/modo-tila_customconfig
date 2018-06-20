
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


class CmdApplyMorphToAllMeshes(lxu.command.BasicCommand):
	def __init__(self):
		lxu.command.BasicCommand.__init__(self)

		self.dyna_Add('morphMapName', lx.symbol.sTYPE_STRING)

		self.dyna_Add('morphAmount', lx.symbol.sTYPE_FLOAT)
		self.basic_SetFlags(1, lx.symbol.fCMDARG_OPTIONAL)

		self.scn = modo.Scene()
		self.morphMapName = None
		self.morphAmount = 1.0
		self.initialSelection = None
		self.debug = False

	def arg_UIHints (self, index, hints):
		if index == 0:
			hints.Label('Source MorphMap')
		if index == 1:
			hints.Label('Morph amount')
	
	def cmd_UserName (self):
 		return 'Apply morph to all meshes'

	def cmd_Desc (self):
 		return 'Apply morph map to the selected morph map in all meshes in the scene.'

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
			self.init_message("error", "No morphmMap selected", "Please slelect one morph map first")
			return None

	def applyMorphMap(self, CurrentMorphMapName):
		meshSelection = self.scn.items('mesh')
		i = 0
		for item in meshSelection:
			item.select(replace=True)
			vmaps = item.geometry.vmaps
			morphMaps = vmaps.morphMaps

			morphMapNames = [m.name for m in morphMaps]
			if CurrentMorphMapName not in morphMapNames or self.morphMapName not in morphMapNames:
				self.printLog('morphMap {} not in {} item'.format(CurrentMorphMapName, item.name))
				continue
			
			for map in morphMaps:
				if map.name == CurrentMorphMapName:
					self.printLog('morphMap {} found in {}'.format(CurrentMorphMapName, item.name))
					lx.eval('select.vertexMap {} morf replace'.format(CurrentMorphMapName))
					self.breakDialog('About to morph')
					lx.eval('vertMap.applyMorph {} {}'.format(self.morphMapName, self.morphAmount))

			i += 1
		else:
			self.initialSelection[0].select(replace=True)
			lx.eval('select.vertexMap {} morf replace'.format(CurrentMorphMapName))

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
				self.morphMapName = self.dyna_String(0)
			if self.dyna_IsSet(1):
				self.morphAmount = self.dyna_Float(1)

			self.initialSelection = [self.scn.selectedByType('mesh')[0]]

			currentMorphMapName = self.getSelectedMorphMap()

			if currentMorphMapName is None:
				self.printLog('No morphMap selected')
				return

			self.applyMorphMap(currentMorphMapName)
		except:
			lx.out(traceback.format_exc())

	def cmd_Query(self, index, vaQuery):
		lx.notimpl()


lx.bless(CmdApplyMorphToAllMeshes, "tila.applyMorphToAllMeshes")
