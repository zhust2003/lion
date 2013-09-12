package lion.engine.lights
{
	/**
	 * 平行光 
	 * @author Dalton
	 * 
	 */	
	public class DirectionalLight extends Light
	{
		public var intensity:Number;
		
		public function DirectionalLight(color:uint, intensity:Number = 1)
		{
			super(color);
			
			this.intensity = intensity;
		}
	}
}