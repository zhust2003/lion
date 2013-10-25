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
		
		
		// 所有的光线寄存器
		private var _pointLightRegisters:Vector.<ShaderRegisterElement>;
		private var _dirLightRegisters:Vector.<ShaderRegisterElement>;
		
		// 输入
		// 光源数量
		protected var numDirectionalLights:int;
		protected var numPointLights:int;
		
		// 输出
		// 光源索引
		// 光源位置，光源颜色等
		protected var lightVetexConstantIndex:int;
		// 模型视图投影矩阵（计算最终位置的）
		// 法线投影矩阵（计算法线的世界位置）
		protected var normalMatrixIndex:int;
		// 模型矩阵（计算顶点的世界坐标）
		protected var matrixIndex:int;	
		// 材质的漫反射索引
		protected var diffuseFragmentConstantsIndex:int;
		// 摄像机位置索引
		private var cameraPositionIndex:int;
		
		
		// uv缓存索引，一般是va1
		private var _uvBufferIndex:int;
		// 法线缓存索引，一般是va2
		private var _normalBufferIndex:int;
		
		
		private var diffuseInputRegister:ShaderRegisterElement;
		
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
			
			// va0 = localposition
			_sharedRegisters.localPosition = _registerCache.getFreeVertexAttribute();
			_sharedRegisters.targetLightColor = _registerCache.getFreeVarying();
			
			compileGlobalPositionCode();
			compileProjectionCode();
			
			compileUVCode();
			compileNormalCode();
			compileViewDirCode();
			compileLightingCode();
			
			compileFragmentOutput();
		}
		
		private function compileGlobalPositionCode():void
		{
			_sharedRegisters.globalPositionVertex = _registerCache.getFreeVertexVectorTemp();
			var positionMatrixReg:ShaderRegisterElement = _registerCache.getFreeVertexConstant();
			matrixIndex = positionMatrixReg.index;
			_vertexCode += "m44 " + _sharedRegisters.globalPositionVertex + ", " + _sharedRegisters.localPosition + ", " + positionMatrixReg + "\n";
		}
		
		private function compileUVCode():void
		{
			var uvAttributeReg:ShaderRegisterElement = _registerCache.getFreeVertexAttribute();
			_uvBufferIndex = uvAttributeReg.index;
		}
		
		/**
		 * 编译法线相关代码 
		 * 
		 */		
		private function compileNormalCode():void
		{
			// 顶点的法线
			_sharedRegisters.normalInput = _registerCache.getFreeVertexAttribute();
			_normalBufferIndex = _sharedRegisters.normalInput.index;
			
			// 法线世界变换并归一化
			// 获取法线变换矩阵
			var normalMatrix:ShaderRegisterElement = _registerCache.getFreeVertexConstant();
			normalMatrixIndex = normalMatrix.index;
			
			// 变换后世界坐标
			_sharedRegisters.normalVarying = _registerCache.getFreeVertexVectorTemp();
			
			_vertexCode += "m33 " + _sharedRegisters.normalVarying + ".xyz, " + _sharedRegisters.normalInput + ".xyz, " + normalMatrix + "\n" +
						   "nrm " + _sharedRegisters.normalVarying + ".xyz, " + _sharedRegisters.normalVarying + ".xyz \n";
		}
		
		/**
		 * 编译视线代码 
		 * 计算镜面反射的时候需要
		 */		
		private function compileViewDirCode():void
		{
			var cameraPositionReg:ShaderRegisterElement = _registerCache.getFreeVertexConstant();
			cameraPositionIndex = cameraPositionReg.index;
			_sharedRegisters.viewDirVertex = _registerCache.getFreeFragmentVectorTemp();
			_vertexCode += "sub " + _sharedRegisters.viewDirVertex + ", " + cameraPositionReg + ", " + _sharedRegisters.globalPositionVertex + "\n";
		}
		
		/**
		 * 计算光源代码
		 * Gouraud 着色 
		 * 
		 */		
		private function compileLightingCode():void
		{
			// 用来给外部的材质传值的索引
			lightVetexConstantIndex = -1;
			
			// 初始化所有光线寄存器
			initLightData();
			// 初始化光照寄存器位置
			initLightRegisters();
			// 计算平行光代码
			compileDirectionalLightCode();
			// 计算点光源代码
			compilePointLightCode();
		}
		
		private function initLightData():void
		{
			_pointLightRegisters = new Vector.<ShaderRegisterElement>(numPointLights * 3, true);
			_dirLightRegisters = new Vector.<ShaderRegisterElement>(numDirectionalLights * 3, true);
		}
		
		private function initLightRegisters():void
		{
			var i:uint, len:uint;
			
			// 材质的漫反射索引
			diffuseInputRegister = _registerCache.getFreeVertexConstant();
			diffuseFragmentConstantsIndex = diffuseInputRegister.index;
			
			len = _dirLightRegisters.length;
			for (i = 0; i < len; ++i) {
				_dirLightRegisters[i] = _registerCache.getFreeVertexConstant();
				if (lightVetexConstantIndex == -1)
					lightVetexConstantIndex = _dirLightRegisters[i].index;
			}
			
			len = _pointLightRegisters.length;
			for (i = 0; i < len; ++i) {
				_pointLightRegisters[i] = _registerCache.getFreeVertexConstant();
				if (lightVetexConstantIndex == -1)
					lightVetexConstantIndex = _pointLightRegisters[i].index;
			}
		}		
		
		private function compileDirectionalLightCode():void
		{
			var regIndex:int;
			var diffuseColorReg:ShaderRegisterElement;
			var specularColorReg:ShaderRegisterElement;
			var lightPosReg:ShaderRegisterElement;
			var lightDirReg:ShaderRegisterElement;
			var t:ShaderRegisterElement;
			var viewDirReg:ShaderRegisterElement;
			var total:ShaderRegisterElement = _registerCache.getFreeVertexVectorTemp();
			
			// 平行光的漫反射
			for (var i:uint = 0; i < numPointLights; ++i) {
				lightPosReg = _pointLightRegisters[regIndex++];
				diffuseColorReg = _pointLightRegisters[regIndex++];
				specularColorReg = _pointLightRegisters[regIndex++];
				lightDirReg = _registerCache.getFreeVertexVectorTemp();
				viewDirReg = _sharedRegisters.viewDirVertex;
				t = _registerCache.getFreeVertexVectorTemp();
				
				// 1. 漫反射
				// 顶点到光源的向量 = 光源位置 - 顶点位置
				// 归一化
				_vertexCode += "sub " + lightDirReg + ", " + lightPosReg + ", " + _sharedRegisters.globalPositionVertex + "\n" +
							   "nrm " + lightDirReg + ".xyz, " + lightDirReg + ".xyz \n" +
				// 临时值 = 点积法线与该向量
							   "dp3 " + t + ".x" + lightDirReg + ".xyz, " + _sharedRegisters.normalVarying + ".xyz \n" +
				// 临时值 = [0, 1]
							   "sat " + t + ".x" + t + ".x \n" + 
				// TODO 漫反射颜色 = 材质的漫反射颜色 * 光线的漫反射颜色
				// 变量 = 光线的漫反射颜色 * 临时值
							   "mul " + t + ".rgb, " + diffuseColorReg + ".rgb, " + t + ".xxx \n" +
							   "add " + total + ".rgb, " + total + ", " + t + "\n" +
				// 2. 环境光
				
				// 3. 镜面反射(blinn-phong half vector model)
							    // 先计算半向量
								"add " + t + ", " + lightDirReg + ", " + viewDirReg + "\n" +
								// 归一化
								"nrm " + t + ".xyz, " + t + " \n" +
								// 点乘法线
								"dp3 " + t + ".x, " + _sharedRegisters.normalVarying + ", " + t + "\n" +
								// 约束范围
								"sat " + t + ".x, " + t + ".x\n";
			}
		}
		
		private function compilePointLightCode():void
		{
			// 点光源与直线光的区别就是，该光源会随着离光源距离递减
		}
		
		private function compileProjectionCode():void
		{
			_vertexCode += "m44 op, va0, vc0		\n"
		}
		
		private function compileFragmentOutput():void
		{
			// 如果有纹理，获取纹理颜色
			var ftemp:ShaderRegisterElement = _registerCache.getFreeFragmentVectorTemp();
			
			_fragmentCode += 'mul ' + ftemp + ', '+ ftemp + ', ' + _sharedRegisters.targetLightColor + ' \n' +	
							 "mov " + _registerCache.fragmentOutputRegister + ", " + ftemp + " \n";
			
		}
	}
}