#python

# File: mc_lxRename_rename.py
# Author: Matt Cox
# Description: Bulk renames a selection of items, changing their names to the rename string.

import lx
import re

lxRRenameText = lx.eval( "user.value mcRename.rename ?" )

if len(lxRRenameText) != 0:
    try:
        lxRSelectedItems = lx.evalN('query sceneservice selection ? all')
        for x in lxRSelectedItems:
            lx.eval('select.Item %s' %str(x))
            try:
                lx.eval('item.name "%s"'%(lxRRenameText))
            except:
                lx.eval('dialog.setup error')
                lx.eval('dialog.title {Error}')
                lx.eval('dialog.msg {Unable to rename items.}')
                lx.eval('dialog.open')
        
        lx.eval('select.drop item')
        for x in lxRSelectedItems:
            lx.eval('select.Item %s add' %str(x))
    except:
        lx.out('Exception "%s" on line: %d' % (sys.exc_value, sys.exc_traceback.tb_lineno))