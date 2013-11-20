package lion.engine.shaders
{
	/**
	 * 寄存器缓存，管理所有的寄存器池与寄存器元素 
	 * @author Dalton
	 * 
	 */	
	public class ShaderRegisterCache
	{		
		private var _fragmentTempCache:ShaderRegisterPool;
		private var _vertexTempCache:ShaderRegisterPool;
		private var _varyingCache:ShaderRegisterPool;
		private var _fragmentConstantsCache:ShaderRegisterPool;
		private var _vertexConstantsCache:ShaderRegisterPool;
		private var _textureCache:ShaderRegisterPool;
		private var _vertexAttributesCache:ShaderRegisterPool;
		
		public var fragmentOutputRegister:ShaderRegisterElement;
		private var _vertexOutputRegister:ShaderRegisterElement;
		public var numUsedFragmentConstants:int;
		public var numUsedVertexConstants:int;
		private var numUsedTextures:int;
		
		public function ShaderRegisterCache()
		{
		}
		
		public function reset():void {
			// 寄存器临时变量
			_fragmentTempCache = new ShaderRegisterPool("ft", 8);
			_vertexTempCache = new ShaderRegisterPool("vt", 8);
			// 顶点着色器与片段着色器通讯变量
			_varyingCache = new ShaderRegisterPool("v", 8);
			// 纹理寄存器
			_textureCache = new ShaderRegisterPool("fs", 8);
			// 顶点属性寄存器
			_vertexAttributesCache = new ShaderRegisterPool("va", 8);
			// 片段常量寄存器
			_fragmentConstantsCache = new ShaderRegisterPool("fc", 28);
			// 顶点常量寄存器
			_vertexConstantsCache = new ShaderRegisterPool("vc", 128);
			// 片段输出寄存器
			fragmentOutputRegister = new ShaderRegisterElement("oc", -1);
			// 顶点输出寄存器
			_vertexOutputRegister = new ShaderRegisterElement("op", -1);
		}
		
		/**
		 * 获取可用的顶点属性 
		 * @return 
		 * 
		 */		
		public function getFreeVertexAttribute():ShaderRegisterElement
		{
			return _vertexAttributesCache.requestFreeVectorReg();
		}
		
		/**
		 * 获取可用的纹理寄存器 
		 * @return 
		 * 
		 */		
		public function getFreeTextureReg():ShaderRegisterElement
		{
			return _textureCache.requestFreeVectorReg();
		}
		
		/**
		 * 获取临时的顶点寄存器 
		 * @return 
		 * 
		 */		
		public function getFreeVertexVectorTemp():ShaderRegisterElement
		{
			return _vertexTempCache.requestFreeVectorReg();
		}
		
		public function removeVertexTempUsage(register:ShaderRegisterElement):void
		{
			_vertexTempCache.removeUsage(register);
		}
		
		/**
		 * 获取临时的片段寄存器 
		 * @return 
		 * 
		 */		
		public function getFreeFragmentVectorTemp():ShaderRegisterElement
		{
			return _fragmentTempCache.requestFreeVectorReg();
		}
		
		public function removeFragmentTempUsage(register:ShaderRegisterElement):void
		{
			_fragmentTempCache.removeUsage(register);
		}
		
		/**
		 * 获取顶点与片段通讯寄存器 
		 * @return 
		 * 
		 */		
		public function getFreeVarying():ShaderRegisterElement
		{
			return _varyingCache.requestFreeVectorReg();
		}
		
		/**
		 * 获取可用的片段常量寄存器 
		 * @return 
		 * 
		 */		
		public function getFreeFragmentConstant():ShaderRegisterElement
		{
			++numUsedFragmentConstants;
			return _fragmentConstantsCache.requestFreeVectorReg();
		}
		
		/**
		 * 获取可用的顶点常量寄存器 
		 * @return 
		 * 
		 */	
		public function getFreeVertexConstant():ShaderRegisterElement
		{
			++numUsedVertexConstants;
			return _vertexConstantsCache.requestFreeVectorReg();
		}
	
		
		public function dispose():void
		{
			_fragmentTempCache.dispose();
			_vertexTempCache.dispose();
			_varyingCache.dispose();
			_textureCache.dispose();
			_fragmentConstantsCache.dispose();
			_vertexAttributesCache.dispose();
			
			_fragmentTempCache = null;
			_vertexTempCache = null;
			_varyingCache = null;
			_fragmentConstantsCache = null;
			_vertexAttributesCache = null;
			fragmentOutputRegister = null;
			_vertexOutputRegister = null;
		}
	}
}