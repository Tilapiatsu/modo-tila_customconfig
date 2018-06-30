
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
import sys
import MorphToSelected_Module as m
from MorphToSelected_Module import Classes as c


class CmdMorphToSelectedByTopology(lxu.command.BasicCommand):
    scn = None
    mm = c.MessageManagement()

    def __init__(self):
        lxu.command.BasicCommand.__init__(self)

        self.source = None
        self.destination = None

    def cmd_Flags(self):
        return lx.symbol.fCMD_MODEL | lx.symbol.fCMD_UNDO

    def basic_Enable(self, msg):
        return True

    def cmd_Interact(self):
        pass

    def init(self):
        if self.scn is None:
            self.scn = modo.Scene()

        if len(self.scn.selected) < 2:
            self.mm.error(
                'First select the Source item then the Destination one', True)
            sys.exit()

        if self.source is None:
            self.source = self.scn.selected[0]

        if self.destination is None:
            self.destination = self.scn.selected[1]

        if self.source is None or self.destination is None:
            self.mm.error(
                'First select the Source item then the Destination one')

    def basic_Execute(self, msg, flags):
        try:
            self.init()

            reload(c)

            # construct args
            args = [self.source, self.destination]

            MorphToSelected = c.MorphToSelected(args)

            MorphToSelected.Morph(args)
        except:
            lx.out(traceback.format_exc())

    def cmd_Query(self, index, vaQuery):
        lx.notimpl()


lx.bless(CmdMorphToSelectedByTopology, m.TILA_COMMANDNAME)
