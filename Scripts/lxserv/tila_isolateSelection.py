
################################################################################
#
# scriptname.py
#
# Version: 1
#
# Author: Tilapiatsu
#
# Description: Isolate selected item - ( hide unselected )
#
# Last Update: 05/07/2016
#
################################################################################

import lx
import lxifc
import lxu.command
import modo


class CmdTila_isolateSelection(lxu.command.BasicCommand):
    def __init__(self):
        lxu.command.BasicCommand.__init__(self)

        self.commands = ('hide.sel', 'hide.invert')

        self.scn = modo.Scene()
        self.selection = self.scn.selected

    def cmd_Flags(self):
        return lx.symbol.fCMD_MODEL | lx.symbol.fCMD_UNDO

    def basic_Enable(self, msg):
        return True

    def cmd_Interact(self):
        pass

    def isolateSelection(self):
        for command in self.commands:
            lx.eval(command)

        self.scn.select(self.selection)

    def isPolygonSelected(self):
        polygonIsSelected = False

        for item in self.selection:
            if len(item.geometry.polygons.selected) < 1:
                polygonIsSelected = polygonIsSelected or False
            else:
                polygonIsSelected = polygonIsSelected or True

        return polygonIsSelected

    def isEdgeSelected(self):
        edgeIsSelected = False

        for item in self.selection:
            if len(item.geometry.edges.selected) < 1:
                edgeIsSelected = edgeIsSelected or False
            else:
                edgeIsSelected = edgeIsSelected or True

        return edgeIsSelected

    def isVertexSelected(self):
        vertexIsSelected = False

        for item in self.selection:
            if len(item.geometry.vertices.selected) < 1:
                vertexIsSelected = vertexIsSelected or False
            else:
                vertexIsSelected = vertexIsSelected or True

        return vertexIsSelected

    def basic_Execute(self, msg, flags):
        if len(self.selection) == 0:
            self.scn.select(self.scn.items())

            self.isolateSelection()
        else:
            if lx.eval('select.typeFrom item;pivot;center;edge;polygon;vertex;ptag ?'):
                lx.eval('hide.unsel')

            elif lx.eval('select.typeFrom polygon;edge;vertex;item;pivot;center;ptag ?'):
                if self.isPolygonSelected():
                    lx.eval('hide.unsel')
                else:
                    lx.eval('unhide')

            elif lx.eval('select.typeFrom edge;vertex;polygon;item;pivot;center;ptag ?'):
                if self.isEdgeSelected():
                    lx.eval('select.expand')
                    lx.eval('select.convert polygon')
                    lx.eval('hide.unsel')
                else:
                    lx.eval('unhide')

            elif lx.eval('select.typeFrom vertex;edge;polygon;item;pivot;center;ptag ?'):
                if self.isVertexSelected():
                    lx.eval('select.expand')
                    lx.eval('select.expand')
                    lx.eval('select.convert polygon')
                    lx.eval('hide.unsel')
                else:
                    lx.eval('unhide')

    def cmd_Query(self, index, vaQuery):
        lx.notimpl()

lx.bless(CmdTila_isolateSelection, "tila.isolateSelection")

