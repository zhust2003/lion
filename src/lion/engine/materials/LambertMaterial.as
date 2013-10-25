package lion.engine.materials
{
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.Texture;
	
	import lion.engine.math.Color;
	import lion.engine.shaders.ShaderCompiler;
	import lion.engine.textures.BitmapTexture;

	/**
	 * 基本材质 
	 * @author Dalton
	 * 
	 */	
	public class LambertMaterial extends BaseMaterial
	{
		// 环境光
		private var ambient:Color;
		// 漫反射光
		private var diffuse:Color;
		// 自发光
		private var emission:Color;
		
		protected var _vertexConstantData:Vector.<Number> = new Vector.<Number>();
		protected var _fragmentConstantData:Vector.<Number> = new Vector.<Number>();
		protected var _compiler:ShaderCompiler;
		
		public function LambertMaterial()
		{
			super();
		}
		
		override protected function get vertexShader():String {
			return "m44 op, va0, vc2    \n" +    // 4x4 matrix transform 
				'mov v1, va1 \n' +
				
				// 直线光，flat着色
				// 光源朝向顶点坐标的向量
				'm44 vt0, va0, vc6 \n' +
				'sub vt1, vc0, vt0 \n' + 
				'nrm vt1.xyz, vt1.xyz \n' +
				
				// 法线变换并归一化
				'm33 vt2.xyz, va2.xyz, vc10 \n' +
				'nrm vt2.xyz, vt2.xyz \n' +
				
				// 点积 CosA = L . Normal
				'dp3 vt3.x, vt1.xyz, vt2.xyz \n' +	
				'sat vt3.x, vt3.x \n' +
				// diffuse
				'mul vt4.rgb, vc1.rgb, vt3.xxx \n' + 
				// todo ambient
				
				'mov v0, vt4.rgb \n';
		}
		
		override protected function get fragmentShader():String {
			return "tex ft0, v1, fs0 <2d> \n" +
				'mul ft0, ft0, v0 \n' +	
				"mov oc, ft0"; //Set the output color to the value interpolated from the three triangle vertices
		}
		
		protected function updateLightConstants():void {
			
		}
		
		private function updateProgram():void
		{
			initCompiler();
			initConstantData();
		}
		
		private function initConstantData():void
		{
			// 通过编译器获取的片段常量数量，顶点常量数量，设定这里需要赋值的常量数组长度
		}
		
		private function initCompiler():void
		{
			_compiler = new ShaderCompiler();
			_compiler.compile();
		}
		
		protected function update():void {
			// TODO 判断是否需要更新程序
			updateProgram();
			
			// 主要的问题就是，怎么通过动态的光源计算出动态的着色器程序
			// 另外也计算出需要传入GPU的一些数据
			
			// 流程，
			// 编译器只需要光源数量，即可拼接处光照的着色器代码
			// 另外通过编译器编译后输出的一些信息，比如光源偏移量等等，输出到外面给当前材质获取
			// 当前材质知道偏移量后，设定常量值
		}
	}
}