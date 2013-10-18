package lion.engine.materials
{
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.Texture;
	
	import lion.engine.math.Color;
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
	}
}