package lion.engine.renderer
{
	import com.adobe.utils.AGALMiniAssembler;
	import com.adobe.utils.PerspectiveMatrix3D;
	
	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
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
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	import lion.engine.cameras.Camera;
	import lion.engine.cameras.OrthographicCamera;
	import lion.engine.cameras.PerspectiveCamera;
	import lion.engine.core.Mesh;
	import lion.engine.core.Object3D;
	import lion.engine.core.Scene;
	import lion.engine.core.SkyBox;
	import lion.engine.core.Surface;
	import lion.engine.geometries.Geometry;
	import lion.engine.geometries.PlaneGeometry;
	import lion.engine.lights.DirectionalLight;
	import lion.engine.lights.Light;
	import lion.engine.lights.PointLight;
	import lion.engine.materials.DepthMaterial;
	import lion.engine.materials.Material;
	import lion.engine.materials.MaterialUpdateState;
	import lion.engine.materials.WireframeMaterial;
	import lion.engine.math.Frustum;
	import lion.engine.math.Matrix3;
	import lion.engine.math.Matrix4;
	import lion.engine.math.Plane;
	import lion.engine.math.Vector2;
	import lion.engine.math.Vector3;
	import lion.engine.math.Vector4;
	import lion.engine.renderer.base.RenderableElement;
	import lion.engine.textures.RenderTexture;
	
	public class Stage3DRenderer implements IRenderer
	{
		private var stage:Stage;
		public var stage3D:Stage3D;
		public var context:Context3D;
		
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
		
		private var s:MaterialUpdateState;
		private var _depthViewProjectionMatrix:Matrix4;
		private var _depthShadowMap:RenderTexture;
		
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
			s = new MaterialUpdateState();
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
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			context = stage3D.context3D;
			trace("Display Driver:", context.driverInfo);
			
			configContext3D();
			stage.addEventListener(Event.RESIZE, onResize);
		}
		
		protected function onResize(event:Event):void
		{
			trace('reconfig context3d', stage.stageWidth, stage.stageHeight);
			context.configureBackBuffer(stage.stageWidth, stage.stageHeight, 2, true);
		}
		
		private function configContext3D():void
		{
			context.enableErrorChecking = true; //Can slow rendering - only turn on when developing/testing
			context.configureBackBuffer(stage.stageWidth, stage.stageHeight, 2, true);
			// not blend
			context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			// stage3d 顺时针是正面朝向，逆时针是反面朝向，与opengl相反
			context.setCulling(Context3DTriangleFace.NONE);
			currentSide = Context3DTriangleFace.NONE;
			context.setDepthTest(true, Context3DCompareMode.LESS_EQUAL);
			
			// 设置纹理
			s.context = context;
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
					r.z = o.position.z;
					renderList.push(r);
				}
			}
			if (o is Light) {
				if (o is PointLight) {
					s.numPointLights++;
				}
				if (o is DirectionalLight) {
					s.numDirectionalLights++;
				}
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
			s.reset();
			fillRenderList(scene);
			s.lights = lights;
			
			// 对物体进行排序
			renderList.sort(painterSortByObject);
			
			// 遍历所有需要渲染的对象，转化为基本渲染元素
			renderElements.length = 0;
			
			var centroid:Vector3 = new Vector3();
			for each (var r:RenderObject in renderList) {
				var o:Object3D = r.object;
				var modelMatrix:Matrix4 = o.matrixWorld;
				
				if (o is Mesh) {
					var geometry:Geometry = Mesh(o).geometry;
					
					var re:RenderableElement = geometry.renderableElement;
					
					if (! re) {
						var vertices:Vector.<Vector3> = geometry.vertices;
						var faces:Vector.<Surface> = geometry.faces;
//						var normals:Vector.<Vector3> = geometry.normals;
						var uvs:Vector.<Vector.<Vector2>> = geometry.faceVertexUvs;
						
						// 将三角形面片转成可渲染的面片数据
						var vertexPool:Vector.<Number> = new Vector.<Number>();
						var indexPool:Vector.<uint> = new Vector.<uint>();
						var faceIndex:int = 0;
						var offset:int = 0;
						for each (var f:Surface in faces) {
							// 顶点数据
							var v1:Vector3 = vertices[f.a];
							var v2:Vector3 = vertices[f.b];
							var v3:Vector3 = vertices[f.c];
							var allVertices:Array = [v1, v2, v3];
							var vertexNormals:Array = f.vertexNormals;
							var i:int = 0;
							
							var uv:Vector.<Vector2> = uvs[faceIndex];
							
							// 插入所有顶点数据
							for (var key:int = 0; key < allVertices.length; key++) {
								var v:Vector3 = allVertices[key];
								// 坐标
								vertexPool.push(v.x);
								vertexPool.push(v.y);
								vertexPool.push(v.z);
								
								// u,v
								vertexPool.push(uv[i].x);
								vertexPool.push(uv[i].y);
								
								// 法线
								// 如果有顶点法线
								if (vertexNormals.length == 3) {
									var vn:Vector3 = vertexNormals[i];
									vertexPool.push(vn.x);
									vertexPool.push(vn.y);
									vertexPool.push(vn.z);
								} else {
									vertexPool.push(f.normal.x);
									vertexPool.push(f.normal.y);
									vertexPool.push(f.normal.z);
								}
								
								// 如果是线框图，才需要计算顶点与对应边的距离
								if (Mesh(o).material is WireframeMaterial) {
									// 计算每个顶点到另外两条边的距离
									// 计算投影后的v1, v2, v3位置
									// 因为没有几何着色器，所以投影距离只能软计算
									var lv1:Vector3 = projectionVector(v1, modelMatrix);
									var lv2:Vector3 = projectionVector(v2, modelMatrix);
									var lv3:Vector3 = projectionVector(v3, modelMatrix);
									var vd:Vector3 = new Vector3();
									if (key == 0) {
										vd.x = calcDist(lv1, lv2, lv3);
									} else if (key == 1) {
										vd.y = calcDist(lv2, lv1, lv3);
									} else {
										vd.z = calcDist(lv3, lv1, lv2);
									}
									vertexPool.push(vd.x);
									vertexPool.push(vd.y);
									vertexPool.push(vd.z);
								}
								i++;
							}
							
							
							
							// 索引数据
							indexPool.push(offset);
							indexPool.push(offset + 1);
							indexPool.push(offset + 2);
							offset += 3;
							faceIndex ++;
						}
						
						
						// 基本的渲染面
						// 一整个物体，一个渲染元素
						re = new RenderableElement();
						re.model = modelMatrix;
						re.triangleCount = indexPool.length / 3;
						re.indexList = indexPool;
						re.vertexList = vertexPool;
						centroid.copy(o.position).applyProjection(viewProjectionMatrix);
						re.z = centroid.z;
						re.object = r.object;
						re.context = context;
						
						geometry.renderableElement = re;
					}
					
					renderElements.push(re);
				}
			}
			
			if (renderElements.length <= 0) return;
			
			// 对基本渲染元素进行排序
			renderElements.sort(painterSort);
			
			
			drawCount = 0;
			
			
			// pre render
			
			// 更新光照阴影图
			updateLightShadow();
			
			context.setRenderToBackBuffer();
			context.clear(0.19, 0.30, 0.47);
			
			// 光栅化，将所有的基本渲染元素光栅化到窗口
			for each (var e:RenderableElement in renderElements) {
				renderElement(e, camera, viewProjectionMatrix);
			}
			
			
			// 呈现
			context.present();
			
			// post render
		}
		
		private function projectionVector(v:Vector3, modelMatrix:Matrix4):Vector3 {
			var lv1:Vector4 = new Vector4();
			lv1.copy(v);
			lv1.applyMatrix4(modelMatrix);
			// 投影变换
			lv1.applyMatrix4(viewProjectionMatrix);
			// 除以齐次值
			var invW:Number = 1 / lv1.w;
			lv1.x *= invW;
			lv1.y *= invW;
			lv1.z *= invW;
			lv1.w = 1;
			
			// 视口变换
			var w:Number = stage.stageWidth;
			var h:Number = stage.stageHeight;
			var hw:Number = w / 2;
			var hh:Number = h / 2;
			var toViewPort:Matrix4 = new Matrix4(
				hw - 0, 0,  0, hw,
				0, -(hh - 0), 0, hh,
				0, 0,   1, 0,
				0, 0,   0, 1
			);
			lv1.applyMatrix4(toViewPort);
			
			return new Vector3(lv1.x, lv1.y, lv1.z);
		}
		
		private function calcDist(v1:Vector3, v2:Vector3, v3:Vector3):Number
		{
			var v2v3:Vector3 = new Vector3().subVectors(v3, v2).normalize();
			var v1v2:Vector3 = new Vector3().subVectors(v1, v2);
			var det:Number = v1v2.dot(v2v3);
			
			return v1.dist(v2v3.multiply(det).add(v2));
		}
		
		private function renderElement(e:RenderableElement, camera:Camera, vpm:Matrix4, material:Material = null):void {
			// 初始化顶点，索引缓冲区
			e.initVertexBuffer();
			e.initIndexBuffer();
			e.setPositionBuffer();
			
			// 模型矩阵
			s.matrix = e.model.toMatrix3D();
			
			// 投影矩阵
			s.viewProjectionMatrix = vpm.toMatrix3D();
			
			// 法线矩阵
			var normalMatrix:Matrix3 = new Matrix3().getNormalMatrix(e.model);
			s.normalMatrix = normalMatrix.toMatrix3D();
			
			// 相机位置
			s.cameraPosition = camera.position;
			
			// 渲染元素
			s.renderElement = e;
			
			// 阴影相关
			if (_depthViewProjectionMatrix) {
				s.depthViewProjectionMatrix = _depthViewProjectionMatrix.toMatrix3D();
				s.depthTexture = _depthShadowMap;
			}
			
			// 设置渲染程序（顶点，片段）			
			var m:Material = material || (e.object as Mesh).material;
			
			// 激活材质
			m.activate(s.context);
			
			// 更新材质信息
			m.update(s);
			
			// 剔除面
			if (m.side != currentSide) {
				context.setCulling(m.side);
				currentSide = m.side;
			}
			
			// 渲染
			e.render();
			
			// 析构材质
			m.deactivate(s.context);
			
			drawCount++;
			
			e.dispose();
			
			// 重新清理绑定纹理及顶点缓存
			for (var ia:uint = 0; ia < 8; ++ia) {
				context.setVertexBufferAt(ia, null);
				context.setTextureAt(ia, null);
			}
		}
		
		/**
		 * 更新光照阴影图 
		 * 
		 */		
		private function updateLightShadow():void
		{
			// 遍历每个需要产生阴影的光照
			for each (var l:Light in lights) {
				if (l.castShadow) {
					if (l.shadowMap) {
						l.shadowMap.dispose();
					}
					// 渲染纹理大小
					l.shadowMap = new RenderTexture(1024, 1024);
					
					// 以这个shadowmap作为渲染目标
					context.setRenderToTexture(l.shadowMap.getTexture(context, true), true);
					context.clear(0, 0, 0);
					
					// 不同的光源不同的相机类型
					var camera:Camera;
					if (l is DirectionalLight) {
						camera = new OrthographicCamera(-200, 200, 200, -200);
					} else if (l is PointLight) {
						camera = new PerspectiveCamera(50, 1);
					}
					// 光源位置
					camera.position.getPositionFromMatrix(l.matrixWorld);
					// 光源方向
					var normalMatrix:Matrix3 = new Matrix3();
					normalMatrix.getNormalMatrix(l.matrixWorld);
					camera.lookAt(new Vector3(0, 0, -1).applyMatrix3(normalMatrix));
					camera.updateMatrixWorld();

					// 以这个光作为摄像机位置
					// 生成每个光照的shadowmap
					var vm:Matrix4 = new Matrix4();
					var vpm:Matrix4 = new Matrix4();
					
					// 新的视图投影矩阵
					vm.copy(camera.matrixWorldInverse.getInverse(camera.matrixWorld));
					vpm.multiplyMatrices(camera.projectionMatrix, vm);
					
					_depthViewProjectionMatrix = vpm;
					_depthShadowMap = l.shadowMap;
					
					// 深度材质
					var depthMaterial:DepthMaterial = new DepthMaterial();
					
					// 渲染所有
					for each (var e:RenderableElement in renderElements) {
						if (! (e.object is SkyBox)) {
							renderElement(e, camera, vpm, depthMaterial);
						}
					}
					
					// 调试使用
//					for each (var e:RenderableElement in renderElements) {
//						if (Mesh(e.object).geometry is PlaneGeometry) {
//							Mesh(e.object).material.texture = l.shadowMap;
//						}
//					}
					// 只支持一个
					break;
				}
			}
		}
	}
}


import flash.display.Graphics;
import flash.display3D.Context3D;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.IndexBuffer3D;
import flash.display3D.VertexBuffer3D;

import lion.engine.core.Object3D;
import lion.engine.materials.Material;
import lion.engine.math.Matrix4;
import lion.engine.math.Vector3;
import lion.engine.math.Vector4;

/**
 * 渲染基本物件 
 * @author Dalton
 * 
 */
class RenderObject {
	public var id:int;
	public var object:Object3D;
	public var z:Number;
}
