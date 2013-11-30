package lion.engine.core
{
	import lion.engine.geometries.Geometry;
	import lion.engine.geometries.PlaneGeometry;
	import lion.engine.materials.Material;
	
	/**
	 * 公告牌，没有旋转分量 
	 * @author Dalton
	 * 
	 */	
	public class Sprite3D extends Mesh
	{
		public function Sprite3D(m:Material, width:Number, height:Number)
		{
			var g:PlaneGeometry = new PlaneGeometry(width, height);
			super(g, m);
		}
		
	}
}