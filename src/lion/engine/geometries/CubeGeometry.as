package lion.engine.geometries
{
	import lion.engine.core.Surface;
	import lion.engine.math.Vector3;

	/**
	 * 立方体 
	 * @author Dalton
	 * 
	 */
	public class CubeGeometry extends Geometry
	{
		// 所有立方体的顶点
//		public var vertices:Array = [
//			new Vector3(-1, -1, 1),
//			new Vector3(1, -1, 1),
//			new Vector3(1, 1, 1),
//			new Vector3(-1, 1, 1),
//			new Vector3(-1, -1, -1),
//			new Vector3(1, -1, -1),
//			new Vector3(1, 1, -1),
//			new Vector3(-1, 1, -1)
//		];
//		// 所有六个面
//		public var subfaces:Array = [
//			[0, 1, 2, 3], [1, 5, 6, 2], [5, 4, 7, 6], [4, 0, 3, 7], [0, 4, 5, 1], [3, 2, 6, 7]
//		];
//		
//		// 所有六个面颜色
//		public var colors:Array = [
//			0xFF0000, 0x00FF00, 0x0000FF, 0xFFFF00, 0x00FFFF, 0xFF00FF
//		];
		
		// x
		private var width:Number;
		// y
		private var height:Number;
		// z
		private var depth:Number;
		private var widthSegments:int;
		private var heightSegments:int;
		private var depthSegments:int;
		
		public function CubeGeometry(width:Number, height:Number, depth:Number, widthSegments:int = 1, heightSegments:int = 1, depthSegments:int = 1)
		{
			this.width = width;
			this.height = height;
			this.depth = depth;
			this.widthSegments = widthSegments;
			this.heightSegments = heightSegments;
			this.depthSegments = depthSegments;
			
			// 建立六个面
			// 每个面有两个三角形，一个三角形三个顶点
			var halfWidth:Number = width / 2;
			var halfHeight:Number = height / 2;
			var halfDepth:Number = depth / 2;
			buildPlane('z', 'y', -1, -1, this.depth, this.height, halfWidth);
			buildPlane('z', 'y',  1, -1, this.depth, this.height, -halfWidth);
			buildPlane('x', 'z',  1,  1, this.width, this.depth, halfHeight);
			buildPlane('x', 'z',  1, -1, this.width, this.depth, -halfHeight);
			buildPlane('x', 'y',  1, -1, this.width, this.height, halfDepth);
			buildPlane('x', 'y', -1, -1, this.width, this.height, -halfDepth);
		}
		
		private function buildPlane(u:String, v:String, udir:int, vdir:int, width:Number, height:Number, depth:Number):void {
			var iy:int = 0, ix:int = 0;
			var halfWidth:Number = width / 2;
			var halfHeight:Number = height / 2;
			var gridX:int = this.widthSegments,
				gridY:int = this.heightSegments;
			var gridX1:int = this.widthSegments+1,
				gridY1:int = this.heightSegments+1;
			var w:String;
			var offset:int = vertices.length;
			if ((u === 'x' && v === 'y') || (u === 'y' && v === 'x')) {
				w = 'z';
			} else if ((u === 'x' && v === 'z') || (u === 'z' && v === 'x')) {
				w = 'y';
				gridY = this.depthSegments;
			} else if ((u === 'y' && v === 'z') || (u === 'z' && v === 'y')) {
				w = 'x';
				gridX = this.depthSegments;
			}
			var gridWidth:Number = width / gridX;
			var gridHeight:Number = height / gridY;
			
			// 构建顶点
			for (iy = 0; iy <= heightSegments; ++iy) {
				for (ix = 0; ix <= widthSegments; ++ix) {
					var vector:Vector3 = new Vector3();
					vector[u] = (- halfWidth + ix * gridWidth) * udir;
					vector[v] = (- halfHeight + iy * gridHeight) * vdir;
					vector[w] = depth;
					vertices.push(vector);
				}
			}
			
			// 构建面
			var normal:Vector3 = new Vector3();
			normal[w] = depth > 0 ? 1 : - 1;
			for (iy = 0; iy < heightSegments; ++iy) {
				for (ix = 0; ix < widthSegments; ++ix) {
					// 获得顶点索引
					var a:int = ix + gridX1 * iy;
					var b:int = ix + gridX1 * (iy + 1);
					var c:int = ix + 1 + gridX1 * (iy + 1);
					var d:int = ix + 1 + gridX1 * iy;
					
					// 两个三角面
					var face:Surface = new Surface(a + offset, b + offset, d + offset, normal);
					faces.push(face);
					
					face = new Surface(b + offset, c + offset, d + offset, normal);
					faces.push(face);
				}
			}
			
			// 合并顶点
		}
	}
}