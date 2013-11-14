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
		// 顶点世界坐标
		public var globalPositionVertex:ShaderRegisterElement;
		// 顶点本地坐标
		public var localPosition:ShaderRegisterElement;
		// 法线寄存器，一般是va1
		public var normalInput:ShaderRegisterElement;
		// 法线变换后的临时变量，此时已经是世界坐标
		public var normalVarying:ShaderRegisterElement;
		// 目标颜色
		public var targetLightColor:ShaderRegisterElement;
		// 视线向量
		public var viewDirVertex:ShaderRegisterElement;
		
		public function ShaderRegisterData()
		{
		}
	}
}