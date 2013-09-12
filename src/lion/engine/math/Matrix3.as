package lion.engine.math
{
	/**
	 * 3x3矩阵，主要给法向量用，因为法向量不需要平移 
	 * @author Dalton
	 * 
	 */	
	public class Matrix3
	{
		public var elements:Vector.<Number>;
		
		public function Matrix3(n11:Number = 1, n12:Number = 0, n13:Number = 0, 
								n21:Number = 0, n22:Number = 1, n23:Number = 0, 
								n31:Number = 0, n32:Number = 0, n33:Number = 1)
		{
			elements = new Vector.<Number>(9);
			
			elements[0] = n11; elements[1] = n12; elements[2] = n13;
			elements[3] = n21; elements[4] = n22; elements[5] = n23;
			elements[6] = n31; elements[7] = n32; elements[8] = n33; 
		}
		
		public function set(n11:Number, n12:Number, n13:Number,
							n21:Number, n22:Number, n23:Number, 
							n31:Number, n32:Number, n33:Number):Matrix3 {
			elements[0] = n11; elements[1] = n12; elements[2] = n13;
			elements[3] = n21; elements[4] = n22; elements[5] = n23; 
			elements[6] = n31; elements[7] = n32; elements[8] = n33;
			
			return this;
		}
		
		public function identity():Matrix3 {
			set(1, 0, 0,
				0, 1, 0,
				0, 0, 1);
			
			return this;
		}
		
		/**
		 * 复制矩阵值 
		 * @param m
		 * @return 
		 * 
		 */		
		public function copy(m:Matrix3):Matrix3 {
			var me:Vector.<Number> = m.elements;
			set(me[0], me[1], me[2],
				me[3], me[4], me[5],
				me[6], me[7], me[8]);
			
			return this;
		}
		
		public function getInverse(m:Matrix4):Matrix3 {
			var me:Vector.<Number> = m.elements;
			var te:Vector.<Number> = this.elements;
			
			te[0] =   me[10] * me[5] - me[9] * me[6];
			te[3] = - me[10] * me[4] + me[8] * me[6];
			te[6] =   me[9] * me[4] - me[8] * me[5];
			te[1] = - me[10] * me[1] + me[9] * me[2];
			te[4] =   me[10] * me[0] - me[8] * me[2];
			te[7] = - me[9] * me[0] + me[8] * me[1];
			te[2] =   me[6] * me[1] - me[5] * me[2];
			te[5] = - me[6] * me[0] + me[4] * me[2];
			te[8] =   me[5] * me[0] - me[4] * me[1];
			
			var det:Number = me[0] * te[0] + me[4] * te[1] + me[8] * te[2];
			
			// no inverse
			if (det === 0) {
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
		public function multiplyScalar(s:Number):Matrix3 {
			var te:Vector.<Number> = this.elements;
			
			te[0] *= s; te[1] *= s; te[2] *= s;
			te[3] *= s; te[4] *= s; te[5] *= s;
			te[6] *= s; te[7] *= s; te[8] *= s;
			
			return this;
		}
		
		public function transpose():Matrix3 {
			var tmp:Number, m:Vector.<Number> = this.elements;
			
			tmp = m[3]; m[3] = m[1]; m[1] = tmp;
			tmp = m[6]; m[6] = m[2]; m[2] = tmp;
			tmp = m[7]; m[7] = m[5]; m[5] = tmp;
			
			return this;
		}
		
		/**
		 * 获取法线矩阵
		 *  
		 * @param m
		 * @return 
		 * 
		 */		
		public function getNormalMatrix(m:Matrix4):Matrix3 {
			return this.getInverse(m).transpose();
		}
	}
}