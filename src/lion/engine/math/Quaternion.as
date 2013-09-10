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
		
		/**
		 * 关联的欧拉角 
		 */		
		public var euler:Euler;
		
		public function Quaternion(x:Number = 0, y:Number = 0, z:Number = 0, w:Number = 1)
		{
			this._x = x;
			this._y = y;
			this._z = z;
			this._w = w;
		}
		
		public function copy(q:Quaternion):Quaternion {
			this._x = q.x;
			this._y = q.y;
			this._z = q.z;
			this._w = q.w;
			
			updateEuler();
			
			return this;
		}
		
		/**
		 * 从欧拉角转成四元数 
		 * @param euler
		 * @return 
		 * 
		 */		
		public function setFromEuler(euler:Euler, update:Boolean = true):Quaternion {
			var c1:Number = Math.cos( euler.x / 2 );
			var c2:Number = Math.cos( euler.y / 2 );
			var c3:Number = Math.cos( euler.z / 2 );
			var s1:Number = Math.sin( euler.x / 2 );
			var s2:Number = Math.sin( euler.y / 2 );
			var s3:Number = Math.sin( euler.z / 2 );
			
			if (euler.order === 'XYZ') {
				
				this._x = s1 * c2 * c3 + c1 * s2 * s3;
				this._y = c1 * s2 * c3 - s1 * c2 * s3;
				this._z = c1 * c2 * s3 + s1 * s2 * c3;
				this._w = c1 * c2 * c3 - s1 * s2 * s3;
				
			} else if (euler.order === 'YXZ') {
				
				this._x = s1 * c2 * c3 + c1 * s2 * s3;
				this._y = c1 * s2 * c3 - s1 * c2 * s3;
				this._z = c1 * c2 * s3 - s1 * s2 * c3;
				this._w = c1 * c2 * c3 + s1 * s2 * s3;
				
			} else if (euler.order === 'ZXY') {
				
				this._x = s1 * c2 * c3 - c1 * s2 * s3;
				this._y = c1 * s2 * c3 + s1 * c2 * s3;
				this._z = c1 * c2 * s3 + s1 * s2 * c3;
				this._w = c1 * c2 * c3 - s1 * s2 * s3;
				
			} else if (euler.order === 'ZYX') {
				
				this._x = s1 * c2 * c3 - c1 * s2 * s3;
				this._y = c1 * s2 * c3 + s1 * c2 * s3;
				this._z = c1 * c2 * s3 - s1 * s2 * c3;
				this._w = c1 * c2 * c3 + s1 * s2 * s3;
				
			} else if (euler.order === 'YZX') {
				
				this._x = s1 * c2 * c3 + c1 * s2 * s3;
				this._y = c1 * s2 * c3 + s1 * c2 * s3;
				this._z = c1 * c2 * s3 - s1 * s2 * c3;
				this._w = c1 * c2 * c3 - s1 * s2 * s3;
				
			} else if (euler.order === 'XZY') {
				
				this._x = s1 * c2 * c3 - c1 * s2 * s3;
				this._y = c1 * s2 * c3 - s1 * c2 * s3;
				this._z = c1 * c2 * s3 + s1 * s2 * c3;
				this._w = c1 * c2 * c3 + s1 * s2 * s3;
				
			}
			
			if (update) {
				updateEuler();
			}
			
			return this;
		}
		
		/**
		 * 从旋转轴，角度转成四元数，其实就是四元数的定义 
		 * @param axis
		 * @param angle
		 * @return 
		 * 
		 */		
		public function setFromAxisAngle(axis:Vector3, angle:Number):Quaternion {
			var halfAngle:Number = angle / 2, s:Number = Math.sin(halfAngle);
			
			_x = axis.x * s;
			_y = axis.y * s;
			_z = axis.z * s;
			
			_w = Math.cos(halfAngle);
			
			updateEuler();
			
			return this;
		}
		
		/**
		 * 从旋转矩阵转成四元数 
		 * @param m
		 * @return 
		 * 
		 */		
		public function setFromRotationMatrix(m:Matrix4):Quaternion {
			// http://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToQuaternion/index.htm
			
			// assumes the upper 3x3 of m is a pure rotation matrix (i.e, unscaled)
			
			var te:Vector.<Number> = m.elements,
				
				m11:Number = te[0], m12:Number = te[1], m13:Number = te[2],
				m21:Number = te[4], m22:Number = te[5], m23:Number = te[6],
				m31:Number = te[8], m32:Number = te[9], m33:Number = te[10],
				
				tr:Number = m11 + m22 + m33,
				s:Number;
			
			if (tr > 0) {
				
				s = 0.5 / Math.sqrt( tr + 1.0 );
				
				this._w = 0.25 / s;
				this._x = ( m32 - m23 ) * s;
				this._y = ( m13 - m31 ) * s;
				this._z = ( m21 - m12 ) * s;
				
			} else if (m11 > m22 && m11 > m33) {
				
				s = 2.0 * Math.sqrt( 1.0 + m11 - m22 - m33 );
				
				this._w = (m32 - m23 ) / s;
				this._x = 0.25 * s;
				this._y = (m12 + m21 ) / s;
				this._z = (m13 + m31 ) / s;
				
			} else if (m22 > m33) {
				
				s = 2.0 * Math.sqrt( 1.0 + m22 - m11 - m33 );
				
				this._w = (m13 - m31 ) / s;
				this._x = (m12 + m21 ) / s;
				this._y = 0.25 * s;
				this._z = (m23 + m32 ) / s;
				
			} else {
				
				s = 2.0 * Math.sqrt( 1.0 + m33 - m11 - m22 );
				
				this._w = ( m21 - m12 ) / s;
				this._x = ( m13 + m31 ) / s;
				this._y = ( m23 + m32 ) / s;
				this._z = 0.25 * s;
				
			}
			
			updateEuler();
			
			return this;
		}
		
		public function conjugate():Quaternion {
			_x *= -1;
			_y *= -1;
			_z *= -1;
			updateEuler();
			
			return this;
		}
		
		public function inverse():Quaternion {
			return conjugate().normalize();
		}
		
		/**
		 * 四元数归一化 
		 * @return 
		 * 
		 */		
		public function normalize():Quaternion {
			var l:Number = this.length();
			
			if (l === 0) {
				
				this._x = 0;
				this._y = 0;
				this._z = 0;
				this._w = 1;
				
			} else {
				
				l = 1 / l;
				
				this._x = this._x * l;
				this._y = this._y * l;
				this._z = this._z * l;
				this._w = this._w * l;
				
			}
			updateEuler();
			
			return this;
		}
		
		public function multiply(q:Quaternion):Quaternion {
			return multiplyQuaternions(this, q);
		}
		
		/**
		 * 四元数相乘 
		 * @param a
		 * @param b
		 * @return 
		 * 
		 */		
		public function multiplyQuaternions(a:Quaternion, b:Quaternion):Quaternion {
			// from http://www.euclideanspace.com/maths/algebra/realNormedAlgebra/quaternions/code/index.htm
			
			var qax:Number = a.x, qay:Number = a.y, qaz:Number = a.z, qaw:Number = a.w;
			var qbx:Number = b.x, qby:Number = b.y, qbz:Number = b.z, qbw:Number = b.w;
			
			this._x = qax * qbw + qaw * qbx + qay * qbz - qaz * qby;
			this._y = qay * qbw + qaw * qby + qaz * qbx - qax * qbz;
			this._z = qaz * qbw + qaw * qbz + qax * qby - qay * qbx;
			this._w = qaw * qbw - qax * qbx - qay * qby - qaz * qbz;
			
			updateEuler();
			return this;
		}
		
		public function slerp(qb:Quaternion, t:Number):Quaternion {
			var x:Number = this._x, y:Number = this._y, z:Number = this._z, w:Number = this._w;
			
			// http://www.euclideanspace.com/maths/algebra/realNormedAlgebra/quaternions/slerp/
			
			var cosHalfTheta:Number = w * qb._w + x * qb._x + y * qb._y + z * qb._z;
			
			if ( cosHalfTheta < 0 ) {
				
				this._w = -qb._w;
				this._x = -qb._x;
				this._y = -qb._y;
				this._z = -qb._z;
				
				cosHalfTheta = -cosHalfTheta;
				
			} else {
				
				this.copy( qb );
				
			}
			
			if (cosHalfTheta >= 1.0) {
				
				this._w = w;
				this._x = x;
				this._y = y;
				this._z = z;
				
				return this;
				
			}
			
			var halfTheta:Number = Math.acos(cosHalfTheta);
			var sinHalfTheta:Number = Math.sqrt(1.0 - cosHalfTheta * cosHalfTheta);
			
			if (Math.abs(sinHalfTheta) < 0.001) {
				
				this._w = 0.5 * (w + this._w);
				this._x = 0.5 * (x + this._x);
				this._y = 0.5 * (y + this._y);
				this._z = 0.5 * (z + this._z);
				
				return this;
				
			}
			
			var ratioA:Number = Math.sin((1 - t) * halfTheta) / sinHalfTheta,
				ratioB:Number = Math.sin(t * halfTheta) / sinHalfTheta;
			
			this._w = (w * ratioA + this._w * ratioB);
			this._x = (x * ratioA + this._x * ratioB);
			this._y = (y * ratioA + this._y * ratioB);
			this._z = (z * ratioA + this._z * ratioB);
			
			updateEuler();
			
			return this;
		}
		
		public function lengthSQ():Number {
			return _x * _x + _y * _y + _z * _z + _w * _w;
		}
		
		public function length():Number {
			return Math.sqrt(lengthSQ());
		}

		public function get w():Number
		{
			return _w;
		}

		public function set w(value:Number):void
		{
			_w = value;
			updateEuler();
		}

		public function get z():Number
		{
			return _z;
		}

		public function set z(value:Number):void
		{
			_z = value;
			updateEuler();
		}

		public function get y():Number
		{
			return _y;
		}

		public function set y(value:Number):void
		{
			_y = value;
			updateEuler();
		}

		public function get x():Number
		{
			return _x;
		}

		public function set x(value:Number):void
		{
			_x = value;
			updateEuler();
		}
		
		
		private function updateEuler():void {
			if (euler) {
				euler.setFromQuaternion(this, null, false);
			}
		}
		
		public function clone():Quaternion {
			return new Quaternion(_x, _y, _z, _w);
		}
	}
}