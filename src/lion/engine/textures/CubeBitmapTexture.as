package lion.engine.textures
{
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	
	import lion.engine.utils.MipmapGenerator;
	import lion.engine.utils.TextureUtils;

	/**
	 * 立方纹理
	 * 主要用来做天空纹理 
	 * @author Dalton
	 * 
	 */	
	public class CubeBitmapTexture extends BaseTexture
	{
		private var _bitmapDatas:Vector.<BitmapData>;
		public var format:String = "";
		
		public function CubeBitmapTexture(posX:BitmapData, 
									negX:BitmapData, 
									posY:BitmapData, 
									negY:BitmapData, 
									posZ:BitmapData, 
									negZ:BitmapData)
		{
			_bitmapDatas = new Vector.<BitmapData>(6, true);
			testSize(_bitmapDatas[0] = posX);
			testSize(_bitmapDatas[1] = negX);
			testSize(_bitmapDatas[2] = posY);
			testSize(_bitmapDatas[3] = negY);
			testSize(_bitmapDatas[4] = posZ);
			testSize(_bitmapDatas[5] = negZ);
			super(posX.width, posY.height);
		}
		
		private function testSize(value:BitmapData):void
		{
			if (value.width != value.height)
				throw new Error("BitmapData should have equal width and height!");
			if (! TextureUtils.isBitmapDataValid(value))
				throw new Error("Invalid bitmapData: Width and height must be power of 2 and cannot exceed 2048");
		}
		
		override public function getTexture(context3D:Context3D, o:Boolean = false):TextureBase {
			// 创建纹理对象
			if (! textureBase) {
				textureBase = context3D.createCubeTexture(_width, Context3DTextureFormat.BGRA, false);
				// 提交纹理对象到GPU
				uploadContent(textureBase);
			}
			return textureBase;
		}
		
		override protected function uploadContent(texture:TextureBase):void
		{
			for (var i:int = 0; i < 6; ++i)
				MipmapGenerator.generateMipMaps(_bitmapDatas[i], texture, null, _bitmapDatas[i].transparent, i);
		}
		
		override public function dispose():void
		{
			for each (var b:BitmapData in _bitmapDatas) {
				b.dispose();
			}
			_bitmapDatas = null;
			super.dispose();
		}
	}
}