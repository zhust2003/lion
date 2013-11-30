package lion.engine.utils
{
	import lion.engine.math.Plane;
	import lion.engine.math.Sphere;
	import lion.engine.math.Vector3;

	/**
	 * 光线 
	 * @author Dalton
	 * 
	 */	
	public class Ray
	{
		private var _origin:Vector3;
		private var _direction:Vector3;
		
		public function Ray(origin:Vector3, direction:Vector3)
		{
			_origin = origin;
			_direction = direction;
		}
		
		public function intersectBox():Vector3 {
			
		}
		
		public function distanceToPoint():Number {
			
		}
		
		public function isIntersectionSphere(s:Sphere):Boolean {
			
		}
		
		public function isIntersectionPlane(p:Plane):Boolean {
			
		}
	}
}