package
{
	import lion.engine.geometries.CubeGeometry;
	import lion.engine.math.Vector3;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	[SWF(frameRate="60", width="800", height="600", backgroundColor="#0")]
	public class lion extends Sprite
	{
		private var _cube:CubeGeometry;
		private var _angle:Number = 0;
		
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
			for (var i:int = 0; i < _cube.vertices.length; ++i) {
				var p:Vector3 = _cube.vertices[i];
				p = p.rotationY(_angle).rotationX(_angle).rotationZ(_angle);
				t.push(p.project(800, 600, 300, 5));
			}
			
			// 按z排序
			var avgZ:Array = [];
			for (var i:int = 0; i < _cube.faces.length; ++i) {
				var f:Array = _cube.faces[i];
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
			for (var i:int = 0; i < _cube.faces.length; ++i) {
				var f:Array = _cube.faces[avgZ[i].index];
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