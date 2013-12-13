package lion.engine.materials
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	
	import lion.engine.math.Color;
	import lion.engine.math.Vector3;

	/**
	 * 线框材质 
	 * 参考：
	 * http://volgogradetzzz.blogspot.com/2012/06/wireframe-shader.html
	 * http://blogs.aerys.in/jeanmarc-leroux/2011/12/17/minko-2-0-new-feature-wireframe-rendering/
	 * @author Dalton
	 * 
	 */	
	public class WireframeMaterial extends BaseMaterial
	{
		public function WireframeMaterial()
		{
			super();
		}
		
		// 顶点着色器
		// 计算世界坐标
		// 将世界坐标移到op
		// 移动到对应边的距离到v0
		// 并设定v0
		override protected function get vertexShader():String {
			return "m44 vt0, va0, vc0    \n" +	
				"mov op, vt0 \n" +
				"mov v0, va3";				
		}
		
		// 片段着色器
		override protected function get fragmentShader():String {
			// 求出距离的最小值
			return "min ft0.x, v0.x, v0.y		\n"+ 
				"min ft0.x, ft0.x, v0.z \n" +
				// 如果距离的最小值小于等于边线宽度，代表是边线，此时ft0.x为1
				"slt ft0.y, ft0.x, fc1.x \n" +
				"sub ft0.y, ft0.y, fc2.x \n" +
				// 如果小于0，则不输出颜色
				"kil ft0.y \n" + 
				
				// 平滑算法 2^(-2x^2)
				"sub ft0.y, fc1.x, ft0.x \n" + 
				"sub ft0.y, fc2.y, ft0.y \n" + 
				"pow ft0.y, ft0.y, fc1.w \n" + 
				"mul ft0.y, ft0.y, fc1.z \n" + 
				"exp ft0.z, ft0.y \n" +
				// 当距离d < lineWidth - 1是，设置为1，否则设置平滑值
				"slt ft0.y, ft0.x, fc1.y \n" +
				// 设置1或者0
				"mov ft0.w, ft0.y\n" + 
				
				// 想象之中，如果是  < lineWidth - 1设置为0
				"sub ft0.y, fc2.x, ft0.y \n" +
				"mul ft0.z, ft0.z, ft0.y \n" +
				
				"add ft0.w, ft0.w, ft0.z \n" +
				
				// 边线颜色
				"mov ft1.rgba, fc0.rgba \n" +
				"mul ft1.a, ft1.a, ft0.w \n" +
				"mov oc ft1 \n";			
		}
		
		override public function update(s:MaterialUpdateState):void {
			// 设置程序
			if (dirty) {
				this.program = s.context.createProgram();
				program.upload(vshader.agalcode, fshader.agalcode);
				dirty = false;
			}
			
			s.context.setProgram(program);
			
			s.context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			// 设置距离的顶点属性
			s.renderElement.setDistanceBuffer(3);
			
			// 常量
			var vdata:Vector.<Number> = new Vector.<Number>();
			s.matrix.append(s.viewProjectionMatrix);
			s.matrix.copyRawDataTo(vdata, 0, true);
			s.context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, vdata, 4);
			
			// 片段常量
			var lineColor:Color = new Color(0xFFFFFF);
			var lineWidth:Number = 2;
			var smoothWidth:Number = 1;
			var data:Vector.<Number> = Vector.<Number>([lineColor.r, lineColor.g, lineColor.b, 1,
														lineWidth + smoothWidth, lineWidth - smoothWidth, -2, 2, 
														1, smoothWidth * 2, 0, 1]);
			s.context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, data, 3);
		}
		
		override public function deactivate(context:Context3D):void {
			context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
		}
	}
}