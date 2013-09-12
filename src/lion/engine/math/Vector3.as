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
		
		public function copy(v:Vector3):Vector3 {
			this.x = v.x;
			this.y = v.y;
			this.z = v.z;
			
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
		
		public function subVectors(a:Vector3, b:Vector3):Vector3 {
			this.x = a.x - b.x;
			this.y = a.y - b.y;
			this.z = a.z - b.z;
			
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
		
		public function crossVectors(a:Vector3, b:Vector3):Vector3 {
			var ax:Number = a.x, ay:Number = a.y, az:Number = a.z;
			var bx:Number = b.x, by:Number = b.y, bz:Number = b.z;
			
			this.x = ay * bz - az * by;
			this.y = az * bx - ax * bz;
			this.z = ax * by - ay * bx;
			
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
		
		
		public function applyMatrix4(m:Matrix4):Vector3 {
			var e:Vector.<Number> = m.elements;
			var x:Number = this.x, y:Number = this.y, z:Number = this.z;
			this.x = e[0] * x + e[1] * y + e[2] * z + e[3];
			this.y = e[4] * x + e[5] * y + e[6] * z + e[7];
			this.z = e[8] * x + e[9] * y + e[10] * z + e[11];
			
			return this;
		}
		
		public function applyProjection(m:Matrix4):Vector3 {
			var x:Number = this.x, y:Number = this.y, z:Number = this.z;
			
			var e:Vector.<Number> = m.elements;
			var d:Number = 1 / (e[12] * x + e[13] * y + e[14] * z + e[15]); // perspective divide
			
			this.x = (e[0] * x + e[1] * y + e[2]  * z + e[3]) * d;
			this.y = (e[4] * x + e[5] * y + e[6]  * z + e[7]) * d;
			this.z = (e[8] * x + e[9] * y + e[10] * z + e[11]) * d;
			
			return this;
		}
		
		public function getPositionFromMatrix(m:Matrix4):Vector3 {
			this.x = m.elements[3];
			this.y = m.elements[7];
			this.z = m.elements[11];
			
			return this;
		}
		
		public function clone():Vector3 {
			return new Vector3(x, y, z);
		}
		
		public function toString():String {
			return "[Vector3 (x:" + x + ", y:" + y + ", z:" + z + ")]";
		}
		
		public function applyMatrix3(m:Matrix3):Vector3
		{
			var x:Number = this.x;
			var y:Number = this.y;
			var z:Number = this.z;
			
			var e:Vector.<Number> = m.elements;
			
			this.x = e[0] * x + e[1] * y + e[2] * z;
			this.y = e[3] * x + e[4] * y + e[5] * z;
			this.z = e[6] * x + e[7] * y + e[8] * z;
			
			return this;
		}
	}
}