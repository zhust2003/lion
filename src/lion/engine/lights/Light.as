package lion.engine.lights
{
	import lion.engine.core.Object3D;
	import lion.engine.math.Color;
	
	public class Light extends Object3D
	{
		public var color:Color;
		
		public function Light(color:uint)
		{
			super();
			this.color = new Color(color);
		}
	}
}