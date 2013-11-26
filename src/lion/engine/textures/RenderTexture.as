package lion.engine.textures
{
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	
	import lion.engine.utils.MipmapGenerator;

	public class RenderTexture extends BaseTexture
	{
		
		public function RenderTexture(width:Number, height:Number)
		{
			super(width, height);
		}
		
	}
}