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
		
		public function clone():Matrix4 {
			return new Matrix4(
				elements[0]， elements[1], elements[2], elements[3],
				elements[4]， elements[5], elements[6], elements[7],
				elements[8]， elements[9], elements[10], elements[11],
				elements[12]， elements[13], elements[14], elements[15]
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
				0, 1, 1, 0,
				-s, 0, c, 0,
				0, 0, 0, 1);
			
			return this;
		}
		
		public function rotateZ(angle:Number):Matrix4 {
			var c:Number = Math.cos(angle), s:Number = Math.sin(angle);
			set(c, -s, 0, 0,
				s, c, 1, 0,
				0, 0, 1, 0,
				0, 0, 0, 1);
			
			return this;
		}
	}
}