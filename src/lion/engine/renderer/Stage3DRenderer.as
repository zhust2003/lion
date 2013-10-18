package lion.engine.renderer
{
	import com.adobe.utils.AGALMiniAssembler;
	import com.adobe.utils.PerspectiveMatrix3D;
	
	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	import lion.engine.cameras.Camera;
	import lion.engine.core.Mesh;
	import lion.engine.core.Object3D;
	import lion.engine.core.Scene;
	import lion.engine.core.Surface;
	import lion.engine.geometries.Geometry;
	import lion.engine.lights.Light;
	import lion.engine.math.Frustum;
	import lion.engine.math.Matrix3;
	import lion.engine.math.Matrix4;
	import lion.engine.math.Vector2;
	import lion.engine.math.Vector3;
	import lion.engine.math.Vector4;
	
	public class Stage3DRenderer implements IRenderer
	{
		private var stage:Stage;
		public var stage3D:Stage3D;
		private var context:Context3D;
		
		private var indexList:IndexBuffer3D;
		private var vertexes:VertexBuffer3D;
		private var finalTransform:Matrix3D = new Matrix3D();
		
		private var viewMatrix:Matrix4;
		private var viewProjectionMatrix:Matrix4;
		private var frustum:Frustum;
		private var renderList:Vector.<RenderObject>;
		private var lights:Vector.<Light>;
		private var renderElements:Vector.<RenderableElement>;
		
		[Embed(source="../../../../assets/t.png", mimeType="image/png")]
		private var t:Class;
		public var drawCount:int;
		private var currentProgram3D:Program3D;
		private var currentSide:String;
		
		public function Stage3DRenderer(stage:Stage, renderMode:String="auto", profile:String="baselineConstrained")
		{
			this.stage = stage;
			trace('stage3D length:', this.stage.stage3Ds.length);
			
			if (this.stage.stage3Ds.length > 0) {
				this.stage3D = this.stage.stage3Ds[0];
				stage3D.addEventListener(Event.CONTEXT3D_CREATE, onCreate);
				stage3D.addEventListener(ErrorEvent.ERROR, onError);
				
				var requestContext3D:Function = stage3D.requestContext3D;
				if (requestContext3D.length == 1) requestContext3D(renderMode);
				else requestContext3D(renderMode, profile);
			}
			
			renderList = new Vector.<RenderObject>();
			renderElements = new Vector.<RenderableElement>();
			viewMatrix = new Matrix4();
			viewProjectionMatrix = new Matrix4();
			lights = new Vector.<Light>;
			frustum = new Frustum();
		}
		
		protected function onError(event:ErrorEvent):void
		{
			if (event.errorID == 3702)
				trace("This application is not correctly embedded (wrong wmode value)");
			else
				trace("Stage3D error: " + event.text);
		}
		
		protected function onCreate(event:Event):void
		{
			init();
		}
		
		protected function init():void {
			context = stage3D.context3D;
			trace("Display Driver:", context.driverInfo);
			
			configContext3D();
		}
		
		private function configContext3D():void
		{
			context.enableErrorChecking = true; //Can slow rendering - only turn on when developing/testing
			context.configureBackBuffer(stage.stageWidth, stage.stageHeight, 2, false);
			// stage3d 顺时针是正面朝向，逆时针是反面朝向，与opengl相反
//			context.setCulling(Context3DTriangleFace.FRONT);
//			context.setDepthTest(true, Context3DCompareMode.LESS_EQUAL);
			
			// 设置纹理
//			var b:BitmapData = (new t()).bitmapData;
//			var texture:Texture = context.createTexture(b.width, b.height, Context3DTextureFormat.BGRA, false);
//			texture.uploadFromBitmapData(b);
//			context.setTextureAt(0, texture);
		}
		
		
		/**
		 * 模型转为基本渲染对象 
		 * 由于基本的模型是树形结构，所有需要平铺得到所有的渲染对象
		 * @param o
		 * 
		 */		
		private function fillRenderList(o:Object3D):void
		{
			if (o.visible === false) return;
			if (o is Mesh) {
				// 视景体剔除
				if (frustum.intersectsObject(o as Mesh)) {
					
					// 建立渲染对象
					var r:RenderObject = new RenderObject();
					r.id = o.id;
					r.object = o;
					r.z = Mesh(o).position.z;
					renderList.push(r);
				}
			}
			if (o is Light) {
				lights.push(o);
			}
			for each (var c:Object3D in o.children) {
				fillRenderList(c);
			}
		}
		
		/**
		 * 物体排序 
		 * @param a
		 * @param b
		 * @return 
		 * 
		 */		
		private function painterSortByObject(a:RenderObject, b:RenderObject):int {
			if (a.z !== b.z) {
				return b.z - a.z < 0 ? -1 : 1;
			} else if (a.id !== b.id) {
				return a.id - b.id > 0 ? -1 : 1;
			} else {
				return 0;
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
				return b.z - a.z < 0 ? -1 : 1;
			} else if (a.id !== b.id) {
				return a.id - b.id > 0 ? -1 : 1;
			} else {
				return 0;
			}
		}
		
		public function render(scene:Scene, camera:Camera, viewport:Rectangle):void
		{
			// 更新场景所有物件的矩阵
			scene.updateMatrixWorld();
			if (! camera.parent) camera.updateMatrixWorld();
			
			// 摄像机矩阵
			viewMatrix.copy(camera.matrixWorldInverse.getInverse(camera.matrixWorld));
			// 再乘投影矩阵
			viewProjectionMatrix.multiplyMatrices(camera.projectionMatrix, viewMatrix);
			// 设置视景体
			frustum.setFromMatrix(viewProjectionMatrix);
			
			// 获取场景类所有的需要渲染物件
			renderList.length = 0;
			lights.length = 0;
			fillRenderList(scene);
			renderList.sort(painterSortByObject);
			
			// 遍历所有需要渲染的对象，转化为基本渲染元素
			renderElements.length = 0;
			// 所有顶点
			var pool:Vector.<Number> = new Vector.<Number>();
			var offset:int = 0;
			
			for each (var r:RenderObject in renderList) {
				var o:Object3D = r.object;
				var modelMatrix:Matrix4 = o.matrixWorld;
				
				if (o is Mesh) {
					var geometry:Geometry = Mesh(o).geometry;
					var vertices:Vector.<Vector3> = geometry.vertices;
					var faces:Vector.<Surface> = geometry.faces;
					var normals:Vector.<Vector3> = geometry.normals;
					var uvs:Array = geometry.faceVertexUvs;
					
					// 将三角形面片转成可渲染的面片数据
					var t:Vector.<uint> = new Vector.<uint>();
					var faceIndex:int = 0;
					for each (var f:Surface in faces) {
						// 顶点数据
						var v1:Vector3 = vertices[f.a];
						var v2:Vector3 = vertices[f.b];
						var v3:Vector3 = vertices[f.c];
						var allVertices:Array = [v1, v2, v3];
						var vertexNormals:Array = f.vertexNormals;
						var i:int = 0;
						
						var uv:Array = uvs[faceIndex];
						
						for each (var v:Vector3 in allVertices) {
							// 坐标
							pool.push(v.x);
							pool.push(v.y);
							pool.push(v.z);
							
							// u,v
							pool.push(uv[i].x);
							pool.push(uv[i].y);
							
							// 法线
							// 如果有顶点法线
							if (vertexNormals.length == 3) {
								var vn:Vector3 = vertexNormals[i];
								pool.push(vn.x);
								pool.push(vn.y);
								pool.push(vn.z);
							} else {
								pool.push(f.normal.x);
								pool.push(f.normal.y);
								pool.push(f.normal.z);
							}
							i++;
						}
						
						// 索引数据
						t.push(offset);
						t.push(offset + 1);
						t.push(offset + 2);
						offset += 3;
						faceIndex ++;
					}
					
					
					// 基本的渲染面
					// 一整个物体，一个渲染元素
					var centroid:Vector3 = new Vector3();
					var re:RenderableElement = new RenderableElement();
					re.model = modelMatrix;
					re.triangleCount = t.length / 3;
					re.indexList = t;
					centroid.copy(Mesh(o).position).applyProjection(viewProjectionMatrix);
					re.z = centroid.z;
					re.object = r.object;
					renderElements.push(re);
				}
			}
			
			if (pool.length <= 0) return;
			
			// 对基本渲染元素进行排序
			renderElements.sort(painterSort);
			
			// 顶点数组
			const dataPerVertex:int = 8;
			vertexes = context.createVertexBuffer(pool.length/dataPerVertex, dataPerVertex);
			vertexes.uploadFromVector(pool, 0, pool.length/dataPerVertex);
			
			context.setVertexBufferAt(0, vertexes, 0, Context3DVertexBufferFormat.FLOAT_3); // va0 is position
			context.setVertexBufferAt(1, vertexes, 3, Context3DVertexBufferFormat.FLOAT_2); // va1 is uv
			context.setVertexBufferAt(2, vertexes, 5, Context3DVertexBufferFormat.FLOAT_3); // va2 is normal
			
			
			drawCount = 0;
			
			context.clear(0, 0, 0);
			
			// 光栅化，将所有的基本渲染元素光栅化到窗口
			for each (var e:RenderableElement in renderElements) {
				// 设置渲染程序（顶点，片段）
				setProgram(e.object as Mesh);
				
				// 索引数组
				indexList = context.createIndexBuffer(e.indexList.length);
				indexList.uploadFromVector(e.indexList, 0, e.indexList.length);

				// 模型视图投影矩阵
				finalTransform.identity();
				finalTransform.append(e.model.toMatrix3D());
				finalTransform.append(viewProjectionMatrix.toMatrix3D());
				
				// 将常量提交给顶点着色器，对应变量为vc2
				context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 2, finalTransform, true);
				
				// 模型矩阵
				finalTransform.identity();
				finalTransform.append(e.model.toMatrix3D());
				context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 6, finalTransform, true);
				
				// 法线矩阵
				var normalMatrix:Matrix3 = new Matrix3().getNormalMatrix(e.model);
				context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 10, normalMatrix.toMatrix3D(), true);
				
				
				// 绘制三角形
				context.drawTriangles(indexList, 0, e.triangleCount);
				drawCount++;
				
				indexList.dispose();
			}
			
			vertexes.dispose();
			
			// 呈现
			context.present();
		}
		
		private function setProgram(object:Mesh):void
		{
			// 如果材质对应的着色器对还没初始化
			if (object.material.dirty) {
				object.material.program = initProgram(object.material.vshader, object.material.fshader);
				object.material.dirty = false;
			}
			// 设置着色器对
			var program:Program3D = object.material.program;
			if (program != currentProgram3D) {
				context.setProgram(program);
				currentProgram3D = program;
			}
			// 初始化材质需要提交给GPU的东西，
			// 比如纹理需要绑定等等
			if (object.material.texture) {
				var t:TextureBase = object.material.texture.getTexture(context);
				context.setTextureAt(0, t);
			} else {
				context.setTextureAt(0, null);
			}
			
			// 剔除面
			if (object.material.side != currentSide) {
				context.setCulling(object.material.side);
				currentSide = object.material.side;
			}
			
			// 计算所有的光照，提交到着色器
			// 临时光源
			// 光源位置
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, Vector.<Number>([0, 30, 20, 1]), 1);
			// 光源颜色
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 1, Vector.<Number>([1, 1, 1, 1]), 1);
		}
		
		/**
		 * 初始化着色器对 
		 * @param vertexAssembly
		 * @param fragmentAssembly
		 * 
		 */		
		private function initProgram(vertexAssembly:AGALMiniAssembler, fragmentAssembly:AGALMiniAssembler):Program3D {
			var program:Program3D = context.createProgram();
			program.upload(vertexAssembly.agalcode, fragmentAssembly.agalcode);
			
			return program;
		}
	}
}


import flash.display.Graphics;
import flash.display3D.IndexBuffer3D;

import lion.engine.core.Object3D;
import lion.engine.materials.Material;
import lion.engine.math.Matrix4;
import lion.engine.math.Vector3;
import lion.engine.math.Vector4;

class RenderObject {
	public var id:int;
	public var object:Object3D;
	public var z:Number;
}

class RenderableElement {
	public var id:int;
	public var z:Number;
	public var model:Matrix4;
	public var indexList:Vector.<uint>;
	public var triangleCount:uint;
	public var object:Object3D;
	public function render(context:Graphics):void {
		
	}
}