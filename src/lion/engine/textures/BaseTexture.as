package lion.engine.textures
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	
	import lion.engine.math.Vector2;
	import lion.engine.utils.MipmapGenerator;

	public class BaseTexture
	{
		protected var textureBase:Texture;
		public var generateMipmaps:Boolean;
		protected var _width:Number;
		protected var _height:Number;
		public var wrap:String;
		public var offset:Vector2;
		public var repeat:Vector2;
		
		public function BaseTexture(width:Number, height:Number, genMipmap:Boolean = true)
		{
			_width = width;
			_height = height;
			generateMipmaps = genMipmap;
			offset = new Vector2(0, 0);
			repeat = new Vector2(1, 1);
			wrap = "clamp";
		}
		
		public function getTexture(context3D:Context3D, o:Boolean = false):Texture {
			// 创建纹理对象
			if (! textureBase) {
				textureBase = context3D.createTexture(_width, _height, Context3DTextureFormat.BGRA, o);
				// 提交纹理对象到GPU
				uploadContent(textureBase);
			}
			return textureBase;
		}
		
		protected function uploadContent(texture:Texture):void {
		}
		
		public function dispose():void {
			if (textureBase) {
				textureBase.dispose();
			}
		}
	}
}