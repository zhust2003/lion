package lion.engine.math
{
	import flash.geom.Matrix3D;

	/**
	 * 4 x 4 矩阵 
	 * @author Dalton
	 * 
	 */	
	public class Matrix4
	{
		public var elements:Vector.<Number>;
		public function Matrix4(n11:Number = 1, n12:Number = 0, n13:Number = 0, n14:Number = 0, 
								n21:Number = 0, n22:Number = 1, n23:Number = 0, n24:Number = 0, 
								n31:Number = 0, n32:Number = 0, n33:Number = 1, n34:Number = 0, 
								n41:Number = 0, n42:Number = 0, n43:Number = 0, n44:Number = 1)
		{
			elements = new Vector.<Number>(16);
			
			elements[0] = n11; elements[1] = n12; elements[2] = n13; elements[3] = n14;
			elements[4] = n21; elements[5] = n22; elements[6] = n23; elements[7] = n24;
			elements[8] = n31; elements[9] = n32; elements[10] = n33; elements[11] = n34;
			elements[12] = n41; elements[13] = n42; elements[14] = n43; elements[15] = n44;
		}
		
		public function set(n11:Number, n12:Number, n13:Number, n14:Number, 
							n21:Number, n22:Number, n23:Number, n24:Number, 
							n31:Number, n32:Number, n33:Number, n34:Number, 
							n41:Number, n42:Number, n43:Number, n44:Number):Matrix4 {
			elements[0] = n11; elements[1] = n12; elements[2] = n13; elements[3] = n14;
			elements[4] = n21; elements[5] = n22; elements[6] = n23; elements[7] = n24;
			elements[8] = n31; elements[9] = n32; elements[10] = n33; elements[11] = n34;
			elements[12] = n41; elements[13] = n42; elements[14] = n43; elements[15] = n44;
			return this;
		}
		
		public function identity():Matrix4 {
			set(1, 0, 0, 0,
				0, 1, 0, 0,
				0, 0, 1, 0,
				0, 0, 0, 1);
			return this;
		}
		
		public function multiply(m:Matrix4):Matrix4 {
			var ae:Vector.<Number> = this.elements;
			var be:Vector.<Number> = m.elements;
			var te:Vector.<Number> = this.elements;
			
			var a11:Number = ae[0], a12:Number = ae[1], a13:Number = ae[2], a14:Number = ae[3];
			var a21:Number = ae[4], a22:Number = ae[5], a23:Number = ae[6], a24:Number = ae[7];
			var a31:Number = ae[8], a32:Number = ae[9], a33:Number = ae[10], a34:Number = ae[11];
			var a41:Number = ae[12], a42:Number = ae[13], a43:Number = ae[14], a44:Number = ae[15];
			
			var b11:Number = be[0], b12:Number = be[1], b13:Number = be[2], b14:Number = be[3];
			var b21:Number = be[4], b22:Number = be[5], b23:Number = be[6], b24:Number = be[7];
			var b31:Number = be[8], b32:Number = be[9], b33:Number = be[10], b34:Number = be[11];
			var b41:Number = be[12], b42:Number = be[13], b43:Number = be[14], b44:Number = be[15];
			
			te[0] = a11 * b11 + a12 * b21 + a13 * b31 + a14 * b41;
			te[1] = a11 * b12 + a12 * b22 + a13 * b32 + a14 * b42;
			te[2] = a11 * b13 + a12 * b23 + a13 * b33 + a14 * b43;
			te[3] = a11 * b14 + a12 * b24 + a13 * b34 + a14 * b44;
			
			te[4] = a21 * b11 + a22 * b21 + a23 * b31 + a24 * b41;
			te[5] = a21 * b12 + a22 * b22 + a23 * b32 + a24 * b42;
			te[6] = a21 * b13 + a22 * b23 + a23 * b33 + a24 * b43;
			te[7] = a21 * b14 + a22 * b24 + a23 * b34 + a24 * b44;
			
			te[8] = a31 * b11 + a32 * b21 + a33 * b31 + a34 * b41;
			te[9] = a31 * b12 + a32 * b22 + a33 * b32 + a34 * b42;
			te[10] = a31 * b13 + a32 * b23 + a33 * b33 + a34 * b43;
			te[11] = a31 * b14 + a32 * b24 + a33 * b34 + a34 * b44;
			
			te[12] = a41 * b11 + a42 * b21 + a43 * b31 + a44 * b41;
			te[13] = a41 * b12 + a42 * b22 + a43 * b32 + a44 * b42;
			te[14] = a41 * b13 + a42 * b23 + a43 * b33 + a44 * b43;
			te[15] = a41 * b14 + a42 * b24 + a43 * b34 + a44 * b44;
			
			return this;
		}
		
		public function clone():Matrix4 {
			return new Matrix4(
				elements[0], elements[1], elements[2], elements[3],
				elements[4], elements[5], elements[6], elements[7],
				elements[8], elements[9], elements[10], elements[11],
				elements[12], elements[13], elements[14], elements[15]
			);
		}
		
		public function translate(x:Number, y:Number, z:Number):Matrix4 {
			set(1, 0, 0, x,
				0, 1, 0, y,
				0, 0, 1, z,
				0, 0, 0, 1);
			return this;
		}
		
		public function rotateX(angle:Number):Matrix4 {
			var c:Number = Math.cos(angle), s:Number = Math.sin(angle);
			set(1, 0, 0, 0,
				0, c, -s, 0,
				0, s, c, 0,
				0, 0, 0, 1);
			
			return this;
		}
		
		public function rotateY(angle:Number):Matrix4 {
			var c:Number = Math.cos(angle), s:Number = Math.sin(angle);
			set(c, 0, s, 0,
				0, 1, 0, 0,
				-s, 0, c, 0,
				0, 0, 0, 1);
			
			return this;
		}
		
		public function rotateZ(angle:Number):Matrix4 {
			var c:Number = Math.cos(angle), s:Number = Math.sin(angle);
			set(c, -s, 0, 0,
				s, c, 0, 0,
				0, 0, 1, 0,
				0, 0, 0, 1);
			
			return this;
		}
		
		/**
		 * 正射视景体到标准视景体的转换
		 * 标准视景体为 [-1, 1] x [-1, 1] x [-1, 1] 
		 * @param left
		 * @param right
		 * @param top
		 * @param bottom
		 * @param near
		 * @param far
		 * @return 
		 * 
		 */		
		public function makeOrthographic(left:Number, right:Number, top:Number, bottom:Number, near:Number, far:Number):Matrix4 {
			var te:Vector.<Number> = this.elements;
			var w:Number = right - left;
			var h:Number = top - bottom;
			var p:Number = far - near;
			
			var x:Number = (right + left) / w;
			var y:Number = (top + bottom) / h;
			var z:Number = (far + near) / p;
			
			te[0] = 2 / w;	te[1] = 0;		te[2] = 0;		te[3] = -x;
			te[4] = 0;		te[5] = 2 / h;	te[6] = 0;		te[7] = -y;
			te[8] = 0;		te[9] = 0;		te[10] = -2 / p;te[11] = -z;
			te[12] = 0;		te[13] = 0;		te[14] = 0;		te[15] = 1;
			
			return this;
		}
		
		
		public function makePerspective(left:Number, right:Number, top:Number, bottom:Number, near:Number, far:Number):Matrix4 {
			var te:Vector.<Number> = this.elements;
			var x:Number = 2 * near / (right - left);
			var y:Number = 2 * near / (top - bottom);
			
			var a:Number = (right + left) / (right - left);
			var b:Number = (top + bottom) / (top - bottom);
			var c:Number = - (far + near) / (far - near);
			var d:Number = - 2 * far * near / (far - near);
			
			te[0] = x;	te[1] = 0;	te[2] = a;	te[3] = 0;
			te[4] = 0;	te[5] = y;	te[6] = b;	te[7] = 0;
			te[8] = 0;	te[9] = 0;	te[10] = c;	te[11] = d;
			te[12] = 0;	te[13] = 0;	te[14] = -1;te[15] = 0;
			
			return this;
		}
	}
}