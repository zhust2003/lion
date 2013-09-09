package lion.engine.math
{
	public class Vector4
	{
		public var x:Number;
		public var y:Number;
		public var z:Number;
		public var w:Number;
		
		public function Vector4(x:Number = 0, y:Number = 0, z:Number = 0, w:Number = 1)
		{
			this.x = x;
			this.y = y;
			this.z = z;
			this.w = w;
		}
		
		public function set(x:Number, y:Number, z:Number, w:Number):Vector4 {
			this.x = x;
			this.y = y;
			this.z = z;
			this.w = w;
			
			return this;
		}
		
		public function copy(v:Vector3):Vector4 {
			this.x = v.x;
			this.y = v.y;
			this.z = v.z;
			this.w = 1;
			
			return this;
		}
		
		public function applyMatrix4(m:Matrix4):Vector4 {
			var e:Vector.<Number> = m.elements;
			var x:Number = this.x, 
				y:Number = this.y, 
				z:Number = this.z,
				w:Number = this.w;
			this.x = e[0] * x + e[1] * y + e[2] * z + e[3] * w;
			this.y = e[4] * x + e[5] * y + e[6] * z + e[7] * w;
			this.z = e[8] * x + e[9] * y + e[10] * z + e[11] * w;
			this.w = e[12] * x + e[13] * y + e[14] * z + e[15] * w;
			
			return this;
		}
		
		public function toString():String {
			return "[Vector4 (x:" + x + ", y:" + y + ", z:" + z + ", w:" + w + ")]";
		}
	}
}