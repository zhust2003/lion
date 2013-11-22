package lion.engine.lights
{
	import flash.display3D.textures.TextureBase;
	
	import lion.engine.core.Object3D;
	import lion.engine.math.Color;
	import lion.engine.textures.RenderTexture;
	
	public class Light extends Object3D
	{
		public var color:Color;
		public var shadowMap:RenderTexture;
		
		public function Light(color:uint)
		{
			super();
			this.color = new Color(color);
			this.castShadow = false;
		}
	}
}