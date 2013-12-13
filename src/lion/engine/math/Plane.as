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
		// 平面方程： ax + by + cz + d = 0;
		// normal = [a, b, c];
		// constant = d;
		// http://www.cnblogs.com/kesalin/archive/2009/09/09/plane_equation.html
		
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
		
		// 推导过程
		// http://www.cnblogs.com/kesalin/archive/2009/09/09/plane_equation.html
		// 如果点在法线方向，则为正
		// 反向，则为负
		// 为0则在平面上
		public function distanceToPoint(point:Vector3):Number {
			return this.normal.dot(point) + constant;
		}
	}
}