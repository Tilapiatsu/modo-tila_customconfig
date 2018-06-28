
################################################################################
#
# tila_transfertVertexID.py
#
# Version:
#
# Author:
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


class CmdTransfertVertexID(lxu.command.BasicCommand):

    def __init__(self):
        lxu.command.BasicCommand.__init__(self)

        self.mm = MessageManagement()
        self.source = None
        self.destination = None

        self.scn = None

    def cmd_Flags(self):
        return lx.symbol.fCMD_MODEL | lx.symbol.fCMD_UNDO

    def basic_Enable(self, msg):
        return True

    def cmd_Interact(self):
        pass

    def init(self):
        if self.scn is None:
            self.scn = modo.Scene()

        if self.source is None:
            self.source = self.scn.selected[0]

        if self.destination is None:
            self.destination = self.scn.selected[1]

    def basic_Execute(self, msg, flags):
        self.init()

        morphMapCreator = MorphMapCreator()

        morphMapCreator.morphToDestination()

    def cmd_Query(self, index, vaQuery):
        lx.notimpl()


lx.bless(CmdTransfertVertexID, "tila.transfertVertexID")


class Topology(CmdTransfertVertexID):
    def __init__(self):

        self.Mesh = None

    def GetSelectedEdges(self):
        pass

    def GetSelectedVertices(self):
        pass

    def GetSelectedFaces(self):
        pass

    def GetUniqueFaceIdByEdges(self, edgeList):
        pass

    def GetUniqueVertexIdByEdge(self, edgeList):
        pass

    def GetTheOtherVertexOfAnEdge(self, edgeID, vertID):
        pass

    def GetTheNumberOfEdgesFromVertex(self, vertID):
        pass

    def GetTheOtherFaceOfAnEdge(self, edgeID, faceID):
        pass

    def GetOrderedEdgeList(self, faceID, edgeID, vertID):
        pass

    def GetOrderedVerticesFromOrderedEdgeList(self, edgeList, vertID):
        pass


class PolygonMapping(CmdTransfertVertexID):
    def __init__(self):
        self.source = None
        self.destination = None

        self.FaceList = ()
        self.SrcFaceDone = {}
        self.DstFaceDone = {}
        self.MappedVertexSrcToDst = ()
        self.MappedVertexDstToSrc = ()
        self.MappedVertexTuple = ()

    def Private_ComputeFace(self):
        pass

    def Private_ComputeFace(self, facedata):
        pass

    def Compute(self, srcFaceID, srcEdgeID, srcVertID, dstFaceID, dstEdgeID, dstVertID, progr):
        pass

    def GetMappedList(self):
        pass

    def GetMappedListForSourceVertexSelection(self):
        pass

    def GetMappedListForDestinationVertexSelection(self):
        pass

    def InvertMappedList(self, inputMappedList):
        pass


class MorphMapCreator(CmdTransfertVertexID):
    def __init__(self, morphMapName=None):
        super(MorphMapCreator, self).init()
        if morphMapName is None:
            morphMap = self.getSelectedMorphMap()

        if morphMap is None:
            morphmap = self.getMorphMapByName(morphMapName)

        if morphMap is None:
            morphMap = self.createMorphMap(self.source, 'Destination')

        self.morphMap = morphMap

    def getSelectedMorphMap(self):
        try:
            morphMapName = lx.eval('vertMap.name ? morf active')
            if morphMapName is not None:
                return morphMapName

        except:
            self.mm.error("No morph map selected")
            return None

    def getMorphMapByName(self, name):
        morphMap = self.source.geometry.vmaps[name]

        if morphMap is not None:
            return morphmap
        else:
            self.mm.error('MorphMap {} not in {} item'.format(
                name, self.source.name), True)
            return None

    def createMorphMap(self, item, name):
        vmaps = item.geometry.MeshMapsMeshMaps

        return vmaps.addMorphMap(name)

    def morphToDestination(self):
        for v in self.source.geometry.vertices:
            self.moveVertToPosition(v, (0, 0, 0))

        self.source.setMeshEdits()

    def moveVertToPosition(self, vertexID, destinationCoorinate):
        self.morphMap[vertexID] = destinationCoorinate


class MessageManagement():
    def __init__(self):
        pass

    @staticmethod
    def init_message(type='info', title='info', message='info'):
        return_result = type == 'okCancel'or type == 'yesNo' or type == 'yesNoCancel' or type == 'yesNoAll' or type == 'yesNoToAll' or type == 'saveOK' or type == 'fileOpen'or type == 'fileOpenMulti'or type == 'fileSave'or type == 'dir'
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

    def info(self, message, dialog=False):
        if dialog:
            self.init_message('info', 'info', message)
        else:
            message = 'TransfertVertexID : {} '.format(message)
            lx.out(message)

    def warning(self, message, dialog=False):
        if dialog:
            self.init_message('warning', 'warning', message)
        else:
            message = 'TransfertVertexID : {} '.format(message)
            lx.out(message)

    def error(self, message, dialog=False):
        if dialog:
            self.init_message('error', 'error', message)
        else:
            message = 'TransfertVertexID : {} '.format(message)
            lx.out(message)

    def breakPoint(self, message='break'):
        self.init_message('info', message, message)
