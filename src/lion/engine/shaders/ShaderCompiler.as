package lion.engine.shaders
{
	import lion.engine.textures.BaseTexture;
	import lion.engine.textures.BitmapTexture;

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
		
		// ========== 输入 ==========
		// 光源数量
		public var numDirectionalLights:int;
		public var numPointLights:int;
		
		// ========== 输出 ==========
		// 光源索引
		// 光源位置，光源颜色等
		public var lightVetexConstantIndex:int;
		// 模型视图投影矩阵（计算最终位置的）
		// 法线投影矩阵（计算法线的世界位置）
		public var normalMatrixIndex:int;
		// 模型矩阵（计算顶点的世界坐标）
		public var matrixIndex:int;	
		// 投影矩阵
		public var viewProjectionMatrixIndex:int;
		// 材质的漫反射索引
		public var diffuseVertexConstantsIndex:int;
		// 材质的镜面反射索引
		public var specularVertexConstantsIndex:int;
		// 材质的环境光索引
		public var ambientVertexConstantsIndex:int;
		// 其他通用值
		public var commonConstantsIndex:int;
		// 摄像机位置索引
		public var cameraPositionIndex:int;
		// uv缓存索引，一般是va1
		public var uvBufferIndex:int;
		// 法线缓存索引，一般是va2
		public var normalBufferIndex:int;
		// 纹理索引
		public var texturesIndex:int;
		
		// uv变换索引，offset and repeat
		public var uvTransformIndex:int;
		
		// 阴影相关
		public var depthMapConstantsIndex:int;
		public var depthMapProjIndex:int;
		public var depthMapTexturesIndex:int;
		public var depthMapFragmentIndex:int;
		
		
		private var diffuseInputRegister:ShaderRegisterElement;
		private var specularInputRegister:ShaderRegisterElement;
		private var ambientInputRegister:ShaderRegisterElement;
		private var totalLightColor:ShaderRegisterElement;
		private var commonInputRegister:ShaderRegisterElement;
		private var _texture:BaseTexture;
		private var depthMapUVRegister:ShaderRegisterElement;
		private var _shadowMapping:Boolean;
		
		public function ShaderCompiler()
		{
			_sharedRegisters = new ShaderRegisterData();
			_registerCache = new ShaderRegisterCache();
			_registerCache.reset();
		}
		
		public function get fragmentCode():String
		{
			return _fragmentCode;
		}

		public function get vertexCode():String
		{
			return _vertexCode;
		}

		public function compile(texture:BaseTexture, shadowMapping:Boolean):void {
			// 编译的最终目的就是生成顶点着色器代码以及片段着色器代码
			_vertexCode = "";
			_fragmentCode = "";
			
			// va0 = localposition
			_sharedRegisters.localPosition = _registerCache.getFreeVertexAttribute();
			_sharedRegisters.targetLightColor = _registerCache.getFreeVarying();
			
			// ====== 顶点着色器 ======
			
			// 计算全局位置
			compileGlobalPositionCode();
			// 计算投影
			compileProjectionCode();
			
			_texture = texture;
			if (_texture) {
				compileUVCode();
			}
			compileNormalCode();
			compileViewDirCode();
			
			// 计算光照
			compileLightingCode();
			
			// 如果有需要阴影贴图
			_shadowMapping = shadowMapping;
			if (_shadowMapping) {
				compileDepthMapUV();
			}
			
			// ====== 片段着色器 ======
			
			compileFragmentOutput();
		}
		
		private function compileDepthMapUV():void
		{
			var temp:ShaderRegisterElement = _registerCache.getFreeVertexVectorTemp();
			var dataReg:ShaderRegisterElement = _registerCache.getFreeVertexConstant();
			var depthMapProj:ShaderRegisterElement = _registerCache.getFreeVertexConstant();
			_registerCache.getFreeVertexConstant();
			_registerCache.getFreeVertexConstant();
			_registerCache.getFreeVertexConstant();
			depthMapUVRegister = _registerCache.getFreeVarying();
			// * 0.5 + 0.5的常量（uv跟视图位置不同）
			// http://www.web-tinker.com/article/20179.html
			depthMapConstantsIndex = dataReg.index * 4;
			// 以光源为位置的视图投影矩阵
			depthMapProjIndex = depthMapProj.index * 4;
			
			_vertexCode += "m44 " + temp + ", " + _sharedRegisters.globalPositionVertex + ", " + depthMapProj + "\n" +
				// 齐次化w = 1
				"div " + temp + ", " + temp + ", " + temp + ".w \n" +
				// 位置转uv *0.5 + 0.5
				"mul " + temp + ".xy, " + temp + ".xy, " + dataReg + ".xy \n" +
				"add " + depthMapUVRegister + ", " + temp + ", " + dataReg + ".xxzz\n";
			
			_registerCache.removeVertexTempUsage(temp);
		}
		
		/**
		 * 编译世界位置 
		 * 
		 */		
		private function compileGlobalPositionCode():void
		{
			_sharedRegisters.globalPositionVertex = _registerCache.getFreeVertexVectorTemp();
			var positionMatrixReg:ShaderRegisterElement = _registerCache.getFreeVertexConstant();
			_registerCache.getFreeVertexConstant();
			_registerCache.getFreeVertexConstant();
			_registerCache.getFreeVertexConstant();
			matrixIndex = positionMatrixReg.index * 4;
			_vertexCode += "m44 " + _sharedRegisters.globalPositionVertex + ", " + _sharedRegisters.localPosition + ", " + positionMatrixReg + "\n";
		}
		
		/**
		 * 编译uv坐标 
		 * 
		 */		
		private function compileUVCode():void
		{
			var uvAttributeReg:ShaderRegisterElement = _registerCache.getFreeVertexAttribute();
			uvBufferIndex = uvAttributeReg.index;
			
			
			var varying:ShaderRegisterElement = _registerCache.getFreeVarying();
			_sharedRegisters.uvVarying = varying;
			
			var uvTransformConst:ShaderRegisterElement = _registerCache.getFreeVertexConstant();
			var temp:ShaderRegisterElement = _registerCache.getFreeVertexVectorTemp();
			uvTransformIndex = uvTransformConst.index * 4;
			
			// 加上uv offset和乘于repeat
			_vertexCode += "mul " + temp + ", " + uvAttributeReg + ", " + uvTransformConst + ".zw\n";
			_vertexCode += "add " + temp + ", " + temp + ", " + uvTransformConst + ".xy\n";
			_vertexCode += "mov " + _sharedRegisters.uvVarying + ", " + temp + "\n";
			
			_registerCache.removeVertexTempUsage(temp);
		}
		
		public function get numUsedVertexConstants():uint
		{
			return _registerCache.numUsedVertexConstants;
		}
		
		public function get numUsedFragmentConstants():uint
		{
			return _registerCache.numUsedFragmentConstants;
		}
		/**
		 * 编译法线相关代码 
		 * 
		 */		
		private function compileNormalCode():void
		{
			// 顶点的法线
			_sharedRegisters.normalInput = _registerCache.getFreeVertexAttribute();
			normalBufferIndex = _sharedRegisters.normalInput.index;
			
			// 法线世界变换并归一化
			// 获取法线变换矩阵
			var normalMatrix:ShaderRegisterElement = _registerCache.getFreeVertexConstant();
			_registerCache.getFreeVertexConstant();
			_registerCache.getFreeVertexConstant();
			_registerCache.getFreeVertexConstant();
			normalMatrixIndex = normalMatrix.index * 4;
			
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
			cameraPositionIndex = cameraPositionReg.index * 4;
			_sharedRegisters.viewDirVertex = _registerCache.getFreeVertexVectorTemp();
			_vertexCode += "sub " + _sharedRegisters.viewDirVertex + ", " + cameraPositionReg + ", " + _sharedRegisters.globalPositionVertex + "\n" +
						   "nrm " + _sharedRegisters.viewDirVertex + ".xyz, " + _sharedRegisters.viewDirVertex + ".xyz \n";
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
			
			totalLightColor = _registerCache.getFreeVertexVectorTemp();
			
			// 初始化默认环境光
			_vertexCode += "mov " + totalLightColor + ".rgb, " + ambientInputRegister + "\n";
				
			// 计算平行光代码
			compileDirectionalLightCode();
			// 计算点光源代码
			compilePointLightCode();
			
			_vertexCode += "mov " + _sharedRegisters.targetLightColor + ".rgb, " + totalLightColor + "\n";
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
			diffuseVertexConstantsIndex = diffuseInputRegister.index * 4;
			// 材质的镜面反射索引
			specularInputRegister = _registerCache.getFreeVertexConstant();
			specularVertexConstantsIndex = specularInputRegister.index * 4;
			// 材质的环境光索引
			ambientInputRegister = _registerCache.getFreeVertexConstant();
			ambientVertexConstantsIndex = ambientInputRegister.index * 4;
			
			len = _dirLightRegisters.length;
			for (i = 0; i < len; ++i) {
				_dirLightRegisters[i] = _registerCache.getFreeVertexConstant();
				if (lightVetexConstantIndex == -1)
					lightVetexConstantIndex = _dirLightRegisters[i].index * 4;
			}
			
			len = _pointLightRegisters.length;
			for (i = 0; i < len; ++i) {
				_pointLightRegisters[i] = _registerCache.getFreeVertexConstant();
				if (lightVetexConstantIndex == -1)
					lightVetexConstantIndex = _pointLightRegisters[i].index * 4;
			}
			commonInputRegister = _registerCache.getFreeVertexConstant();
			commonConstantsIndex = commonInputRegister.index * 4;
		}		
		
		private function compileDirectionalLightCode():void
		{
			var regIndex:int;
			var diffuseColorReg:ShaderRegisterElement;
			var specularColorReg:ShaderRegisterElement;
			var lightPosReg:ShaderRegisterElement;
			var lightDirReg:ShaderRegisterElement = _registerCache.getFreeVertexVectorTemp();
			var t:ShaderRegisterElement = _registerCache.getFreeVertexVectorTemp();
			var ift:ShaderRegisterElement = _registerCache.getFreeVertexVectorTemp();
			var viewDirReg:ShaderRegisterElement = _sharedRegisters.viewDirVertex;
			
			// 平行光的漫反射
			for (var i:uint = 0; i < numDirectionalLights; ++i) {
				lightPosReg = _dirLightRegisters[regIndex++];
				diffuseColorReg = _dirLightRegisters[regIndex++];
				specularColorReg = _dirLightRegisters[regIndex++];
				
				// 1. 漫反射
				// 顶点到光源的向量 = 光源位置 - 顶点位置
				// 归一化
				_vertexCode +=  "sub " + lightDirReg + ", " + lightPosReg + ", " + _sharedRegisters.globalPositionVertex + "\n" +
								"nrm " + lightDirReg + ".xyz, " + lightDirReg + ".xyz \n" +
								
				// 临时值 = 点积法线与该向量
								"dp3 " + t + ".x, " + lightDirReg + ".xyz, " + _sharedRegisters.normalVarying + ".xyz \n" +
				// 临时值 = [0, 1]
								"sat " + t + ".x, " + t + ".x \n" + 
								
//								"ine " + t + ", " + commonInputRegister + ".y \n" +
								"sne " + ift + ".x, " + t + ".x, " + commonInputRegister + ".y \n" +
								
				// 漫反射颜色 = 材质的漫反射颜色 * 光线的漫反射颜色
								"mul " + t + ".rgb, " + diffuseInputRegister + ".rgb, " + t + ".xxx \n" +
				// 变量 = 光线的漫反射颜色 * 临时值
								"mul " + t + ".rgb, " + diffuseColorReg + ".rgb, " + t + ".rgb \n" +
								"add " + totalLightColor + ".rgb, " + totalLightColor + ", " + t + "\n" +
				// 2. 环境光
//								"add " + total + ".rgb, " + total + ", " + ambientInputRegister + "\n" +
				
				// 3. 镜面反射
								
								// (blinn-phong half vector model)
//							    // 先计算半向量
//								"add " + t + ", " + lightDirReg + ", " + viewDirReg + "\n" +
//								// 归一化
//								"nrm " + t + ".xyz, " + t + ".xyz \n" +
//								// 点乘法线
//								// N dot H((L+V)/|L+V|)
//								"dp3 " + t + ".x, " + _sharedRegisters.normalVarying + ".xyz, " + t + ".xyz\n" +
//								// 约束范围
//								"sat " + t + ".x, " + t + ".x \n" +
								
								// phong
								// 计算R
								"mul " + t + ".xyz, " + _sharedRegisters.normalVarying + ".xyz, " + commonInputRegister + ".x \n" +
								"dp3 " + t + ".x, " + lightDirReg + ".xyz, " + t + ".xyz\n" +
								"sat " + t + ".x, " + t + ".x\n" +
								"mul " + t + ".xyz, " + _sharedRegisters.normalVarying + ".xyz, " + t + ".x \n" +
								"sub " + t + ", " + t + ", " + lightDirReg + "\n" +
								"nrm " + t + ".xyz, " + t + ".xyz \n" +
								// V dot R
								"dp3 " + t + ".x, " + viewDirReg + ".xyz, " + t + ".xyz\n" +
								"sat " + t + ".x, " + t + ".x\n" +
								
								// shininess 系数
								"pow " + t + ".x, " + t + ".x, " + specularInputRegister + ".w \n" +
								
								"mul " + t + ".rgb, " + specularColorReg + ".rgb, " + t + ".x \n" +
								"mul " + t + ".rgb, " + specularInputRegister + ".rgb, " + t + ".rgb \n" +
								"mul " + t + ".rgb, " + ift + ".xxx, " + t + ".rgb \n" +
//								"add " + totalLightColor + ".rgb, " + totalLightColor + ", " + t + "\n" + 
//								"eif \n";
								"add " + totalLightColor + ".rgb, " + totalLightColor + ", " + t + "\n";
			}
			
			_registerCache.removeVertexTempUsage(lightDirReg);
			_registerCache.removeVertexTempUsage(t);
			_registerCache.removeVertexTempUsage(ift);
		}
		
		private function compilePointLightCode():void
		{
			// 点光源与直线光的区别就是，该光源会随着离光源距离递减
			var regIndex:int;
			var diffuseColorReg:ShaderRegisterElement;
			var specularColorReg:ShaderRegisterElement;
			var lightPosReg:ShaderRegisterElement;
			var lightDirReg:ShaderRegisterElement = _registerCache.getFreeVertexVectorTemp();
			var t:ShaderRegisterElement = _registerCache.getFreeVertexVectorTemp();
			var ift:ShaderRegisterElement = _registerCache.getFreeVertexVectorTemp();
			var viewDirReg:ShaderRegisterElement = _sharedRegisters.viewDirVertex;
			
			// 平行光的漫反射
			for (var i:uint = 0; i < numPointLights; ++i) {
				lightPosReg = _pointLightRegisters[regIndex++];
				diffuseColorReg = _pointLightRegisters[regIndex++];
				specularColorReg = _pointLightRegisters[regIndex++];
				
//				var factor:ShaderRegisterElement = _registerCache.getFreeVertexVectorTemp();
//				var dist:ShaderRegisterElement = _registerCache.getFreeVertexVectorTemp();
//				var factor1:ShaderRegisterElement = _registerCache.getFreeVertexVectorTemp();
//				var factor2:ShaderRegisterElement = _registerCache.getFreeVertexVectorTemp();
				
				// 1. 漫反射
				// 顶点到光源的向量 = 光源位置 - 顶点位置
				// 归一化
				_vertexCode +=  "sub " + lightDirReg + ", " + lightPosReg + ", " + _sharedRegisters.globalPositionVertex + "\n" +
				
								"dp3 " + ift + ".w, " + lightDirReg + ", " + lightDirReg + "\n" +
								"sqt " + ift + ".w, " + ift + ".w \n" +
								"sub " + ift + ".w, " + diffuseColorReg + ".w, " + ift + ".w \n" + 
//								// 计算光线衰减值
//								// 衰减系数在漫反射的最后一个值那边
								"mul " + ift + ".w, " + specularColorReg + ".w, " + ift + ".w \n" + 
								"nrm " + lightDirReg + ".xyz, " + lightDirReg + ".xyz \n" +
				
								// 临时值 = 点积法线与该向量
								"dp3 " + t + ".x, " + lightDirReg + ".xyz, " + _sharedRegisters.normalVarying + ".xyz \n" +
								// 临时值 = [0, 1]
								"sat " + t + ".x, " + t + ".x \n" + 
								// 反面照不到
								"sne " + ift + ".x, " + t + ".x, " + commonInputRegister + ".y \n" +
								
								// 漫反射颜色 = 材质的漫反射颜色 * 光线的漫反射颜色
								"mul " + t + ".rgb, " + diffuseInputRegister + ".rgb, " + t + ".xxx \n" +
								// 变量 = 光线的漫反射颜色 * 临时值
								"mul " + t + ".rgb, " + diffuseColorReg + ".rgb, " + t + ".rgb \n" +
								"mul " + t + ".rgb, " + ift + ".w, " + t + ".rgb \n" +
								"add " + totalLightColor + ".rgb, " + totalLightColor + ", " + t + "\n" +
								
								// 3. 镜面反射
								
								// phong
								// 计算R
								"mul " + t + ".xyz, " + _sharedRegisters.normalVarying + ".xyz, " + commonInputRegister + ".x \n" +
								"dp3 " + t + ".x, " + lightDirReg + ".xyz, " + t + ".xyz\n" +
								"sat " + t + ".x, " + t + ".x\n" +
								"mul " + t + ".xyz, " + _sharedRegisters.normalVarying + ".xyz, " + t + ".x \n" +
								"sub " + t + ", " + t + ", " + lightDirReg + "\n" +
								"nrm " + t + ".xyz, " + t + ".xyz \n" +
								// V dot R
								"dp3 " + t + ".x, " + viewDirReg + ".xyz, " + t + ".xyz\n" +
								"sat " + t + ".x, " + t + ".x\n" +
								
								// shininess 系数
								"pow " + t + ".x, " + t + ".x, " + specularInputRegister + ".w \n" +
								
								"mul " + t + ".rgb, " + specularColorReg + ".rgb, " + t + ".x \n" +
								"mul " + t + ".rgb, " + specularInputRegister + ".rgb, " + t + ".rgb \n" +
								"mul " + t + ".rgb, " + ift + ".xxx, " + t + ".rgb \n" +
								"mul " + t + ".rgb, " + ift + ".w, " + t + ".rgb \n" +
								"add " + totalLightColor + ".rgb, " + totalLightColor + ", " + t + "\n";
			}
			_registerCache.removeVertexTempUsage(lightDirReg);
			_registerCache.removeVertexTempUsage(t);
			_registerCache.removeVertexTempUsage(ift);
		}
		
		/**
		 * 编译投影代码 
		 * 
		 */		
		private function compileProjectionCode():void
		{
			var viewProjectionReg:ShaderRegisterElement = _registerCache.getFreeVertexConstant();
			_registerCache.getFreeVertexConstant();
			_registerCache.getFreeVertexConstant();
			_registerCache.getFreeVertexConstant();
			 viewProjectionMatrixIndex = viewProjectionReg.index * 4;
			 var tmp:ShaderRegisterElement = _registerCache.getFreeVertexVectorTemp();
			 
			_vertexCode +=  "m44 " + tmp + ", " + _sharedRegisters.globalPositionVertex + ", " + viewProjectionReg + "\n" +
							"mov op, " + tmp + " \n";
			_registerCache.removeVertexTempUsage(tmp);
		}
		
		private function compileFragmentOutput():void
		{
			var albedo:ShaderRegisterElement = _registerCache.getFreeFragmentVectorTemp();
			if (_texture) {
				var textureReg:ShaderRegisterElement = _registerCache.getFreeTextureReg();
				texturesIndex = textureReg.index;
				_fragmentCode += getTex2DSampleCode(albedo, textureReg, _texture) +
								 "mul " + albedo + ".xyz, " + albedo + ", " + _sharedRegisters.targetLightColor + "\n";
			} else {
				_fragmentCode += "mov " + albedo + ", " + _sharedRegisters.targetLightColor + "\n";
			}
			
			// 阴影贴图
			if (_shadowMapping) {
				var depthColor:ShaderRegisterElement = _registerCache.getFreeFragmentVectorTemp();
				var depthMapRegister:ShaderRegisterElement = _registerCache.getFreeTextureReg();
				depthMapTexturesIndex = depthMapRegister.index;
				var depthMapFragmentConst:ShaderRegisterElement = _registerCache.getFreeFragmentConstant();
				depthMapFragmentIndex = depthMapFragmentConst.index * 4;
				
				_fragmentCode += "tex " + depthColor + ", " + depthMapUVRegister + ", " + depthMapRegister + " <2d, nearest, clamp>\n" +
								// 增加点误差容错
								"add " + depthColor + ".z, " + depthColor + ".z, " + depthMapFragmentConst + ".x \n" +
								// 如果depthMapUVRegister.z比较大，即depthMapUVRegister.z > depthCol.z，说明被遮挡
								"slt " + albedo + ".w, " + depthMapUVRegister + ".z, " + depthColor + ".z\n" +
								"mul " + albedo + ", " + albedo + ".xyz, " + albedo + ".www \n";
			}
			
			_fragmentCode += "mov " + _registerCache.fragmentOutputRegister + ", " + albedo + " \n";
			
		}
		
		protected function getTex2DSampleCode(targetReg:ShaderRegisterElement, 
											  inputReg:ShaderRegisterElement, 
											  texture:BaseTexture, 
											  uvReg:ShaderRegisterElement = null, 
											  useSmoothTextures:Boolean = false):String
		{
			var wrap:String = texture.wrap;
			var filter:String;
			var format:String = "";
			var enableMipMaps:Boolean = texture.generateMipmaps;
			
			if (useSmoothTextures)
				filter = enableMipMaps? "linear,miplinear" : "linear";
			else
				filter = enableMipMaps? "nearest,mipnearest" : "nearest";
			
			uvReg ||= _sharedRegisters.uvVarying;
			return "tex " + targetReg + ", " + uvReg + ", " + inputReg + " <2d," + filter + "," + format + wrap + ">\n";
		}
	}
}