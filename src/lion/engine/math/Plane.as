package lion.engine.math
{
	/**
	 * 平面类 
	 * @author Dalton
	 * 
	 */	
	public class Plane
	{
		// 平面方程可以表示成一个法线与平面上的点
		// 进一步推导可得法线与法线与点的点乘，即这里的常量
		// 平面方程： ax + bx + cx + d = 0;
		// normal = [a, b, c];
		// constant = d;
		public var normal:Vector3;
		public var constant:Number;
		
		public function Plane()
		{
			normal = new Vector3();
			constant = 0;
		}
		
		public function set(n:Vector3, c:Number):Plane {
			normal.copy(n);
			constant = c;
			
			return this;
		}
		
		public function setComponents(x:Number, y:Number, z:Number, w:Number):Plane {
			normal.set(x, y, z);
			constant = w;
			
			return this;
		}
		
		public function normalize():Plane {
			var inverseLen:Number = 1 / normal.length;
			normal.multiply(inverseLen);
			constant *= inverseLen;
			
			return this;
		}
		
		public function negate():Plane {
			constant *= -1;
			normal.negate();
			
			return this;
		}
		
		public function distanceToPoint(point:Vector3):Number {
			return this.normal.dot(point) + constant;
		}
	}
}