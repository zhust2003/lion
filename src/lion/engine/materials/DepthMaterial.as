package lion.engine.materials
{
	import flash.display3D.Context3DProgramType;

	/**
	 * 用来生成阴影图的深度材质 
	 * @author Dalton
	 * 
	 */	
	public class DepthMaterial extends BaseMaterial
	{
		public function DepthMaterial()
		{
			super();
		}
		
		// 顶点着色器
		// 计算世界坐标
		// 将世界坐标移到op
		// 并设定v0
		override protected function get vertexShader():String {
			return "m44 vt0, va0, vc0    \n" +	
					"mov op, vt0 \n" +
					"mov v0, vt0";				
		}
		
		// 片段着色器
		override protected function get fragmentShader():String {
			return "div ft1, v0, v0.w		\n"+ 
					"mov ft0.xyz, ft1.zzz \n" +
					"mov ft0.w fc0.x \n" +
					"mov oc ft0 \n";			
		}
		
		override public function update(s:MaterialUpdateState):void {
			// 设置程序
			if (dirty) {
				this.program = s.context.createProgram();
				program.upload(vshader.agalcode, fshader.agalcode);
				dirty = false;
			}
			s.context.setProgram(program);
			
			// TODO 放在初始化
			var data:Vector.<Number> = Vector.<Number>([1.0, 255.0, 65025.0, 16581375.0,
														1.0/255.0, 1.0/255.0, 1.0/255.0, 0.0,
														1.0, 0.0, 0.0, 1.0]);
			s.context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, data, 3);
			
			// 常量
			var vdata:Vector.<Number> = new Vector.<Number>();
			s.matrix.append(s.viewProjectionMatrix);
			s.matrix.copyRawDataTo(vdata, 0, true);
			s.context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, vdata, 4);
		}
	}
}