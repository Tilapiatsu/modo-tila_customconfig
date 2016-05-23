#python

# Created by Take-Z [http://blog.livedoor.jp/take_z_ultima] and freely available here
# [http://park7.wakwak.com/~oxygen/lib/script/modo/category.html]

# Packaged by Cristobal Vila [http://www.etereaestudios.com]
# to form part of the Eterea UV Tools, distributed free.

import lx

def discoedge(edge,dvert):
	polys=list(dvert[edge[0]].intersection(dvert[edge[1]]))
	elist=[]
	for p in polys:
		e=edge*1
		e.append(p)
		elist.append(e)
	return elist

# ((v1,v2),poly)の隣のエッジ(v1,v3)の不連続ポリゴンを検索する
def nextp(v1,v2,v3,poly):
	while True:
		verts=list(lx.evalN("query layerservice poly.vertList ? %s" % poly))
		ptr=verts.index(int(v1))
		n=len(verts)
		if str(verts[(ptr-1+n)%n])==v2:
			next=str(verts[(ptr+1)%n])
		else:
			next=str(verts[(ptr+n-1)%n])
		for v in v3:
			if next==v[0]:return [v1,v[0],poly,v[1]]
		polys=lx.evalN("query layerservice edge.polyList ? (%s,%s)" % (v1,next))
		if len(polys)<2:return None
		if str(polys[0])==poly:
			poly=str(polys[1])
		else:
			poly=str(polys[0])
		v2=next
main=lx.eval("query layerservice layer.index ? main")
seledges=lx.evalN("query layerservice edges ? selected")
if len(seledges)!=0:
	seed=seledges[0].strip("()").split(",")
	if len(seledges)>1:
		for i,e in enumerate(seledges):
			if i==0:continue
			ed=[int(v) for v in e.strip("()").split(",")]
			polys=lx.eval("query layerservice edge.polyList ? %s" % e)
			for p in polys:
				lx.eval("select.element [%s] edge remove [%s] [%s] [%s]"% (main,ed[0],ed[1],p))
	lx.eval("select.convert vertex")
	verts=[v.strip("()").split(",") for v in lx.evalN("query layerservice uvs ? selected")]
	dvert={}
	for v in verts:
		if not dvert.has_key(v[1]):
			dvert[v[1]]=set([v[0]])
		else:
			dvert[v[1]].add(v[0])
	seed=discoedge(seed,dvert)
	if seed[0][2]=='-1' and len(seed)>1:
		seed=seed[1]
	else:
		seed=seed[0]

	lx.eval("select.type edge")

	lx.eval("select.edgeLoop base [0] uv")
	edges=list(lx.evalN("query layerservice edges ? selected"))
	edges.pop(edges.index(seledges[0]))
	edges=[e.strip("()").split(",") for e in edges]
	v1=seed[0]
	v2=seed[1]
	poly=seed[2]
	delist=[seed]
	while len(edges)!=0:
		find=False
		v3=[]
		for i,e in enumerate(edges):
			if e[0]==v1:
				v3.append([e[1],i])
				find=True
			elif e[1]==v1:
				v3.append([e[0],i])
				find=True
		if not find:break
		nextedge=nextp(v1,v2,v3,poly)
		if poly==nextedge[2]:break
		delist.append(nextedge)
		edges.pop(nextedge[3])
		v2=v1
		v1=nextedge[1]
		poly=nextedge[2]
	v1=seed[1]
	v2=seed[0]
	poly=seed[2]
	while len(edges)!=0:
		find=False
		v3=[]
		for i,e in enumerate(edges):
			if e[0]==v1:
				v3.append([e[1],i])
				find=True
			elif e[1]==v1:
				v3.append([e[0],i])
				find=True
		if not find:break
		nextedge=nextp(v1,v2,v3,poly)
		if poly==nextedge[2]:break
		delist.append(nextedge)
		edges.pop(nextedge[3])
		v2=v1
		v1=nextedge[1]
		poly=nextedge[2]
	lx.eval("select.drop edge")
	for e in delist:
		lx.command("select.element",layer=main,type="edge",mode="add",index=int(e[0]),index2=int(e[1]),index3=int(e[2]))
