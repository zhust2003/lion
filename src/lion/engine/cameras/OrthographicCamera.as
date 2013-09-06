package lion.engine.cameras
{
	import lion.engine.math.Matrix4;

	/**
	 * 正射投影 
	 * @author Dalton
	 * 
	 */	
	public class OrthographicCamera extends Camera
	{
		private var left:Number;
		private var right:Number;
		private var top:Number;
		private var bottom:Number;
		private var near:Number
		private var far:Number;
		
		public function OrthographicCamera(left:Number, right:Number, top:Number, bottom:Number, near:Number = 0.1, far:Number = 2000)
		{
			super();
			
			this.left = left;
			this.right = right;
			this.top = top;
			this.bottom = bottom;
			this.near = near;
			this.far = far;
			
			updateProjectionMatrix();
		}
		
		public function updateProjectionMatrix():void {
			projectionMatrix.makeOrthographic(left, right, top, bottom, near, far);
		}
	}
}