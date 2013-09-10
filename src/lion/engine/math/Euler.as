package lion.engine.math
{
	import flash.geom.Matrix;

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
		
		/**
		 * 关联的四元数 
		 */		
		public var quaternion:Quaternion;
		
		public static const RotationOrders:Array = ['XYZ', 'YZX', 'ZXY', 'XZY', 'YXZ', 'ZYX'];
		
		public static const DefaultOrder:String = 'XYZ';
		
		public function Euler(x:Number = 0, y:Number = 0, z:Number = 0, order:String = DefaultOrder)
		{
			this._x = x;
			this._y = y;
			this._z = z;
			this._order = order;
		}
		
		public function copy(e:Euler):Euler {
			this._x = e.x;
			this._y = e.y;
			this._z = e.z;
			this._order = e.order;
			
			updateQuaternion();
			
			return this;
		}
		
		/**
		 * 从旋转矩阵转为欧拉角 
		 * @param m
		 * @param order
		 * @return 
		 * 
		 */		
		public function setFromRotationMatrix(m:Matrix4, order:String):Euler {
			var te:Vector.<Number> = m.elements;
			var m11:Number = te[0], m12:Number = te[1], m13:Number = te[2];
			var m21:Number = te[4], m22:Number = te[5], m23:Number = te[6];
			var m31:Number = te[8], m32:Number = te[9], m33:Number = te[10];
			
			order = order || this._order;
			
			if ( order === 'XYZ' ) {
				
				this._y = Math.asin(clamp(m13));
				
				if (Math.abs(m13) < 0.99999) {
					
					this._x = Math.atan2(- m23, m33);
					this._z = Math.atan2(- m12, m11);
					
				} else {
					
					this._x = Math.atan2(m32, m22);
					this._z = 0;
					
				}
				
			} else if (order === 'YXZ') {
				
				this._x = Math.asin(- clamp(m23));
				
				if (Math.abs(m23) < 0.99999) {
					
					this._y = Math.atan2(m13, m33);
					this._z = Math.atan2(m21, m22);
					
				} else {
					
					this._y = Math.atan2(- m31, m11);
					this._z = 0;
					
				}
				
			} else if (order === 'ZXY') {
				
				this._x = Math.asin(clamp(m32));
				
				if (Math.abs(m32) < 0.99999) {
					
					this._y = Math.atan2(- m31, m33);
					this._z = Math.atan2(- m12, m22);
					
				} else {
					
					this._y = 0;
					this._z = Math.atan2(m21, m11);
					
				}
				
			} else if (order === 'ZYX') {
				
				this._y = Math.asin(- clamp(m31));
				
				if (Math.abs(m31) < 0.99999) {
					
					this._x = Math.atan2(m32, m33);
					this._z = Math.atan2(m21, m11);
					
				} else {
					
					this._x = 0;
					this._z = Math.atan2(- m12, m22);
					
				}
				
			} else if (order === 'YZX') {
				
				this._z = Math.asin(clamp(m21));
				
				if (Math.abs(m21) < 0.99999) {
					
					this._x = Math.atan2(- m23, m22);
					this._y = Math.atan2(- m31, m11);
					
				} else {
					
					this._x = 0;
					this._y = Math.atan2(m13, m33);
					
				}
				
			} else if (order === 'XZY') {
				
				this._z = Math.asin(- clamp(m12));
				
				if (Math.abs(m12) < 0.99999) {
					
					this._x = Math.atan2(m32, m22);
					this._y = Math.atan2(m13, m11);
					
				} else {
					
					this._x = Math.atan2(- m23, m33);
					this._y = 0;
					
				}
				
			} else {
				
				throw new Error('不支持的欧拉角序' + order);
				
			}
			
			this._order = order;
			
			updateQuaternion();
			
			return this;
		}
		
		/**
		 * 从四元数转成欧拉角 
		 * @param q
		 * @param order
		 * @return 
		 * 
		 */		
		public function setFromQuaternion(q:Quaternion, order:String, update:Boolean = true):Euler {
			// q is assumed to be normalized
			
			// http://www.mathworks.com/matlabcentral/fileexchange/20696-function-to-convert-between-dcm-euler-angles-quaternions-and-euler-vectors/content/SpinCalc.m
			
			var sqx:Number = q.x * q.x;
			var sqy:Number = q.y * q.y;
			var sqz:Number = q.z * q.z;
			var sqw:Number = q.w * q.w;
			
			order = order || this._order;
			
			if (order === 'XYZ') {
				
				this._x = Math.atan2(2 * (q.x * q.w - q.y * q.z), (sqw - sqx - sqy + sqz));
				this._y = Math.asin(clamp(2 * (q.x * q.z + q.y * q.w)));
				this._z = Math.atan2(2 * (q.z * q.w - q.x * q.y), (sqw + sqx - sqy - sqz));
				
			} else if (order === 'YXZ') {
				
				this._x = Math.asin(clamp(2 * (q.x * q.w - q.y * q.z)));
				this._y = Math.atan2(2 * (q.x * q.z + q.y * q.w), (sqw - sqx - sqy + sqz));
				this._z = Math.atan2(2 * (q.x * q.y + q.z * q.w), (sqw - sqx + sqy - sqz));
				
			} else if (order === 'ZXY') {
				
				this._x = Math.asin(clamp(2 * (q.x * q.w + q.y * q.z)));
				this._y = Math.atan2(2 * (q.y * q.w - q.z * q.x), (sqw - sqx - sqy + sqz));
				this._z = Math.atan2(2 * (q.z * q.w - q.x * q.y), (sqw - sqx + sqy - sqz));
				
			} else if (order === 'ZYX') {
				
				this._x = Math.atan2(2 * (q.x * q.w + q.z * q.y), (sqw - sqx - sqy + sqz));
				this._y = Math.asin(clamp( 2 * (q.y * q.w - q.x * q.z)));
				this._z = Math.atan2(2 * (q.x * q.y + q.z * q.w), (sqw + sqx - sqy - sqz));
				
			} else if (order === 'YZX') {
				
				this._x = Math.atan2(2 * (q.x * q.w - q.z * q.y), (sqw - sqx + sqy - sqz));
				this._y = Math.atan2(2 * (q.y * q.w - q.x * q.z), (sqw + sqx - sqy - sqz));
				this._z = Math.asin(clamp(2 * (q.x * q.y + q.z * q.w)));
				
			} else if (order === 'XZY') {
				
				this._x = Math.atan2(2 * (q.x * q.w + q.y * q.z ), (sqw - sqx + sqy - sqz ));
				this._y = Math.atan2(2 * (q.x * q.z + q.y * q.w ), (sqw + sqx - sqy - sqz ));
				this._z = Math.asin(clamp(2 * (q.z * q.w - q.x * q.y)));
				
			} else {
				
				throw new Error('不支持的欧拉角序' + order);
				
			}
			
			this._order = order;
			
			if (update) {
				updateQuaternion();
			}
			
			return this;
		}

		public function get order():String
		{
			return _order;
		}

		public function set order(value:String):void
		{
			_order = value;
			updateQuaternion();
		}

		public function get z():Number
		{
			return _z;
		}

		public function set z(value:Number):void
		{
			_z = value;
			updateQuaternion();
		}

		public function get y():Number
		{
			return _y;
		}

		public function set y(value:Number):void
		{
			_y = value;
			updateQuaternion();
		}

		public function get x():Number
		{
			return _x;
		}

		public function set x(value:Number):void
		{
			_x = value;
			updateQuaternion();
		}
		
		
		private function updateQuaternion():void {
			if (quaternion) {
				quaternion.setFromEuler(this, false);
			}
		}
		
		// clamp, to handle numerical problems
		private function clamp(x:Number):Number {
			return Math.min(Math.max(x, -1), 1);
		}
	}
}