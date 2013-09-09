package lion.engine.math
{
	/**
	 * 欧拉角 
	 * 优点：直观
	 * 缺点：不好做插值，万向节锁
	 * @author Dalton
	 * 
	 */	
	public class Euler
	{
		private var _x:Number;
		private var _y:Number;
		private var _z:Number;
		private var _order:String;
		
		public static const RotationOrders:Array = ['XYZ', 'YZX', 'ZXY', 'XZY', 'YXZ', 'ZYX'];
		
		public static const DefaultOrder:String = 'XYZ';
		
		public function Euler(x:Number = 0, y:Number = 0, z:Number = 0, order:String = DefaultOrder)
		{
			this._x = x;
			this._y = y;
			this._z = z;
			this._order = order;
		}

		public function get order():String
		{
			return _order;
		}

		public function set order(value:String):void
		{
			_order = value;
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

	}
}