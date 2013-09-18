package lion.engine.math
{
	public class Sphere
	{
		public var center:Vector3;
		public var radius:Number;
		
		public function Sphere(center:Vector3 = null, radius:Number = 10)
		{
			this.center = center || new Vector3();
			this.radius = radius;
		}
		
		public function copy(sphere:Sphere):Sphere {
			this.center.copy(sphere.center);
			this.radius = sphere.radius;
			return this;
		}
		
		public function setFromPoints(points:Vector.<Vector3>):Sphere {
			var b:Box = new Box();
			center = b.setFromPoint(points).center();
			var maxRadiuSq:Number = 0;
			for each (var p:Vector3 in points) {
				maxRadiuSq = Math.max(maxRadiuSq, center.distSQ(p));
			}
			radius = Math.sqrt(maxRadiuSq);
			return this;
		}
		
		public function applyMatrix4(m:Matrix4):Sphere {
			center.applyMatrix4(m);
			radius *= m.getMaxScaleOnAxis();
			return this;
		}
	}
}