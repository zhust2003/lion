package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	import lion.engine.cameras.OrthographicCamera;
	import lion.engine.cameras.PerspectiveCamera;
	import lion.engine.geometries.CubeGeometry;
	import lion.engine.math.MathUtil;
	import lion.engine.math.Matrix4;
	import lion.engine.math.Vector3;
	import lion.engine.math.Vector4;
	import lion.engine.utils.InputManager;
	
	[SWF(frameRate="60", width="600", height="600", backgroundColor="#0")]
	public class lion extends Sprite
	{
		private var _cube:CubeGeometry;
		private var _angle:Number = 0;
		private var _viewProjectionMatrix:Matrix4 = new Matrix4();
//		private var _camera:OrthographicCamera = new OrthographicCamera(-5, 5, 5, -5, -5, 5);
		private var _camera:PerspectiveCamera = new PerspectiveCamera(60, 1);
		private var _viewMatrix:Matrix4 = new Matrix4();
		
		public function lion()
		{
			InputManager.instance.init(stage);
			_cube = new CubeGeometry(100, 100, 100);
			addEventListener(Event.ENTER_FRAME, update);
			_camera.position.set(0, 2, -5);
			_camera.lookAt(new Vector3(0, 0, 0));
			_camera.updateMatrixWorld();
		}
		
		protected function update(event:Event):void
		{
			_angle++;
			render();
		}
		
		public function render():void {
//			graphics.clear();
//			
//			// 做顶点转换
//			var t:Array = [];
//			var rad:Number = MathUtil.toRadians(_angle);
//			var i:int = 0;
//			
//			for (i = 0; i < _cube.vertices.length; ++i) {
//				var p:Vector4 = new Vector4()
//				p.copy(_cube.vertices[i]);
//				
//				// 模型矩阵
//				var m:Matrix4 = new Matrix4();
//				m.rotateX(rad).multiply(new Matrix4().rotateY(rad));
//				p.applyMatrix4(m);
//				
//				// 转成世界坐标
////				var worldMatrix:Matrix4 = new Matrix4();
////				worldMatrix.multiply(new Matrix4().translate(0, 0, 5));
////				p.applyMatrix4(worldMatrix);
//				
//				// 投影矩阵
//				// 先将世界坐标转为相对于摄像机原点的坐标矩阵
//				_viewMatrix.copy(_camera.matrixWorldInverse.getInverse(_camera.matrixWorld));
//				// 再乘投影矩阵
//				_viewProjectionMatrix.multiplyMatrices(_camera.projectionMatrix, _viewMatrix);
//				p.applyMatrix4(_viewProjectionMatrix);
//				
//				// 除以齐次值
//				var invW:Number = 1 / p.w;
//				p.x *= invW;
//				p.y *= invW;
//				p.z *= invW;
//				p.w = 1;
//				
//				// 现在得到的就是标准视景体 
//				// [-1, 1] x [-1, 1] x [-1, 1] 
//				// TODO 视景体剔除
//
//				// 标准视景体到窗口的转换
//				var padding:Number = 20;
//				var w:Number = stage.stageWidth;
//				var h:Number = stage.stageHeight;
//				var hw:Number = w / 2;
//				var hh:Number = h / 2;
//				var o:Matrix4 = new Matrix4(
//					hw - 2 * padding, 0,  0, hw,
//					0, -(hh - 2 * padding), 0, hh,
//					0, 0,   1, 0,
//					0, 0,   0, 1
//				);
//				p.applyMatrix4(o);
//				
//				t.push(p);
//			}
//			
//			// 按z排序
//			var avgZ:Array = [];
//			var f:Array;
//			for (i = 0; i < _cube.subfaces.length; ++i) {
//				f = _cube.subfaces[i];
//				var avg:Number = ((t[f[0]].z + t[f[1]].z + t[f[2]].z + t[f[3]].z) / 4);
//				avgZ.push({"index":i, "z": avg});
//			}
//			
//			// 最远的排最前面
//			avgZ.sort(function (a:Object, b:Object):int {
//				if (b.z > a.z) {
//					return -1;
//				} else {
//					return 1;
//				}
////				return b.z - a.z;
//			});
//			
//			// 开始绘制
//			for (i = 0; i < _cube.subfaces.length; ++i) {
//				f = _cube.subfaces[avgZ[i].index];
//				graphics.beginFill(_cube.colors[avgZ[i].index], 1.0);
//				graphics.moveTo(t[f[0]].x, t[f[0]].y);
//				graphics.lineTo(t[f[1]].x, t[f[1]].y);
//				graphics.lineTo(t[f[2]].x, t[f[2]].y);
//				graphics.lineTo(t[f[3]].x, t[f[3]].y);
//				graphics.endFill();
//			}
		}
	}
}