#python
#RenderOutputManager 
#Daniel Potuznik
#www.onestepmda.com
#info@onestpmda.ch

#Description
"""
#Render Pass Manager for modo 601 You can create very easily pass rendering 
1.) Choice your base path image file:  
    X: \ myproject \ frame \ plan_1 \ plan_1 


2.) Choice your pass rendering     
    color, depth, occlusion...
    

3.) you can also create un group mask and put you rendering output
    GroupName = "Engravings" and you put your render ouput below

4.) Create / update Render Output
  - With separate folder:
  - X: \ myproject \ frame \ plan_1 \ color \ plan_1_color_001.png  
  - X: \ myproject \ frame \ plan_1 \ depth \ plan_1_depth_001.png  
  - X: \ myproject \ frame \ plan_1 \ AO \ plan_1_AO_001.png  

  - with create parent group filder
  - X: \ myproject \ frame \ plan_1 \ Engravings \ color \ plan_1_color_001.png  
  - X: \ myproject \ frame \ plan_1 \ Engravings \depth \ plan_1_depth_001.png  
  - X: \ myproject \ frame \ plan_1 \ Engravings\ AO \ plan_1_AO_001.png  

  - Without separate folder 
  - X: \ myproject \ frame \ plan_1 \ plan_1_color_001.png  
  - X: \ myproject \ frame \ plan_1 \ plan_1_depth_001.png  
  - X: \ myproject \ frame \ plan_1 \ plan_1_AO_001.png 

- you can set your own suffixe and the image format for each render pass
- you can set easily the depth and the occlusion ray

WHEN YOU CREATE / UPDATE BOUTON:
    - if you have render ouput layer selected, it only update the existing layer
    - if you select nothing (= to Render) , Render or an Group Mask it update and create Render output below the item selected

UPDATE ONLY EXISTING BOUTON:

    it's update all the existing render ouput on the scene with the new setting ( if you rename an group, or change the base folder)


#Installation
#put the folder in your script folder


V0.12
    -permet de cree des couche aussi pour calculer en layer il suffit que Target name soit vide
    - recupere le bon nom de l'image avec le boutton "get Active render output" my_image_color -> my_image

V0.13
    ajout du layout dans la configuration ce qui permet de cree une popup
    layout.createOrClose cookie:renderOutputPalette layout:"Render Output Manager Palette" title:"Render Output Manager" width:350 height:900 persistent:1 style:palette

V0.14
    correction orthographique

V1.5 dec 10 2015
    
    - Conversion en Kit pour une instal facile
    - ajout du Gamma
    - ajout d'un nouveau module d'édition

V1.7
    #AJOUT FILE PATTERN
    #[GROUPNAME] = parent group mask name
    #[BASENAME] = nom du fichier
    #[LAYERNAME] = nom du render output
    #[SUFFIXE] = type de render alpha,color,id etc...
    
    - Simplification de l'utilisation 
    - Amélioration de la mise à jour des calques
    
    
V1.7.1
    correction test Remap Pixel Values
    
V1.7.2
    Correction du Grab 
    
V1.8
    new enancement :
- add all new passes avaible on 801
- add Remap Pixel Values for motion and depth
- add Antialiasing Toggle on preference tab for each layer
- Grab Avtive layer has been completely recoded , now it's getting the reel information how the layer has been created, for easy use
- new tag "CAMERA" it's allow to use the render camera name to create your images
- "Update camera name" it's update all layer with the name of the actual render camera, its allow you to easly change all layer with the new name, if you are for exemple 2 camera on your scene (ex: take_01,take_02) and you want to create a new folder with the new camera (take_02), you simply select the render camera to take_02 , click on "update Camera Name" and it create for you all new folder structure based on your pattern ex c:\take_02\ground\color\myImage...

V1.8.1

- add update all button on prefs tab

V1.8.11

- correction camera name ""

V1.8.2

- ajout d'un prefix sur les nom des render Output
- ajout d'utiliser les suffixe comme nom de render egalement


V1.8.3

- demande avant d'écraser le depth,AO motion
- ne demande pas le prefix si on update seulement
- on efface l'ancien prefix

V1.8.4
- ajout load save preset
"""

import lx
import sys
import string
import math
import os 
import platform
import modo
import json


# FUNTION -----------------------------------------------
def savePreset():
    global listName, listFormat
    listSavePreset = ['rom_fileName','rom_AORay','rom_patternFile','rom_motionPixel','rom_motionRemap','rom_AORange','rom_maximumDepth','rom_depthRemap']

    listRender = getRequestedRenderOutput()
    i = len(listName);
    saveData = {}
    ii=0
    for x in xrange(i):
        saveData[listRender[x]['nameActive']]  = listRender[x]['active']

    for x in listSavePreset:
        saveData[x] = lx.eval('user.value %s ?' % x)
    # Single file format
    outpath = modo.dialogs.customFile('fileSave', 'Save File', ('text',), ('Text File',), ext=('rom',))
    with open(outpath, 'w') as f:
         json.dump(saveData, f)


def loadPreset():
    # Single file format
    outpath = modo.dialogs.customFile('fileOpen', 'Open File', ('text',), ('Text File',), ('*.rom',))
    with open(outpath, 'r') as f:
        saveData = json.load(f)
    i = len(saveData);
    for x in saveData:
        nameFlag = x
        lx.eval('user.value %s {%s}' % (nameFlag, saveData[x]))






def getRequestedRenderOutput():
    """ recupere la liste des element de lutilisateur avec toute les valeur utils
    active = est ce le calque est actif
    name = le nom du renderOutput
    suffixe = le nom du siffixe pour le layer en ours
    format = le format de l'image demander
    gamma = le gamma de l'image demander
    """
    global listName,listFormat
    try:
        renderOutputList = {}
        i = len(listName);
        lx.out(i)
        for x in xrange(i):
            n = listName[x]
            nameActive = "rom_"+n+"Flag"
            nameSuffixe = "rom_"+n+"Ext"
            nameFormat = "rom_"+n+"Format"
            nameGamma = "rom_"+n+"Gamma"
            nameAlias = "rom_"+n+"Alias"
            
            itemActive = lx.eval('user.value %s ?' % nameActive)
        
            renderOutputList[x] = {}
            renderOutputList[x]['active'] = itemActive
            renderOutputList[x]['nameActive'] = nameActive
            renderOutputList[x]['name'] = listRender[x]
            renderOutputList[x]['suffixe'] = lx.eval('user.value %s ?' % nameSuffixe)
            lFormat = lx.eval('user.value %s ?' % nameFormat)
            renderOutputList[x]['format'] = listFormat[int(lFormat)]
            lx.out(nameActive)
            renderOutputList[x]['gamma'] = lx.eval('user.value %s  ?' % nameGamma)
            renderOutputList[x]['alias'] = lx.eval('user.value %s  ?' % nameAlias)
        return renderOutputList
    
    except:
    #exc_log()
        lx.out("ERROR getRequestedRenderOutput")
        return None


def updateRenderOutput(listAllRO,existingRO,createFolder):
    """ Met a jour la list des render output
    cree, active ou desactive un render output et met a jour les information
    """
    global updateOnly       # on a selectionner des render output dans la scene et on veut les mettre a jour    
    global updateExistingOnly   # on fait la mise a jour seulement de ceux qui existe dans la scene
    global groupSelected    # un groupMask a ete selectionner et on va cree les nouveau dessous
    global osType
    global useRenderName    #Utilise le nom du render output
    global patternFile      #"[GROUPNAME]|[LAYERNAME]|[BASENAME]_[LAYERNAME]_[SUFFIXE]_"
    global RENDERCAMERA     # name of the actual render camera set in the scene
    
    separator="\\"
    if osType != "Windows":
        separator = "/"


    try:
        #on recuper la list des element existant
        existRO = []
        num = len(existingRO)
        if (num):
            for x in xrange(num):
                itemId = existingRO[x]
                lx.eval( "select.item {%s}" %itemId )
                existRO.append(lx.eval( "shader.setEffect ?" ))
                # si c'est la couche alpha on la laisse active et on efface son chemin au cas ou on enregistre pas la couche separer
                #if lx.eval( "shader.setEffect ?" ) == "shade.alpha" :
                #    lx.eval( "shader.setVisible %s %s" %(itemId,1) )
                #    lx.eval( r'item.channel renderOutput$filename ""' );
                #    lx.out(listAllRO)
                #    gammaFile = listAllRO[0]['gamma'] # 0 = (alpha)
                #    lx.eval( r'item.channel renderOutput$gamma %s' %gammaFile )
                    
            lx.out(existRO)
        

        #on update ou on cree les nouveau render pass
        targetPath = lx.eval('user.value rom_fileName ?')
        patternOutput = lx.eval('user.value rom_patternFile ?')
        motionRemap =  lx.eval('user.value rom_motionRemap ?')
        depthRemap = lx.eval('user.value rom_depthRemap ?')
        #nameFile = targetPath.rfind("\\")
        #lx.out(targetPath[0:nameFile])
        pathFile =""
        i = len(listAllRO)
        for x in xrange(i):
            itemRO = listAllRO[x]
            #si on met a jour on ne regarde pas si il est actif ou non
            if (itemRO['active'] == 1) or (updateOnly or updateExistingOnly):
                lx.out("YES")
                foundUpdate = False
                formatFile = itemRO['format']
                gammaFile = itemRO['gamma']
                aliasFile = itemRO['alias']
                # on verifie si il existe deja
                flag = 1
                
                if (num):
                    for xx in xrange(num):
                        lx.out("Check if exist:"+existRO[xx] +"-"+itemRO['name'])
                        if existRO[xx] == itemRO['name']:
                            #il existe deja pas besoin de le cree
                            lx.out("EXIST",itemId)
                            foundUpdate = True
                            flag = 0
                            itemId = existingRO[xx]
                            lx.eval( "select.item {%s}" %itemId )
                            lx.eval( r'item.channel renderOutput$gamma %s' %gammaFile )
                            lx.eval( r'item.channel renderOutput$antialias %s' %aliasFile )
                            lx.eval( r'item.tag string "ROMN:renderOutput" "%s"' %(targetPath+","+patternOutput))
                            #On ne le met pas a jour si il n'existe pas encore et qu'on ne force pas la mise a jour
                            testEmptyFilename = lx.eval( r'item.channel renderOutput$filename ?')
                            forceUpdate =  True #lx.eval('user.value rom_updateEmptyFilename ?')

                            lx.out("le cheminrecuperer est %s" %testEmptyFilename)
                            if targetPath !="" :
                                if testEmptyFilename != None or  forceUpdate:

                                    nameFile = targetPath.rfind(separator)
                                    baseFolder = targetPath[0:nameFile+1]
                                    BASENAME = targetPath[nameFile+1: len(targetPath)]
                                    RENDERNAME = format_filename(lx.eval('query sceneservice item.name ? %s' % itemId))
                                    TYPENAME= itemRO['suffixe']
                                    GROUP =""
                                    parentID = lx.eval('query sceneservice item.parent ? %s' % itemId)
                                    lx.out("PARENT_ID:"+parentID)
                                    if (parentID) and (lx.eval('query sceneservice item.type ? %s' % parentID) == "mask"):
                                        GROUP = lx.eval('query sceneservice item.name ? %s' % parentID)
                                        GROUP = GROUP.replace(" (Item)","")
                                        GROUP = GROUP.replace(" (Material)","")
                                        GROUP = format_filename(GROUP)
                                    else:
                                        GROUP ="" 
                                    

                                    nameFile = patternFile.replace("[GROUPNAME]",GROUP)
                                    nameFile = nameFile.replace("[CAMERA]",RENDERCAMERA)
                                    nameFile = nameFile.replace("[LAYERNAME]",RENDERNAME)
                                    nameFile = nameFile.replace("[BASENAME]",BASENAME)
                                    nameFile = nameFile.replace("[SUFFIXE]",TYPENAME)
                                    nameFile = nameFile.replace("|",separator)
                                    nameFile = baseFolder + nameFile
                                    nameFile = nameFile.replace(separator+separator+separator,separator)
                                    nameFile = nameFile.replace(separator+separator,separator)
                                    pathFile = os.path.dirname(nameFile)
                                    lx.out("LE FICHIER:"+nameFile)
                                    lx.eval( r'item.channel renderOutput$filename "%s"' %nameFile )
                                    lx.eval( r'item.channel renderOutput$format "%s"' %formatFile )

                                    #MakePath
                                    makes_path(pathFile,createFolder)
                            else:
                                lx.eval( r'item.channel renderOutput$filename ""'  )
                                lx.eval( r'item.channel renderOutput$format ""'  )
                                
                            lx.eval( "shader.setVisible %s %s" %(itemId,1) )
                            
                            # on demande si on veut mettre a jour les donner
                            
                            if itemRO['name'] == "occl.ambient" or itemRO['name'] == "depth" or itemRO['name'] == "motion" :
                                typeRender = itemRO['name']
                                typeRender.replace("occl.ambient","AO")
                                try:
                                    # set up the dialog
                                    lx.eval('dialog.setup yesNo')
                                    lx.eval('dialog.title {Do you want update ?}')
                                    lx.eval('dialog.msg {Do you want update %s values ?}' %typeRender)
                                    lx.eval('dialog.result ok')

                                    # Cree la structure des répértoire
                                    lx.eval('dialog.open')
                                    result = lx.eval("dialog.result ?")
                                    updateVal = True

                                except:
                                    # ON NE CREE PAS LA STRUCTURE AUTOMATIQUEMENT
                                    updateVal = False
                                
                                
                            # si c'est l'ambient on uptate les valeur ray et range
                            
                            if itemRO['name'] == "occl.ambient" and updateVal :
                                occRay = lx.eval('user.value rom_AORay ?')
                                occRange = lx.eval('user.value rom_AORange ?')


                                lx.eval( "item.channel renderOutput$occlRays %s" %occRay)
                                lx.eval( "item.channel renderOutput$occlRange %s" %occRange)
                            if itemRO['name'] == "depth" and updateVal:
                               
                                lx.eval("item.channel renderOutput$remap %s" %depthRemap)
                                if (depthRemap):
                                    depthRange = lx.eval('user.value rom_maximumDepth ?')
                                    lx.eval( "item.channel renderOutput$depthMax %s" %depthRange)
                                
                                    
                            if itemRO['name'] == "motion" and updateVal:
                               
                                lx.eval("item.channel renderOutput$remap %s" %motionRemap)
                                if (motionRemap):
                                    motionPixel = lx.eval('user.value rom_motionPixel ?')
                                    lx.eval( "item.channel renderOutput$motionMax %s" %motionPixel)
                        
                                
                
                # si il existe pas on le cree
                
                if (flag) and (not (updateOnly or updateExistingOnly)):
                    foundUpdate = True
                    lx.eval("select.itemType polyRender")
                    lx.eval("shader.create renderOutput")
                    lx.eval("shader.setEffect {%s}" %itemRO['name'] )
                    RenderSelect = lx.eval1('query sceneservice selection ? renderOutput')
                    
                    #est ce qu'on ajoute le prefix
                    addPrefix = ""
                    if (lx.eval('user.value rom_askPrefix ?') == True):
                        addPrefix = lx.eval('user.value rom_prefixName ?')
                    # est ce qu'on utilise le suffixe comme nom de layer
                    if (lx.eval('user.value rom_useSuffixe ?') == True):
                        NameRenderOutput = addPrefix + itemRO['suffixe']
                        
                    else:
                        NameRenderOutput = lx.eval('query sceneservice renderOutput.Name ? "%s"' %RenderSelect )
                        NameRenderOutput = addPrefix + NameRenderOutput
                        NameRenderOutput = NameRenderOutput.replace(" ", "_")
                        NameRenderOutput = NameRenderOutput.replace("_Output", "");
                        NameRenderOutput = NameRenderOutput.replace("_Shading", "");
                        NameRenderOutput = NameRenderOutput.replace("Shading_", "");
                        NameRenderOutput = NameRenderOutput.replace("(", "");
                        NameRenderOutput = NameRenderOutput.replace(")", "");
                    lx.eval('item.name "%s" renderOutput' %NameRenderOutput)
                    typeGroup = ""
               
                    if groupSelected:
                        groupSelectedName = lx.eval('query sceneservice item.name ? %s' % groupSelected)
                        groupSelectedName = groupSelectedName.replace(" (Item)","")
                        groupSelectedName = groupSelectedName.replace(" (Material)","")
                        groupSelectedName=format_filename(groupSelectedName)
                        typeGroup  = lx.eval('query sceneservice item.type ? %s' % groupSelected)
                        lx.eval("texture.parent %s -1" %groupSelected)
                    lx.eval( r'item.channel renderOutput$gamma %s' %gammaFile )
                    lx.eval( r'item.channel renderOutput$antialias %s' %aliasFile )
                    lx.eval( r'item.tag string "ROMN:renderOutput" "%s"' %(targetPath+","+patternOutput))
                    
                    # si c'est l'ambient on uptate les valeur ray et range
                    if itemRO['name'] == "occl.ambient" :
                        occRay = lx.eval('user.value rom_AORay ?')
                        occRange = lx.eval('user.value rom_AORange ?')
                        lx.eval( "item.channel renderOutput$occlRays %s" %occRay)
                        lx.eval( "item.channel renderOutput$occlRange %s" %occRange)
                    if itemRO['name'] == "depth" :
                        lx.eval("item.channel renderOutput$remap %s" %depthRemap)
                        if (depthRemap):
                            depthRange = lx.eval('user.value rom_maximumDepth ?')
                            lx.eval( "item.channel renderOutput$depthMax %s" %depthRange)            
                    if itemRO['name'] == "motion" : 
                        lx.eval("item.channel renderOutput$remap %s" %motionRemap)
                        if (motionRemap):
                            motionPixel = lx.eval('user.value rom_motionPixel ?')
                            lx.eval( "item.channel renderOutput$motionMax %s" %motionPixel)
                        

                    if targetPath !="" :


                        nameFile = targetPath.rfind(separator)
                        baseFolder = targetPath[0:nameFile+1]
                        BASENAME = targetPath[nameFile+1: len(targetPath)]
                        RENDERNAME = NameRenderOutput
                        TYPENAME= itemRO['suffixe']
                        GROUP =""
                        #on test si c'est bien un group et si on a choisi de creer un repertoir
                        if groupSelected and groupSelectedName and typeGroup=="mask":
                            GROUP = groupSelectedName
                            

                        nameFile = patternFile.replace("[GROUPNAME]",GROUP)
                        nameFile = nameFile.replace("[CAMERA]",RENDERCAMERA)
                        nameFile = nameFile.replace("[LAYERNAME]",RENDERNAME)
                        nameFile = nameFile.replace("[BASENAME]",BASENAME)
                        nameFile = nameFile.replace("[SUFFIXE]",TYPENAME)
                        nameFile = nameFile.replace("|",separator)
                        nameFile = baseFolder + nameFile
                        nameFile = nameFile.replace(separator+separator+separator,separator)
                        nameFile = nameFile.replace(separator+separator,separator)
                        pathFile = os.path.dirname(nameFile)
                        lx.out("LE FICHIER:"+nameFile)
                        lx.eval( r'item.channel renderOutput$filename "%s"' %nameFile )
                        lx.eval( r'item.channel renderOutput$format "%s"' %formatFile )                            

                        #MakePath
                        makes_path(pathFile,createFolder)
                    else:
                        lx.eval( r'item.channel renderOutput$filename ""'  )
                        lx.eval( r'item.channel renderOutput$format ""'  )

            #si il est pas actif mais il existe on l'efface
            else:
                if (num):
                    for xx in xrange(num):
                        lx.out("Check if need to delete:"+existRO[xx] +"-"+itemRO['name'])
                        if existRO[xx] == itemRO['name']:
                            lx.out("Delete %s" %itemRO['name'])
                            itemId = existingRO[xx]
                            lx.eval( "select.item {%s}" %itemId )
                            lx.eval( "texture.delete")
    
    except: 
        lx.out( "Command failed with updateRenderOutput ", sys.exc_info() )
        
        return None

        
def updateCameraName(listAllRO,existingRO,createFolder):
    """ Met a jour la list des render output
    cree, active ou desactive un render output et met a jour les information
    """
    global updateOnly       # on a selectionner des render output dans la scene et on veut les mettre a jour    
    global updateExistingOnly   # on fait la mise a jour seulement de ceux qui existe dans la scene
    global groupSelected    # un groupMask a ete selectionner et on va cree les nouveau dessous
    global osType
    global useRenderName    #Utilise le nom du render output
    global patternFile      #"[GROUPNAME]|[LAYERNAME]|[BASENAME]_[LAYERNAME]_[SUFFIXE]_"
    global RENDERCAMERA     # name of the actual render camera set in the scene
    
    separator="\\"
    if osType != "Windows":
        separator = "/"


    try:
        #on recuper la list des element existant
        existRO = []
        num = len(existingRO)
        if (num):
            for x in xrange(num):
                itemId = existingRO[x]
                lx.eval( "select.item {%s}" %itemId )
                existRO.append(lx.eval( "shader.setEffect ?" ))
                
        #on update ou on cree les nouveau render pass
        targetPath = lx.eval('user.value rom_fileName ?')
        patternOutput = lx.eval('user.value rom_patternFile ?')
        #nameFile = targetPath.rfind("\\")
        #lx.out(targetPath[0:nameFile])
        pathFile =""
        i = len(listAllRO)
        for x in xrange(i):
            itemRO = listAllRO[x]
                
            if (num):
                for xx in xrange(num):
                    lx.out("Check if exist:"+existRO[xx] +"-"+itemRO['name'])
                    if existRO[xx] == itemRO['name']:
                        formatFile = itemRO['format']
                        itemId = existingRO[xx]
                        lx.eval( "select.item {%s}" %itemId )
                        itemFileName = lx.eval( r'item.tag string "ROMN:renderOutput" ?')
                        if (itemFileName == ""):
                            continue
                        else:
                            line = itemFileName.split(",")
                            patternFile = line[1]
                            targetPath =line[0]
                            
                        nameFile = targetPath.rfind(separator)
                        baseFolder = targetPath[0:nameFile+1]
                        BASENAME = targetPath[nameFile+1: len(targetPath)]
                        RENDERNAME = format_filename(lx.eval('query sceneservice item.name ? %s' % itemId))
                        TYPENAME= itemRO['suffixe']
                        GROUP =""
                        parentID = lx.eval('query sceneservice item.parent ? %s' % itemId)
                        lx.out("PARENT_ID:"+parentID)
                        if (parentID) and (lx.eval('query sceneservice item.type ? %s' % parentID) == "mask"):
                            GROUP = lx.eval('query sceneservice item.name ? %s' % parentID)
                            GROUP = GROUP.replace(" (Item)","")
                            GROUP = GROUP.replace(" (Material)","")
                            GROUP = format_filename(GROUP)
                        else:
                            GROUP ="" 
                        
                        
                        nameFile = patternFile.replace("[GROUPNAME]",GROUP)
                        nameFile = nameFile.replace("[CAMERA]",RENDERCAMERA)
                        nameFile = nameFile.replace("[LAYERNAME]",RENDERNAME)
                        nameFile = nameFile.replace("[BASENAME]",BASENAME)
                        nameFile = nameFile.replace("[SUFFIXE]",TYPENAME)
                        nameFile = nameFile.replace("|",separator)
                        nameFile = baseFolder + nameFile
                        nameFile = nameFile.replace(separator+separator+separator,separator)
                        nameFile = nameFile.replace(separator+separator,separator)
                        pathFile = os.path.dirname(nameFile)
                        lx.out("LE FICHIER:"+nameFile)
                        lx.eval( r'item.channel renderOutput$filename "%s"' %nameFile )
                        lx.eval( r'item.channel renderOutput$format "%s"' %formatFile )

                        #MakePath
                        makes_path(pathFile,createFolder)
    
    except: 
        lx.out( "Command failed with Update Camera ", sys.exc_info() )
        
        return None


# create path 
def mkdir_path(path):
    if not os.access(path, os.F_OK):
         os.mkdirs(path)
    
def format_filename(s):
    """Take a string and return a valid filename constructed from the string.
    Uses a whitelist approach: any characters not present in valid_chars are
    removed. Also spaces are replaced with underscores.
    Note: this method may produce invalid filenames such as ``, `.` or `..`
    When I use this method I prepend a date string like '2009_01_15_19_46_32_'
    and append a file extension like '.txt', so I avoid the potential of using
    an invalid filename.
    """
    lx.out(s)
    #valid_chars = "-_.() %s%s" % (string.ascii_letters, string.digits)
    valid_chars = "-_.! 0123456789%s" % (string.ascii_letters)
    filename = ''.join(c for c in s if c in valid_chars)
    filename = filename.replace(' ','_') # I don't like spaces in filenames.
    return filename


def makes_path(pathFile,createFolder):
    if (createFolder ==1):
        lx.out("CREATE FOLDER: "+pathFile)
        try:
            os.makedirs(pathFile)                   
        except:
            lx.out("Alredy exist :"+pathFile)



def getRenderOuptut():
    """ Get a list of item IDs of type 'type'
        Returns a list of item IDs or None if there are no items of the specified
        tyep or if there's an error. Error printed is to Event log.
        type - the type of item to be returned (mesh, camera etc)
    """
    global updateOnly 
    global groupSelected
    global updateExistingOnly
    updateOnly = False
    try:
        """
        #Si on fait seulement la mise a jour on recuoere tous les render existant ou ceux que lon a selectionner
        if (updateExistingOnly):
            RenderOutputsSelected = lx.evalN('query sceneservice selection ? renderOutput')
            RenderOutputs = []

            if RenderOutputsSelected:
                for layer in RenderOutputsSelected:
                    lx.out("UPDADE ONLY ",layer)
                    RenderOutputs.append(lx.eval('query sceneservice item.ID ? %s' % layer))
                return RenderOutputs
            # si on a rien selectionner on met a jour tous les éléments
            else:
            
                itemlist = []
                numitems = lx.eval('!!query sceneservice renderOutput.N ?')
                if numitems == 0:
                    return None
                else:
                    for x in xrange(numitems):
                    #typeLayer = lx.eval( "query sceneservice item.type ? %s" %(x) )
                    #if( typeLayer == "renderOutput" ) :
                        idRender = lx.eval('query sceneservice renderOutput.ID ? %s' % (x))
                        itemlist.append(idRender)
                    return itemlist
"""


        #Est ce qu'on a selectionner des render Ouput
        RenderOutputsSelected = lx.evalN('query sceneservice selection ? renderOutput')
        RenderOutputs = []

        if RenderOutputsSelected:
            for layer in RenderOutputsSelected:
                lx.out(layer)
                lx.out("le parent:"+lx.eval('query sceneservice item.parent ? %s' % layer))
                RenderOutputs.append(lx.eval('query sceneservice item.ID ? %s' % layer))
            updateOnly = True;
            return RenderOutputs

        #Est ce qu'une selection de group exist ?
        selectionMask = lx.evalN('query sceneservice selection ? mask')
        masks = []

        if selectionMask:
            layer = selectionMask[0]
            lx.out(layer)
            groupSelected = layer #lx.eval('query sceneservice item.name ? %s' % layer)
            nameGroup = lx.eval('query sceneservice item.name ? %s' % layer) +"_"
            nameGroup = nameGroup.replace(" (Material)","")
            nameGroup = nameGroup.replace(" (Item)","")

            lx.eval('user.value rom_prefixName %s' %(nameGroup))
            #Has child output           
            childRender = lx.evalN('query sceneservice item.children ? %s' % layer)
            lx.out(childRender)
            return childRender


        #Est ce qu'une selection de Render principal ?
        selectionMask = lx.evalN('query sceneservice selection ? polyRender')
        masks = []

        if selectionMask:
            layer = selectionMask[0]
            lx.out(layer)
            groupSelected = layer #lx.eval('query sceneservice item.name ? %s' % layer)
            #Has child output           
            childRender = lx.evalN('query sceneservice item.children ? %s' % layer)
            lx.out(childRender)
            return childRender


        # On peut cree seulement en selectionnant le poly render, un render output ou un mask
        itemlist = []
        numitems = lx.eval('!!query sceneservice renderOutput.N ?')
        if numitems == 0:
            return None
        else:
            for x in xrange(numitems):
        #typeLayer = lx.eval( "query sceneservice item.type ? %s" %(x) )
        #if( typeLayer == "renderOutput" ) :
                    itemlist.append(lx.eval('query sceneservice renderOutput.ID ? %s' % (x)))

            return itemlist
    except:
        #exc_log()
        lx.out("ERROR getRenderOuptut")
        return None




def restoreSelection(listSelections):

    try:
        lx.out(listSelections)
        first=True
        for x in listSelections:
            lx.out("select :"+x)
            if first:
                lx.eval( "select.item {%s} set" %x )
            else:
                lx.eval( "select.item {%s} add" %x )
            first= False
    
    except:
        #exc_log()
        lx.out("ERROR restoreSelection")
        return None


def setVisibilityItem(listItem,visibilty = 0):
    """ rend visible ou invilible la liste des elements
    """
    try:
         for x in listItem:
            lx.eval( "shader.setVisible %s %s" %(x,visibilty) )
    
    except:
        #exc_log()
        lx.out("ERROR VISIBILITY")
        return None


# END FUNTION -----------------------------------------------


# MAIN PROGRAMME --------------------------------------------

tracing = lx.trace( True )
args = lx.args()

arg = args[0] 
#arg1 = args[1] 

#arg = lx.arg()

groupSelected = ""
lx.out("GS",groupSelected)
updateOnly = False
updateExistingOnly = False
osType =  platform.system()
lx.out ("TYPE OS: "+ osType)
RENDERCAMERA = lx.eval('render.camera ?')
if RENDERCAMERA != None:
    RENDERCAMERA = lx.eval('query sceneservice item.name ? "%s"' %RENDERCAMERA)
else:
    RENDERCAMERA =""
#init variable render pass

listDescription =   ["Color","Alpha","Depth","Motion","Driver A","Driver B","Driver C","Driver D","dpdu Vector","dpdv Vector","Geometry Normal","Object Coordinates","Segment ID","Shading Incidence","Shading Normal","Surface ID","UV Coordinates","World Coordinates","Ambient Occlusion","IC Positions","IC Values","Illumination Direct","Illumination Indirect","Illumination Total","Illumination Unshadowed","Reflection Occlusion","Shadow Density","Diffuse Amount","Diffuse Coefficient","Diffuse Color","Diffuse Energy Concervation","Diffuse Roughness","Relflection Coefficient","Roughness","Specular Coefficient","Subsurface Amount","Subsurface Color","Transparency Amount","Transparency Color","Particle Age","Particle ID","Particle Velocity","Diffuse Direct","Diffuse Indirect","Diffuse Total","Diffuse Unshadowed","Luminous Shading","Reflection Shading","Shaded AA Samples","Specular Shading","Transparency Shading","SubSurface Shading","Volume Depth","Volume Opacity","Volume Scattering"]

listRender =["shade.color","shade.alpha","depth","motion","driver.a","driver.b","driver.c","driver.d","geo.dpdu","geo.dpdv","geo.normal","geo.object","geo.segment","shade.incidence","shade.normal","geo.surface","geo.uv","geo.world","occl.ambient","ic.position","ic.value","shade.illumDir","shade.illumInd","shade.illum","shade.illumUns","occl.reflect","shadow","mat.diffAmt","mat.diffuse","mat.diffCol","mat.diffEng","mat.diffRough","mat.reflection","mat.rough","mat.specular","mat.subsAmt","mat.subsCol","mat.tranAmt","mat.tranCol","particle.age","particle.id","particle.vel","shade.diffDir","shade.diffInd","shade.diffuse","shade.diffUns","shade.luminosity","shade.reflection","shade.samples","shade.specular","shade.transparency","shade.subsurface","volume.depth","volume.opacity","volume.scattering"]
listName =   ["color","alpha","depth","motion","DriverA","DriverB","DriverC","DriverD","dpdu","dpdv","geoNormal","geoObject","segment","shadeIncidence","normal","ID","UV","geoWorld","AO","icPosition","icValue","illumDir","illumInd","illum","illumUns","refAO","shadow","matDiffAmt","diffMask","matDiffCol","matDiffEng","matDiffRough","refMask","matRough","specMask","matSubsAmt","matSubsCol","matTranAmt","matTranCol","particleAge","particleId","particleVel","diffDir","diffInd","diffuse","diffUns","luminosity","reflection","shadeSamples","spec","trans","subsurface","volumeDepth","volumeOpacity","volumeScattering"]
listFormat= "$FLEX","$Targa","BMP","HDR","PNG","PNG16","JP2","JP216","JP216Lossless","JPG","PSD","SGI","TIF","TIF16","TIF16BIG","openexr","openexr_32","openexr","openexr_tiled16","openexr_tiled32"


# END INIT -------------------------------------------------------------------------------

#PayPal
if arg == 'about':
    lx.eval('openURL "http://www.onestepmda.ch/modo/"')


if arg == 'init':
    lx.out("INIT RENDER OUTPUT MANAGER")

if arg == 'loadPreset':
    lx.out("LOADING PRESET")
    loadPreset()

if arg == 'savePreset':
    lx.out("SAVING PRESET")
    savePreset()

#recupere la liste des layer actif "renderOutput"
if arg == 'getRender':

    #On sauve la selection 
    active_scene = lx.eval("query sceneservice scene.name ? current")
    OSF_saveSelection = lx.evalN("query sceneservice selection ? all")

    #on eteint tous les flag
    numList = len(listName)
    i=0
    while ( i < numList):
        nameFlag = "rom_"+listName[i]+"Flag";
        lx.eval('user.value %s {}' % nameFlag)
        i = i+ 1

        #on recupere la liste de tous les layer actif
    existingRenderOutput = getRenderOuptut()
    #on regarde chaque layer si il existe on active le boutton correspondant
    num = len(existingRenderOutput)
    first = True
    if (num):
        for x in xrange(num):
            itemId = existingRenderOutput[x]
            lx.eval( "select.item {%s}" %itemId )
            parentName = lx.eval('query sceneservice item.parent ? %s' % itemId)
            parentName = lx.eval('query sceneservice item.name ? %s' % parentName)
            lx.out("Nom Du groupe Parent:"+parentName)
            effect = lx.eval( "shader.setEffect ?" )
            # on recherche la couche correspondante
            numLayer = len(listRender)
            for xx in xrange(numLayer):
                if effect == listRender[xx]:
                    #Grab On/off Layer
                    activeLayer = lx.eval( r'item.channel textureLayer$enable ?')
                    #Grab the gamma
                    gammaFile = lx.eval( 'item.channel renderOutput$gamma ?')
                    gammaName = "rom_"+listName[xx]+"Gamma"
                    lx.eval( 'user.value %s {%s}' %(gammaName,gammaFile))

                    #Grab Name
                    if first :
                        itemFileName = lx.eval( r'item.tag string "ROMN:renderOutput" ?')
                        if (itemFileName == ""):
                            itemFileName = lx.eval( r'item.channel renderOutput$filename ?' )
                        else:
                            line = itemFileName.split(",")
                            lx.eval( r'user.value rom_patternFile "%s"' %line[1])
                            lx.eval( r'user.value rom_fileName "%s"' %line[0]) 
                            first=False
                    
                    if (itemFileName != None) and ( first):
                        #si on avait cree des sub directory on l'enleve
                        itemFileName = itemFileName.replace("\\"+listName[xx]+"\\", "\\");
                        itemFileName = itemFileName.replace("_"+listName[xx], "");
                        #On Enleve le nom du group parent
                        itemFileName = itemFileName.replace("\\"+parentName+"\\", "\\");
                        if osType != "Windows":
                            #si on avait cree des sub directory on l'enleve
                            itemFileName = itemFileName.replace("/"+listName[xx]+"/", "/");
                            itemFileName = itemFileName.replace("_"+listName[xx], "");
                            #On Enleve le nom du group parent
                            itemFileName = itemFileName.replace("/"+parentName+"/", "/");
                        lx.eval( r'user.value rom_fileName "%s"' %itemFileName) 
                        first=False             
                                        
                    # si c'est le layer depth ou occlusion, ou color on recupere les variable de base
                    if effect == "occl.ambient":
                        occRay = lx.eval('item.channel renderOutput$occlRays ?')
                        occRange = lx.eval('item.channel renderOutput$occlRange ?')
                        lx.eval( "user.value rom_AORay %s" %occRay)
                        lx.eval( "user.value rom_AORange %s" %occRange) 
                    if effect == "depth":
                        depthRange = lx.eval('item.channel renderOutput$depthMax ?')
                        lx.eval( "user.value rom_maximumDepth %s" %depthRange)
                    if effect == "motion" :
                        motionPixel = lx.eval('item.channel renderOutput$motionMax ?')
                        lx.eval( "user.value rom_motionPixel %s" %motionPixel)

                    """ 
                    #Si c'est un alpha on l'active seulement si il y a un fichier definit
                    if effect == "shade.alpha":
                        fileName = lx.eval( r'item.channel renderOutput$filename ?' )
                        if fileName == "":
                            activeLayer = 0
                    """
                    nameFlag = "rom_"+listName[xx]+"Flag"
                    lx.eval('user.value %s {%s}' %(nameFlag,activeLayer))
                    lx.out(nameFlag)
    restoreSelection(OSF_saveSelection)
    



# NOM DE l'IMAGE DE BASE POUR LE RENDU
if arg == 'targetFile':
    try:
        # Choose the base name for image render pass
        lx.eval('dialog.setup fileSave')
        lx.eval('dialog.title {Choose target destination and basename}')
        #lx.eval('dialog.result "c:"')
        # Add two file formats, xml and text
        lx.eval( 'dialog.fileTypeCustom all "Base Name, Ex: CAM-001" "*.*" all' );
    
        # Open the dialog and see which button was pressed
        lx.eval('dialog.open')
        result = lx.eval("dialog.result ?")
        ext = lx.eval( "dialog.fileSaveFormat ? extension" );
        lx.out("Yes:",ext,result.replace("."+ext,""))
        lx.eval('user.value rom_fileName {%s}' % result.replace("."+ext,""))
        
    
    
    except:
        lx.out("No")
    
# MISE A JOUR DES RENDER OUPTUT EXISTANT
if arg == 'mainUpdate':
    arg = "main"
    updateExistingOnly = True

# MISE A JOUR DES RENDER OUPTUT
if arg == 'main':
    
    lx.eval('user.def rom_prefixName username {Prefix}')
    lx.eval('user.def rom_prefixName dialogname {Enter Prefix To Add Render Output Name}')
    #on recupere l'info si on veut ajouter un prefixe au nom de rendu
    askPrefixName = lx.eval('user.value rom_askPrefix ?')
    # on efface l'ancien prefix on le recupre seulement du nom du group selectionner sionon il est vide par default
    lx.eval('user.value rom_prefixName ""' )
    #On sauve la selection 
    active_scene = lx.eval("query sceneservice scene.name ? current")
    OSF_saveSelection = lx.evalN("query sceneservice selection ? all")

    #On verifie si on a bien selectionner un element pour cree
    if updateExistingOnly != True :
        if len(OSF_saveSelection) == 0:
            lx.eval("select.itemType polyRender")
            OSF_saveSelection = lx.evalN("query sceneservice selection ? all")
            #OSF_saveSelection[0] = lx.eval("query sceneservice item.id ?")
            #lx.out("Please select an group, Render Output or render to create/Update an render Output")
            #sys.exit(0)

    #on verifie si on veut les repertoire separer
    createFolder = 0 # de base on ne cree pas les repertoire
    targetPath = lx.eval('user.value rom_fileName ?')
    patternFile  = lx.eval('user.value rom_patternFile ?')
    if targetPath!="":

        try:
            # set up the dialog
            lx.eval('dialog.setup yesNo')
            lx.eval('dialog.title {Creating folder}')
            lx.eval('dialog.msg {Do you want to create folder structure if needed ?\n(Base folder must be exist)}')
            lx.eval('dialog.result ok')

            # Cree la structure des répértoire
            lx.eval('dialog.open')
            result = lx.eval("dialog.result ?")
            createFolder = 1

        except:
            # ON NE CREE PAS LA STRUCTURE AUTOMATIQUEMENT
            createFolder = 0

    #on cree les layer pass render
        

        
    #on recupere la liste de tous les layer actif
    existingRenderOutput = getRenderOuptut()
    
    #On test si on veux ajouter un prefixe seulement quand on cree
    if updateExistingOnly != True :
        if askPrefixName:
            try:
                lx.eval('user.value rom_prefixName')
            except:
                lx.eval('user.value rom_prefixName ""' )
    #On les rend invisible seulement si on ne fait pas la mise a jour
    #if not (updateOnly or updateExistingOnly):
    #   setVisibilityItem(existingRenderOutput,0)
    #On cree ou on active les layer demander par l'utilisateur
    listRenderOutputs = getRequestedRenderOutput()
    #on met a jour la liste des renderOutput
    updateRenderOutput(listRenderOutputs,existingRenderOutput,createFolder)
    lx.out(existingRenderOutput)
    restoreSelection(OSF_saveSelection)

    
# MISE A JOUR DES RENDER OUPTUT
if arg == 'updateCamera':
    lx.out("UPDATE CAMERA NAME")

    #On sauve la selection 
    active_scene = lx.eval("query sceneservice scene.name ? current")
    OSF_saveSelection = lx.evalN("query sceneservice selection ? all")

    #on verifie si on veut les repertoire separer
    createFolder = 0 # de base on ne cree pas les repertoire
    try:
        # set up the dialog
        lx.eval('dialog.setup yesNo')
        lx.eval('dialog.title {Creating folder}')
        lx.eval('dialog.msg {Do you want to create folder structure if needed ?\n(Base folder must be exist)}')
        lx.eval('dialog.result ok')

        # Cree la structure des répértoire
        lx.eval('dialog.open')
        result = lx.eval("dialog.result ?")
        createFolder = 1

    except:
        # ON NE CREE PAS LA STRUCTURE AUTOMATIQUEMENT
        createFolder = 0


    
    #on recupere la liste de tous les layer
    existingRenderOutput = []
    numitems = lx.eval('!!query sceneservice renderOutput.N ?')
    if numitems == 0:
        sys.exit(0)
    else:
        for x in xrange(numitems):
                existingRenderOutput.append(lx.eval('query sceneservice renderOutput.ID ? %s' % (x)))

    #On recupere les info des preferences
    listRenderOutputs = getRequestedRenderOutput()
    #on met a jour la liste des renderOutput
    updateCameraName(listRenderOutputs,existingRenderOutput,createFolder)
    lx.out(existingRenderOutput)
    restoreSelection(OSF_saveSelection)

# MISE A JOUR DES PREFERENCES
if arg == 'updatePrefs':
    lx.out("UPDATE ALL PREFERENCE")                
    arg1 = args[1] 
    nameValue = "rom_all"+arg1
    getValue = lx.eval("user.value %s ?" %nameValue)
    
    listRenderOutputs = getRequestedRenderOutput()
    for item in listName:
        setName = "rom_"+item+arg1 
        lx.eval("user.value %s %s" %(setName,getValue))
    
    