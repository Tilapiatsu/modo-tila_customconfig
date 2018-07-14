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
        self.src_topology = Topology(self.source)
        self.dst_topology = Topology(self.destination)

        self.src_selectedVerts = self.src_topology.GetSelectedVertices()
        self.src_selectedEdges = self.src_topology.GetSelectedEdges()
        self.src_selectedFaces = self.src_topology.GetSelectedFaces()

        self.dst_selectedVerts = self.dst_topology.GetSelectedVertices()
        self.dst_selectedEdges = self.dst_topology.GetSelectedEdges()
        self.dst_selectedFaces = self.dst_topology.GetSelectedFaces()

    def Morph(self, args=None):
        self.getSourceDestination(args)

        # morphMapCreator = MorphMapCreator()

        # morphMapCreator.morphToDestination()
        # self.mm.debugMode = False

        lx.eval('!!log.masterClear')

        allowToContinue = True

        if len(self.src_selectedVerts) != 1:
            self.mm.error('Please Select one vertex on the soucre Mesh', True)
            allowToContinue = False
        if len(self.src_selectedEdges) != 1:
            self.mm.error('Please Select one edge on the soucre Mesh', True)
            allowToContinue = False
        if len(self.src_selectedFaces) != 1:
            self.mm.error('Please Select one face on the soucre Mesh', True)
            allowToContinue = False

        if len(self.dst_selectedVerts) != 1:
            self.mm.error(
                'Please Select one vertex on the destination Mesh', True)
            allowToContinue = False
        if len(self.dst_selectedEdges) != 1:
            self.mm.error(
                'Please Select one edge on the destination Mesh', True)
            allowToContinue = False
        if len(self.dst_selectedFaces) != 1:
            self.mm.error(
                'Please Select one face on the destination Mesh', True)
            allowToContinue = False

        if not allowToContinue:
            return None

        meshCompare = PolygonMapping()

        meshCompare.Compute(self.src_selectedFaces[0], self.src_selectedEdges[0], self.src_selectedVerts[0],
                            self.dst_selectedFaces[0], self.dst_selectedEdges[0], self.dst_selectedVerts[0])

        mappedList = meshCompare.GetMappedList()

        morphMapCreator = MorphMapCreator()
        print morphMapCreator.morphMap
        morphMapCreator.morphToDestination(
            source=mappedList[0], destination=mappedList[1])

        morphMapCreator.selectMorphMap()

        self.revertSelection()

        return True

        # commonFace = topology.GetUniqueFaceIdByEdges(selectedEdges)

        # if commonFace is not None:
        #     lx.eval('select.typeFrom polygon;edge;vertex;item;pivot;center;ptag true')
        #     commonFace.select()

        # commonVertex = topology.GetUniqueVertexIdByEdge(selectedEdges)

        # if commonVertex is not None:
        #     lx.eval('select.typeFrom vertex;edge;polygon;item;pivot;center;ptag true')
        #     commonVertex.select()

        # otherVertex = topology.GetTheOtherVertexOfAnEdge(topology.GetSelectedEdges()[
        #     0], topology.GetSelectedVertices()[0])

        # if otherVertex is not None:
        #     lx.eval('select.typeFrom vertex;edge;polygon;item;pivot;center;ptag true')
        #     otherVertex.select(replace=True)

        # numberEdges = topology.GetTheNumberOfEdgesFromVertex(
        #     topology.GetSelectedVertices()[0])

        # print numberEdges

        # otherFace = topology.GetTheOtherFaceOfAnEdge(
        #     topology.GetSelectedEdges()[0], topology.GetSelectedFaces()[0])

        # if otherFace is not None:
        #     lx.eval('select.drop polygon')
        #     otherFace.select(replace=False)

        # list = topology.GetOrderedEdgeList(topology.GetSelectedFaces(
        # )[0], topology.GetSelectedEdges()[0], topology.GetSelectedVertices()[0])

        # print list

        # list = topology.GetOrderedVerticesFromOrderedEdgeList(
        #     topology.GetSelectedEdges(), topology.GetSelectedVertices()[0])

        # print list

    def getSourceDestination(self, args):
        if args is not None:
            i = 0
            self.source = args[i]
            i += 1
            self.destination = args[i]

        else:
            self.source = self.scn.selected[0]
            self.destination = self.scn.selected[1]

    def revertSelection(self):
        self.src_selectedVerts[0].select(replace=True)
        self.src_selectedEdges[0].select(replace=True)
        self.src_selectedFaces[0].select(replace=True)

        self.dst_selectedVerts[0].select()
        self.dst_selectedEdges[0].select()
        self.dst_selectedFaces[0].select()


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

        # vertexList2ID = [v.idndex for v in vertexList2]
        vertex2Position = [v.position for v in vertexList2]
        for vert in vertexList1:
            if vert.position in vertex2Position:
                return vert
        else:
            self.mm.error('No common vertices found')
            for e in edgeList:
                self.mm.error(e.id)
            return None

    def GetTheOtherVertexOfAnEdge(self, edge, vert):
        vertlist = edge.vertices

        for v in vertlist:
            if v != vert:
                return v
        else:
            return None

    def getTheEdgesFromVertex(self, vert):

        originalEdgeSelection = self.GetSelectedEdges()

        for edge in originalEdgeSelection:
            edge.deselect()

        for v in vert.vertices:
            v.select()

        lx.eval('select.convert edge')

        connectedEdges = self.GetSelectedEdges()

        for edge in connectedEdges:
            edge.deselect()
        if len(originalEdgeSelection) == 0:
            lx.eval('select.drop edge')
            lx.eval('select.typeFrom vertex;edge;polygon;item;pivot;center;ptag true')
        else:
            i = 0
            param = True
            for edge in originalEdgeSelection:
                if i == 1:
                    param = False

                edge.select(replace=param)
                i += 1

        vert.select(replace=True)

        return connectedEdges

    def GetTheNumberOfEdgesFromVertex(self, vert):
        return len(self.getTheEdgesFromVertex(vert))

    def GetTheOtherFaceOfAnEdge(self, edge, poly):
        polygonList = edge.polygons
        if len(polygonList) == 1:
            return None
        for p in polygonList:
            if p != poly:
                return p
        else:
            return None

    # get an ordered edge list of a face
    # the order starts from the given edge and continue in the opposite direction of the vertid

    #  x1------a------x2
    #  |               |
    #  b       F       c
    #  |               |
    #  x3-----d-------x4
    #
    # GetOrderedEdgeList F c x4 - - > cabd
    # GetOrderedEdgeList F a x1 - - > acdb

    # param faceid
    # param edgeid in the face
    # param vertid on the edge

    def GetOrderedEdgeList(self, face, edge, vert):
        outputlist = []

        edgelist = list(face.edges)

        if edge not in edgelist:
            self.mm.error("Edge doesn't belong to polygon", True)
            sys.exit()

        vertexList = edge.vertices

        if vert not in vertexList:
            self.mm.error("vertex doesn't belong to edge", True)
            sys.exit()

        outputlist.append(edge)
        edgelist.remove(edge)

        while len(edgelist) > 1:
            # get the other vertex
            vert = self.GetTheOtherVertexOfAnEdge(edge, vert)

            # find and edge in the list of edges left that is sharing the new vertid
            notFound = True
            for otherEdge in edgelist:
                if notFound:
                    # other vert
                    othervertlist = otherEdge.vertices
                    if vert in othervertlist:
                        edge = otherEdge
                        notFound = False
                        continue

            # add the element to the list
            outputlist.append(edge)
            edgelist.remove(edge)

        # add the last to the list
        outputlist.append(edgelist[0])

        # return result
        return outputlist

    def GetOrderedVerticesFromOrderedEdgeList(self, edgelist, vert):
        if vert not in edgelist[0].vertices:
            self.mm.error("vertex doesn't belong to edge")
            sys.exit()

        outputlist = [vert]

        # add all vertices to the list in order

        for e in edgelist:
            vert = self.GetTheOtherVertexOfAnEdge(e, vert)
            outputlist.append(vert)

        return outputlist


# private function don't call this function!
# use the "Compute" function
# it will compute this face and put on the stack all the faces to compute next
# param facedata: the tuple of src and dst data
class PolygonMapping(MorphToSelected):
    iter = 0

    def __init__(self):
        MorphToSelected.__init__(self)

        self.FaceList = []
        self.SrcFaceDone = {}
        self.DstFaceDone = {}
        self.MappedVertexSrcToDst = {}
        self.MappedVertexTuple = []

    def Private_ComputeFace(self, facedata):

        srcFace = facedata[0]
        dstFace = facedata[1]

        allowToContinue = True

        # make sure we haven't computed this already
        if srcFace[0].index in self.SrcFaceDone.keys():
            if self.SrcFaceDone[srcFace[0].index]:
                allowToContinue = False

        if dstFace[0].index in self.DstFaceDone.keys():
            if self.DstFaceDone[dstFace[0].index]:
                allowToContinue = False

        # save the fact that we've done this face
        self.SrcFaceDone[srcFace[0].index] = True
        self.DstFaceDone[dstFace[0].index] = True

        # stop if needed
        if not allowToContinue:
            # self.mm.error('skipping : Face have already been computed')
            self.revertSelection()
            return None

        # let's get the ordered list for both source and destination
        sourceEdgeOrdered = self.src_topology.GetOrderedEdgeList(
            srcFace[0], srcFace[1], srcFace[2])
        destinationEdgeOrdered = self.dst_topology.GetOrderedEdgeList(
            dstFace[0], dstFace[1], dstFace[2])

        # check if we have the same number of edges
        if len(sourceEdgeOrdered) == len(destinationEdgeOrdered):

            # we can save the mapping of these
            sourceVertexOrdered = self.src_topology.GetOrderedVerticesFromOrderedEdgeList(
                sourceEdgeOrdered, srcFace[2])
            destinationVertexOrdered = self.dst_topology.GetOrderedVerticesFromOrderedEdgeList(
                destinationEdgeOrdered, dstFace[2])

            cnt = len(sourceVertexOrdered)

            # check if any vert is already mapped to a value.
            # if it is we check if it's mapped to the same value
            allowToContinue = True
            for i in xrange(cnt):
                srcVert = sourceVertexOrdered[i]
                dstVert = destinationVertexOrdered[i]

                # if srcVert.index in self.MappedVertexSrcToDst.keys():
                #     if self.MappedVertexSrcToDst[srcVert.index][1] != dstVert:
                #         allowToContinue = False
                #         break

            # if we have to stop we return
            if not allowToContinue:
                # self.mm.error('Not allowed to continue 2')
                self.revertSelection()
                return None

            for i in xrange(cnt):
                srcVert = sourceVertexOrdered[i]
                dstVert = destinationVertexOrdered[i]

                self.MappedVertexSrcToDst[srcVert.index] = [srcVert, dstVert]

            # we can add the connected faces
            for i in xrange(cnt - 1):
                srcVert = sourceVertexOrdered[i]
                dstVert = destinationVertexOrdered[i]
                srcVert2 = sourceVertexOrdered[i + 1]
                dstVert2 = destinationVertexOrdered[i + 1]

                srcEdge = sourceEdgeOrdered[i]
                dstEdge = destinationEdgeOrdered[i]

                # find connected face
                srcF = self.src_topology.GetTheOtherFaceOfAnEdge(
                    srcEdge, srcFace[0])
                dstF = self.dst_topology.GetTheOtherFaceOfAnEdge(
                    dstEdge, dstFace[0])

                # we will do this face only if they both exists
                if srcF is not None and dstF is not None:
                    # we add this face only if we are growing along an edge connected two vertices that are connected to the same amout of edges
                    if self.src_topology.GetTheNumberOfEdgesFromVertex(srcVert) == self.dst_topology.GetTheNumberOfEdgesFromVertex(dstVert) or self.src_topology.GetTheNumberOfEdgesFromVertex(srcVert2) == self.dst_topology.GetTheNumberOfEdgesFromVertex(dstVert2):
                        self.FaceList.append([[srcF, srcEdge, srcVert],
                                              [dstF, dstEdge, dstVert]])

    # compute the mapping between the two poly
    def Compute(self, srcFace, srcEdge, srcVert, dstFace, dstEdge, dstVert, progress=None):

        # get the number of faces
        nbFaces = len(self.source.geometry.polygons)
        faceIncrement = 0

        # get the first face
        srcFaceList = [srcFace, srcEdge, srcVert]
        dstFaceList = [dstFace, dstEdge, dstVert]

        # add this face to the list of faces to do
        self.FaceList.append([srcFaceList, dstFaceList])

        # let's do all the list of faces
        for face in self.FaceList:
            self.Private_ComputeFace(face)

            faceIncrement += 1

            if progress is not None:
                val = (25 * faceIncrement) / nbFaces
                progress.value = val

        if progress is not None:
            progress.value = 100

        # we've build the list, let's create the tupple list
        cnt = len(self.MappedVertexSrcToDst)
        keys = self.MappedVertexSrcToDst.keys()

        for i in xrange(cnt):
            if keys[i] is not None:
                tuple = [self.MappedVertexSrcToDst[keys[i]]
                         [0], self.MappedVertexSrcToDst[keys[i]][1]]
                self.MappedVertexTuple.append(tuple)

    # get mapped list
    # return the mapped tupple list between source and destination
    def GetMappedList(self):
        srcList = []
        dstList = []
        for v in self.MappedVertexTuple:
            srcList.append(v[0])
            dstList.append(v[1])
        return [srcList, dstList]

        # return self.MappedVertexTuple

    # get mapped list
        # return the mapped tupple list of only the selected vertex in the source
    def GetMappedListForSourceVertexSelection(self):
        thelist = []
        sel = self.source.GetSelectedVertices()
        for s in sel:
            if self.MappedVertexSrcToDst[s.index] is not None:
                tuple = [s, self.MappedVertexSrcToDst[s.index]]
                thelist.append(tuple)

        return thelist

    # invert a mapped list
    # this return a tuple with destination source instead of source destination
    def InvertMappedList(self, inputMappedList):
        outputList = []
        for tupple in inputMappedList:
            newTupple = [tupple[1], tupple[0]]
            outputList.append(newTupple)

        return outputList


class PolyPosition(MorphToSelected):
    def __init__(self, compare=None):
        MorphToSelected.__init__(self)

        self.compare = compare


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
            morphMapID = lx.eval('query layerservice vmaps ? morph')
            if len(morphMapID) == 0:
                return None
            else:
                for id in morphMapID:
                    if lx.eval('query layerservice vmap.selected ? {}'.format(id)) == 1:
                        morphMapName = lx.eval(
                            'query layerservice vmap.name ? {}'.format(id))
                        break
                else:
                    return None

            morphMap = self.source.geometry.vmaps[morphMapName]

            return morphMap[0]

        except:
            self.mm.error("No morph map selected")
            return None

    def selectMorphMap(self):
        lx.eval('select.vertexMap {} morf replace'.format(self.morphMap.name))

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

    def morphToDestination(self, source=None, destination=None):

        if destination is None:
            destVertices = self.destination.geometry.vertices
        else:
            destVertices = destination

        if source is None:
            srcVertices = self.source.geometry.vertices
        else:
            srcVertices = source

        for i in xrange(len(srcVertices)):
            destPos = modo.mathutils.Vector3(destVertices[i].position)
            self.moveVertToPosition(srcVertices[i].index, destPos)

        self.source.geometry.setMeshEdits()

    def moveVertToPosition(self, vertexID, destinationCoorinate):
        # print vertexID, self.morphMap, destinationCoorinate
        self.morphMap.setAbsolutePosition(vertexID, destinationCoorinate)
