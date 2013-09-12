package lion.engine.math
{
	public class Color
	{
		public var r:Number = 0;
		public var g:Number = 0;
		public var b:Number = 0;
		
		public function Color(hex:uint = 0)
		{
			r = (hex >> 16 & 0xFF) / 255;
			g = (hex >> 8 & 0xFF) / 255;
			b = (hex & 0xFF) / 255;
		}
		
		public function toRGB():uint
		{
			var r:Number = r * 255;   if (r < 0) r = 0; else if (r > 255) r = 255;
			var g:Number = g * 255; if (g < 0) g = 0; else if (g > 255) g = 255;
			var b:Number = b * 255;  if (b < 0) b = 0; else if (b > 255) b = 255;
			
			return r << 16 | g << 8 | b;
		}
		
		public function copy(c:Color):Color {
			this.r = c.r;
			this.g = c.g;
			this.b = c.b;
			
			return this;
		}
		
		public function add(c:Color):Color {
			this.r += c.r;
			this.g += c.g;
			this.b += c.b;
			
			return this;
		}
		
		public function addScalar(s:Number):Color {
			this.r += s;
			this.g += s;
			this.b += s;
			
			return this;
		}
		
		public function multiply(c:Color):Color {
			this.r *= c.r;
			this.g *= c.g;
			this.b *= c.b;
			
			return this;
		}
		
		public function multiplyScalar(s:Number):Color {
			this.r *= s;
			this.g *= s;
			this.b *= s;
			
			return this;
		}
		
		public function toString():String {
			return "[Color (r:" + r + ", g:" + g + ", b:" + b + ")]";
		}
	}
}