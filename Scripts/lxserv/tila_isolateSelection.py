
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

    def basic_Execute(self, msg, flags):
        if len(self.selection) == 0:
            self.scn.select(self.scn.items())

            self.isolateSelection()
        else:
            lx.eval('hide.unsel')

    def cmd_Query(self, index, vaQuery):
        lx.notimpl()


lx.bless(CmdTila_isolateSelection, "tila.isolateSelection")

