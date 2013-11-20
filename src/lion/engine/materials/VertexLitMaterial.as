package lion.engine.materials
{
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.utils.ByteArray;
	
	import lion.engine.lights.DirectionalLight;
	import lion.engine.lights.Light;
	import lion.engine.lights.PointLight;
	import lion.engine.math.Color;
	import lion.engine.math.Vector3;
	import lion.engine.math.Vector4;
	import lion.engine.shaders.ShaderCompiler;
	import lion.engine.textures.BitmapTexture;

	/**
	 * 基本材质 
	 * Gouraud shader
	 * 基于顶点的简易光照模型，与固定管线的光照模型一致
	 * @author Dalton
	 * 
	 */	
	public class VertexLitMaterial extends BaseMaterial
	{
		// 环境光
		public var ambient:Vector4;
		// 漫反射光
		public var diffuse:Vector4;
		// 镜面反射光
		// 第四个元素为镜面发射的发光系数
		public var specular:Vector4;
		
		protected var _vertexConstantData:Vector.<Number> = new Vector.<Number>();
		protected var _fragmentConstantData:Vector.<Number> = new Vector.<Number>();
		protected var _compiler:ShaderCompiler;
		
		// 光照顶点索引
		private var _lightVetexConstantIndex:int;
		
		private var _normalMatrixIndex:int;
		private var _matrixIndex:int;
		private var _viewProjectionMatrixIndex:int;
		private var _cameraPositionIndex:int;
		
		private var _uvBufferIndex:int;
		private var _normalBufferIndex:int;
		
		private var _diffuseVertexConstantsIndex:int;
		private var _ambientVertexConstantsIndex:int;
		private var _specularVertexConstantsIndex:int;
		private var _commonVertexConstansIndex:int;
		private var _texturesIndex:int;
		
		public function VertexLitMaterial()
		{
			super();
			ambient = new Vector4(0.0, 0.0, 0.0);
			diffuse = new Vector4(0.5, 0.5, 0.5);
			specular = new Vector4(1.0, 1.0, 1.0, 10);
		}
		
		protected function updateLightConstants(lights:Vector.<Light>):void {
			var k:int = _lightVetexConstantIndex;
			var dirPos:Vector3;
			
			for each (var l:Light in lights) {
				if (l is DirectionalLight) {
					var dirLight:DirectionalLight = l as DirectionalLight;
					dirPos = dirLight.position;
					
					_vertexConstantData[k++] = dirPos.x;
					_vertexConstantData[k++] = dirPos.y;
					_vertexConstantData[k++] = dirPos.z;
					_vertexConstantData[k++] = 1;

					_vertexConstantData[k++] = dirLight.color.r * dirLight.intensity;
					_vertexConstantData[k++] = dirLight.color.g * dirLight.intensity;
					_vertexConstantData[k++] = dirLight.color.b * dirLight.intensity;
					_vertexConstantData[k++] = 1;
					
					_vertexConstantData[k++] = dirLight.color.r * dirLight.intensity;
					_vertexConstantData[k++] = dirLight.color.g * dirLight.intensity;
					_vertexConstantData[k++] = dirLight.color.b * dirLight.intensity;
					_vertexConstantData[k++] = 1;
				}
				
				if (l is PointLight) {
					var pointLight:PointLight = l as PointLight;
					dirPos = pointLight.position;
					
					_vertexConstantData[k++] = dirPos.x;
					_vertexConstantData[k++] = dirPos.y;
					_vertexConstantData[k++] = dirPos.z;
					_vertexConstantData[k++] = 1;
					
					_vertexConstantData[k++] = pointLight.color.r * pointLight.intensity;
					_vertexConstantData[k++] = pointLight.color.g * pointLight.intensity;
					_vertexConstantData[k++] = pointLight.color.b * pointLight.intensity;
					_vertexConstantData[k++] = pointLight.distance;
					
					_vertexConstantData[k++] = pointLight.color.r * pointLight.intensity;
					_vertexConstantData[k++] = pointLight.color.g * pointLight.intensity;
					_vertexConstantData[k++] = pointLight.color.b * pointLight.intensity;
					_vertexConstantData[k++] = 1 / (pointLight.distance);
				}
			}
		}
		
		private function updateProgram(s:MaterialUpdateState):void
		{
			if (dirty) {
				// 初始化着色器编译器
				initCompiler(s.numDirectionalLights, s.numPointLights);
				
				// 更新寄存器索引
				updateRegisterIndices();
				
				// 初始化常量数据
				initConstantData();
				
				
				// 提交顶点着色器
				if (true) {
					trace("Compiling AGAL Code:");
					trace("--------------------");
					trace(_compiler.vertexCode);
					trace("--------------------");
					trace(_compiler.fragmentCode);
				}
				this.program = s.context.createProgram();
				var vertexByteCode:ByteArray = vshader.assemble(Context3DProgramType.VERTEX, _compiler.vertexCode);
				var fragmentByteCode:ByteArray = fshader.assemble(Context3DProgramType.FRAGMENT, _compiler.fragmentCode);  
				program.upload(vertexByteCode, fragmentByteCode);
				dirty = false;
			}
			
			s.context.setProgram(program);
		}
		
		// 更新编译器输出的光照常量索引
		private function updateRegisterIndices():void
		{
			// 光照索引
			_lightVetexConstantIndex = _compiler.lightVetexConstantIndex;
			
			// 通用索引
			_normalMatrixIndex = _compiler.normalMatrixIndex;
			_matrixIndex = _compiler.matrixIndex;
			_viewProjectionMatrixIndex = _compiler.viewProjectionMatrixIndex;
			_cameraPositionIndex = _compiler.cameraPositionIndex;
			
			// 顶点属性索引
			_uvBufferIndex = _compiler.uvBufferIndex;
			_normalBufferIndex = _compiler.normalBufferIndex;
			_texturesIndex = _compiler.texturesIndex;
			
			// 材质索引
			_diffuseVertexConstantsIndex = _compiler.diffuseVertexConstantsIndex;
			_specularVertexConstantsIndex = _compiler.specularVertexConstantsIndex;
			_ambientVertexConstantsIndex = _compiler.ambientVertexConstantsIndex;
			
			// 其他通用索引
			_commonVertexConstansIndex = _compiler.commonConstantsIndex;
		}
		
		private function initConstantData():void
		{
			// 通过编译器获取的片段常量数量，顶点常量数量，设定这里需要赋值的常量数组长度
			_vertexConstantData.length = _compiler.numUsedVertexConstants * 4;
			_fragmentConstantData.length = _compiler.numUsedFragmentConstants * 4;
		}
		
		private function initCompiler(numDirectionalLights:uint, numPointLights:uint):void
		{
			_compiler = new ShaderCompiler();
			_compiler.numDirectionalLights = numDirectionalLights;
			_compiler.numPointLights = numPointLights;
			_compiler.compile(texture);
		}
		
		override public function update(s:MaterialUpdateState):void {
			// TODO 判断是否需要更新程序
			updateProgram(s);
			
			// 如果有纹理的话，绑定纹理
			if (texture) {
				var t:TextureBase = texture.getTexture(s.context);
				s.context.setTextureAt(_texturesIndex, t);
				// 设定va uv
				s.renderElement.setUVBuffer(_uvBufferIndex);
			}
			// 设定va normal
			s.renderElement.setNormalBuffer(_normalBufferIndex);
			
			// 主要的问题就是，怎么通过动态的光源计算出动态的着色器程序
			// 另外也计算出需要传入GPU的一些数据
			
			// 流程，
			// 编译器只需要光源数量，即可拼接处光照的着色器代码
			// 另外通过编译器编译后输出的一些信息，比如光源偏移量等等，输出到外面给当前材质获取
			// 当前材质知道偏移量后，设定常量值
			
			// 摄像机位置
			var k:int = _cameraPositionIndex;
			_vertexConstantData[k++] = s.cameraPosition.x;
			_vertexConstantData[k++] = s.cameraPosition.y;
			_vertexConstantData[k++] = s.cameraPosition.z;
			_vertexConstantData[k++] = 1;
			
			
			// 更新光照常量
			updateLightConstants(s.lights);
			
			// 设置材质常量
			updateMaterialConstants();
			
			// 设置通用常量
			updateCommonMatrixes(s);
			
			
			// 提交常量顶点数据（主要是光照相关数据）
			if (false) {
				trace("AGAL Constant Count:");
				trace("--------------------");
				trace(_compiler.numUsedVertexConstants);
				trace("--------------------");
				trace(_compiler.numUsedFragmentConstants);
			}
			s.context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, _vertexConstantData, _compiler.numUsedVertexConstants);
			s.context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _fragmentConstantData, _compiler.numUsedFragmentConstants);
		}
		
		private function updateCommonMatrixes(s:MaterialUpdateState):void
		{
			s.matrix.copyRawDataTo(_vertexConstantData, _matrixIndex, true);
			s.normalMatrix.copyRawDataTo(_vertexConstantData, _normalMatrixIndex, true);
			s.viewProjectionMatrix.copyRawDataTo(_vertexConstantData, _viewProjectionMatrixIndex, true);
//			s.context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, _matrixIndex, s.matrix, true);
//			s.context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, _normalMatrixIndex, s.normalMatrix, true);
//			s.context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, _viewProjectionMatrixIndex, s.viewProjectionMatrix, true);
		}
		
		/**
		 * 更新材质常量 
		 * 
		 */		
		private function updateMaterialConstants():void
		{
			var k:int = _diffuseVertexConstantsIndex;
			_vertexConstantData[k++] = diffuse.x;
			_vertexConstantData[k++] = diffuse.y;
			_vertexConstantData[k++] = diffuse.z;
			_vertexConstantData[k++] = diffuse.w;
			k = _specularVertexConstantsIndex;
			_vertexConstantData[k++] = specular.x;
			_vertexConstantData[k++] = specular.y;
			_vertexConstantData[k++] = specular.z;
			_vertexConstantData[k++] = specular.w;
			k = _ambientVertexConstantsIndex;
			_vertexConstantData[k++] = ambient.x;
			_vertexConstantData[k++] = ambient.y;
			_vertexConstantData[k++] = ambient.z;
			_vertexConstantData[k++] = ambient.w;
			k = _commonVertexConstansIndex;
			_vertexConstantData[k++] = 2;
			_vertexConstantData[k++] = 0;
			_vertexConstantData[k++] = 0;
			_vertexConstantData[k++] = 0;
		}
	}
}