#python

import lx, lxu, modo
from PySide import QtGui

class copyNamesToClipboard(lxu.command.BasicCommand):
    def __init__(self):
        lxu.command.BasicCommand.__init__(self)

    def basic_Execute(self, msg, flags):
        try:
            scene = modo.Scene()
            clipboard = QtGui.QClipboard()                                  # The QtGui.QClipboard gives you access
                                                                            # to your operating system's Copy/Paste Clipboard

            text = None

            if len(scene.selected) == 0:                                    # If you have nothing selected, don't do anything
                pass

            elif len(scene.selected) == 1:                                  # If you have a single item selected
                text = scene.selected[0].name                               # set text to that item's name

            elif len(scene.selected) > 1:                                   # If you have more than one item selected
                selItemsAsNames = [item.name for item in scene.selected]    # Create a list and grab just the names

                                                                            # This join command allows you to take a list
                text = ', '.join(selItemsAsNames)                           # and turn it in to a single long string.
                                                                            # Very useful for displaying lists in a non-python way


            if text is not None:                                            # Only the above elifs were accessed, will this be true
                clipboard.setText(text)
                lx.out('Text copied to clipboard: %s' %(text))

        except Exception as e:
            lx.out(e)

lx.bless(copyNamesToClipboard, 'modo.copyNamesToClipboard')