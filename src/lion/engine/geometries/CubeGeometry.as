package lion.engine.geometries
{
	import lion.engine.math.Vector3;

	public class CubeGeometry extends Geometry
	{
		// 所有立方体的顶点
		public var vertices:Array = [
			new Vector3(-1, -1, 1),
			new Vector3(1, -1, 1),
			new Vector3(1, 1, 1),
			new Vector3(-1, 1, 1),
			new Vector3(-1, -1, -1),
			new Vector3(1, -1, -1),
			new Vector3(1, 1, -1),
			new Vector3(-1, 1, -1)
		];
		// 所有六个面
		public var faces:Array = [
			[0, 1, 2, 3], [1, 5, 6, 2], [5, 4, 7, 6], [4, 0, 3, 7], [0, 4, 5, 1], [3, 2, 6, 7]
		];
		
		// 所有六个面颜色
		public var colors:Array = [
			0xFF0000, 0x00FF00, 0x0000FF, 0xFFFF00, 0x00FFFF, 0xFF00FF
		];
		
		public function CubeGeometry()
		{
		}
	}
}