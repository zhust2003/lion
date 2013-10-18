package lion.engine.textures
{
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	
	import lion.engine.utils.MipmapGenerator;

	public class BitmapTexture
	{
		private var bitmapData:BitmapData;
		private var generateMipmaps:Boolean;
		private var mipMapHolder:BitmapData;
		private var textureBase:Texture;
		
		public function BitmapTexture(bitmapData:BitmapData, generateMipmaps:Boolean = true)
		{
			this.bitmapData = bitmapData;
			this.generateMipmaps = generateMipmaps;
		}
		
		/**
		 * 获取context3D可以使用的纹理类 
		 * @return 
		 * 
		 */		
		public function getTexture(context3D:Context3D):TextureBase {
			// 创建纹理对象
			if (! textureBase) {
				textureBase = context3D.createTexture(bitmapData.width, bitmapData.height, Context3DTextureFormat.BGRA, false);
				// 提交纹理对象到GPU
				uploadContent(textureBase);
			}
			return textureBase;
		}
		
		/**
		 * 提交到GPU 
		 * @param texture
		 * 
		 */		
		private function uploadContent(texture:TextureBase):void {
			if (generateMipmaps) {
				MipmapGenerator.generateMipMaps(bitmapData, texture, mipMapHolder, true);
			} else {
				Texture(texture).uploadFromBitmapData(bitmapData, 0);
			}
		}
		
		public function dispose():void
		{
			if (textureBase) {
				textureBase.dispose();
			}
		}
	}
}