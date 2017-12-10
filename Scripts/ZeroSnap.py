#python
import lx

class SnapZero():
	def __init__(self, axe, local=False):
		self.axe = axe
		self.local = bool(int(local))

	def snap(self):
		if self.local:
			lx.eval('tool.set TransformScale on')
			lx.eval('tool.attr xfrm.transform S{} 0.0'.format(self.axe))
			lx.eval('tool.doApply')
			lx.eval('tool.set TransformScale off 0')
		else:
			lx.eval('vert.set {} 0.0 false false'.format(self.axe))


if __name__ == '__main__':
	axe = lx.args()
	snap = SnapZero(axe[0], axe[1])
	snap.snap()