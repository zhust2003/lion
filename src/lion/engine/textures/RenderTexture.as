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
		
//		/**
//		 * 提交到GPU 
//		 * @param texture
//		 * 
//		 */		
//		override protected function uploadContent(texture:TextureBase):void {
//			var bmp:BitmapData = new BitmapData(_width, _height, false, 0xff0000);
//			MipmapGenerator.generateMipMaps(bmp, texture);
//			bmp.dispose();
//		}
	}
}