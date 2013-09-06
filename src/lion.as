package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	import lion.engine.cameras.OrthographicCamera;
	import lion.engine.geometries.CubeGeometry;
	import lion.engine.math.MathUtil;
	import lion.engine.math.Matrix4;
	import lion.engine.math.Vector3;
	
	[SWF(frameRate="60", width="600", height="600", backgroundColor="#0")]
	public class lion extends Sprite
	{
		private var _cube:CubeGeometry;
		private var _angle:Number = 0;
		private var _viewProjectionMatrix:Matrix4 = new Matrix4();
		private var _camera:OrthographicCamera = new OrthographicCamera(-2, 2, 2, -2);
		
		public function lion()
		{
			_cube = new CubeGeometry();
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		protected function update(event:Event):void
		{
			_angle++;
			render();
		}
		
		public function render():void {
			graphics.clear();
			
			// 做顶点转换
			var t:Array = [];
			var rad:Number = MathUtil.toRadians(_angle);
			var i:int = 0;
			
			for (i = 0; i < _cube.vertices.length; ++i) {
				var p:Vector3 = _cube.vertices[i].clone();
				
				// 模型矩阵
				var m:Matrix4 = new Matrix4();
				m.rotateX(rad).multiply(new Matrix4().rotateY(rad));
				p.applyMatrix4(m);
				
				// 投影矩阵
				_viewProjectionMatrix = new Matrix4();
				_viewProjectionMatrix.multiply(_camera.projectionMatrix);
				p.applyMatrix4(_viewProjectionMatrix);
				
				// 标准视景体到窗口的转换
				var padding:Number = 20;
				var w:Number = stage.stageWidth;
				var h:Number = stage.stageHeight;
				var hw:Number = w / 2;
				var hh:Number = h / 2;
				var o:Matrix4 = new Matrix4(
					hw - 2 * padding, 0,  0, hw,
					0, -(hh - 2 * padding), 0, hh,
					0, 0,   1, 0,
					0, 0,   0, 1
				);
				p.applyMatrix4(o);
				t.push(p);
//				trace(p);
//				t.push(p.applyProjection(800, 600, 300, 5));
			}
			
			// 按z排序
			var avgZ:Array = [];
			var f:Array;
			for (i = 0; i < _cube.faces.length; ++i) {
				f = _cube.faces[i];
				var avg:Number = ((t[f[0]].z + t[f[1]].z + t[f[2]].z + t[f[3]].z) / 4);
				avgZ.push({"index":i, "z": avg});
			}
			
			// 最远的排最前面
			avgZ.sort(function (a:Object, b:Object):int {
				if (b.z > a.z) {
					return 1;
				} else {
					return -1;
				}
//				return b.z - a.z;
			});
			
			// 开始绘制
			for (i = 0; i < _cube.faces.length; ++i) {
				f = _cube.faces[avgZ[i].index];
				graphics.beginFill(_cube.colors[avgZ[i].index], 1.0);
				graphics.moveTo(t[f[0]].x, t[f[0]].y);
				graphics.lineTo(t[f[1]].x, t[f[1]].y);
				graphics.lineTo(t[f[2]].x, t[f[2]].y);
				graphics.lineTo(t[f[3]].x, t[f[3]].y);
				graphics.endFill();
			}
		}
	}
}