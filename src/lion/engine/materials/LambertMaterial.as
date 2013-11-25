package lion.engine.materials
{
	/**
	 * 基本的漫反射材质
	 * 暂用来计算阴影 
	 * @author Dalton
	 * 
	 */	
	public class LambertMaterial extends BaseMaterial
	{
		public function LambertMaterial()
		{
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