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
		
		public function PointLight(color:uint, intensity:Number, distance:Number)
		{
			super(color);
			
			this.intensity = intensity;
			this.distance = distance;
		}
	}
}