#python
x = lx.eval('workPlane.edit cenX:?')
y = lx.eval('workPlane.edit cenY:?')
z = lx.eval('workPlane.edit cenZ:?')
xr = lx.eval('workPlane.edit rotX:?')
yr = lx.eval('workPlane.edit rotY:?')
zr = lx.eval('workPlane.edit rotZ:?')
lx.out(x,y,z,xr,yr,zr)
if x == 0 and y == 0 and z == 0:
    lx.eval('workPlane.fitSelect')
if xr != 0 or yr != 0 or zr != 0:
    lx.eval('workPlane.reset')