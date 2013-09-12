package lion.engine.geometries
{
	import lion.engine.core.Surface;
	import lion.engine.math.Vector3;

	public class Geometry
	{
		public static var geometryIDCount:uint = 0;
		public var id:uint;
		public var name:String;
		// 顶点
		public var vertices:Vector.<Vector3>;
		// 面
		public var faces:Vector.<Surface>;
		
		public function Geometry()
		{
			id = geometryIDCount++;
			name = '';
			vertices = new Vector.<Vector3>();
			faces = new Vector.<Surface>();
		}
		
		public function computeCentroids():void {
			for each (var f:Surface in faces) {
				f.centroid.set(0, 0, 0);
				f.centroid.add(vertices[f.a]);
				f.centroid.add(vertices[f.b]);
				f.centroid.add(vertices[f.c]);
				f.centroid.divide(3);
			}
		}
	}
}