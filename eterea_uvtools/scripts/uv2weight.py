#python

# Created by Take-Z [http://blog.livedoor.jp/take_z_ultima] and freely available here
# [http://park7.wakwak.com/~oxygen/lib/script/modo/category.html]

# Packaged by Cristobal Vila [http://www.etereaestudios.com]
# to form part of the Eterea UV Tools, distributed free.

import lx

def setweight(wname):
	main = lx.eval("query layerservice layers ? main")
	lx.eval("select.type vertex")
	lx.eval("select.drop vertex")
	lx.command("vert.new", x=0 , y=0 , z=0 )
	vert = lx.eval("query layerservice vert.index ? last")
	lx.eval("select.element %(main)s vertex set %(vert)s" % vars())
	lx.eval("poly.makeFace")
	lx.eval("select.type vertex")
	lx.eval("select.element %(main)s vertex set %(vert)s" % vars())
	lx.eval("select.vertexMap \"%(wname)s\" wght replace" % vars())
	lx.eval("tool.set vertMap.setWeight on")
	lx.eval("tool.setAttr vertMap.setWeight weight [100.0 %]")
	lx.eval("tool.doApply")
	lx.eval("tool.set vertMap.setWeight off")
	wmaps = lx.eval("query layerservice vmaps ? weight")
	for w in wmaps : 
		if lx.eval("query layerservice vmap.selected ? %(w)s" %vars()) : break
	v = lx.eval("query layerservice vert.vmapValue ? %(vert)s" % vars() )
	if v == None :
		lx.command("vertMap.new" , name = vname ,type="wght")
	lx.command("delete")

def panel(var,val,type,mes,lst):
	if lx.eval("query scriptsysservice userValue.isDefined ? %(var)s" % vars()) == 0 :
		lx.eval("user.defNew %(var)s %(type)s temporary" % vars())
	if val!=None :
		lx.eval("user.value %(var)s %(val)s" % vars())
	if mes != None :
		lx.eval("user.def %(var)s username \"%(mes)s\"" % vars())
	if lst!=None :
		lx.eval("user.def %(var)s list %(lst)s" % vars())
	if mes != None :
		lx.eval("user.value %(var)s" % vars())
	return lx.eval("user.value %(var)s ?" % vars())

mon=lx.Monitor()
main=lx.eval("query layerservice layers ? main")
vmaps = lx.evalN("query layerservice vmaps ? weight")
wmapnameset=set()
for w in vmaps :
	wname = lx.eval("query layerservice vmap.name ? %(w)s" % vars())
	wmapnameset.add(wname)
lx.eval("select.type vertex")
selverts=lx.evalN("query layerservice verts ? selected")
nonselection=False
if len(selverts)==0:
	nonselection=True
	selverts=lx.evalN("query layerservice verts ? all")
mon.init(len(selverts))
weightmap=panel("uv2weight.weight",None,"string","WeightMap",None)
useuv=panel("uv2weight.use",None,"integer","use","U;V")
shift=panel("uv2weight.shift",None,"float","Shift Value",None)
scale=panel("uv2weight.scale",None,"percent","Scale Value",None)
if weightmap in wmapnameset:
	setweight(weightmap)
else:
	lx.eval("vertMap.new %s wght [0] [0.0 0.0 0.0] [1.0]" % weightmap)
lx.eval("select.vertexMap %s wght replace" % weightmap)
if useuv=="U":
	sel=0
else:
	sel=1
lx.eval("tool.set vertMap.setWeight on")
main = lx.eval("query layerservice layers ? main")
seluvs=lx.evalN("query layerservice vmaps ? Texture")
for uv in seluvs:
	if lx.eval("query layerservice vmap.selected ? %s" % uv) : break
if len(seluvs)!=0:
	for v in selverts:
		mon.step(1)
		uvpos=lx.eval("query layerservice uv.pos ? (-1,%(v)s)" % vars())
		w=uvpos[sel]*scale+shift
		lx.command("select.element",layer=main,type="vertex",mode="set",index=int(v))
		lx.eval("tool.setAttr vertMap.setWeight weight %s" % w)
		lx.eval("tool.doApply")
lx.eval("tool.set vertMap.setWeight off")
lx.eval("select.drop vertex")
if not nonselection :
	for v in selverts:
		lx.command("select.element",layer=main,type="vertex",mode="add",index=int(v))
