package lion.engine.materials
{
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3DProgramType;

	public class BaseMaterial extends Material
	{
		public function BaseMaterial()
		{
			super();
			vshader = new AGALMiniAssembler();
			fshader = new AGALMiniAssembler();
			vshader.assemble(Context3DProgramType.VERTEX, vertexShader, false);
			fshader.assemble(Context3DProgramType.FRAGMENT, fragmentShader, false);  
		}
		
		protected function get vertexShader():String {
			return "m44 op, va0, vc2    \n" +	// 4x4 matrix transform 
					'mov vt1, va1 \n' +
					'mov v1, va2';				// normal
		}
		
		protected function get fragmentShader():String {
			return "mov oc, v1";				//Set the output color to the value interpolated from the three triangle vertices
		}
	}
}