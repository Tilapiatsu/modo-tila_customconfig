import lx
import modo
import sys
import MorphToSelected_Module as m


class MessageManagement():
    prefix = m.TILA_MESSAGEPREFIX
    debugMode = True

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

    def debug(func):
        def func_wrapper(self, message, dialog=False):
            if self.debugMode and not dialog:
                message = '{} : {} '.format('DEBUG_MODE', message)
            return func(self, message, dialog)
        return func_wrapper

    @debug
    def info(self, message, dialog=False):
        if dialog:
            self.init_message('info', 'info', message)
        else:
            message = '{} : {} '.format(self.prefix, message)
            lx.out(message)

    @debug
    def warning(self, message, dialog=False):
        if dialog:
            self.init_message('warning', 'warning', message)
        else:
            message = '{} : {} '.format(self.prefix, message)
            lx.out(message)

    @debug
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

        # morphMapCreator = MorphMapCreator()

        # morphMapCreator.morphToDestination()
        # self.mm.debugMode = False

        topology = Topology(self.source)

        selectedEdges = topology.GetSelectedEdges()

        # commonFace = topology.GetUniqueFaceIdByEdges(selectedEdges)

        # if commonFace is not None:
        #     lx.eval('select.typeFrom polygon;edge;vertex;item;pivot;center;ptag true')
        #     commonFace.select()

        commonVertex = topology.GetUniqueVertexIdByEdge(selectedEdges)

        if commonVertex is not None:
            lx.eval('select.typeFrom vertex;edge;polygon;item;pivot;center;ptag true')
            commonVertex.select()

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
    def __init__(self, mesh):

        self.Mesh = mesh

    def GetSelectedEdges(self):
        selSrv = lx.service.Selection()
        edgeSelTypeCode = selSrv.LookupType(lx.symbol.sSELTYP_EDGE)
        vTransPacket = lx.object.EdgePacketTranslation(
            selSrv.Allocate(lx.symbol.sSELTYP_EDGE))

        numEdges = selSrv.Count(edgeSelTypeCode)

        edges = []
        for i in range(numEdges):
            packetPointer = selSrv.ByIndex(edgeSelTypeCode, i)
            id1, id2 = vTransPacket.Vertices(packetPointer)
            item_ = vTransPacket.Item(packetPointer)

            if item_ == self.Mesh:
                edges.append(modo.MeshEdge.fromIDs(
                    id1, id2, self.Mesh.geometry, self.Mesh))

        return tuple(edges)

    def GetSelectedVertices(self):
        return self.Mesh.geometry.vertices.selected

    def GetSelectedFaces(self):
        return self.Mesh.geometry.polygons.selected

    def GetUniqueFaceIdByEdges(self, edgeList):
        if len(edgeList) != 2:
            self.mm.error('Need two edges ID in the list')
            for e in edgeList:
                self.mm.error(e)
            return None

        polyList1 = edgeList[0].polygons
        polyList2 = edgeList[1].polygons

        if len(polyList1) == 1:
            return polyList1[0]

        if len(polyList2) == 1:
            return polyList2[0]

        for poly in polyList1:
            if poly in polyList2:
                return poly
        else:
            self.mm.error('No common Polygon Found')

    def GetUniqueVertexIdByEdge(self, edgeList):
        if len(edgeList) != 2:
            self.mm.error('Please select 2 edges', True)
            for e in edgeList:
                self.mm.error(e)
            return None

        vertexList1 = edgeList[0].vertices
        vertexList2 = edgeList[1].vertices

        if len(vertexList1) == 1:
            return vertexList1[0]

        if len(vertexList2) == 1:
            return vertexList2[0]

        vertexList2ID = [v.id for v in vertexList2]
        vertex2Position = [v.position for v in vertexList2]
        for vert in vertexList1:
            if vert.position in vertex2Position:
                print vert.position, vertex2Position
                print vert.id, vertexList2ID
                return vert
        else:
            self.mm.error('No common vertices found')
            for e in edgeList:
                self.mm.error(e.id)
            return None

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

        # Use Selected Morphmap
        if self.morphMap is None and morphMapName is not None:
            self.mm.info("Try to select by morphMapName")
            self.morphMap = self.getMorphMapByName(morphMapName)

        if self.morphMap is None:
            destinationMorphMap = self.source.geometry.vmaps[self.morphMapDefaultName]
            # Select a morphmap based on self.morphMapDefaultName
            if len(destinationMorphMap) != 0:
                self.mm.info("Using existing morphmap called '{}'".format(
                    self.morphMapDefaultName))
                self.morphMap = destinationMorphMap[0]

            # Create a New Morph Map called self.morphMapDefaultName
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
        self.morphMap.setAbsolutePosition(vertexID, destinationCoorinate)