#python

# File: mc_lxRename_removeBrackets.py
# Author: Matt Cox
# Description: Bulk renames a selection of items, removing brackets and content from the name.

import lx
import re

try:
    lxRSelectedItems = lx.evalN('query sceneservice selection ? all')
    
    for x in lxRSelectedItems:
        lx.eval('select.Item %s' %str(x))
        lxRMeshNameM = lx.eval('query sceneservice item.name ? %s' %str(x))
        try:
            lxRNewNameM = re.sub(r'\(.*?\)', '', lxRMeshNameM)
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