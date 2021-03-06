package lion.engine.geometries
{
	import lion.engine.core.Surface;
	import lion.engine.math.Box;
	import lion.engine.math.Sphere;
	import lion.engine.math.Vector2;
	import lion.engine.math.Vector3;
	import lion.engine.renderer.base.RenderableElement;

	public class Geometry
	{
		public static var geometryIDCount:uint = 0;
		public var id:uint;
		public var name:String;
		// 顶点
		public var vertices:Vector.<Vector3>;
		// 每个顶点的法线
//		public var normals:Vector.<Vector3>;
		// 面
		public var faces:Vector.<Surface>;
		// UV坐标
		public var faceVertexUvs:Vector.<Vector.<Vector2>>;
		
		// 包围球
		public var boundingSphere:Sphere;
		// 包围盒
		public var boundingBox:Box;
		
		// stage3d的可渲染元素
		public var renderableElement:RenderableElement;
		
		public function Geometry()
		{
			id = geometryIDCount++;
			name = '';
			vertices = new Vector.<Vector3>();
			faces = new Vector.<Surface>();
			faceVertexUvs = new Vector.<Vector.<Vector2>>();
		}
		
		/**
		 * 计算质心 
		 * 
		 */		
		public function computeCentroids():void {
			for each (var f:Surface in faces) {
				f.centroid.set(0, 0, 0);
				f.centroid.add(vertices[f.a]);
				f.centroid.add(vertices[f.b]);
				f.centroid.add(vertices[f.c]);
				f.centroid.divide(3);
			}
		}
		
		/**
		 * 计算包围球 
		 * @return 
		 * 
		 */		
		public function computeBoundingSphere():void {
			if (! boundingSphere) {
				boundingSphere = new Sphere();
			}
			boundingSphere.setFromPoints(vertices);
		}
	}
}