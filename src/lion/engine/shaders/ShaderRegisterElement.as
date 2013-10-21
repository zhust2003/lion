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
		private var _index:int;
		private var _toStr:String;
		
		public function ShaderRegisterElement(regName:String, index:int = -1)
		{
			_regName = regName;
			_index = index;
			
			_toStr = _regName;
			
			if (_index >= 0)
				_toStr += _index;
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