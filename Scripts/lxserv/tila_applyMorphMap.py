
################################################################################
#
# tila_switchMeshesToSelectedMorph.py
#
# Version: 1.0
#
# Author: Tilapiatsu
#
# Description: Apply current morph map to all meshes in the current scene
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


class CmdApplyMorphMap(lxu.command.BasicCommand):
	def __init__(self):
		lxu.command.BasicCommand.__init__(self)

		self.dyna_Add('morphAmount', lx.symbol.sTYPE_FLOAT)
		self.basic_SetFlags(0, lx.symbol.fCMDARG_OPTIONAL)

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
 		return 'Apply selected morph to base mesh'

	def cmd_Desc (self):
 		return 'Apply selected morph to base mesh.'

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
			lx.out('ApplyCompensateMorphMap : {}'.format(message))

	def getSelectedMorphMap(self):
		try:
			morphMapName = lx.eval('vertMap.name ? morf active')
			if morphMapName is not None:
				return morphMapName
		except:
			self.init_message("error", "No morphmMap selected", "Please select one morph map first")
			return None

	def applyMorphMap(self, CurrentMorphMapName):
		meshSelection = self.initialSelection[0]

		meshSelection.select(replace=True)
		vmaps = meshSelection.geometry.vmaps
		morphMaps = vmaps.morphMaps

		morphMapNames = [m.name for m in morphMaps]
		if CurrentMorphMapName not in morphMapNames:
			self.printLog('morphMap {} not in {} item'.format(CurrentMorphMapName, meshSelection.name))
			return
		
		# Applying morph to basemesh
		lx.eval('select.vertexMap {} morf 3'.format(CurrentMorphMapName))
		lx.eval('vertMap.applyMorph {} {}'.format(CurrentMorphMapName, self.morphAmount))

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
				self.morphAmount = self.dyna_Float(0)

			self.initialSelection = [self.scn.selectedByType('mesh')[0]]

			self.morphMapName = self.getSelectedMorphMap()

			if self.morphMapName is None:
				self.printLog('No morphMap selected')
				return

			self.applyMorphMap(self.morphMapName)
		except:
			lx.out(traceback.format_exc())

	def cmd_Query(self, index, vaQuery):
		lx.notimpl()


lx.bless(CmdApplyMorphMap, "tila.applyMorphMap")
