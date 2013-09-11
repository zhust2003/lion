package lion.engine.core
{
	import lion.engine.geometries.Geometry;
	import lion.engine.materials.Material;

	/**
	 * 3D物体（由材质与多边形组成） 
	 * @author Dalton
	 * 
	 */	
	public class Mesh extends Object3D
	{
		public var geometry:Geometry;
		public var material:Material;
		
		public function Mesh(g:Geometry, m:Material)
		{
			super();
			this.geometry = g;
			this.material = m;
		}
	}
}