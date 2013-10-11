package lion.engine.renderer
{
	import com.adobe.utils.AGALMiniAssembler;
	import com.adobe.utils.PerspectiveMatrix3D;
	
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
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
		
		// Gouraud Shader
		private const VERTEX_SHADER:String =
			"m44 op, va0, vc2    \n" +    // 4x4 matrix transform 
//			'mov vt0, va2 \n' +
//			'mov v0, va1 \n';
		
			// 直线光，flat着色
			// 光源朝向顶点坐标的向量
			'm44 vt0, va0, vc6 \n' +
			'sub vt1, vc0, vt0 \n' + 
			'nrm vt1.xyz, vt1.xyz \n' +
			
			// 法线变换并归一化
			'm33 vt2.xyz, va2.xyz, vc10 \n' +
			'nrm vt2.xyz, vt2.xyz \n' +
			
			// 点积 CosA = L . Normal
			'dp3 vt3.x, vt1.xyz, vt2.xyz \n' +	
			'sat vt3.x, vt3.x \n' +
			'mul vt4.rgb, vc1.rgb, vt3.xxx \n' + 
			'mov v0, vt4.rgb \n';
		
	
		
		private const FRAGMENT_SHADER:String = 
			"mov oc, v0"; //Set the output color to the value interpolated from the three triangle vertices
		
		
		// Phong Shader
//		private const VERTEX_SHADER:String =
//			"m44 op, va0, vc2    \n" +    // 4x4 matrix transform 
//			'mov v0, va0 \n' +
//			
//			// 法线变换并归一化
//			'm33 vt2.xyz, va2.xyz, vc10 \n' +
//			'nrm vt2.xyz, vt2.xyz \n' +
//			'mov v2, vt2.xyz \n' +
//			
//			'mov v1, va2';
//		
//		private const FRAGMENT_SHADER:String = 
//			// 直线光，flat着色
//			// 光源朝向顶点坐标的向量
//			'm44 ft0, v0, fc6 \n' +
//			'sub ft1, fc0, ft0 \n' + 
//			'nrm ft1.xyz, ft1.xyz \n' +
//			
//			'dp3 ft3.x, ft1.xyz, v2.xyz \n' +	
//			'sat ft3.x, ft3.x \n' +
//			'mul ft4.rgb, fc1.rgb, ft3.xxx \n' + 
//			"mov oc, ft4"; //Set the output color to the value interpolated from the three triangle vertices
		
		private var vertexAssembly:AGALMiniAssembler = new AGALMiniAssembler();
		private var fragmentAssembly:AGALMiniAssembler = new AGALMiniAssembler();
		private var programPair:Program3D;
		
		private var viewMatrix:Matrix4;
		private var viewProjectionMatrix:Matrix4;
		private var frustum:Frustum;
		private var renderList:Vector.<RenderObject>;
		private var lights:Vector.<Light>;
		private var renderElements:Vector.<RenderableElement>;
		
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
				
				
				// Compile shaders
				// 两个可编程管线，顶点着色器跟像素着色器
				vertexAssembly.assemble(Context3DProgramType.VERTEX, VERTEX_SHADER, false);
				fragmentAssembly.assemble(Context3DProgramType.FRAGMENT, FRAGMENT_SHADER, false);  
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
			context.setCulling(Context3DTriangleFace.FRONT);
//			context.setDepthTest(true, Context3DCompareMode.LESS_EQUAL);
			
			programPair = context.createProgram();
			programPair.upload(vertexAssembly.agalcode, fragmentAssembly.agalcode);
			context.setProgram(programPair);
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
					
					
					// 将三角形面片转成可渲染的面片数据
					var t:Vector.<uint> = new Vector.<uint>();
					for each (var f:Surface in faces) {
						// 顶点数据
						var v1:Vector3 = vertices[f.a];
						var v2:Vector3 = vertices[f.b];
						var v3:Vector3 = vertices[f.c];
						var allVertices:Array = [v1, v2, v3];
						var vertexNormals:Array = f.vertexNormals;
						var i:int = 0;
						
						for each (var v:Vector3 in allVertices) {
							// 坐标
							pool.push(v.x);
							pool.push(v.y);
							pool.push(v.z);
							
							// 颜色
							pool.push(1);
							pool.push(1);
							pool.push(1);
							
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
					}
					
					
					// 基本的渲染面
					var centroid:Vector3 = new Vector3();
					var re:RenderableElement = new RenderableElement();
					re.model = modelMatrix;
					re.triangleCount = t.length / 3;
					re.indexList = t;
					centroid.copy(Mesh(o).position).applyProjection(viewProjectionMatrix);
					re.z = centroid.z;
					renderElements.push(re);
				}
			}
			
			if (pool.length <= 0) return;
			
			// 对基本渲染元素进行排序
			renderElements.sort(painterSort);
			
			// 顶点数组
			const dataPerVertex:int = 9;
			vertexes = context.createVertexBuffer(pool.length/dataPerVertex, dataPerVertex);
			vertexes.uploadFromVector(pool, 0, pool.length/dataPerVertex);
			
			context.setVertexBufferAt(0, vertexes, 0, Context3DVertexBufferFormat.FLOAT_3); // va0 is position
//			context.setVertexBufferAt(1, vertexes, 3, Context3DVertexBufferFormat.FLOAT_3); // va2 is normal
			context.setVertexBufferAt(2, vertexes, 6, Context3DVertexBufferFormat.FLOAT_3); // va2 is normal
			
			
			var drawCount:int = 0;
			
			context.clear(0, 0, 0);
			
			// 光栅化，将所有的基本渲染元素光栅化到窗口
			for each (var e:RenderableElement in renderElements) {
				// 索引数组
				indexList = context.createIndexBuffer(e.indexList.length);
				indexList.uploadFromVector(e.indexList, 0, e.indexList.length);
				
				// 光源位置
				context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, Vector.<Number>([0, 30, 20, 1]), 1);
				// 光源颜色
				context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 1, Vector.<Number>([1, 1, 1, 1]), 1);

				// 模型视图投影矩阵
				finalTransform.identity();
				finalTransform.append(e.model.toMatrix3D());
				finalTransform.append(viewProjectionMatrix.toMatrix3D());
				//				// 视口变换
				//				var w:Number = viewport.width;
				//				var h:Number = viewport.height;
				//				var hw:Number = w / 2;
				//				var hh:Number = h / 2;
				//				var toViewPort:Matrix3D = new Matrix3D(Vector.<Number>([
				//					hw - viewport.x, 0,  0, hw,
				//					0, -(hh - viewport.y), 0, hh,
				//					0, 0,   1, 0,
				//					0, 0,   0, 1
				//				]));
				//				finalTransform.append(toViewPort);
				
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
	public function render(context:Graphics):void {
		
	}
}