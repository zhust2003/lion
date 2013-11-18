package lion.engine.materials
{
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Program3D;
	
	import lion.engine.textures.BitmapTexture;

	/**
	 * 材质 
	 * @author Dalton
	 * 
	 */	
	public class Material
	{
		public static var materialIDCount:uint = 0;
		public var id:uint;
		public var name:String;
		
		// 剔除面
		public var side:String;
		
		// 深度对比模式
		public var depthCompareMode:String = Context3DCompareMode.LESS_EQUAL;
		// 混合模式
		public var blendFactorSource:String = Context3DBlendFactor.ONE;
		public var blendFactorDest:String = Context3DBlendFactor.ZERO;
		public var enableBlending:Boolean;
		
		// 着色器相关
		public var program:Program3D;
		public var dirty:Boolean = true;
		
		public var vshader:AGALMiniAssembler;
		public var fshader:AGALMiniAssembler;
		
		// 使用的纹理
		public var texture:BitmapTexture;
		
		public function Material()
		{
			id = materialIDCount++;
			name = '';
			side = Context3DTriangleFace.FRONT;
		}
		
		public function activate():void {
		
		}
		
		public function update(s:MaterialUpdateState):void {
		
		}
		
		public function deactivate():void {
		
		}
	}
}