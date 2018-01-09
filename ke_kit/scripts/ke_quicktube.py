# python
# QuickTube v1.4 for Modo - Kjell Emanuelsson 2018 - A quickpipe (by seneca menard) variant with arguments built in that I used a bunch of macros for
# Tested on v11.1v1
# Contact: sendtonulldevice@gmail.com
#
# Update 1.4 - Kit version. Closes loops (edges).
# Update 1.3 - Fixed some more bugs (tested on 11.2)
# Update 1.2 - Fixed a few bugs
# Update 1.1 - Offset now compensates for low side count subdivision tubes = tighter fit! (might be a micron off, but not even a problem! (thx Auvinen & Ålind! )
#
# Makes pipes along element selections (using tube tool): 
#					VERTS (in selected order), EDGES (in any order - crossing loops will cause random directions), and POLYGON faces (makes a border edge selection) 
#					(at least 2 verts, 1 edge or 1 face. vert mode only makes one tube.)
#
#					Edge loops ,if continous, are CLOSED unless using the scale argument, leaving uncontinous loops OPEN. 
#					By default it uses the values from the TubeTool for sides,segments and radius.
#
#					Symmetry is turned off during operation and turned on again if on.
# 					Workplane placement will be retained after operation (though axis -display- is unlocked)	
# 
# Installation: Place .py file in "scripts" folder for Modo (For PC usually C:\Users\ *insert name here* \AppData\Roaming\Luxology\Scripts )
# 				optional pie form example: Place .cfg file in "configs" folder for Modo (For PC usually C:\Users\ *insert name here* \AppData\Roaming\Luxology\Configs )
#
# Usage: @ke_quicktube.py 
# Usage with arguments example: @ke_quicktube.py offset psubd scale 
#
# Argument rules: Argument order is not important EXCEPT for numbers: 
#				  Numbers MUST be in this order: 
#				  "offset" number must be first in order (if used) and then the "user" values (in the order: sides, segments, radius)
#
# Arguments:	(no argument)	:	makes tubes on selections in face poly mode but also closes tubes that are continous loops (no caps, ever, sorry)
#				offset			:	offsets the tube by tube tool radius - makes the tube be placed ON the edge or vert (instead of in center)
#									note: based on radius = low side count will make offset gap (when subd'd) more sides = better offset	
#				offset 0.01 	:	(0.01 is an example value) offset with value overrides the tube tool radius with a specified amount 
#				select			:	selects the resulting tube poly mesh(es) 
#				subd			: 	set subdivsion mode to tube(s)
#				psubd			:	set catmull-clark ('pixar') subdivision mode to tube(s)
#				automeshtype	:	checks the connected mesh for poly type and apples the same : face, subd or psubd (a bit hacky, works so far...)
#				user 4 1 0.01	:	(example values) specifies SIDES, SEGMENTS and RADIUS overrides. 
#									It will check the tube tool and leave those values the same, enabling you to switch from preset tube hotkeys/pie to tube tool defined tubes)
#									*ALL three values must always be entered when using the 'user' argument.*
#									You can combine with offset (and also with offset value for additional offset distance.)					
#				scale			:	Allows you to immediately scale the tubes after operation (Selects tube(s) rings and sets appropriate AC) 
#									*Will not close tubes* (tip: if you abs need closed: skip 'scale'& select ring edge(s) & use senecas pipescale script after instead...)
#									The mesh can still also be selected in polygon mode with 'select' argument.				
#
# Recommended use: set up your desired use cases in a pie menu (or whatever form) and also hotkey the most frequently used one(s)
#				   (example pie CFG should be included)	
import math
uArgs = lx.args() 
# default vars
meshType = "face"
offset = False
offVal = 0
compoffVal = 0
argVal = []
autoClose = False
autoSelect = False
select = False
scale = False
edgemode = False
vertmode = False
automeshtype = False
user = False
usrval = False
rowList = []
vertRow = []
verbose = False
onTop = False

if verbose : 
	print "-------------" # Eventlog separator

	
# --------------------------------------------------------------------
# UserValue checks
# --------------------------------------------------------------------


if lx.eval('user.value ke_quicktube.mode ?') != "TubeTool" :
	user, usrval = True, True
	
	
# mode independent values 
usrval_offset = lx.eval('user.value ke_quicktube.offset ?')	

if usrval_offset != "None" :
	if usrval_offset == "onTop" : 
		offset = True
		onTop = True
	# elif usrval_offset == "Center" : offset = False
	elif usrval_offset == "Custom" : 
		offset = True
		offVal = lx.eval('user.value ke_quicktube.offsetVal ?')	
	else : pass
	
usrval_sel = lx.eval('user.value ke_quicktube.sel ?')		
	
if usrval_sel == "Select" : select = True
elif usrval_sel == "Scaling" : scale = True		
else : pass	


# User mode specific values	
if usrval :

	usrval_mesh = lx.eval('user.value ke_quicktube.mesh ?')			

	# if usrval_mesh == "face" : pass
	if usrval_mesh == "subd" : meshType = "subpatch"
	elif usrval_mesh == "psubd" : meshType = "psubdiv"
	elif usrval_mesh == "auto" : automeshtype = True
	else : pass

	seg = lx.eval('user.value ke_quicktube.seg ?')			
	side = lx.eval('user.value ke_quicktube.sides ?')			
	rad = lx.eval('user.value ke_quicktube.rad ?')	
	
	if onTop :
		offVal = rad
		compoffVal = rad * math.cos(math.pi / side)
	else :	
		compoffVal = offVal * math.cos(math.pi / side)
	
	if verbose :
		print "Mesh:",usrval_mesh,"  offset:",usrval_offset,"  selection:",usrval_sel
		print "Segments:", seg, "  Sides:", side, "  Radius:", rad
	
elif len(uArgs) != 0:

	# Checking manual user overrides here
	for i in range(len(uArgs)):
		if "psubd" in uArgs:	
			meshType = "psubdiv"
			autoSelect = True
		if "subd" in uArgs:	
			meshType = "subpatch"
			autoSelect = True
		if "scale" in uArgs:	
			scale = True	
			autoSelect = True
		if "select" in uArgs:	
			autoSelect = True	
			select = True	
		if "offset" in uArgs:	
			offset = True
		if "user" in uArgs:	
			user = True
		if "automeshtype" in uArgs:	
			automeshtype = True
			autoSelect = True	
		else: pass

	for nr in uArgs:
		try:
			argVal.append(float(nr))
		except ValueError:
			continue	
			
floatCount = len(argVal)		

autoSelect = True # Makes sure mesh not converts to usr type
	

def fn_ogVals():
	global ograd, ogseg, ogside, ogtwist
	lx.eval('tool.set prim.tube on')
	ograd = lx.eval('tool.attr prim.tube radius ?')
	ogseg = lx.eval('tool.attr prim.tube segments ?')
	ogside = lx.eval('tool.attr prim.tube sides ?')	
	lx.eval('tool.set prim.tube off')
		
def fn_sortRows():
	while (len(loopEdges)-1) > 0 :
		vertRow = [loopEdges[0][0], loopEdges[0][1]]
		loopEdges.pop(0)
		rowList.append(vertRow)	
		
		for n in xrange(0, len(edges)):
			i = 0 
			for edgeverts in loopEdges:
				if vertRow[0] == edgeverts[0]:
					vertRow.insert(0, edgeverts[1] )
					loopEdges.pop(i)
					break
				elif vertRow[0] == edgeverts[1]:
					vertRow.insert(0, edgeverts[0] )		
					loopEdges.pop(i)
					break
				elif vertRow[-1] == edgeverts[0]:
					vertRow.append(edgeverts[1] )		
					loopEdges.pop(i)
					break
				elif vertRow[-1] == edgeverts[1]:
					vertRow.append(edgeverts[0] )		
					loopEdges.pop(i)	
					break
				else:
					i = i + 1
			
def fn_pipeTool():
	global offVal
	if offset == True and meshType != "face":
		offVal = compoffVal
		
	for i in rowList:
		lx.eval('tool.set prim.tube on')
		lx.eval('tool.setAttr prim.tube mode add')
		if user == True:
			lx.eval('tool.setAttr prim.tube sides %s' %side)
			lx.eval('tool.setAttr prim.tube segments %s' %seg)
			lx.eval('tool.setAttr prim.tube radius %s' %rad)
			
		# Close tube if loop 
		if i[0] == i[-1]:
			lx.eval('tool.attr prim.tube closed true')
			# if scale == False:
			i.pop(-1)
		else:
			# if vertmode != True:  # Only closing if loop now
			lx.eval('tool.attr prim.tube closed false')
			lx.eval('tool.attr prim.tube caps false')
					
		# if scale == True:
			# lx.eval('tool.attr prim.tube closed false')
			# lx.eval('tool.attr prim.tube caps false')
			
		tubeSegNr = 1
		for v in i:
			pos = lx.eval('query layerservice vert.pos ? %s' %v)
			if offset == True:
				vN = lx.eval('query layerservice vert.normal ? %s' %v)
				pos = pos[0] + (vN[0] * offVal), pos[1] + (vN[1] * offVal), pos[2] + (vN[2] * offVal)
			lx.eval('tool.setAttr prim.tube number %s' %tubeSegNr)
			tubeSegNr = tubeSegNr + 1
			lx.eval('tool.setAttr prim.tube ptX %s' %pos[0] )
			lx.eval('tool.setAttr prim.tube ptY %s' %pos[1] )
			lx.eval('tool.setAttr prim.tube ptZ %s' %pos[2] )
				
		lx.eval('tool.doApply')
		lx.eval('tool.set prim.tube off')

def fn_errorMsg():
	lx.eval('dialog.setup error')
	lx.eval('dialog.title {Selection Error! (Most likely)}')
	lx.eval('dialog.msg {Select at least 2 verts, 1 edge or 1 face.}')
	lx.eval('dialog.open')
	sys.exit()
	
def fn_errorValMsg():
	lx.eval('dialog.setup error')
	lx.eval('dialog.title {Argument Value error')
	lx.eval('dialog.msg {Value argument(s) does not fit parameters}')
	lx.eval('dialog.open')
	sys.exit()	

def fn_polySel():
	if automeshtype == True:
		global meshType
		# hacky check for mesh type (subd,psub or face) 
		lx.eval('select.expand')	
		lx.eval('select.convert polygon')
		lx.eval('select.drop polygon')

		lx.eval('select.polygon add type subdiv')
		if lx.eval('query layerservice polys ? selected'):
			meshType = "subpatch"
			lx.eval('select.drop polygon')
			
		if meshType != "subpatch":	
			lx.eval('select.polygon add type psubdiv')
			if lx.eval('query layerservice polys ? selected'):
				meshType = "psubdiv"
				lx.eval('select.drop polygon')
				
	lx.eval('select.type polygon')
	lx.eval('select.all')
		
		
# Check Values
if not usrval:
	if offset == True and user == False:
		if floatCount == 1:
			offVal = argVal[0]
		elif floatCount == 0:
			lx.eval('tool.set prim.tube on')
			offVal = lx.eval('tool.attr prim.tube radius ?')	
			sidecount = lx.eval('tool.attr prim.tube sides ?')	
			compoffVal = offVal * math.cos(math.pi / sidecount)
			lx.eval('tool.set prim.tube off')
		elif floatCount > 1:
			fn_errorValMsg()
				
	if offset == True and user == True:
		if floatCount == 3:
			side = int(argVal[0])
			seg = int(argVal[1])
			rad = argVal[2]
			offVal = rad
			compoffVal = rad * math.cos(math.pi / side)
			fn_ogVals()
		elif floatCount == 4:
			side = int(argVal[1])
			seg = int(argVal[2])
			rad = argVal[3]
			# rad = rad * math.cos(math.pi / side)
			offVal = argVal[0] + argVal[3]
			fn_ogVals()
		elif floatCount > 4 or floatCount == 2 or floatCount == 1:
			fn_errorValMsg()

	if offset == False and user == True:
		if floatCount != 3:
			fn_errorValMsg()
		else:	
			side = int(argVal[0])
			seg = int(argVal[1])
			rad = argVal[2]	
			fn_ogVals()

else : 
	# if offVal != 0 :
		# compoffVal = offVal * math.cos(math.pi / side)
	
	fn_ogVals()
		
		
# check symmetry & WP		
symmetry = lx.eval('select.symmetryState ?')
if symmetry != "none":
	lx.eval('select.symmetryState none')
	
# lx.setOption("queryAnglesAs", "degrees")
WPcenX = lx.eval("workplane.edit ? 0 0 0 0 0")
WPcenY = lx.eval("workplane.edit 0 ? 0 0 0 0")
WPcenZ = lx.eval("workplane.edit 0 0 ? 0 0 0")
WProtX = lx.eval("workplane.edit 0 0 0 ? 0 0")
WProtY = lx.eval("workplane.edit 0 0 0 0 ? 0")
WProtZ = lx.eval("workplane.edit 0 0 0 0 0 ?")
lx.eval('workPlane.reset')		
		

# Set mode and run ops		
selmode = lx.eval('query layerservice selmode ?')

if selmode == "vertex":
	seltest = lx.eval1('query layerservice vert.N ? selected')
	if seltest <= 1:
		fn_errorMsg()
	else:
		lx.eval('select.editSet ke_tempSelSet add')
		vertmode = True

elif selmode == "polygon":	
	seltest = lx.eval1('query layerservice poly.N ? selected')
	if seltest < 1:
		fn_errorMsg()
	else:
		lx.eval('@AddBoundary.py')
		lx.eval('select.editSet ke_tempSelSet add')
		edgemode = True
		edgeSel = lx.evalN('query layerservice edges ? selected')
		
elif selmode == "edge":
	edgeSel = lx.evalN('query layerservice edges ? selected')
	if len(edgeSel) < 1:
		fn_errorMsg()
	lx.eval('select.editSet ke_tempSelSet add')	
	if len(edgeSel)	== 1:
		vertmode = True
		lx.eval('select.convert vertex')
	else: 
		edgemode = True				

		
		
if edgemode == True:
	if autoSelect == True:
		fn_polySel()
		lx.eval('select.type edge')
		
	edges = []
	for i in edgeSel:
		indices = i[1:-1]
		indices = indices.split(',')
		edges.append(indices)

	loopEdges = list(edges)	
	fn_sortRows()
	fn_pipeTool()	

if vertmode == True:
	if autoSelect == True:
		lx.eval('select.convert edge')
		fn_polySel()
		lx.eval('select.type vertex')

	verts = lx.eval('query layerservice verts ? selected')
	rowList.append(verts)
	fn_pipeTool()	

# selection prep	
if autoSelect == True:
	lx.eval('select.type polygon')
	lx.eval('select.invert')

# set mesh type
if meshType != "face":
	lx.eval('poly.convert face %s true' %meshType)	
	if select == False and scale == False:
		lx.eval('select.drop polygon')
	if select == False and automeshtype == True and scale == False:
		lx.eval('select.drop polygon')
				
# restore symmetry
if symmetry != "none":
	lx.eval('select.symmetryState %s' %symmetry)
# restore WP
lx.eval('workPlane.edit %s %s %s %s %s %s' %(WPcenX, WPcenY, WPcenZ, WProtX, WProtY, WProtZ) )
# restore tube tool vals
if user == True:
	lx.eval('tool.set prim.tube on')
	lx.eval('tool.setAttr prim.tube sides %s' %ogside)
	lx.eval('tool.setAttr prim.tube segments %s' %ogseg)
	lx.eval('tool.setAttr prim.tube radius %s' %ograd)
	lx.eval('tool.set prim.tube off')

# activate scale
if scale == True:
	lx.eval('vertMap.deleteByName EPCK ke_tempSelSet')		
	lx.eval('select.type polygon')
	lx.eval('select.convert edge')
	lx.eval('select.loop next')
	# lx.eval('@AddBoundary.py')
	lx.eval('select.ring')
	if select == False:
		lx.eval('select.type polygon')
		lx.eval('select.drop polygon')
		lx.eval('select.type edge')
	lx.eval('tool.set center.local on')
	lx.eval('tool.set axis.auto on')
	lx.eval('tool.set xfrm.scale on')
# set selections
elif scale == False:
	lx.eval('select.type edge')
	lx.eval('select.drop edge')
	if edgemode == True:
		lx.eval('select.useSet ke_tempSelSet select')
		lx.eval('vertMap.deleteByName EPCK ke_tempSelSet')
	if select == True:
		lx.eval('select.type polygon')
elif edgemode == True:
	lx.eval('vertMap.deleteByName EPCK ke_tempSelSet')
#eof