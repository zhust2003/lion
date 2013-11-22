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
			
			// row-major
			// 列优先实在看着不舒服
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
			return multiplyMatrices(this, m);;
		}
		
		/**
		 * 复制矩阵值 
		 * @param m
		 * @return 
		 * 
		 */		
		public function copy(m:Matrix4):Matrix4 {
			var me:Vector.<Number> = m.elements;
			set(me[0], me[1], me[2], me[3],
				me[4], me[5], me[6], me[7],
				me[8], me[9], me[10], me[11],
				me[12], me[13], me[14], me[15]);
			return this;
		}
		
		/**
		 * 矩阵乘法 
		 * @param a
		 * @param b
		 * @return 
		 * 
		 */		
		public function multiplyMatrices(a:Matrix4, b:Matrix4):Matrix4 {
			var ae:Vector.<Number> = a.elements;
			var be:Vector.<Number> = b.elements;
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
		 * 通过位置，四元数，缩放参数复合成四维矩阵 
		 * @param position
		 * @param quaternion
		 * @param scale
		 * @return 
		 * 
		 */		
		public function compose(position:Vector3, quaternion:Quaternion, scale:Vector3):Matrix4 {
			makeRotationFromQuaternion(quaternion);
			makeScale(scale);
			makePosition(position);
			return this;
		}
		
		private function makeScale(v:Vector3):Matrix4 {
			var te:Vector.<Number> = this.elements;
			var x:Number = v.x, y:Number = v.y, z:Number = v.z;
			
			te[0] *= x; te[1] *= y; te[2] *= z;
			te[4] *= x; te[5] *= y; te[6] *= z;
			te[8] *= x; te[9] *= y; te[10] *= z;
			te[12] *= x; te[13] *= y; te[14] *= z;
			
			return this;
		}
		
		/**
		 * 四元数转为矩阵 
		 * @param quaternion
		 * @return 
		 * 
		 */		
		private function makeRotationFromQuaternion(q:Quaternion):Matrix4 {
			var te:Vector.<Number> = this.elements;
			
			var x:Number = q.x, y:Number = q.y, z:Number = q.z, w:Number = q.w;
			var x2:Number = x + x, y2:Number = y + y, z2:Number = z + z;
			var xx:Number = x * x2, xy:Number = x * y2, xz:Number = x * z2;
			var yy:Number = y * y2, yz:Number = y * z2, zz:Number = z * z2;
			var wx:Number = w * x2, wy:Number = w * y2, wz:Number = w * z2;
			
			te[0] = 1 - ( yy + zz );
			te[1] = xy - wz;
			te[2] = xz + wy;
			
			te[4] = xy + wz;
			te[5] = 1 - ( xx + zz );
			te[6] = yz - wx;
			
			te[8] = xz - wy;
			te[9] = yz + wx;
			te[10] = 1 - ( xx + yy );
			
			// last column
			te[3] = 0;
			te[7] = 0;
			te[11] = 0;
			
			// bottom row
			te[12] = 0;
			te[13] = 0;
			te[14] = 0;
			te[15] = 1;
			
			return this;
		}
		
		/**
		 * 欧拉角转成矩阵 
		 * http://www.euclideanspace.com/maths/geometry/rotations/conversions/eulerToMatrix/index.htm
		 * @param euler
		 * @return 
		 * 
		 */		
		private function makeRotationFromEuler(euler:Euler):Matrix4 {
			var te:Vector.<Number> = this.elements;
			
			var x:Number = euler.x, y:Number = euler.y, z:Number = euler.z;
			var a:Number = Math.cos(x), b:Number = Math.sin(x);
			var c:Number = Math.cos(y), d:Number = Math.sin(y);
			var e:Number = Math.cos(z), f:Number = Math.sin(z);
			
			var ae:Number, af:Number, be:Number, bf:Number, ce:Number, cf:Number, de:Number, df:Number, ac:Number, ad:Number, bc:Number, bd:Number;
			
			// 不同的欧拉角顺序导致的最终矩阵值是不同的
			if (euler.order === 'XYZ') {
				
				ae = a * e;
				af = a * f;
				be = b * e;
				bf = b * f;
				
				te[0] = c * e;
				te[1] = - c * f;
				te[2] = d;
				
				te[4] = af + be * d;
				te[5] = ae - bf * d;
				te[6] = - b * c;
				
				te[8] = bf - ae * d;
				te[9] = be + af * d;
				te[10] = a * c;
				
			} else if (euler.order === 'YXZ') {
				
				ce = c * e;
				cf = c * f;
				de = d * e;
				df = d * f;
				
				te[0] = ce + df * b;
				te[1] = de * b - cf;
				te[2] = a * d;
				
				te[4] = a * f;
				te[5] = a * e;
				te[6] = - b;
				
				te[8] = cf * b - de;
				te[9] = df + ce * b;
				te[10] = a * c;
				
			} else if (euler.order === 'ZXY') {
				
				ce = c * e;
				cf = c * f;
				de = d * e;
				df = d * f;
				
				te[0] = ce - df * b;
				te[1] = - a * f;
				te[2] = de + cf * b;
				
				te[4] = cf + de * b;
				te[5] = a * e;
				te[6] = df - ce * b;
				
				te[8] = - a * d;
				te[9] = b;
				te[10] = a * c;
				
			} else if (euler.order === 'ZYX') {
				
				ae = a * e;
				af = a * f;
				be = b * e;
				bf = b * f;
				
				te[0] = c * e;
				te[1] = be * d - af;
				te[2] = ae * d + bf;
				
				te[4] = c * f;
				te[5] = bf * d + ae;
				te[6] = af * d - be;
				
				te[8] = - d;
				te[9] = b * c;
				te[10] = a * c;
				
			} else if (euler.order === 'YZX') {
				
				ac = a * c;
				ad = a * d;
				bc = b * c;
				bd = b * d;
				
				te[0] = c * e;
				te[1] = bd - ac * f;
				te[2] = bc * f + ad;
				
				te[4] = f;
				te[5] = a * e;
				te[6] = - b * e;
				
				te[8] = - d * e;
				te[9] = ad * f + bc;
				te[10] = ac - bd * f;
				
			} else if (euler.order === 'XZY') {
				
				ac = a * c;
				ad = a * d;
				bc = b * c;
				bd = b * d;
				
				te[0] = c * e;
				te[1] = - f;
				te[2] = d * e;
				
				te[4] = ac * f + bd;
				te[5] = a * e;
				te[6] = ad * f - bc;
				
				te[8] = bc * f - ad;
				te[9] = b * e;
				te[10] = bd * f + ac;
			}
			
			// last column
			te[3] = 0;
			te[7] = 0;
			te[11] = 0;
			
			// bottom row
			te[12] = 0;
			te[13] = 0;
			te[14] = 0;
			te[15] = 1;
			
			return this;
		}
		
		private function makePosition(position:Vector3):Matrix4 {
			var te:Vector.<Number> = this.elements;
			
			te[3] = position.x;
			te[7] = position.y;
			te[11] = position.z;
			return this;
		}
		
		/**
		 * 获取逆矩阵 
		 * 与逆矩阵相乘为单位矩阵
		 * @param m
		 * @return 
		 * 
		 */		
		public function getInverse(m:Matrix4):Matrix4 {	
			// based on http://www.euclideanspace.com/maths/algebra/matrix/functions/inverse/fourD/index.htm
			var te:Vector.<Number> = this.elements;
			var me:Vector.<Number> = m.elements;
			
			var n11:Number = me[0], n12:Number = me[1], n13:Number = me[2], n14:Number = me[3];
			var n21:Number = me[4], n22:Number = me[5], n23:Number = me[6], n24:Number = me[7];
			var n31:Number = me[8], n32:Number = me[9], n33:Number = me[10], n34:Number = me[11];
			var n41:Number = me[12], n42:Number = me[13], n43:Number = me[14], n44:Number = me[15];
			
			// 余子式
			te[0] = n23*n34*n42 - n24*n33*n42 + n24*n32*n43 - n22*n34*n43 - n23*n32*n44 + n22*n33*n44;
			te[1] = n14*n33*n42 - n13*n34*n42 - n14*n32*n43 + n12*n34*n43 + n13*n32*n44 - n12*n33*n44;
			te[2] = n13*n24*n42 - n14*n23*n42 + n14*n22*n43 - n12*n24*n43 - n13*n22*n44 + n12*n23*n44;
			te[3] = n14*n23*n32 - n13*n24*n32 - n14*n22*n33 + n12*n24*n33 + n13*n22*n34 - n12*n23*n34;
			te[4] = n24*n33*n41 - n23*n34*n41 - n24*n31*n43 + n21*n34*n43 + n23*n31*n44 - n21*n33*n44;
			te[5] = n13*n34*n41 - n14*n33*n41 + n14*n31*n43 - n11*n34*n43 - n13*n31*n44 + n11*n33*n44;
			te[6] = n14*n23*n41 - n13*n24*n41 - n14*n21*n43 + n11*n24*n43 + n13*n21*n44 - n11*n23*n44;
			te[7] = n13*n24*n31 - n14*n23*n31 + n14*n21*n33 - n11*n24*n33 - n13*n21*n34 + n11*n23*n34;
			te[8] = n22*n34*n41 - n24*n32*n41 + n24*n31*n42 - n21*n34*n42 - n22*n31*n44 + n21*n32*n44;
			te[9] = n14*n32*n41 - n12*n34*n41 - n14*n31*n42 + n11*n34*n42 + n12*n31*n44 - n11*n32*n44;
			te[10] = n12*n24*n41 - n14*n22*n41 + n14*n21*n42 - n11*n24*n42 - n12*n21*n44 + n11*n22*n44;
			te[11] = n14*n22*n31 - n12*n24*n31 - n14*n21*n32 + n11*n24*n32 + n12*n21*n34 - n11*n22*n34;
			te[12] = n23*n32*n41 - n22*n33*n41 - n23*n31*n42 + n21*n33*n42 + n22*n31*n43 - n21*n32*n43;
			te[13] = n12*n33*n41 - n13*n32*n41 + n13*n31*n42 - n11*n33*n42 - n12*n31*n43 + n11*n32*n43;
			te[14] = n13*n22*n41 - n12*n23*n41 - n13*n21*n42 + n11*n23*n42 + n12*n21*n43 - n11*n22*n43;
			te[15] = n12*n23*n31 - n13*n22*n31 + n13*n21*n32 - n11*n23*n32 - n12*n21*n33 + n11*n22*n33;
			
			// 行列式值
			var det:Number = n11 * te[0] + n21 * te[1] + n31 * te[2] + n41 * te[3];
			
			if (det == 0) {
				throw new Error("行列式值为0，不存在逆矩阵"); 
				this.identity();
				return this;
			}
			
			// 除以行列式值
			this.multiplyScalar(1 / det);
			
			return this;
		}
		
		/**
		 * 乘以标量 
		 * @param s
		 * @return 
		 * 
		 */		
		public function multiplyScalar(s:Number):Matrix4 {
			var te:Vector.<Number> = this.elements;
			
			te[0] *= s; te[1] *= s; te[2] *= s; te[3] *= s;
			te[4] *= s; te[5] *= s; te[6] *= s; te[7] *= s;
			te[8] *= s; te[9] *= s; te[10] *= s; te[11] *= s;
			te[12] *= s; te[13] *= s; te[14] *= s; te[15] *= s;
			
			return this;
		}
		
		/**
		 * 朝向某个向量 
		 * @param eye
		 * @param target
		 * @param up
		 * @return 
		 * 
		 */		
		public function lookAt(eye:Vector3, target:Vector3, up:Vector3):Matrix4 {
			var te:Vector.<Number> = this.elements;
			
			var x:Vector3 = new Vector3();
			var y:Vector3 = new Vector3();
			var z:Vector3 = new Vector3();
			// 这个朝向向量的坐标系z轴直接指向目标
			z.subVectors(eye, target).normalize();
			// 通过叉乘算出x轴
			x.crossVectors(up, z).normalize();
			y.crossVectors(z, x);
			
			te[0] = x.x; te[1] = y.x; te[2] = z.x;
			te[4] = x.y; te[5] = y.y; te[6] = z.y;
			te[8] = x.z; te[9] = y.z; te[10] = z.z;
			
			return this;
		}
		
		/**
		 * 获取矩阵的行列式
		 * @return 
		 * 
		 */		
		public function determinant():Number {
			return 0;
		}
		
		/**
		 * 正射视景体到标准视景体的转换
		 * opengl
		 * 标准视景体为 [-1, 1] x [-1, 1] x [-1, 1]
		 * dx
		 * 标准视景体为[0, 1] 
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
			
			// opengl
			var dx:Number = (right + left) / w;
			var dy:Number = (top + bottom) / h;
			var dz:Number = (near) / p;
			
			te[0] = 2 / w;	te[1] = 0;		te[2] = 0;		te[3] = -dx;
			te[4] = 0;		te[5] = 2 / h;	te[6] = 0;		te[7] = -dy;
			te[8] = 0;		te[9] = 0;		te[10] = -1 / p;te[11] = -dz;
			te[12] = 0;		te[13] = 0;		te[14] = 0;		te[15] = 1;
			
			// dx
//			var dx:Number = (left) / w;
//			var dy:Number = (bottom) / h;
//			var dz:Number = (near) / p;
//			
//			te[0] = 1 / w;	te[1] = 0;		te[2] = 0;		te[3] = -dx;
//			te[4] = 0;		te[5] = 1 / h;	te[6] = 0;		te[7] = -dy;
//			te[8] = 0;		te[9] = 0;		te[10] = -1 / p;te[11] = -dz;
//			te[12] = 0;		te[13] = 0;		te[14] = 0;		te[15] = 1;
			
			return this;
		}
		
		/**
		 * 
		 * 透视视景体到标准视景体的转换
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
		public function makePerspective(left:Number, right:Number, bottom:Number, top:Number, near:Number, far:Number):Matrix4 {
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
		
		public function getMaxScaleOnAxis():Number {
			var te:Vector.<Number> = this.elements;
			
			var scaleXSq:Number = te[0] * te[0] + te[4] * te[4] + te[8] * te[8];
			var scaleYSq:Number = te[1] * te[1] + te[5] * te[5] + te[9] * te[9];
			var scaleZSq:Number = te[2] * te[2] + te[6] * te[6] + te[10] * te[10];
			
			return Math.sqrt(Math.max(scaleXSq, Math.max(scaleYSq, scaleZSq)));
		}
		
		/**
		 * 矩阵拷贝
		 * 新建对象 
		 * @return 
		 * 
		 */		
		public function clone():Matrix4 {
			return new Matrix4(
				elements[0], elements[1], elements[2], elements[3],
				elements[4], elements[5], elements[6], elements[7],
				elements[8], elements[9], elements[10], elements[11],
				elements[12], elements[13], elements[14], elements[15]
			);
		}
		
		public function toString():String {
			return "[Matrix4]\n" +
					elements[0] + "," + elements[1] + "," + elements[2] + "," + elements[3] + "\n" +
					elements[4] + "," + elements[5] + "," + elements[6] + "," + elements[7] + "\n" +
					elements[8] + "," + elements[9] + "," + elements[10] + "," + elements[11] + "\n" +
					elements[12] + "," + elements[13] + "," + elements[14] + "," + elements[15];
		}
		
		public function toMatrix3D():Matrix3D {
			return new Matrix3D(Vector.<Number>([elements[0], elements[4], elements[8], elements[12],
								elements[1], elements[5], elements[9], elements[13],
								elements[2], elements[6], elements[10], elements[14],
								elements[3], elements[7], elements[11], elements[15]]));
		}
	}
}