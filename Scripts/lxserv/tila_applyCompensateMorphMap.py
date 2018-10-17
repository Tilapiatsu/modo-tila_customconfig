
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


class CmdApplyCompensateMorphMap(lxu.command.BasicCommand):
	def __init__(self):
		lxu.command.BasicCommand.__init__(self)

		self.dyna_Add('morphAmount', lx.symbol.sTYPE_FLOAT)
		self.basic_SetFlags(0, lx.symbol.fCMDARG_OPTIONAL)

		self.dyna_Add('cleanMorph', lx.symbol.sTYPE_BOOLEAN)
		self.basic_SetFlags(1, lx.symbol.fCMDARG_OPTIONAL)

		self.scn = modo.Scene()
		self.morphMapName = None
		self.morphAmount = 1.0
		self.cleanMorph = False
		self.initialSelection = None
		self.debug = False

	def arg_UIHints (self, index, hints):
		if index == 0:
			hints.Label('Source MorphMap')
		if index == 1:
			hints.Label('Morph amount')
	
	def cmd_UserName (self):
 		return 'Apply selected morph to base mesh and compensate all other morph maps'

	def cmd_Desc (self):
 		return 'Apply selected morph to base mesh and compensate all other morph maps.'

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

	def printLog(self, message, force=False):
		if self.debug or force:
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
		for item in self.initialSelection:
			item.select(replace=True)
			vmaps = item.geometry.vmaps
			morphMaps = vmaps.morphMaps

			morphMapNames = [m.name for m in morphMaps]
			if CurrentMorphMapName not in morphMapNames:
				self.printLog('MorphMap "{}" not in {} item'.format(CurrentMorphMapName, item.name))
				continue
			
			# Applying morph to basemesh
			self.printLog('Applying morph {} to basemesh'.format(CurrentMorphMapName), force=True)
			lx.eval('select.vertexMap {} morf 3'.format(CurrentMorphMapName))
			lx.eval('vertMap.applyMorph {} {}'.format(CurrentMorphMapName, self.morphAmount))


			# Compensate on all other morph maps
			for map in morphMaps:
				if map.name != CurrentMorphMapName:
					self.printLog('Compensate MorphMap {}'.format(map.name))
					lx.eval('select.vertexMap {} morf replace'.format(map.name))
					lx.eval('vertMap.applyMorph {} {}'.format(CurrentMorphMapName, -self.morphAmount))
			
			self.printLog('cleanMorph : {}'.format(self.cleanMorph), force=True)
			if self.cleanMorph:
				# Clean morphmap
				self.printLog('Cleaning morphmap {}'.format(CurrentMorphMapName), force=True)
				lx.eval('select.vertexMap {} morf replace'.format(CurrentMorphMapName))
				lx.eval('vertMap.clear morf')
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
				self.morphAmount = self.dyna_Float(0)

			if self.dyna_IsSet(1):
				self.cleanMorph = self.dyna_Bool(1)

			self.initialSelection = self.scn.selectedByType('mesh')

			if len(self.initialSelection)<1:
				result = self.init_message('yesNo','No mesh selected', 'No mesh selected. \n Do you want to proceed to all mesh items in the scene ?')
				if result:
					self.initialSelection = self.scn.items('mesh')
				else:
					self.init_message('info', 'Aborded', 'Operation aborded by the user')
					return

			self.morphMapName = self.getSelectedMorphMap()

			if self.morphMapName is None:
				self.printLog('No morphMap selected')
				self.init_message('info', 'No Morph Map selected', 'Select one morph map')
				return

			self.applyMorphMap(self.morphMapName)
		except:
			lx.out(traceback.format_exc())

	def cmd_Query(self, index, vaQuery):
		lx.notimpl()


lx.bless(CmdApplyCompensateMorphMap, "tila.applyCompensateMorphMap")
