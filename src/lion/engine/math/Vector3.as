package lion.engine.math
{
	import flash.geom.Matrix3D;

	/**
	 * 三维向量 
	 * @author Dalton
	 * 
	 */	
	public class Vector3
	{
		public var x:Number;
		public var y:Number;
		public var z:Number;
		
		public function Vector3(x:Number = 0, y:Number = 0, z:Number = 0)
		{
			this.x = x;
			this.y = y;
			this.z = z;
		}
		
		public function set(x:Number, y:Number, z:Number):Vector3 {
			this.x = x;
			this.y = y;
			this.z = z;
			return this;
		}
		
		public function rotationY(angle:Number):Vector3 {
			var rad:Number = angle * Math.PI / 180;
			var cosa:Number = Math.cos(rad);
			var sina:Number = Math.sin(rad);
			var z:Number = this.z * cosa - this.x * sina;
			var x:Number = this.z * sina + this.x * cosa;
			return new Vector3(x, this.y, z);
		}
		
		public function rotationX(angle:Number):Vector3 {
			var rad:Number = angle * Math.PI / 180;
			var cosa:Number = Math.cos(rad);
			var sina:Number = Math.sin(rad);
			var z:Number = this.y * cosa - this.z * sina;
			var y:Number = this.y * sina + this.z * cosa;
			return new Vector3(this.x, y, z);
		}
		
		public function rotationZ(angle:Number):Vector3 {
			var rad:Number = angle * Math.PI / 180;
			var cosa:Number = Math.cos(rad);
			var sina:Number = Math.sin(rad);
			var x:Number = this.x * cosa - this.y * sina;
			var y:Number = this.x * sina + this.y * cosa;
			return new Vector3(x, y, this.z);
		}
		
		public function applyProjection(viewWidth:Number, viewHeight:Number, fov:Number, viewDistance:Number):Vector3 {
			var factor:Number = fov / (viewDistance + this.z);
			var x:Number = this.x * factor + viewWidth / 2;
			var y:Number = this.y * factor + viewHeight / 2;
			return new Vector3(x, y, this.z);
		}
		
		public function clone():Vector3 {
			return new Vector3(x, y, z);
		}
	}
}