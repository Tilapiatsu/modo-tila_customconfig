#python

# Modified from original created by "Take-Z" [http://blog.livedoor.jp/take_z_ultima]
# and freely available here [http://park7.wakwak.com/~oxygen/lib/script/modo/category.html]

# ver 1.1 - Updated to accept arguments by Richard Rodriguez (aka gm770) - 1/20/2011
# ver 1.2 - Updated to be compatible with Modo 701 by Dongju - 3/28/2013

# Packaged by Cristobal Vila [http://www.etereaestudios.com] to form part of the Eterea UV Tools, distributed free.

#	@UVBlockAligner_11.py - Brings up the usual drop down. (same as original)
#	@UVBlockAligner_11.py U Center - Calls "U Center" Method
#	@UVBlockAligner_11.py Horizontal Space 0.0 - Calls "Horizontal Space" Method with a spacing of 0.0
#	@UVBlockAligner_11.py Horizontal Space - Calls "Horizontal Space" Method and opens a dialog for spacing

import lx

texselerror=1

def panel(var,val,type,mes,lst):
	if lx.eval("query scriptsysservice userValue.isDefined ? %(var)s" % vars()) == 0 :
		lx.eval("user.defNew %(var)s %(type)s temporary" % vars())
	if val!=None :
		lx.eval("user.value %(var)s %(val)s" % vars())
	if mes != None :
		lx.eval("user.def %(var)s username \"%(mes)s\"" % vars())
	if lst!=None :
		lx.eval('user.def %(var)s list "%(lst)s"' % vars())
	if mes != None :
		lx.eval("user.value %(var)s" % vars())
	return lx.eval("user.value %(var)s ?" % vars())

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

def uvtrans(du,dv,sw):
	lx.eval("tool.set TransformMove on")
	lx.eval("tool.setAttr xfrm.transform TX 0")
	lx.eval("tool.setAttr xfrm.transform TY 0")
	lx.eval("tool.setAttr xfrm.transform TZ 0")
	lx.eval("tool.setAttr xfrm.transform RX 0.0")
	lx.eval("tool.setAttr xfrm.transform RY 0.0")
	lx.eval("tool.setAttr xfrm.transform RZ 0.0")
	lx.eval("tool.setAttr xfrm.transform SX 1.0")
	lx.eval("tool.setAttr xfrm.transform SY 1.0")
	lx.eval("tool.setAttr xfrm.transform SZ 1.0")
	lx.eval("tool.setAttr xfrm.transform U 0.0")
	lx.eval("tool.setAttr xfrm.transform V 0.0")
	lx.eval("tool.doApply")
	if sw==0:
		lx.eval("tool.setAttr xfrm.transform U %s" % du)
		lx.eval("tool.setAttr xfrm.transform V %s" % dv)
	elif sw==1:
		lx.eval("tool.setAttr xfrm.transform SX %s" % (du / 100.0))
		lx.eval("tool.setAttr xfrm.transform SY %s" % (dv / 100.0))
	lx.eval("tool.doApply")
	lx.eval("tool.set TransformMove off 0")

def hcmp(x,y):
	d=(x[0][2]+x[0][0])/2-(y[0][2]+y[0][0])/2
	if d<0:return -1
	elif d==0:return 0
	else: return 1

def vcmp(x,y):
	d=(x[0][3]+x[0][1])/2-(y[0][3]+y[0][1])/2
	if d<0:return -1
	elif d==0:return 0
	else: return 1

def pymain():
	args = lx.arg()
	arg_split = args.split()
	if len(arg_split) == 0:
		try:
			arg=panel("UVBlockAligner.mode",None,"integer","which mode:",
			"U Center;V Center;Left;Right;Top;Bottom;Max Width;Min Width;"
			+"Max Height;Min Height;Horizontal Distribution;Vertical Distribution;"
			+"Horizontal Space;Vertical Space")
		except:
			return
	elif len(arg_split) > 2:
		arg = "%s %s" % (arg_split[0], arg_split[1])
	else:
		arg = args
		
	spc=0
	if "Space" in arg:
		if len(arg_split) > 2:
			spc = float(arg_split[2])
		else:
			try:
				spc=panel("UVBlockAligner.space",None,"float","Space Distance:",None)
			except:
				return
		
	all=False
	main=lx.eval("query layerservice layer.index ? main")
	vmaps=set(lx.evalN("query layerservice vmaps ? selected"))
	texture=set(lx.evalN("query layerservice vmaps ? texture"))
	seltexture=list(vmaps.intersection(texture))
	if len(seltexture)==0:
		return texselerror
	seltexture=int(seltexture[0])
	lx.eval("query layerservice vmap.name ? %s" % seltexture)
	lx.eval("select.type polygon")
	backup=lx.evalN("query layerservice polys ? selected")
	if len(backup)!=0:
		lx.eval("select.connect")
		selpolys=set(lx.evalN("query layerservice polys ? selected"))
	else:
		selpolys=set(lx.evalN("query layerservice polys ? all"))
		all=True
	lx.eval("select.drop polygon")
	block=[]
	while len(selpolys)!=0:
		p=list(selpolys)[0]
		lx.command("select.element",layer=main,type="polygon",mode="set",index=int(p))
		lx.eval("select.connect")
		bps=lx.evalN("query layerservice polys ? selected")
		range=None
		for p in bps:
			verts=lx.evalN("query layerservice poly.vertList ? %s" % p)
			for v in verts:
				uv=lx.eval("query layerservice uv.pos ? (%s,%s)" % (p,v))
				if range==None:
					range=[uv[0],uv[1],uv[0],uv[1]]
				else:
					if range[0]>uv[0]:range[0]=uv[0]
					if range[1]>uv[1]:range[1]=uv[1]
					if range[2]<uv[0]:range[2]=uv[0]
					if range[3]<uv[1]:range[3]=uv[1]
		selpolys=selpolys.difference(set(bps))
		block.append([range,bps])
	if "Horizontal" in arg:block.sort(hcmp)
	if "Vertical" in arg:block.sort(vcmp)
	cu=0
	cv=0
	minu=None
	n=len(block)
	for b in block:
		r=b[0]
		if minu==None:
			minu=r[0]
			maxu=r[2]
			minv=r[1]
			maxv=r[3]
			sumw=r[2]-r[0]
			sumh=r[3]-r[1]
			minwu=maxwu=r[2]-r[0]
			minwv=maxwv=r[3]-r[1]
		else:
			if minu>r[0]:minu=r[0]
			if maxu<r[2]:maxu=r[2]
			if minv>r[1]:minv=r[1]
			if maxv<r[3]:maxv=r[3]
			wu=r[2]-r[0]
			wv=r[3]-r[1]
			if minwu>wu:minwu=wu
			if minwv>wv:minwv=wv
			if maxwu<wu:maxwu=wu
			if maxwv<wv:maxwv=wv
			sumw=sumw+r[2]-r[0]
			sumh=sumh+r[3]-r[1]
		cu=cu+(r[0]+r[2])/2
		cv=cv+(r[1]+r[3])/2
	cu=cu/n
	cv=cv/n
	if n>1:
		spw=((maxu-minu)-sumw)/(n-1)
		sph=((maxv-minv)-sumh)/(n-1)
	ptu=(maxu+minu)/2-(spc*(n-1)+sumw)/2
	ptv=(maxv+minv)/2-(spc*(n-1)+sumh)/2
	for ptr,b in enumerate(block):
		r=b[0]
		lx.eval("select.drop polygon")
		for p in b[1]:
			lx.command("select.element",layer=main,type="polygon",mode="add",index=int(p))
		if arg=="U Center":
			uvtrans(cu-(r[0]+r[2])/2,0,0)
		elif arg=="V Center":
			uvtrans(0,cv-(r[1]+r[3])/2,0)
		elif arg=="Left":
			uvtrans(minu-r[0],0,0)
		elif arg=="Right":
			uvtrans(maxu-r[2],0,0)
		elif arg=="Bottom":
			uvtrans(0,minv-r[1],0)
		elif arg=="Top":
			uvtrans(0,maxv-r[3],0)
		elif arg=="Min Width":
			lx.eval("tool.set actr.auto on 0")
			lx.eval("tool.setAttr center.auto cenU %s" % ((r[0]+r[2])/2))
			lx.eval("tool.setAttr center.auto cenV %s" % ((r[1]+r[3])/2))
			uvtrans(minwu/(r[2]-r[0])*100,100,1)
			lx.eval("tool.set actr.auto off 0")
		elif arg=="Max Width":
			lx.eval("tool.set actr.auto on 0")
			lx.eval("tool.setAttr center.auto cenU %s" % ((r[0]+r[2])/2))
			lx.eval("tool.setAttr center.auto cenV %s" % ((r[1]+r[3])/2))
			uvtrans(maxwu/(r[2]-r[0])*100,100,1)
			lx.eval("tool.set actr.auto off 0")
		elif arg=="Min Height":
			lx.eval("tool.set actr.auto on 0")
			lx.eval("tool.setAttr center.auto cenU %s" % ((r[0]+r[2])/2))
			lx.eval("tool.setAttr center.auto cenV %s" % ((r[1]+r[3])/2))
			uvtrans(100,minwv/(r[3]-r[1])*100,1)
			lx.eval("tool.set actr.auto off 0")
		elif arg=="Max Height":
			lx.eval("tool.set actr.auto on 0")
			lx.eval("tool.setAttr center.auto cenU %s" % ((r[0]+r[2])/2))
			lx.eval("tool.setAttr center.auto cenV %s" % ((r[1]+r[3])/2))
			uvtrans(100,maxwv/(r[3]-r[1])*100,1)
			lx.eval("tool.set actr.auto off 0")

		elif arg=="Horizontal Distribution":
			if ptr==0:
				pu=r[2]
				continue
			elif ptr==n-1:break
			pu=pu+spw
			uvtrans(pu-r[0],0,0)
			pu=pu+(r[2]-r[0])
		elif arg=="Vertical Distribution":
			if ptr==0:
				pv=r[3]
				continue
			elif ptr==n-1:break
			pv=pv+sph
			uvtrans(0,pv-r[1],0)
			pv=pv+(r[3]-r[1])
		elif arg=="Horizontal Space":
			uvtrans(ptu-r[0],0,0)
			ptu=ptu+spc+r[2]-r[0]
		elif arg=="Vertical Space":
			uvtrans(0,ptv-r[1],0)
			ptv=ptv+spc+r[3]-r[1]
	lx.eval("select.drop polygon")
	if not all:
		for p in backup:
			lx.command("select.element",layer=main,type="polygon",mode="add",index=int(p))

mode=whichmode()
error=pymain()
if error==texselerror:
	lx.eval('dialog.setup error')
	lx.eval('dialog.title "Selection Error"')
	lx.eval('dialog.msg "UVマップを選択して下さい。"' )
	lx.eval('dialog.open')
lx.eval("select.type %s" % mode)
