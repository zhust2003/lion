package lion.engine.cameras
{
	import lion.engine.math.MathUtil;

	/**
	 * 透视投影 
	 * @author Dalton
	 * 
	 */	
	public class PerspectiveCamera extends Camera
	{
		private var fov:Number;
		private var aspect:Number;
		private var near:Number;
		private var far:Number;
		
		public function PerspectiveCamera(fov:Number = 50, aspect:Number = 1, near:Number = 0.1, far:Number = 2000)
		{
			super();
			
			this.fov = fov;
			this.aspect = aspect;
			this.near = near;
			this.far = far;
			
			updateProjectionMatrix();
		}
		
		public function updateProjectionMatrix():void {
			var ymax:Number = near * Math.tan(MathUtil.toRadians(fov * 0.5));
			var ymin:Number = - ymax;
			var xmin:Number = ymin * aspect;
			var xmax:Number = ymax * aspect;
			trace(xmin, xmax, ymin, ymax);
			projectionMatrix.makePerspective(xmin, xmax, ymin, ymax, near, far);
		}
	}
}