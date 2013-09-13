package lion.engine.renderer
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import lion.engine.cameras.Camera;
	import lion.engine.core.Mesh;
	import lion.engine.core.Object3D;
	import lion.engine.core.Scene;
	import lion.engine.core.Surface;
	import lion.engine.geometries.Geometry;
	import lion.engine.lights.DirectionalLight;
	import lion.engine.lights.Light;
	import lion.engine.lights.PointLight;
	import lion.engine.lights.SpotLight;
	import lion.engine.materials.BaseMaterial;
	import lion.engine.math.Color;
	import lion.engine.math.Frustum;
	import lion.engine.math.Matrix3;
	import lion.engine.math.Matrix4;
	import lion.engine.math.Vector3;
	import lion.engine.math.Vector4;
	
	/**
	 * 软件渲染 
	 * @author Dalton
	 * 
	 */	
	public class SoftRenderer implements IRenderer
	{
		public var container:Sprite;
		private var context:Graphics;
		private var viewMatrix:Matrix4;
		private var viewProjectionMatrix:Matrix4;
		private var renderList:Vector.<RenderObject>;
		private var renderElements:Vector.<RenderableElement>;
		private var lights:Vector.<Light>;
		private var frustum:Frustum;
		
		public function SoftRenderer()
		{
			container = new Sprite();
			context = container.graphics;
			renderList = new Vector.<RenderObject>();
			renderElements = new Vector.<RenderableElement>();
			viewMatrix = new Matrix4();
			viewProjectionMatrix = new Matrix4();
			lights = new Vector.<Light>;
		}
		
		public function render(scene:Scene, camera:Camera, viewport:Rectangle):void
		{
			// 清屏
			context.clear();
			
			// 更新场景所有物件的矩阵
			scene.updateMatrixWorld();
			if (! camera.parent) camera.updateMatrixWorld();
			
			// 摄像机矩阵
			viewMatrix.copy(camera.matrixWorldInverse.getInverse(camera.matrixWorld));
			// 再乘投影矩阵
			viewProjectionMatrix.multiplyMatrices(camera.projectionMatrix, viewMatrix);
			
			// 获取场景类所有的需要渲染物件
			renderList.length = 0;
			lights.length = 0;
			fillRenderList(scene);
			// TODO 对物体进行Z轴排序
			
			// 遍历所有需要渲染的对象，转化为基本渲染元素
			renderElements.length = 0;
			for each (var r:RenderObject in renderList) {
				var o:Object3D = r.object;
				var modelMatrix:Matrix4 = o.matrixWorld;
				var normalMatrix:Matrix3 = new Matrix3().getNormalMatrix(modelMatrix);
				
				if (o is Mesh) {
					var geometry:Geometry = Mesh(o).geometry;
					var vertices:Vector.<Vector3> = geometry.vertices;
					var faces:Vector.<Surface> = geometry.faces;
					
					var pool:Vector.<Vector4> = new Vector.<Vector4>();
					
					// 顶点变换
					for each (var v:Vector3 in vertices) {
						var p:Vector4 = new Vector4();
						p.copy(v);
						// 模型变换
						p.applyMatrix4(modelMatrix);
						// 投影变换
						p.applyMatrix4(viewProjectionMatrix);
						// 除以齐次值
						var invW:Number = 1 / p.w;
						p.x *= invW;
						p.y *= invW;
						p.z *= invW;
						p.w = 1;
						
						// 视口变换
						var w:Number = viewport.width;
						var h:Number = viewport.height;
						var hw:Number = w / 2;
						var hh:Number = h / 2;
						var toViewPort:Matrix4 = new Matrix4(
							hw - viewport.x, 0,  0, hw,
							0, -(hh - viewport.y), 0, hh,
							0, 0,   1, 0,
							0, 0,   0, 1
						);
						p.applyMatrix4(toViewPort);
						
						// TODO 顶点的视景体剔除
						
						pool.push(p);
					}
					
					// 将三角形面片转成可渲染的面片数据
					for each (var f:Surface in faces) {
						// 背面剔除
						// 正面的顶点方向为顺时针，所有逆时针的面不加入渲染面
						var va:Vector4 = pool[f.a];
						var vb:Vector4 = pool[f.b];
						var vc:Vector4 = pool[f.c];
						var ac:Vector3 = new Vector3().subVectors(new Vector3(vc.x, vc.y, vc.z), new Vector3(va.x, va.y, va.z));
						var cb:Vector3 = new Vector3().subVectors(new Vector3(vb.x, vb.y, vb.z), new Vector3(vc.x, vc.y, vc.z));
						if (ac.cross(cb).z < 0) {
							continue;
						}
						
						var face:RenderableFace = new RenderableFace();
						face.a = va;
						face.b = vb;
						face.c = vc;
						face.id = o.id;
						
						// 世界坐标
						face.centroid.copy(f.centroid).applyMatrix4(modelMatrix);
						face.normal.copy(f.normal).applyMatrix3(normalMatrix).normalize();
						face.material = Mesh(o).material;
						
						// 相对摄像机的坐标
						var centroid:Vector3 = new Vector3().copy(face.centroid).applyProjection(viewProjectionMatrix);
						face.z = centroid.z;
						renderElements.push(face);
					}
				}
			}
			
			// 对基本渲染元素进行排序
			renderElements.sort(painterSort);
			
			// 光栅化，将所有的基本渲染元素光栅化到窗口
			var i:int = 0;
			for each (var e:RenderableElement in renderElements) {
				if (e is RenderableFace) {
					var color:Color = new Color();
					calculateLight(RenderableFace(e).centroid, RenderableFace(e).normal, color);
					if (RenderableFace(e).material is BaseMaterial) {
						context.beginFill(color.toRGB());
//						context.lineStyle(1, 0xFFFFFF);
					} else {
						context.lineStyle(1, 0xFFFFFF);
					}
					e.render(context);
					if (RenderableFace(e).material is BaseMaterial) {
						context.endFill();
					}
				}
			}
		}
		
		/**
		 * 画家排序 
		 * 由远到近
		 * @param a
		 * @param b
		 * @return 
		 * 
		 */		
		private function painterSort(a:RenderableElement, b:RenderableElement):int {
			if (a.z !== b.z) {
				return b.z - a.z > 0 ? -1 : 1;
			} else if (a.id !== b.id) {
				return a.id - b.id > 0 ? -1 : 1;
			} else {
				return 0;
			}
		}
		
		private function fillRenderList(o:Object3D):void
		{
			if (o.visible === false) return;
			if (o is Mesh) {
				// TODO 视景体剔除
				
				
				// 建立渲染对象
				var r:RenderObject = new RenderObject();
				r.id = o.id;
				r.object = o;
				renderList.push(r);
			}
			if (o is Light) {
				lights.push(o);
			}
			for each (var c:Object3D in o.children) {
				fillRenderList(c);
			}
		}
		
		/**
		 * 计算光照 
		 * @param position
		 * @param normal
		 * @param color
		 * 
		 */		
		private function calculateLight(position:Vector3, normal:Vector3, color:Color):void {
			var lightColor:Color = new Color();
			var lightPosition:Vector3;
			var amount:Number;
			
			for each (var l:Light in lights) {
				lightColor.copy(l.color);
				
				if (l is DirectionalLight) {
					lightPosition = new Vector3().getPositionFromMatrix(l.matrixWorld).normalize();
					amount = normal.dot(lightPosition);
					if (amount <= 0) continue;
					amount *= DirectionalLight(l).intensity;
					color.add(lightColor.multiplyScalar(amount));
				} else if (l is PointLight) {
					lightPosition = new Vector3().getPositionFromMatrix(l.matrixWorld);
					amount = normal.dot(lightPosition.subVectors(lightPosition, position).normalize());
					if (amount <= 0) continue;
					amount *= PointLight(l).distance == 0 ? 1 : 1 - Math.min(position.dist(lightPosition) / PointLight(l).distance, 1);
					if ( amount == 0 ) continue;
					amount *= PointLight(l).intensity;
					color.add(lightColor.multiplyScalar(amount));
				}
			}
		}
	}
}
import flash.display.Graphics;

import lion.engine.core.Object3D;
import lion.engine.materials.Material;
import lion.engine.math.Vector3;
import lion.engine.math.Vector4;

class RenderObject {
	public var id:int;
	public var object:Object3D;
}

class RenderableElement {
	public var id:int;
	public var z:Number;
	public function render(context:Graphics):void {
		
	}
}

class RenderableFace extends RenderableElement {
	public var a:Vector4;
	public var b:Vector4;
	public var c:Vector4;
	public var centroid:Vector3;
	public var normal:Vector3;
	public var material:Material;
	
	public function RenderableFace() {
		a = new Vector4();
		b = new Vector4();
		c = new Vector4();
		centroid = new Vector3();
		normal = new Vector3();
	}
	
	override public function render(context:Graphics):void {
//		context.beginFill(0xFFFFFF, 1.0);
		context.moveTo(a.x, a.y);
		context.lineTo(b.x, b.y);
		context.lineTo(c.x, c.y);
		context.lineTo(a.x, a.y);
//		context.endFill();
	}
}