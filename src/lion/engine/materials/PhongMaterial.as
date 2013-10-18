package lion.engine.materials
{
	import lion.engine.math.Color;

	public class PhongMaterial extends BaseMaterial
	{		
		// 环境光
		private var ambient:Color;
		// 漫反射光
		private var diffuse:Color;
		// 镜面反色光
		private var specular:Color;
		// 自发光
		private var emission:Color;
		
		private var shininess:Number;
		
		public function PhongMaterial()
		{
			super();
		}
		
		// Phong Shader
		override protected function get vertexShader():String {
			return 
				"m44 op, va0, vc2    \n" +    // 4x4 matrix transform 
				'mov v0, va0 \n' +
				
				// 法线变换并归一化
				'm33 vt2.xyz, va2.xyz, vc10 \n' +
				'nrm vt2.xyz, vt2.xyz \n' +
				'mov v2, vt2.xyz \n' +
				
				'mov v1, va2';
		}
		
		override protected function get fragmentShader():String {
			return 
				// 光源朝向顶点坐标的向量
				'm44 ft0, v0, fc6 \n' +
				'sub ft1, fc0, ft0 \n' + 
				'nrm ft1.xyz, ft1.xyz \n' +
				
				'dp3 ft3.x, ft1.xyz, v2.xyz \n' +	
				'sat ft3.x, ft3.x \n' +
				'mul ft4.rgb, fc1.rgb, ft3.xxx \n' + 
				"mov oc, ft4"; //Set the output color to the value interpolated from the three triangle vertices
		}
	}
}