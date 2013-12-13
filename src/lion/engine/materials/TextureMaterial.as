package lion.engine.materials
{
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.TextureBase;

	public class TextureMaterial extends BaseMaterial
	{
		public function TextureMaterial()
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
					"mov v0, va1";				
		}
		
		// 片段着色器
		override protected function get fragmentShader():String {
			return  "tex ft0, v0, fs0 <2d, linear, clamp>\n" +  
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
			
			
			var t:TextureBase = texture.getTexture(s.context);
			s.context.setTextureAt(0, t);
			
			// 设定va uv
			s.renderElement.setUVBuffer(1);
			
			// 常量
			var vdata:Vector.<Number> = new Vector.<Number>();
			s.matrix.append(s.viewProjectionMatrix);
			s.matrix.copyRawDataTo(vdata, 0, true);
			s.context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, vdata, 4);
		}
	}
}