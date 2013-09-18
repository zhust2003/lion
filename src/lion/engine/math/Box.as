package lion.engine.math
{
	public class Box
	{
		public var min:Vector3;
		public var max:Vector3;
		
		public function Box()
		{
			min = new Vector3();
			max = new Vector3();
		}
		
		public function setFromPoint(points:Vector.<Vector3>):Box {
			if (points.length > 0) {
				var point:Vector3 = points[0];
				min.copy(point);
				max.copy(point);
				
				for (var i:int = 1, l:int = points.length; i < l; ++i) {
					this.addPoint(points[i]);
				}
			}
			
			return this;
		}
		
		public function addPoint(point:Vector3):void {
			if (point.x < this.min.x) {
				
				this.min.x = point.x;
				
			} else if (point.x > this.max.x) {
				
				this.max.x = point.x;
				
			}
			
			if (point.y < this.min.y) {
				
				this.min.y = point.y;
				
			} else if (point.y > this.max.y) {
				
				this.max.y = point.y;
				
			}
			
			if (point.z < this.min.z) {
				
				this.min.z = point.z;
				
			} else if (point.z > this.max.z) {
				
				this.max.z = point.z;
				
			}
		}
		
		public function center():Vector3 {
			var result:Vector3 = new Vector3();
			return result.addVectors(this.min, this.max).multiply(0.5);
		}
	}
}