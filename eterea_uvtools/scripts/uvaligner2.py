#python

# Created by Take-Z [http://blog.livedoor.jp/take_z_ultima] and freely available here
# [http://park7.wakwak.com/~oxygen/lib/script/modo/category.html]

# Packaged by Cristobal Vila [http://www.etereaestudios.com]
# to form part of the Eterea UV Tools, distributed free.
# October 2017: small update by Cristobal Vila to make compatible with Modo 11.x

import lx

def whichmode():
	if lx.eval("select.typeFrom vertex;edge;polygon;item;ptag ?") :
		return "vertex"
	elif lx.eval("select.typeFrom edge;vertex;polygon;item;ptag ?") :
		return "edge"
	elif lx.eval("select.typeFrom polygon;vertex;edge;item;ptag ?") :
		return "polygon"
	elif lx.eval("select.typeFrom item;vertex;edge;polygon;ptag ?") :
		return "item"
	else:
		return "ptag"

def uvtrans(du,dv):
	lx.eval("tool.set TransformMove on")
	lx.eval("tool.setAttr xfrm.transform TX [0 m]")
	lx.eval("tool.setAttr xfrm.transform TY [0 m]")
	lx.eval("tool.setAttr xfrm.transform TZ [0 m]")
	lx.eval("tool.setAttr xfrm.transform RX [0.0]")
	lx.eval("tool.setAttr xfrm.transform RY [0.0]")
	lx.eval("tool.setAttr xfrm.transform RZ [0.0]")
	lx.eval("tool.setAttr xfrm.transform SX [100.0]")
	lx.eval("tool.setAttr xfrm.transform SY [100.0]")
	lx.eval("tool.setAttr xfrm.transform SZ [100.0]")
	lx.eval("tool.setAttr xfrm.transform U [0.0]")
	lx.eval("tool.setAttr xfrm.transform V [0.0]")
	lx.eval("tool.doApply")
	lx.eval("tool.setAttr xfrm.transform U [%s]" % du)
	lx.eval("tool.setAttr xfrm.transform V [%s]" % dv)
	lx.eval("tool.doApply")
	lx.eval("tool.set TransformMove off 0")

def setValue(main,vt,u,v):
	p=lx.eval("query layerservice vert.polyList ? %s" % vt)
	uv=lx.eval("query layerservice uv.pos ? (%s,%s)" % (p[0],vt))
	du=u-uv[0]
	dv=v-uv[1]
	lx.command("select.element",layer=main,type="vertex",mode="set",index=int(vt))
	uvtrans(du,dv)

def uvlength(p1,p2):
	return ((p1[0]-p2[0])**2+(p1[1]-p2[1])**2)**0.5

#エッジデータを展開する edlist=[[[vid1,vid2],[vid1,vid2]],[pos1,pos2],length,uvlength]
def edgelist(edges,verts) :
	edlist = []
	for e in edges :
		length = lx.eval("query layerservice edge.length ? %(e)s" % vars())
		vmid=e.strip("()").split(",")
		polys = lx.evalN("query layerservice edge.polylist ? %(e)s" % vars())
		vid1 = "(%s,%s)" %(polys[0],vmid[0])
		cvid1 = "(-1,%s)" % vmid[0]
		vid2 = "(%s,%s)" %(polys[0],vmid[1])
		cvid2 = "(-1,%s)" % vmid[1]
		pos1 = None
		if (vid1 in verts or cvid1 in verts) and (vid2 in verts or cvid2 in verts):
			pos1 = lx.eval("query layerservice uv.pos ? %(vid1)s" % vars())
			pos2 = lx.eval("query layerservice uv.pos ? %(vid2)s" % vars())
		if len(polys)==2 :
			vid3 = "(%s,%s)" %(polys[1],vmid[0])
			cvid3 = "(-1,%s)" % vmid[0]
			vid4 = "(%s,%s)" %(polys[1],vmid[1])
			cvid4 = "(-1,%s)" % vmid[1]
			if (vid3 in verts or cvid3 in verts) and (vid4 in verts or cvid4 in verts):
				pos3 = lx.eval("query layerservice uv.pos ? %(vid3)s" % vars())
				pos4 = lx.eval("query layerservice uv.pos ? %(vid4)s" % vars())
				if pos1 == None :
					edlist.append([[[vid3],[vid4]],[pos3,pos4],length,uvlength(pos3,pos4)])
				else :
					if issame(pos1,pos3) and issame(pos2,pos4) :
						edlist.append([[[vid1,vid3],[vid2,vid4]],[pos1,pos2],length,uvlength(pos1,pos2)])
					else:
						edlist.append([[[vid1],[vid2]],[pos1,pos2],length,uvlength(pos1,pos2)])
						edlist.append([[[vid3],[vid4]],[pos3,pos4],length,uvlength(pos3,pos4)])
			else:
				if pos1 != None :
					edlist.append([[[vid1],[vid2]],[pos1,pos2],length,uvlength(pos1,pos2)])
		else :
			if pos1 != None :
				edlist.append([[[vid1],[vid2]],[pos1,pos2],length,uvlength(pos1,pos2)])
	return edlist

#vertが不連続UVかどうかのチェック
def isDisco(vert):
	polys = lx.eval("query layerservice vert.polyList ? %(vert)s" % vars())
	pos = set()
	for p in polys :
		vmid = "(%(p)s,%(vert)s)" % vars()
		pos.add(lx.eval("query layerservice uv.pos ? %(vmid)s" % vars()))
	if len(pos) == 1:
		return False
	else :
		return True

#重複ポイントデータを削除
def optimize(verts):
	vlist = []
	for v in verts:
		vmid=v.strip("()").split(",")
		if vmid[0] != "-1" :
			vlist.append(v)
		else:
			find = False
			for dv in verts:
				dvmid=dv.strip("()").split(",")
				if dvmid[0] != "-1" and dvmid[1] == vmid[1] :
					find = True
					break
			if not find :
				if isDisco(vmid[1]) :
					polys = lx.eval("query layerservice vert.polyList ? %s" % vmid[1])
					for p in polys :
						vlist.append("("+str(p)+","+vmid[1]+")")
				else:
					vlist.append(v)
	return vlist

def issame(v1,v2):
	if v1[0] == v2[0] and v1[1] == v2[1] :
		return True
	else :
		return False

#ポイントチェインを作る vchain=[[[pos],[vid1],length],[[pos],[vid1,vid2],length],・・・,[[pos],[vid1],length]]
def chain(elist):
	#端の点を見つける
	vchain = []
	done = set()
	ptr = 0
	e1 = None
	for i,e1 in enumerate(elist) :
		ptr = 0
		pos = e1[1][ptr]
		find = False
		for j,e2 in enumerate(elist) :
			if i==j : continue
			if issame(pos,e2[1][0]) :
				find = True
				break
			if issame(pos,e2[1][1]) :
				find = True
				break
		if not find : 
			done.add(i) 
			break

		ptr = 1
		pos = e1[1][ptr]
		find = False
		for j,e2 in enumerate(elist) :
			if i==j : continue
			if issame(pos,e2[1][0]) :
				find = True
				break
			if issame(pos,e2[1][1]) :
				find = True
				break
		if not find :
			done.add(i) 
			break
	#チェイン作成開始
	vchain.append([e1[1][ptr],[e1[0][ptr]],0.0,0.0])
	vchain.append([e1[1][(ptr+1)%2],[e1[0][(ptr+1)%2]],e1[2],e1[3]])
	cnt = 1
	while cnt<len(elist):
		pos = vchain[-1][0]
		for i,e in enumerate(elist) :
			if i in done : continue
			if issame(pos,e[1][0]):
				done.add(i)
				vchain[-1][1].append(e[0][0])
				vchain.append([e[1][1],[e[0][1]],e[2],e[3]])
				break
			if issame(pos,e[1][1]):
				done.add(i)
				vchain[-1][1].append(e[0][1])
				vchain.append([e[1][0],[e[0][0]],e[2],e[3]])
				break
		cnt = cnt + 1
	return vchain

def vmunselect():
    vmaps=lx.evalN("query layerservice vmaps ? selected")
    ctd={"weight":"wght","texture":"txuv","subvweight":"subd","morph":"morf","absmorpf":"spot","rgb":"rgb","rgba":"rgba","pick":"pick"}
    for vm in vmaps:
        name=lx.eval("query layerservice vmap.name ? %s" % vm)
        type=ctd[lx.eval("query layerservice vmap.type ? %s" % vm)]
        lx.eval("select.vertexMap \"%s\" %s remove" % (name,type))

mode = whichmode()
edges = verts = None
main = lx.eval("query layerservice layers ? main")
if mode == "edge" :
	edges = lx.evalN("query layerservice edges ? selected")
	lx.eval("select.convert vertex")
	verts = lx.evalN("query layerservice uvs ? selected")
elif mode == "vertex" :
	verts = lx.evalN("query layerservice uvs ? selected")
	lx.eval("select.convert edge")
	edges = lx.evalN("query layerservice edges ? selected")
if edges != None :
	if lx.eval("query scriptsysservice userValue.isDefined ? uvaligner.divide") == 0 :
		lx.eval("user.defNew uvaligner.divide integer temporary")
	lx.eval("user.def uvaligner.divide username \"divide method\"")
	lx.eval("user.def uvaligner.divide list Uniform;Proportional;UVProportional")
	lx.eval("user.value uvaligner.divide")
	divide = lx.eval("user.value uvaligner.divide ?")
	selverts = optimize(verts)
	elist = edgelist(edges,selverts)
	sum = 0.0
	uvsum = 0.0
	for e in elist :
		sum = sum + e[2]
		uvsum = uvsum + e[3]
	vchain = chain(elist)
	lx.eval("select.drop polygon")
	lx.eval("select.type vertex")
	vecu = vchain[-1][0][0] - vchain[0][0][0]
	vecv = vchain[-1][0][1] - vchain[0][0][1]
	vecu = vecu 
	vecv = vecv 
	distance = 0.0

	for i,v in enumerate(vchain) :
		if i == 0 or i == len(vchain) - 1 : continue
		if divide == "Uniform" :
			posu = vecu / len(edges) * i + vchain[0][0][0]
			posv = vecv / len(edges) * i + vchain[0][0][1]
		elif divide == "UVProportional":
			distance = distance + v[3]
			t = distance / uvsum
			posu = vecu * t + vchain[0][0][0]
			posv = vecv * t + vchain[0][0][1]
		else:
			distance = distance + v[2]
			t = distance / sum
			posu = vecu * t + vchain[0][0][0]
			posv = vecv * t + vchain[0][0][1]
		vmid=v[1][0][0].strip("()").split(",")
		if not isDisco(vmid[1]) :
			setValue(main,vmid[1],posu,posv)
		else:
			for vid in v[1][0] :
				vmid=vid.strip("()").split(",")
				lx.command("select.element",layer=main,type="vertex",mode="set",index=int(vmid[1]),index3=int(vmid[0]))
				strpos = str(posu) + " " + str(posv)  
				lx.command("vertMap.setPValue",value = strpos)
		vmid=v[1][1][0].strip("()").split(",")
		if not isDisco(vmid[1]) :
			setValue(main,vmid[1],posu,posv)
		else:
			for vid in v[1][1] :
				vmid=vid.strip("()").split(",")
				lx.command("select.element",layer=main,type="vertex",mode="set",index=int(vmid[1]),index3=int(vmid[0]))
				lx.command("vertMap.setPValue",value = strpos)
lx.eval("select.type %(mode)s" % vars())
if mode == "vertex" :
	if verts != None :
		for v in verts :
			vmid=v.strip("()").split(",")
			lx.command("select.element",layer=main,type="vertex",mode="add",index=int(vmid[1]),index3=int(vmid[0]))
elif mode == "edge" :
	if edges != None :
		for e in edges :
			vmid=e.strip("()").split(",")
			lx.command("select.element",layer=main,type="vertex",mode="add",index=int(vmid[0]),index2=int(vmid[1]))

