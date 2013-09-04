package com.yile.engine.math
{
	import flash.geom.Matrix3D;

	public class Vector3D
	{
		public var x:Number;
		public var y:Number;
		public var z:Number;
		
		public function Vector3D(x:Number, y:Number, z:Number)
		{
			this.x = x;
			this.y = y;
			this.z = z;
		}
		
		public function rotationY(angle:Number):Vector3D {
			var rad:Number = angle * Math.PI / 180;
			var cosa:Number = Math.cos(rad);
			var sina:Number = Math.sin(rad);
			var z:Number = this.z * cosa - this.x * sina;
			var x:Number = this.z * sina + this.x * cosa;
			return new Vector3D(x, this.y, z);
		}
		
		public function rotationX(angle:Number):Vector3D {
			var rad:Number = angle * Math.PI / 180;
			var cosa:Number = Math.cos(rad);
			var sina:Number = Math.sin(rad);
			var z:Number = this.y * cosa - this.z * sina;
			var y:Number = this.y * sina + this.z * cosa;
			return new Vector3D(this.x, y, z);
		}
		
		public function project(viewWidth:Number, viewHeight:Number, fov:Number, viewDistance:Number):Vector3D {
			var factor:Number = fov / (viewDistance + this.z);
			var x:Number = this.x * factor + viewWidth / 2;
			var y:Number = this.y * factor + viewHeight / 2;
			return new Vector3D(x, y, this.z);
		}
	}
}