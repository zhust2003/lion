package lion.engine.core
{
	import lion.engine.math.Matrix4;
	import lion.engine.math.Vector3;

	/**
	 * 基本的三维物体类 
	 * 树形结构
	 * @author Dalton
	 * 
	 */	
	public class Object3D
	{
		private var parent:Object3D;
		private var children:Vector.<Object3D>;
		private var id:uint;
		public static var objectIDCount:uint = 0;
		private var name:String;
		private var position:Vector3;
		private var matrix:Matrix4;
		private var matrixWorld:Matrix4;
		
		public function Object3D()
		{
			id = objectIDCount++;
			parent = null;
			children = new Vector.<Object3D>();
			name = '';
			position = new Vector3();
		}
		
		public function add(o:Object3D):void {
			
		}
		
		public function remove(o:Object3D):void {
			
		}
		
		public function getObjectByID(id:uint, recursive:Boolean = false):Object3D {
			return null;
		}
		
		public function getObjectByName(name:String, recursive:Boolean = false):Object3D {
			return null;
		}
		
		public function updateMatrix():void {
			
		}
		
		public function updateMatrixWorld():void {
			
		}
	}
}