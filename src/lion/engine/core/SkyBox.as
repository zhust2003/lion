package lion.engine.core
{
	import lion.engine.geometries.CubeGeometry;
	import lion.engine.geometries.Geometry;
	import lion.engine.materials.Material;
	import lion.engine.materials.SkyBoxMaterial;
	import lion.engine.textures.CubeBitmapTexture;
	
	public class SkyBox extends Mesh
	{
		public function SkyBox(t:CubeBitmapTexture)
		{
			var g:Geometry = new CubeGeometry(2000, 2000, 2000);
			var m:Material = new SkyBoxMaterial(t);
			super(g, m);
		}
	}
}