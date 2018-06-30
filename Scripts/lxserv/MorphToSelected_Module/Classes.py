import lx
import modo
import MorphToSelected_Module as m


class MessageManagement():
    prefix = m.TILA_MESSAGEPREFIX

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
            message = '{} : {} '.format(self.prefix, message)
            lx.out(message)

    def warning(self, message, dialog=False):
        if dialog:
            self.init_message('warning', 'warning', message)
        else:
            message = '{} : {} '.format(self.prefix, message)
            lx.out(message)

    def error(self, message, dialog=False):
        if dialog:
            self.init_message('error', 'error', message)
        else:
            message = '{} : {} '.format(self.prefix, message)
            lx.out(message)

    def breakPoint(self, message='break'):
        self.init_message('info', message, message)


class MorphToSelected():

    mm = MessageManagement()
    scn = None

    def __init__(self, args=None):
        self.scn = modo.Scene()

        self.getSourceDestination(args)

    def Morph(self, args=None):
        self.getSourceDestination(args)

        morphMapCreator = MorphMapCreator()

        morphMapCreator.morphToDestination()

    def getSourceDestination(self, args):
        if args is not None:
            i = 0
            self.source = args[i]
            i += 1
            self.destination = args[i]

        else:
            self.source = self.scn.selected[0]
            self.destination = self.scn.selected[1]


class Topology(MorphToSelected):
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


class PolygonMapping(MorphToSelected):
    def __init__(self):
        MorphToSelected.__init__(self)

        self.FaceList = ()
        self.SrcFaceDone = {}
        self.DstFaceDone = {}
        self.MappedVertexSrcToDst = ()
        self.MappedVertexDstToSrc = ()
        self.MappedVertexTuple = ()

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


class MorphMapCreator(MorphToSelected):
    morphMapDefaultName = 'Destination'

    def __init__(self, morphMapName=None):
        MorphToSelected.__init__(self)
        if morphMapName is None:
            self.morphMap = self.getSelectedMorphMap()

        if self.morphMap is None and morphMapName is not None:
            self.mm.info("Try to select by morphMapName")
            self.morphMap = self.getMorphMapByName(morphMapName)

        if self.morphMap is None:
            destinationMorphMap = self.source.geometry.vmaps[self.morphMapDefaultName]
            if len(destinationMorphMap) != 0:
                self.mm.info("Using existing morphmap called '{}'".format(
                    self.morphMapDefaultName))
                self.morphMap = destinationMorphMap[0]
            else:
                self.mm.info("Create a new morphmap called '{}'".format(
                    self.morphMapDefaultName))
                self.morphMap = self.createMorphMap(
                    self.source, self.morphMapDefaultName)

    def getSelectedMorphMap(self):
        try:
            morphMapName = lx.eval('vertMap.name ? morf active')
            morphMap = self.source.geometry.vmaps[morphMapName]
            return morphMap[0]

        except:
            self.mm.error("No morph map selected")
            return None

    def getMorphMapByName(self, name):
        morphMap = self.source.geometry.vmaps[name]

        if morphMap is not None:
            return morphmap[0]
        else:
            self.mm.error('MorphMap {} not in {} item'.format(
                name, self.source.name), True)
            return None

    def createMorphMap(self, item, name):
        vmaps = item.geometry.vmaps
        vmaps.addMorphMap(name)

        return self.source.geometry.vmaps[name][0]

    def morphToDestination(self):
        i = 0
        destVertices = self.destination.geometry.vertices
        matrixObject = self.destination.channel('worldMatrix').get()
        matrix = modo.Matrix4(matrixObject)

        for v in self.source.geometry.vertices:
            destPos = modo.mathutils.Vector3(destVertices[i].position)
            self.moveVertToPosition(i, destPos)
            i += 1

        self.source.geometry.setMeshEdits()

    def moveVertToPosition(self, vertexID, destinationCoorinate):
        # print vertexID, self.morphMap, destinationCoorinate
        self.morphMap[vertexID] = destinationCoorinate
