package lion.engine.geometries
{
	import lion.engine.math.Vector3;
	/**
	 * 立方体 
	 * @author Dalton
	 * 
	 */
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
		public var subfaces:Array = [
			[0, 1, 2, 3], [1, 5, 6, 2], [5, 4, 7, 6], [4, 0, 3, 7], [0, 4, 5, 1], [3, 2, 6, 7]
		];
		
		// 所有六个面颜色
		public var colors:Array = [
			0xFF0000, 0x00FF00, 0x0000FF, 0xFFFF00, 0x00FFFF, 0xFF00FF
		];
		
		private var width:Number;
		private var height:Number;
		private var depth:Number;
		
		public function CubeGeometry(width:Number, height:Number, depth:Number)
		{
			this.width = width;
			this.height = height;
			this.depth = depth;
			
			// 建立六个面
			// 每个面有两个三角形，一个三角形三个顶点
			
			// 合并顶点
		}
	}
}