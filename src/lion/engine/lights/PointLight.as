package lion.engine.lights
{
	/**
	 * 点光源 
	 * @author Dalton
	 * 
	 */	
	public class PointLight extends Light
	{
		public var intensity:Number;
		public var distance:Number;
		
		public function PointLight(color:uint, intensity:Number = 1, distance:Number = 0)
		{
			super(color);
			
			this.intensity = intensity;
			this.distance = distance;
		}
	}
}