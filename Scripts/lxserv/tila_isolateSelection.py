
################################################################################
#
# scriptname.py
#
# Version: 1
#
# Author: Tilapiatsu
#
# Description: Isolate selected item - ( hide unselected )
#
# Last Update: 05/07/2016
#
################################################################################

import lx
import lxifc
import lxu.command
import modo


class CmdTila_isolateSelection(lxu.command.BasicCommand):
	def __init__(self):
		lxu.command.BasicCommand.__init__(self)

		self.commands = ('hide.sel', 'hide.invert')
		self.compatibleItem = 	('mesh',
								'locator',
								'camera',
								'meshInst',
								'proxy',
								'replicator',
								 )
		self.allItemType = ('group',
							'mediaClip',
							'locator',
							'mesh',
							'light',
							'camera',
							'meshInst',
							'txtrLocator',
							'render',
							'environment',
							'backdrop',
							'textureLayer',
							'actionclip',
							'groupLocator',
							'transform',
							'translation',
							'rotation',
							'scale',
							'shear',
							'xfrmcore',
							'force.root',
							'falloff',
							'deformGroup',
							'deformFolder',
							'videoClip',
							'shader',
							'baseVolume',
							'scene',
							'deform',
							'locdeform',
							'chanEffect',
							'chanModify',
							'widget',
							'itemModify',
							'bake',
							'meshoperation',
							'tooloperation',
							'selectionoperation',
							'schmNode',
							'actionpose',
							'videoStill',
							'videoSequence',
							'videoBlank',
							'imageLayer',
							'imageGroup',
							'imageFolder',
							'audioClip',
							'audioFile',
							'shaderFolder',
							'advancedMaterial',
							'mask',
							'constant',
							'imageMap',
							'defaultShader',
							'matcapShader',
							'unrealShader',
							'unityShader',
							'projectShader',
							'projectTexture',
							'renderOutput',
							'capsule',
							'process',
							'vmapTexture',
							'variationTexture',
							'tensionTexture',
							'grid',
							'dots',
							'checker',
							'noise',
							'cellular',
							'wood',
							'weave',
							'ripples',
							'occlusion',
							'gradient',
							'polyRender',
							'lightMaterial',
							'envMaterial',
							'ceFloat',
							'ceMatrix',
							'ikSolver',
							'sunLight',
							'pointLight',
							'spotLight',
							'areaLight',
							'cylinderLight',
							'domeLight',
							'meshLight',
							'portal',
							'photometryLight',
							'triSurf',
							'proxy',
							'replicator',
							'surfGen',
							'surfGenLoc',
							'particleSim',
							'furMaterial',
							'volume',
							'sprite',
							'renderBool',
							'blob',
							'pcloud',
							'cmChannelRelation',
							'cmGeometryConstraint',
							'cmPathConstraint',
							'cmIntersect',
							'cmTransformConstraint',
							'cmDynamicParent',
							'cmDirectionConstraint',
							'cmMathBasic',
							'cmMath',
							'cmMathTrig',
							'cmMathVector',
							'cmVector',
							'cmDistanceConstraint',
							'cmRevolve',
							'cmMeasureDistance',
							'cmMeasureAngle',
							'cmLogic',
							'cmMatrixBlend',
							'cmMatrixCompose',
							'cmMatrixVector',
							'cmOscillator',
							'cmNoise',
							'cmColorHSV',
							'cmColorKelvin',
							'cmTime',
							'cmIKDual2D',
							'deformMDD2',
							'deformMDD',
							'realParticle',
							'morphMix',
							'mapMix',
							'cmShaderEffects',
							'cmShaderRaycast',
							'cmShaderLighting',
							'cmShaderRayType',
							'cmShaderSwitch',
							'particleOp',
							'val.wireframe',
							'val.Display_Counter1.RJJ',
							'val.Display_Counter2.RJJ',
							'val.Display_UVLEDs.RJJ',
							'val.Geometric_Box.RJJ',
							'val.Geometric_Circular.RJJ',
							'val.Geometric_Corners.RJJ',
							'val.Geometric_Cubic.RJJ',
							'val.Geometric_Dimples.RJJ',
							'val.Geometric_Grid.RJJ',
							'val.Geometric_Iris.RJJ',
							'val.Geometric_Linear.RJJ',
							'val.Geometric_Polygon.RJJ',
							'val.Geometric_Radial.RJJ',
							'val.Geometric_Ring.RJJ',
							'val.Geometric_RndLinear.RJJ',
							'val.Geometric_Spiral.RJJ',
							'val.Geometric_Star.RJJ',
							'val.Noise_Agate.RJJ',
							'val.Noise_Bozo.RJJ',
							'val.Noise_Cruddy.RJJ',
							'val.Noise_Dented.RJJ',
							'val.Noise_Etched.RJJ',
							'val.Noise_FlowBozo.RJJ',
							'val.Noise_Granite.RJJ',
							'val.Noise_Hybrid.RJJ',
							'val.Noise_Lump.RJJ',
							'val.Noise_MarbleNoise.RJJ',
							'val.Noise_MarbleVein.RJJ',
							'val.Noise_MultiFractal.RJJ',
							'val.Noise_Pebbles.RJJ',
							'val.Noise_PuffyClouds.RJJ',
							'val.Noise_Ridged.RJJ',
							'val.Noise_Scar.RJJ',
							'val.Noise_Scruffed.RJJ',
							'val.Noise_Strata.RJJ',
							'val.Noise_Stucco.RJJ',
							'val.Noise_VectorBozo.RJJ',
							'val.Noise_WrappedfBm.RJJ',
							'val.Noise_fBm.RJJ',
							'val.Organic_ArtDeco.RJJ',
							'val.Organic_Blister.RJJ',
							'val.Organic_Branches.RJJ',
							'val.Organic_Caustic.RJJ',
							'val.Organic_Cellular.RJJ',
							'val.Organic_Cheesy.RJJ',
							'val.Organic_Concrete.RJJ',
							'val.Organic_Crackle.RJJ',
							'val.Organic_Dirt.RJJ',
							'val.Organic_Disturbed.RJJ',
							'val.Organic_EasyWood.RJJ',
							'val.Organic_Electric.RJJ',
							'val.Organic_Fire.RJJ',
							'val.Organic_FireWall.RJJ',
							'val.Organic_HardWood.RJJ',
							'val.Organic_Membrane.RJJ',
							'val.Organic_Minky.RJJ',
							'val.Organic_Scatter.RJJ',
							'val.Organic_SinBlob.RJJ',
							'val.Organic_Veins.RJJ',
							'val.Organic_Wires.RJJ',
							'val.Organic_WormVein.RJJ',
							'val.Panels_Peel.RJJ',
							'val.Panels_Plates.RJJ',
							'val.Panels_RivetRust.RJJ',
							'val.Panels_Rivets.RJJ',
							'val.Panels_Rust.RJJ',
							'val.Panels_Smear.RJJ',
							'val.Process_EasyGrad.RJJ',
							'val.Process_RegionalHSV.RJJ',
							'val.Skins_Camo.RJJ',
							'val.Skins_Crumpled.RJJ',
							'val.Skins_DinoSkin.RJJ',
							'val.Skins_Disease.RJJ',
							'val.Skins_FrogSkin.RJJ',
							'val.Skins_GrainyWood.RJJ',
							'val.Skins_Leather.RJJ',
							'val.Skins_Monster.RJJ',
							'val.Skins_Pastella.RJJ',
							'val.Skins_Peened.RJJ',
							'val.Skins_Scratches.RJJ',
							'val.Space_Blast.RJJ',
							'val.Space_Coriolis.RJJ',
							'val.Space_Flare.RJJ',
							'val.Space_GasGiant.RJJ',
							'val.Space_Glint.RJJ',
							'val.Space_Hurricane.RJJ',
							'val.Space_Nurnies.RJJ',
							'val.Space_Planet.RJJ',
							'val.Space_PlanetClouds.RJJ',
							'val.Space_Rings.RJJ',
							'val.Space_StarField.RJJ',
							'val.Space_Swirl.RJJ',
							'val.Space_Terra.RJJ',
							'val.Space_Windows.RJJ',
							'val.Tiles_Basket.RJJ',
							'val.Tiles_BathTile.RJJ',
							'val.Tiles_Bricks.RJJ',
							'val.Tiles_Checks.RJJ',
							'val.Tiles_Cornerless.RJJ',
							'val.Tiles_Cubes.RJJ',
							'val.Tiles_DashLine.RJJ',
							'val.Tiles_DiamondDeck.RJJ',
							'val.Tiles_FishScales.RJJ',
							'val.Tiles_HexTile.RJJ',
							'val.Tiles_Lattice1.RJJ',
							'val.Tiles_Lattice2.RJJ',
							'val.Tiles_Lattice3.RJJ',
							'val.Tiles_Mosaic.RJJ',
							'val.Tiles_OctTile.RJJ',
							'val.Tiles_Parquet.RJJ',
							'val.Tiles_Paving.RJJ',
							'val.Tiles_Plaid.RJJ',
							'val.Tiles_Planks.RJJ',
							'val.Tiles_Ribs.RJJ',
							'val.Tiles_RoundedTile.RJJ',
							'val.Tiles_Shingles.RJJ',
							'val.Tiles_Spots.RJJ',
							'val.Tiles_Stamped.RJJ',
							'val.Tiles_Tacos.RJJ',
							'val.Tiles_TarTan.RJJ',
							'val.Tiles_Tiler.RJJ',
							'val.Tiles_TriChecks.RJJ',
							'val.Tiles_TriHexes.RJJ',
							'val.Tiles_TriTile.RJJ',
							'val.Tiles_Wall.RJJ',
							'val.Water_DripDrop.RJJ',
							'val.Water_Rain.RJJ',
							'val.Water_Ripples.RJJ',
							'val.Water_Surf.RJJ',
							'val.Water_Waves.RJJ',
							'val.Water_WindyWaves.RJJ',
							'val.Waveforms_BiasGain.RJJ',
							'val.Waveforms_Fresnel.RJJ',
							'val.Waveforms_Gamma.RJJ',
							'val.Waveforms_Gaussian.RJJ',
							'val.Waveforms_Impulse.RJJ',
							'val.Waveforms_Noise.RJJ',
							'val.Waveforms_Ramp.RJJ',
							'val.Waveforms_Rounded.RJJ',
							'val.Waveforms_SCurve.RJJ',
							'val.Waveforms_SawTooth.RJJ',
							'val.Waveforms_Scallop.RJJ',
							'val.Waveforms_Sine.RJJ',
							'val.Waveforms_Smooth.RJJ',
							'val.Waveforms_SmoothImpulse.RJJ',
							'val.Waveforms_SmoothStep.RJJ',
							'val.Waveforms_Staircase.RJJ',
							'material.celShader',
							'material.hairMaterial',
							'val.RpcTexture',
							'val.RTCurvature',
							'material.celEdges',
							'material.halftone',
							'material.iridescence',
							'material.thinfilm',
							'material.skinMaterial',
							'AlembicFile',
							'AlembicCurves',
							'AlembicCloud',
							'AlembicMesh',
							'alias.chanmod',
							'alias.selop',
							'alias.meshop',
							'cmClamp',
							'cmColorBlend',
							'cmColorCorrect',
							'cmColorGamma',
							'cmColorInvert',
							'cmConstant',
							'cmCurveProbe',
							'cmCycler',
							'Expression',
							'cmFloatOffset',
							'cmFloatWarp',
							'cmGenerateID',
							'cmLinearBlend',
							'cmMathMulti',
							'cmMatrixConstruct',
							'cmMatrixFromEuler',
							'cmMatrixInvert',
							'cmMatrixOffset',
							'cmMatrixToEuler',
							'cmMatrixTranspose',
							'cmMatrixVectorMultiply',
							'cmMatrixWarp',
							'cmMeshInfo',
							'val.noise.gabor',
							'val.noise.poisson',
							'cmPosParticleConstraint',
							'probeFalloff',
							'itemChannelProbe',
							'cmQuaternionConjugate',
							'cmQuaternionFromAxisAngle',
							'cmQuaternionFromEuler',
							'cmQuaternionFromMatrix',
							'cmQuaternionGetValue',
							'cmQuaternionMath',
							'cmQuaternionNormalize',
							'cmQuaternionSetValue',
							'cmQuaternionSlerp',
							'cmQuaternionToAxisAngle',
							'cmQuaternionToEuler',
							'cmQuaternionToMatrix',
							'cmQuaternionVectorMultiply',
							'cmRandom',
							'cmRotParticleConstraint',
							'cmSimpleKinematics',
							'cmSmooth',
							'cmSound',
							'cmSpeed',
							'cmStringCompose',
							'cmStringConstant',
							'cmStringFindAndReplace',
							'cmStringSwitch',
							'cmSwitch',
							'cmUVConstraint',
							'cmVectorByScalar',
							'cmVectorMagnitude',
							'cmVectorOrthogonalize',
							'cmVectorReflection',
							'cmVelocity',
							'cmWaveform',
							'curvePtGen',
							'falloff.capsule',
							'falloff.radial',
							'falloff.linear',
							'falloff.constant',
							'morphDeform',
							'itemInfluence',
							'weightContainer',
							'genInfluence',
							'deform.bend',
							'deform.bezier',
							'falloff.bezier',
							'bezierNode',
							'deform.crvConst',
							'deform.lag',
							'deform.lattice',
							'deform.magnet',
							'deform.push',
							'deform.spline',
							'deform.slack',
							'falloff.spline',
							'deform.vortex',
							'deform.wrap',
							'softLag',
							'anchor',
							'dynamicCollisionEmitter',
							'collisionEmitter',
							'cons',
							'dynamicsConstraintModifier',
							'dynamicFluid',
							'consHinge',
							'consPin',
							'consPoint',
							'proceduralShatterItem',
							'dynamic.replicatorFilter',
							'consSlideHinge',
							'solver',
							'consSpring',
							'pmodel.edgeToCurve.item',
							'force.linear',
							'force.radial',
							'force.drag',
							'force.turbulence',
							'force.vortex',
							'force.wind',
							'force.curve',
							'force.newton',
							'gaskettoy',
							'gear.item',
							'gplane',
							'ikFullBody',
							'image.GradFill',
							'laceGeom',
							'curvefill',
							'uvtransform',
							'vertexmaptransfer',
							'modSculpt',
							'cRebuild.mOp',
							'sphere.geometry',
							'radialEmitter',
							'curveEmitter',
							'surfEmitter',
							'sourceEmitter',
							'collectorEmitter',
							'particleTerminator',
							'flockingOp',
							'csvCache',
							'cmPID',
							'pmodel.array',
							'pmodel.falloffSelOp',
							'pmodel.helix',
							'pmodel.linear',
							'pmodel.meshmerge',
							'pmodel.mirror',
							'pmodel.pathGenCurve',
							'pmodel.penGen',
							'pmodel.transformMap',
							'pMod.audio',
							'pMod.basic',
							'pMod.expression',
							'pMod.generator',
							'pMod.lookat',
							'pMod.random',
							'pMod.sieve',
							'pMod.step',
							'points.poisson',
							'pmodel.scatter',
							'item.rock',
							'RPC.Mesh',
							'vertop.selop',
							'edgeop.selop',
							'polyop.selop',
							'typefilter.selop',
							'ADSR.simMod',
							'CameraPlane',
							'CameraMatch',
							'deferredMesh',
							'deferredSubMesh',
							'VDBVoxel',
							'cmFusionUnion',
							'cmFusionIntersect',
							'cmFusionSubtract',
							'sdfStrip.item',
							'sdf.item',
							'ABCCurvesDeform.sample',
							'ABCdeform.sample',
							'dynamicCollider',
							'bakeItemRO',
							'bakeItemTexture',
							'assignselectionset.meshop.item',
							'axisDrill.meshop.item',
							'boolean.meshop.item',
							'delete.meshop.item',
							'freeze.meshop.item',
							'pmodel.materialTag.item',
							'smooth.meshop.item',
							'solidDrill.meshop.item',
							'symmetrize.meshop.item',
							'border.selop.item',
							'boundaryedges.selop.item',
							'growshrink.selop.item',
							'index.selop.item',
							'invert.selop.item',
							'selbyrange.selop.item',
							'useselectionset.selop.item',
							'content.preset.item',
							'curve.circle.item',
							'curve.diamond.item',
							'curve.ellipse.item',
							'curve.nsided.item',
							'curve.rectangle.item',
							'curve.star.item',
							'detriangulate.meshop.item',
							'edge.bevel.item',
							'edge.extrude.item',
							'effector.clone.item',
							'effector.cutter.item',
							'effector.sweep.item',
							'gen.pathsteps.item',
							'pmodel.workplane.item',
							'poly.bevel.item',
							'poly.extrude.item',
							'poly.julienne.item',
							'poly.knife.item',
							'poly.reduct.item',
							'poly.smshift.item',
							'prim.capsule.item',
							'prim.cone.item',
							'prim.cube.item',
							'prim.cylinder.item',
							'prim.ellipsoid.item',
							'prim.sphere.item',
							'prim.text.item',
							'prim.toroid.item',
							'subdivide.tool.item',
							'symmetry.tool.item',
							'vert.bevel.item',
							'vert.extrude.item',
							'vert.merge.item',
							'poly.thicken.item',
							'curve.extrude.item',
							'radial.sweep.item',
							'pen.extrude.item',
							'linear.clone.item',
							'array.clone.item',
							'radial.array.item',
							'scatter.clone.item',
							'curve.clone.item',
							'pen.clone.item',
							'curve.slice.item',
							'pen.slice.item',
							'mirror.clone.item',
							'flowthrough.simMod',
							'follower.simMod',
							'latch.simMod',
							'string.encode')

		self.incompatibleItem = ('advancedMaterial',
								 'defaultShader',
								 'shaderFolder',
								 'wood',
								 'weave',
								 'val',
								 'ripples',
								 'noise',
								 'grid',
								 'dots',
								 'checker',
								 'cellular',
								 'surfGen',
								 'projectShader',
								 'matcapShader',
								 'renderOutput',
								 'projectTexture',
								 'renderOutput',
								 'defaultShader',
								 'furMaterial',
								 'vmapTexture',
								 'variationTexture',
								 'tensionTexture',
								 'process',
								 'occlusion',
								 'gradient',
								 'constant',
								 'image',
								 'imageMap',
								 'mask',
								 'unrealShader',
								 'unityShader',
								 'material',
								 'polyRender',
								 'lightMaterial',
								 'envMaterial',
								 'environment',
								 'scene',
								 'videoStill')

		self.scn = None
		self.selection = None

	def cmd_Flags(self):
		return lx.symbol.fCMD_MODEL | lx.symbol.fCMD_UNDO

	def basic_Enable(self, msg):
		return True

	def cmd_Interact(self):
		pass

	def isolateSelection(self):
		for command in self.commands:
			lx.eval(command)

		self.scn.select(self.selection)

	def isPolygonSelected(self):
		polygonIsSelected = False

		for item in self.selection:
			if item.type == 'mesh':
				if len(item.geometry.polygons.selected) < 1:
					polygonIsSelected = polygonIsSelected or False
				else:
					polygonIsSelected = polygonIsSelected or True

		return polygonIsSelected

	def isEdgeSelected(self):
		edgeIsSelected = False

		for item in self.selection:
			if item.type == 'mesh':
				if len(item.geometry.edges.selected) < 1:
					edgeIsSelected = edgeIsSelected or False
				else:
					edgeIsSelected = edgeIsSelected or True

		return edgeIsSelected

	def isVertexSelected(self):
		vertexIsSelected = False

		for item in self.selection:
			if item.type == 'mesh':
				if len(item.geometry.vertices.selected) < 1:
					vertexIsSelected = vertexIsSelected or False
				else:
					vertexIsSelected = vertexIsSelected or True

		return vertexIsSelected

	def IncompatibleItemSelected(self):
		IncompatibleSelected = False

		for item in self.selection:
			if item.type not in self.compatibleItem:
				print "Incompatible type = " + o
				IncompatibleSelected = True
				break
			else:
				continue

		return IncompatibleSelected

	def NoCompatibleItemSelected(self):
		NoCompatibleSelected = True

		for item in self.selection:
			if item.type not in self.compatibleItem:
				continue
			else:
				NoCompatibleSelected = False
				break

			#print item.name
			#print NoCompatibleSelected

		return NoCompatibleSelected

	def FilterCompatible(self, selection=None):
		if selection==None:
			selection = self.selection

		for i in xrange(len(selection)):
			if selection[i].type.split('.')[0] in self.incompatibleItem:
				self.scn.deselect(selection[i])

	def selectCompatible(self):
		cTypes = ''
		i=0
		for t in self.compatibleItem:
			if i < len(self.compatibleItem):
				cTypes += t + ','
			else:
				cTypes += t

		lx.eval('select.itemType "{}"'.format(cTypes))	

	def basic_Execute(self, msg, flags):
		self.scn = modo.Scene()
		self.selection = self.scn.selected

		if len(self.selection) == 0: #No item selected
			# print 'no item selected'
			self.selectCompatible()
			self.isolateSelection()
		else: #At least one item selected
			if lx.eval('select.typeFrom item;pivot;center;edge;polygon;vertex;ptag ?'): #Item Mode
				#print 'item mode'
				if self.IncompatibleItemSelected() and self.NoCompatibleItemSelected():
					# print 'incompatible and no compatible'
					self.selectCompatible()
					self.isolateSelection()

				elif self.IncompatibleItemSelected():
					# print 'incompatible'
					selection = self.scn.selected

					self.FilterCompatible()
					lx.eval('unhide')
					lx.eval('hide.unsel')

					self.scn.select(selection)

				else:
					# print 'only compatible'
					lx.eval('unhide')
					lx.eval('hide.unsel')

			elif lx.eval('select.typeFrom polygon;edge;vertex;item;pivot;center;ptag ?'): #Polygon Mode
				#print 'polygon mode'
				if self.isPolygonSelected():
					print 'isolate'
					lx.eval('hide.unsel')
				else:
					lx.eval('unhide')

			elif lx.eval('select.typeFrom edge;vertex;polygon;item;pivot;center;ptag ?'): #Edge Mode
				#print 'edge mode'
				if self.isEdgeSelected():
					lx.eval('select.expand')
					lx.eval('select.convert polygon')
					lx.eval('hide.unsel')
				else:
					lx.eval('unhide')

			elif lx.eval('select.typeFrom vertex;edge;polygon;item;pivot;center;ptag ?'): #Vertex Mode
				#print 'vertex mode'
				if self.isVertexSelected():
					lx.eval('select.expand')
					lx.eval('select.expand')
					lx.eval('select.convert polygon')
					lx.eval('hide.unsel')
				else:
					lx.eval('unhide')

	def cmd_Query(self, index, vaQuery):
		lx.notimpl()

lx.bless(CmdTila_isolateSelection, "tila.isolateSelection")

