package lion.engine.geometries
{
	import lion.engine.core.Surface;
	import lion.engine.math.Vector2;
	import lion.engine.math.Vector3;

	/**
	 * 面板 
	 * 逆时针建模 CCW 
	 * 
	 * @author Dalton
	 * 
	 */	
	public class PlaneGeometry extends Geometry
	{
		// x
		private var width:Number;
		// y
		private var height:Number;
		private var widthSegments:Number;
		private var heightSegments:Number;
		
		
		
		public function PlaneGeometry(width:Number, height:Number, widthSegments:int = 1, heightSegments:int = 1)
		{
			super();
			
			this.width = width;
			this.height = height;
			this.widthSegments = widthSegments;
			this.heightSegments = heightSegments;
			
			var halfWidth:Number = width / 2;
			var halfHeight:Number = height / 2;
			var gridWidth:Number = width / widthSegments;
			var gridHeight:Number = height / heightSegments;
			
			var iy:int = 0, ix:int = 0;
			
			// 构建顶点
			for (iy = 0; iy <= heightSegments; ++iy) {
				for (ix = 0; ix <= widthSegments; ++ix) {
					var x:Number = - halfWidth + ix * gridWidth;
					var y:Number = - halfHeight + iy * gridHeight;
					
					vertices.push(new Vector3(x, - y, 0));
				}
			}
			
			// 构建三角形面片
			var normal:Vector3 = new Vector3(0, 0, 1);
			for (iy = 0; iy < heightSegments; ++iy) {
				for (ix = 0; ix < widthSegments; ++ix) {
					// 获得顶点索引
					var gridX:int = (widthSegments + 1);
					var gridY:int = (heightSegments + 1);
					var a:int = ix + gridX * iy;
					var b:int = ix + gridX * (iy + 1);
					var c:int = ix + 1 + gridX * (iy + 1);
					var d:int = ix + 1 + gridX * iy;
					
					var uva:Vector2 = new Vector2(ix / widthSegments, 1 - iy / heightSegments);
					var uvb:Vector2 = new Vector2(ix / widthSegments, 1 - (iy + 1) / heightSegments);
					var uvc:Vector2 = new Vector2((ix + 1) / widthSegments, 1 - (iy + 1) / heightSegments);
					var uvd:Vector2 = new Vector2((ix + 1) / widthSegments, 1 - iy / heightSegments);
					
					// 两个三角面
					var face:Surface = new Surface(a, b, d, normal);
					faces.push(face);
					faceVertexUvs.push(new <Vector2>[uva, uvb, uvd]);
					
					face = new Surface(b, c, d, normal);
					faces.push(face);
					faceVertexUvs.push(new <Vector2>[uvb, uvc, uvd]);
				}
			}
			
			computeCentroids();
		}
	}
}