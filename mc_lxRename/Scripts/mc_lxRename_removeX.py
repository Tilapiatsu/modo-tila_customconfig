#python

# File: mc_lxRename_removeX.py
# Author: Matt Cox
# Description: Bulk renames a selection of items, removing X amount of characters from the start or the end. Based upon the user variable removeX.

import lx
import re

lxRRemoveXString = lx.eval( "user.value mcRename.removeX ?" )
lxRRemoveXArgs = lx.args()
lxRRemoveXArg = lxRRemoveXArgs[0]

if lxRRemoveXString < 0:
    lxRRemoveXString = 0
try:
    lxRSelectedItems = lx.evalN('query sceneservice selection ? all')
    
    for x in lxRSelectedItems:
        lx.eval('select.Item %s' %str(x))
        lxRMeshNameM = lx.eval('query sceneservice item.name ? %s' %str(x))
        try:
            if lxRRemoveXArg == "start":
                lxRNewNameM = lxRMeshNameM[lxRRemoveXString:]
            else:
                lxRNewNameM = lxRMeshNameM[:-lxRRemoveXString]
            lx.eval('item.name "%s"'%(lxRNewNameM))
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