
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
		self.basic_SetFlags (0, lx.symbol.fCMDARG_OPTIONAL)

		self.scn = modo.Scene()
		self.selectedItemOnly = False

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

	def getSelectedMorphMap(self, ):
		try:
			morphMapName = lx.eval('vertMap.name ? morf active')
			if morphMapName is not None:
				return morphMapName
		except:
			self.init_message("error", "No morphmMap selected", "Please slelect one morph map first")
			return None

	def switchMorphMaps(self, morphMapName):
		if self.selectedItemOnly:
			meshSelection = [self.scn.items('mesh')[0]]
		else:
			meshSelection = self.scn.items('mesh')
		i = 0
		for item in meshSelection:
			item.select(replace=True)
			vmaps = item.geometry.vmaps
			morphMaps = vmaps.morphMaps
			
			if morphMapName not in [m.name for m in morphMaps]:
				print 'morphMap not in {} item'.format(item.name)
				continue

			for map in morphMaps:
				if map.name == morphMapName:
					if i == 0:
						lx.eval('select.vertexMap {} morf {}'.format(morphMapName, morphMapName))
					# lx.eval('select.vertexMap {} morf replace'.format(morphMapName))
					lx.eval('vertMap.applyMorph {} 1.0'.format(morphMapName))
					lx.eval('select.vertexMap {} morf replace'.format(morphMapName))
					lx.eval('vertMap.applyMorph {} -2.0'.format(morphMapName))

			for map in morphMaps:
				if map.name != morphMapName:
					lx.eval('select.vertexMap {} morf replace'.format(map.name))
					lx.eval('vertMap.applyMorph {} 1.0'.format(morphMapName))
					lx.eval('select.vertexMap {} morf {}'.format(map.name, morphMapName))
			i += 1
		else:
			meshSelection[0].select(replace=True)
	
	@staticmethod
	def breakPoint(i, number):
		if i == number:
			sys.exit()

	def basic_Execute(self, msg, flags):
		try:
			if self.scn != modo.Scene():
				self.scn = modo.Scene()

			if self.dyna_IsSet(0):
				self.selectedItemOnly = self.dyna_Bool(0)

			morphMapName = self.getSelectedMorphMap()
			
			if morphMapName == None:
				lx.out('No morphMap Found')
				return

			self.switchMorphMaps(morphMapName)
		except:
			lx.out(traceback.format_exc())


	def cmd_Query(self, index, vaQuery):
		lx.notimpl()


lx.bless(CmdSwitchMeshesToSelectedMorph, "tila.switchMeshesToSelectedMorph")

