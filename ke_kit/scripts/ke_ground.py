#python#

# ke_ground v1.0 - Kjell Emanuelsson 2017
#
# "Grounds" selected elements.
#
# Default: Drops selection down in Y. Add 'all' as argument to center selection before grounding in Y.

uArgs = lx.args() 
centeraxis = "y"

if len(uArgs) != 0 :
	centeraxis = uArgs

	
# Check selections/ select verts
selmode = lx.eval1('query layerservice selmode ?')	

if selmode != 'vertex' :
	lx.eval('select.convert vertex')

selected_verts = lx.evalN('query layerservice verts ? selected')	

if selected_verts :
	
	# make sure layer is selected, not just active
	layer_index = lx.eval('query layerservice layers ? selected')
	layer_ID = lx.eval1('query layerservice layer.ID ? {%s}' %layer_index)
	lx.eval('select.subItem {%s} set' %layer_ID )	

	# reset world positions
	lx.eval('vert.center {%s}' %centeraxis )
	
	# get offset Y distance
	poslist = []
	for v in selected_verts :
		poslist.append(lx.evalN('query layerservice vert.wdefpos ? {%s}' %v )[1])
	poslist.sort()
	offset = (poslist[-1] - poslist[0]) / 2	

	# move verts in Y by offset
	lx.eval('tool.clearTask axis center')	
	lx.eval('tool.doApply')
	lx.eval('tool.set TransformMove on')
	lx.eval('tool.attr xfrm.transform lockUV false')
	lx.eval('tool.attr xfrm.transform TY {%s}' %offset)
	lx.eval('tool.attr xfrm.transform TX 0.0')
	lx.eval('tool.attr xfrm.transform TZ 0.0')
	lx.eval('tool.doApply')
	lx.eval('tool.set TransformMove off')
		
	lx.eval('select.drop vertex')
	lx.eval('select.typeFrom {%s}' %selmode )

else : sys.exit(": --- Selection Error : Please select vertex|edge|polygon ---")	

#eof