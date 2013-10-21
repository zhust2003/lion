package lion.engine.shaders
{
	import flash.utils.Dictionary;

	/**
	 * 寄存器池，有些寄存器是有数量限制的，所有用一个池进行维护 
	 * @author Dalton
	 * 
	 */	
	public class ShaderRegisterPool
	{
		private static const _regPool:Dictionary = new Dictionary();
		
		private var _vectorRegisters:Vector.<ShaderRegisterElement>;
		private var _usedVectorCount:Vector.<uint>;
		private var _regName:String;
		private var _regCount:int;
		
		public function ShaderRegisterPool(regName:String, regCount:int)
		{
			_regName = regName;
			_regCount = regCount;
			initRegisters(regName, regCount);
		}
		
		private function initRegisters(regName:String, regCount:int):void
		{
			var hash:String = ShaderRegisterPool._initPool(regName, regCount);
			_vectorRegisters = ShaderRegisterPool._regPool[hash];
			
			_usedVectorCount = new Vector.<uint>(regCount, true);
		}
		
		public function requestFreeVectorReg():ShaderRegisterElement
		{
			for (var i:int = 0; i < _regCount; ++i) {
				if (! isRegisterUsed(i)) {
					_usedVectorCount[i]++;
					return _vectorRegisters[i];
				}
			}
			
			throw new Error("Register overflow!");
		}
		
		private function isRegisterUsed(index:int):Boolean
		{
			if (_usedVectorCount[index] > 0)
				return true;
			
			return false;
		}
		
		private static function _initPool(regName:String, regCount:int):String
		{
			var hash:String = regName + regCount;
			
			if (_regPool[hash] != undefined)
				return hash;
			
			var vectorRegisters:Vector.<ShaderRegisterElement> = new Vector.<ShaderRegisterElement>(regCount, true);
			_regPool[hash] = vectorRegisters;
			
			
			for (var i:int = 0; i < regCount; ++i) {
				vectorRegisters[i] = new ShaderRegisterElement(regName, i);
			}
			return hash;
		}
		
		public function dispose():void
		{
			_vectorRegisters = null;
		}
	}
}