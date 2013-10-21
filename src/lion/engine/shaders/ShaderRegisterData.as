package lion.engine.shaders
{
	/**
	 * 共享的寄存器数据，因为寄存器是按编号放的，用as变量统一访问
	 * 防止更名的问题 
	 * @author Dalton
	 * 
	 */	
	public class ShaderRegisterData
	{
		public var globalPositionVertex:ShaderRegisterElement;
		public var viewDirFragment:ShaderRegisterElement;
		
		public function ShaderRegisterData()
		{
		}
	}
}