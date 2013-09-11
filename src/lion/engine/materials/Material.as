package lion.engine.materials
{
	/**
	 * 材质 
	 * @author Dalton
	 * 
	 */	
	public class Material
	{
		public static var materialIDCount:uint = 0;
		public var id:uint;
		public var name:String;
		
		public function Material()
		{
			id = materialIDCount++;
			name = '';
		}
	}
}