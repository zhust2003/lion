package lion.engine.math
{
	public class MathUtil
	{
		public static const degreeToRadiansFactor:Number = Math.PI / 180;
		public static const radianToDegreesFactor:Number = 180 / Math.PI;
		
		public function MathUtil()
		{
		}
		
		public static function cosd(degrees:Number):Number {
			return Math.cos(toRadians(degrees));
		}
		
		public static function sind(degrees:Number):Number {
			return Math.sin(toRadians(degrees));
		}
		
		public static function toRadians(degrees:Number):Number {
			return degrees * degreeToRadiansFactor;
		}
		
		public static function toDegrees(radians:Number):Number {
			return radians * radianToDegreesFactor;
		}
		
		public static function rand(min:int, max:int):int {
			return min + Math.floor(Math.random() * (max - min + 1));
		}
		
		public static function randf(min:Number, max:Number):Number {
			return min + Math.random() * (max - min);
		}
		
		public static function chance(v:uint):Boolean {
			return (rand(1, 100) <= v);
		}
		
		public static function sign(v:Number):int {
			return (v < 0) ? -1 : ((v > 0) ? 1 : 0);
		}
		
		public static function getRandomElementOf(array:Array):* {
			var idx:int = rand(0, array.length - 1);
			return array[idx];
		}
		
		public static function generateUUID():String {
			
			// http://www.broofa.com/Tools/Math.uuid.htm
			
			var chars:Array = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.split('');
			var uuid:Array = new Array(36);
			var rnd:int = 0, r:int;
				
			for (var i:int = 0; i < 36; i++) {
				
				if (i == 8 || i == 13 || i == 18 || i == 23) {
					uuid[i] = '-';
				} else if (i == 14) {
					uuid[i] = '4';
				} else {
					if (rnd <= 0x02) rnd = 0x2000000 + (Math.random()*0x1000000)|0;
					r = rnd & 0xf;
					rnd = rnd >> 4;
					uuid[i] = chars[(i == 19) ? (r & 0x3) | 0x8 : r];
				}
			}
			
			return uuid.join('');
		}
		// http://en.wikipedia.org/wiki/Smoothstep
		public static function smoothstep(x:Number, min:Number, max:Number):Number {
			if ( x <= min ) return 0;
			if ( x >= max ) return 1;
			
			x = (x - min) / (max - min);
			
			return x * x * (3 - 2 * x);
		}
		
		public static function smootherstep(x:Number, min:Number, max:Number):Number {
			if ( x <= min ) return 0;
			if ( x >= max ) return 1;
			
			x = (x - min) / (max - min);
			
			return x * x * x * (x * (x * 6 - 15) + 10);
		}
	}
}