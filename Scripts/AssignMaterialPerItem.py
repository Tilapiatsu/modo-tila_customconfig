#python
import modo, lx
import random

scn = modo.Scene()

selection = scn.selected

for item in selection:
    name = item.name
    color = [random.random(), random.random(), random.random()]

    item.select(replace = True)

    lx.eval('poly.setMaterial {} {} {} {} 0.8 0.04 true false false'.format(name, '{' + str(color[0]), str(color[1]), str(color[2]) + '}'))
