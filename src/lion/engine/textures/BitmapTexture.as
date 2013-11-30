package lion.engine.textures
{
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	
	import lion.engine.utils.MipmapGenerator;

	public class BitmapTexture extends BaseTexture
	{
		private var bitmapData:BitmapData;
		private var mipMapHolder:BitmapData;
		
		public function BitmapTexture(bitmapData:BitmapData, generateMipmaps:Boolean = true)
		{
			this.bitmapData = bitmapData;
			super(bitmapData.width, bitmapData.height, generateMipmaps);
		}
		
		/**
		 * 提交到GPU 
		 * @param texture
		 * 
		 */		
		override protected function uploadContent(texture:TextureBase):void {
			if (generateMipmaps) {
				MipmapGenerator.generateMipMaps(bitmapData, texture, mipMapHolder, true);
			} else {
				Texture(texture).uploadFromBitmapData(bitmapData, 0);
			}
		}
		
		override public function dispose():void
		{
			if (bitmapData) {
				bitmapData.dispose();
			}
		}
	}
}