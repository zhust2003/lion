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
		private var stage3D:Stage3D;
		private var context:Context3D;
		
		private var indexList:IndexBuffer3D;
		private var vertexes:VertexBuffer3D;
		private var finalTransform:Matrix3D = new Matrix3D();
		
		private const VERTEX_SHADER:String =
			"m44 op, va0, vc0    \n" +    // 4x4 matrix transform 
			"mov v0, va1"; //copy color to varying variable v0
		
		private const FRAGMENT_SHADER:String = 
			"mov oc, v0"; //Set the output color to the value interpolated from the three triangle vertices 
		
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
			
			// 遍历所有需要渲染的对象，转化为基本渲染元素
			renderElements.length = 0;
			var pool:Vector.<Number> = new Vector.<Number>();
			var offset:int = 0;
			
			for each (var r:RenderObject in renderList) {
				var o:Object3D = r.object;
				var modelMatrix:Matrix4 = o.matrixWorld;
				
				if (o is Mesh) {
					var geometry:Geometry = Mesh(o).geometry;
					var vertices:Vector.<Vector3> = geometry.vertices;
					var faces:Vector.<Surface> = geometry.faces;
					
					
					// 将三角形面片转成可渲染的面片数据
					var t:Vector.<uint> = new Vector.<uint>();
					for each (var f:Surface in faces) {
						t.push(f.a + offset);
						t.push(f.b + offset);
						t.push(f.c + offset);
					}
					
					// 顶点变换
					for each (var v:Vector3 in vertices) {
						pool.push(v.x);
						pool.push(v.y);
						pool.push(v.z);
						
						pool.push(v.x);
						pool.push(v.y);
						pool.push(v.z);
						
						offset += 1;
					}
					
					// 基本的渲染面
					var re:RenderableElement = new RenderableElement();
					re.model = modelMatrix;
					re.triangleCount = t.length / 3;
					re.indexList = t;
					renderElements.push(re);
				}
			}
			
			if (pool.length <= 0) return;
			
			// 顶点数组
			const dataPerVertex:int = 6;
			vertexes = context.createVertexBuffer(pool.length/dataPerVertex, dataPerVertex);
			vertexes.uploadFromVector(pool, 0, pool.length/dataPerVertex);
			
			context.setVertexBufferAt(0, vertexes, 0, Context3DVertexBufferFormat.FLOAT_3); // va0 is position
			context.setVertexBufferAt(1, vertexes, 3, Context3DVertexBufferFormat.FLOAT_3); // va1 is color
			
			
			var drawCount:int = 0;
			
			context.clear(0, 0, 0);
			
			// 光栅化，将所有的基本渲染元素光栅化到窗口
			for each (var e:RenderableElement in renderElements) {
				// 索引数组
				indexList = context.createIndexBuffer(e.indexList.length);
				indexList.uploadFromVector(e.indexList, 0, e.indexList.length);

				// 最终矩阵
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

				// 将常量提交给顶点着色器，对应变量为vc0
				context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, finalTransform, true);
				
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