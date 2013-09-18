package lion.engine.math
{
	import lion.engine.core.Mesh;
	import lion.engine.core.Object3D;
	import lion.engine.geometries.Geometry;
	import lion.engine.geometries.SphereGeometry;

	/**
	 * 视景体 
	 * @author Dalton
	 * 参考：Fast Extraction of Viewing Frustum Planes from the WorldView-Projection Matrix
	 * 作者：Gil Gribb Klaus Hartmann
	 */	
	public class Frustum
	{
		// 6个面的视景体
		public var planes:Vector.<Plane>;
		
		public function Frustum()
		{
			planes = new Vector.<Plane>();
			for (var i:int = 0; i < 6; ++i) {
				var p:Plane = new Plane();
				planes.push(p);
			}
		}
		
		/**
		 * 从投影矩阵提取出视景体的6个面 
		 * @param m
		 * @return 
		 * 
		 */		
		public function setFromMatrix(m:Matrix4):Frustum {
			var me:Vector.<Number> = m.elements;
			var me11:Number = me[0], me12:Number = me[1], me13:Number = me[2], me14:Number = me[3];
			var me21:Number = me[4], me22:Number = me[5], me23:Number = me[6], me24:Number = me[7];
			var me31:Number = me[8], me32:Number = me[9], me33:Number = me[10], me34:Number = me[11];
			var me41:Number = me[12], me42:Number = me[13], me43:Number = me[14], me44:Number = me[15];
			
//			trace(m);
			// left
			planes[0].setComponents(me41 + me11, me42 + me12, me43 + me13, me44 + me14).normalize();
			// right
			planes[1].setComponents(me41 - me11, me42 - me12, me43 - me13, me44 - me14).normalize();
			// bottom
			planes[2].setComponents(me41 + me21, me42 + me22, me43 + me23, me44 + me24).normalize();
			// top
			planes[3].setComponents(me41 - me21, me42 - me22, me43 - me23, me44 - me24).normalize();
			// near
			planes[4].setComponents(me41 + me31, me42 + me32, me43 + me33, me44 + me34).normalize();
			// far
			planes[5].setComponents(me41 - me31, me42 - me32, me43 - me33, me44 - me34).normalize();
			
			return this;
		}
		
		/**
		 * 是否与三维物体相交 
		 * @param o
		 * @return 
		 * 
		 */		
		public function intersectsObject(o:Mesh):Boolean {
			var geometry:Geometry = o.geometry;
			
			if (geometry.boundingSphere === null) geometry.computeBoundingSphere();
			
			// 获取包围球
			var sphere:Sphere = new Sphere();
			sphere.copy(geometry.boundingSphere);
			sphere.applyMatrix4(o.matrixWorld);
			
			return this.intersectsSphere(sphere);
		}
		
		/**
		 * 是否与球体相交 
		 * @param s
		 * @return 
		 * 
		 */		
		public function intersectsSphere(s:Sphere):Boolean {
			var center:Vector3 = s.center;
			var negRadius:Number = -s.radius;
			
			for (var i:int = 0; i < 6; i++) {
				var distance:Number = planes[i].distanceToPoint(center);
				
				if (distance < negRadius) {
					return false;
				}
			}
			
			return true;
		}
		
		/**
		 * 是否与盒体相交 
		 * @param b
		 * @return 
		 * 
		 */		
		public function intersectsBox(box:Box):Boolean {
			
			
			return true;
		}
		
		/**
		 * 是否包含这个点 
		 * @param p
		 * @return 
		 * 
		 */		
		public function containsPoint(p:Vector3):Boolean {
			for (var i:int = 0; i < 6; i ++) {
				if (planes[i].distanceToPoint(p) < 0) {
					return false;
				}
			}
			return true;
		}
	}
}