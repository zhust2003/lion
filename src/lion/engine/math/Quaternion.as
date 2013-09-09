package lion.engine.math
{
	/**
	 * 四元数 
	 * 优点：好做插值
	 * 缺点：不直观
	 * @author Dalton
	 * 
	 */	
	public class Quaternion
	{
		private var _x:Number;
		private var _y:Number;
		private var _z:Number;
		private var _w:Number;
		
		public function Quaternion(x:Number = 0, y:Number = 0, z:Number = 0, w:Number = 1)
		{
			this._x = x;
			this._y = y;
			this._z = z;
			this._w = w;
		}

		public function get w():Number
		{
			return _w;
		}

		public function set w(value:Number):void
		{
			_w = value;
		}

		public function get z():Number
		{
			return _z;
		}

		public function set z(value:Number):void
		{
			_z = value;
		}

		public function get y():Number
		{
			return _y;
		}

		public function set y(value:Number):void
		{
			_y = value;
		}

		public function get x():Number
		{
			return _x;
		}

		public function set x(value:Number):void
		{
			_x = value;
		}

		public function clone():Quaternion {
			return new Quaternion(_x, _y, _z, _w);
		}
	}
}