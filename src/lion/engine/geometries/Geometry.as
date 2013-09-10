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
		public var vertics:Vector.<Vector3>;
		// 面
		public var faces:Vector.<Surface>;
		
		public function Geometry()
		{
			id = geometryIDCount++;
			name = '';
			vertics = new Vector.<Vector3>();
			faces = new Vector.<Surface>();
		}
	}
}