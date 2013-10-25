package lion.engine.shaders
{
	/**
	 * 着色器寄存器变量 
	 * @author Dalton
	 * 
	 */	
	public class ShaderRegisterElement
	{
		private var _regName:String;
		public var index:int;
		private var _toStr:String;
		
		public function ShaderRegisterElement(regName:String, index:int = -1)
		{
			_regName = regName;
			this.index = index;
			
			_toStr = _regName;
			
			if (index >= 0)
				_toStr += index;
		}
		
		/**
		 * 着色器实际字符串 
		 * @return 
		 * 
		 */		
		public function toString():String
		{
			return _toStr;
		}
	}
}