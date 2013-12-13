package lion.engine.cameras
{
	import lion.engine.core.Object3D;
	import lion.engine.math.Matrix4;
	import lion.engine.math.Vector3;

	/**
	 * 基本摄像机类 
	 * @author Dalton
	 * 
	 */	
	public class Camera extends Object3D
	{
		public var projectionMatrix:Matrix4;
		public var matrixWorldInverse:Matrix4;
		public var near:Number
		public var far:Number;
		
		public function Camera()
		{
			projectionMatrix = new Matrix4();
			matrixWorldInverse = new Matrix4();
		}
		
		public function lookup(v:Vector3):void {
			
		}
	}
}