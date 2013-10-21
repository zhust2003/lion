package lion.engine.shaders
{
	/**
	 * 着色器编译器
	 * 由于AGAL实在太低级，大部分引擎都做了简易编译器 
	 * 由于AGAL没有循环及函数体，使用也不便，效率也低
	 * 本函数参考away3D
	 * @author Dalton
	 * 
	 */	
	public class ShaderCompiler
	{
		protected var _sharedRegisters:ShaderRegisterData;
		protected var _registerCache:ShaderRegisterCache;
		protected var _vertexCode:String;
		protected var _fragmentCode:String;
		
		// 光照相关索引
		protected var _lightFragmentConstantIndex:int = -1;
		
		public function ShaderCompiler()
		{
			_sharedRegisters = new ShaderRegisterData();
			_registerCache = new ShaderRegisterCache();
			_registerCache.reset();
		}
		
		public function compile():void {
			// 编译的最终目的就是生成顶点着色器代码以及片段着色器代码
			_vertexCode = "";
			_fragmentCode = "";
			
			compileProjectionCode();
			
			compileUVCode();
			compileNormalCode();
			compileViewDirCode();
			compileLightingCode();
			
			compileFragmentOutput();
		}
		
		private function compileUVCode():void
		{
			
		}
		
		private function compileNormalCode():void
		{
			
		}
		
		private function compileViewDirCode():void
		{
			
		}
		
		private function compileLightingCode():void
		{
			
		}
		
		protected function initRegisterIndices():void
		{
			_lightFragmentConstantIndex = -1;
		}
		
		private function compileProjectionCode():void
		{
			_vertexCode += "m44 op, va0, vc0		\n"
		}
		
		private function compileFragmentOutput():void
		{
			_fragmentCode += "mov " + _registerCache.fragmentOutputRegister + ", ft0 \n";
			
		}
	}
}