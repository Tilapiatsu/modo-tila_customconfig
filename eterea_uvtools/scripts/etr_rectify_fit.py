#python

# Created by Cristobal Vila
# To apply a Rectangularize effect ('Rectangle' command) and then a Fit in UV space

u = lx.args()[0]
v = lx.args()[1]

lx.eval("uv.rectangle false 0.2 %s %s" % (u, v))

lx.eval("uv.fit island true")


