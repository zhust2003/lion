package lion.engine.materials
{
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	import flash.display3D.textures.Texture;
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
	 * 基于顶点的简易光照模型，与固定管线的光照模型一致
	 * @author Dalton
	 * 
	 */	
	public class VertexLitMaterial extends BaseMaterial
	{
		// 环境光
		private var ambient:Vector4;
		// 漫反射光
		private var diffuse:Vector4;
		// 镜面反射光
		// 第四个元素为镜面发射的发光系数
		private var specular:Vector4;
		
		protected var _vertexConstantData:Vector.<Number> = new Vector.<Number>();
		protected var _fragmentConstantData:Vector.<Number> = new Vector.<Number>();
		protected var _compiler:ShaderCompiler;
		
		// 光照顶点索引
		private var _lightVetexConstantIndex:int;
		
		public function VertexLitMaterial()
		{
			super();
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
					
					_vertexConstantData[k++] = dirLight.color.r;
					_vertexConstantData[k++] = dirLight.color.g;
					_vertexConstantData[k++] = dirLight.color.b;
					_vertexConstantData[k++] = 1;
					
					_vertexConstantData[k++] = dirLight.color.r;
					_vertexConstantData[k++] = dirLight.color.g;
					_vertexConstantData[k++] = dirLight.color.b;
					_vertexConstantData[k++] = 1;
				}
				
				if (l is PointLight) {
					var pointLight:PointLight = l as PointLight;
					dirPos = pointLight.position;
					
					_vertexConstantData[k++] = dirPos.x;
					_vertexConstantData[k++] = dirPos.y;
					_vertexConstantData[k++] = dirPos.z;
					_vertexConstantData[k++] = 1;
					
					_vertexConstantData[k++] = pointLight.color.r;
					_vertexConstantData[k++] = pointLight.color.g;
					_vertexConstantData[k++] = pointLight.color.b;
					_vertexConstantData[k++] = pointLight.intensity;
					
					_vertexConstantData[k++] = pointLight.color.r;
					_vertexConstantData[k++] = pointLight.color.g;
					_vertexConstantData[k++] = pointLight.color.b;
					_vertexConstantData[k++] = pointLight.distance;
				}
			}
		}
		
		private function updateProgram(context:Context3D, numDirectionalLights:uint, numPointLights:uint):void
		{
			// 初始化着色器编译器
			initCompiler(numDirectionalLights, numPointLights);
			
			// 更新寄存器索引
			updateRegisterIndices();
			
			// 初始化常量数据
			initConstantData();
			
			
			// 提交顶点着色器
			trace("Compiling AGAL Code:");
			trace("--------------------");
			trace(_compiler.vertexCode);
			trace("--------------------");
			trace(_compiler.fragmentCode);
			var program:Program3D = context.createProgram();
			var vertexByteCode:ByteArray = vshader.assemble(Context3DProgramType.VERTEX, _compiler.vertexCode, false);
			var fragmentByteCode:ByteArray = fshader.assemble(Context3DProgramType.FRAGMENT, _compiler.fragmentCode, false);  
			program.upload(vertexByteCode, fragmentByteCode);
			context.setProgram(program);
		}
		
		// 更新编译器输出的光照常量索引
		private function updateRegisterIndices():void
		{
			_lightVetexConstantIndex = _compiler.lightVetexConstantIndex;
		}
		
		private function initConstantData():void
		{
			// 通过编译器获取的片段常量数量，顶点常量数量，设定这里需要赋值的常量数组长度
			_vertexConstantData.length = _compiler.numUsedVertexConstants*4;
			_fragmentConstantData.length = _compiler.numUsedFragmentConstants*4;
		}
		
		private function initCompiler(numDirectionalLights:uint, numPointLights:uint):void
		{
			_compiler = new ShaderCompiler();
			_compiler.numDirectionalLights = numDirectionalLights;
			_compiler.numPointLights = numPointLights;
			_compiler.compile();
		}
		
		protected function update(context:Context3D, numDirectionalLights:uint, numPointLights:uint, lights:Vector.<Light>):void {
			// TODO 判断是否需要更新程序
			updateProgram(context, numDirectionalLights, numPointLights);
			
			// 主要的问题就是，怎么通过动态的光源计算出动态的着色器程序
			// 另外也计算出需要传入GPU的一些数据
			
			// 流程，
			// 编译器只需要光源数量，即可拼接处光照的着色器代码
			// 另外通过编译器编译后输出的一些信息，比如光源偏移量等等，输出到外面给当前材质获取
			// 当前材质知道偏移量后，设定常量值
			
			// 更新光照常量
			updateLightConstants(lights);
			
			// 提交常量顶点数据（主要是光照相关数据）
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, _vertexConstantData, _compiler.numUsedVertexConstants);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _fragmentConstantData, _compiler.numUsedFragmentConstants);
		}
	}
}