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
		
		public function add(v:Vector3):Vector3 {
			this.x += v.x;
			this.y += v.y;
			this.z += v.z;
			
			return this;
		}
		
		public function sub(v:Vector3):Vector3 {
			this.x -= v.x;
			this.y -= v.y;
			this.z -= v.z;
			
			return this;
		}
		
		public function dot(v:Vector3):Number {
			return this.x * v.x + this.y * v.y + this.z * v.z;
		}
		
		public function cross(v:Vector3):Vector3 {
			var x:Number = this.x, y:Number = this.y, z:Number = this.z;
			
			this.x = y * v.z - z * v.y;
			this.y = z * v.x - x * v.z;
			this.z = x * v.y - y * v.x;
			
			return this;
		}
		
		public function multiply(s:Number):Vector3 {
			this.x *= s;
			this.y *= s;
			this.z *= s;
			
			return this;
		}
		
		public function divide(s:Number):Vector3 {
			this.x /= s;
			this.y /= s;
			this.z /= s;
			
			return this;
		}
		
		public function normalize():Vector3 {
			return divide(length);
		}
		
		public function equals(v:Vector3):Boolean {
			return x === v.x && y === v.y && z === v.z;
		}
		
		public function get lengthSQ():Number {
			return this.x * this.x + this.y * this.y + this.z * this.z;
		}
		
		
		public function get length():Number {
			return Math.sqrt(lengthSQ);
		}
		
		public function distSQ(v:Vector3):Number {
			var dx:Number = v.x - x;
			var dy:Number = v.y - y;
			var dz:Number = v.z - z;
			return dx * dx + dy * dy + dz * dz;
		}
		
		public function dist(v:Vector3):Number {
			return Math.sqrt(distSQ(v));
		}
		
		public function applyProjection(viewWidth:Number, viewHeight:Number, fov:Number, viewDistance:Number):Vector3 {
			var factor:Number = fov / (viewDistance + this.z);
			var x:Number = this.x * factor + viewWidth / 2;
			var y:Number = this.y * factor + viewHeight / 2;
			return new Vector3(x, y, this.z);
		}
		
		public function applyMatrix4(m:Matrix4):Vector3 {
			var e:Vector.<Number> = m.elements;
			var x:Number = this.x, y:Number = this.y, z:Number = this.z;
			this.x = e[0] * x + e[1] * y + e[2] * z + e[3];
			this.y = e[4] * x + e[5] * y + e[6] * z + e[7];
			this.z = e[8] * x + e[9] * y + e[10] * z + e[11];
			
			return this;
		}
		
		public function clone():Vector3 {
			return new Vector3(x, y, z);
		}
		
		public function toString():String {
			return "[Vector3 (x:" + x + ", y:" + y + ", z:" + z + ")]";
		}
	}
}