#python

# File: mc_lxRename_numericSuffix.py
# Author: Matt Cox
# Description: Bulk renames a selection of items, numerically adding a number, formatted by the variables in modo.

import lx
import re

try:
    lxRRenameSymbol = lx.eval( "user.value mcRename.numSymbol ?" )
    lxRRenameDigits = lx.eval( "user.value mcRename.numDigits ?" )
    lxRRenameStart = lx.eval( "user.value mcRename.numStart ?" )
    lxRRenameRemoveCurrent = lx.eval( "user.value mcRename.numSuffixRemoveCount ?" )
    lxRNumberingIndexStyle = lx.eval( "pref.value application.indexStyle ?" )
    
    if lxRRenameDigits < 1:
        lxRRenameDigits = 1
    if lxRRenameStart < 0:
        lxRRenameStart = 0


    lxRSelectedItems = lx.evalN('query sceneservice selection ? all')
    
    lxRTotalItems = len(lxRSelectedItems)
    lxRTotalItemsLen = len(str(lxRTotalItems))
    if lxRRenameDigits < lxRTotalItemsLen:
        lxRRenameDigits = lxRTotalItemsLen    
    
    lxRCurrentNumberM = lxRRenameStart
    for x in lxRSelectedItems:
        lx.eval('select.Item %s' %str(x))
        lxRMeshNameM = lx.eval('query sceneservice item.name ? %s' %str(x))
        try:
            lxRCurrentLengthM = len(str(lxRCurrentNumberM))
            lxRCurrentPaddingM = lxRRenameDigits - lxRCurrentLengthM
            lxRCurrentCountM = 0
            lxRCurrentPaddingZerosM = ""
            while lxRCurrentCountM < lxRCurrentPaddingM:
                lxRCurrentPaddingZerosM = str(0) + lxRCurrentPaddingZerosM
                lxRCurrentCountM = lxRCurrentCountM + 1
            
            if lxRRenameRemoveCurrent == True:
                if lxRNumberingIndexStyle == "brak-sp":
                    lxRMeshNameC = re.sub(r' \(.*[0-9]\)$', '', lxRMeshNameM)
                elif lxRNumberingIndexStyle == "brak":
                    lxRMeshNameC = re.sub(r'\(.*[0-9]\)$', '', lxRMeshNameM)
                elif lxRNumberingIndexStyle == "sp":
                    lxRMeshNameC = re.sub(r'\ .*[0-9]$', '', lxRMeshNameM)
                elif lxRNumberingIndexStyle == "uscore":
                    lxRMeshNameC = re.sub(r'\_.*[0-9]$', '', lxRMeshNameM)
                elif lxRNumberingIndexStyle == "none":
                    lxRMeshNameC = re.sub(r'\.*[0-9]$', '', lxRMeshNameM)
                else:
                    lxRMeshNameC = lxRMeshNameM
            else:
                lxRMeshNameC = lxRMeshNameM
               
            lxRNewNameM = lxRMeshNameC + lxRRenameSymbol + str(lxRCurrentPaddingZerosM) + str(lxRCurrentNumberM)
            lx.eval('item.name "%s"'%(lxRNewNameM))
            lxRCurrentNumberM = lxRCurrentNumberM + 1
    
        except:
            lx.out('Error: Unable to Rename Items')  
    lx.eval('select.drop item')
    for x in lxRSelectedItems:
        lx.eval('select.Item %s add' %str(x))
except:
    lx.out('Exception "%s" on line: %d' % (sys.exc_value, sys.exc_traceback.tb_lineno))