package lion.engine.materials
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DTriangleFace;
	
	import lion.engine.math.Vector3;
	import lion.engine.textures.CubeBitmapTexture;

	/**
	 * 天空纹理
	 * 让天空追着摄像机走 
	 * @author Dalton
	 * 
	 */	
	public class SkyBoxMaterial extends BaseMaterial
	{
		private var _cubeTexture:CubeBitmapTexture;
		private var _vertexData:Vector.<Number>;
		
		public function SkyBoxMaterial(t:CubeBitmapTexture)
		{
			_cubeTexture = t;
			_vertexData = new <Number>[0, 0, 0, 0, 1, 1, 1, 1];
			super();
			side = Context3DTriangleFace.BACK;
		}
		
		
		// 顶点着色器
		// 计算摄像机坐标
		// 将摄像机坐标移到op
		// 并设定v0
		override protected function get vertexShader():String {
			return "mul vt0, va0, vc5		\n" +
				"add vt0, vt0, vc4		\n" +
				"m44 op, vt0, vc0		\n" +
				"mov v0, va0\n";		
		}
		
		// 片段着色器
		override protected function get fragmentShader():String {			
			var format:String;
			switch (_cubeTexture.format) {
				case Context3DTextureFormat.COMPRESSED:
					format = "dxt1,";
					break;
				case "compressedAlpha":
					format = "dxt5,";
					break;
				default:
					format = "";
			}
			var mip:String = ",mipnone";
			if (_cubeTexture.generateMipmaps)
				mip = ",miplinear";
			return "tex ft0, v0, fs0 <cube," + format + "linear,clamp" + mip + ">	\n" +
					"mov oc, ft0							\n";
		}
		
		override public function update(s:MaterialUpdateState):void {
			// 设置程序
			if (dirty) {
				this.program = s.context.createProgram();
				program.upload(vshader.agalcode, fshader.agalcode);
				dirty = false;
			}
			s.context.setProgram(program);
			
			var pos:Vector3 = s.cameraPosition;
			_vertexData[0] = pos.x;
			_vertexData[1] = pos.y;
			_vertexData[2] = pos.z;
			_vertexData[4] = _vertexData[5] = _vertexData[6] = 1;
			s.context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, s.viewProjectionMatrix, true);
			s.context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, _vertexData, 2);
		}
		
		override public function activate(context:Context3D):void {
//			context.setDepthTest(false, Context3DCompareMode.LESS_EQUAL);
			context.setTextureAt(0, _cubeTexture.getTexture(context));
		}
		
		override public function deactivate(context:Context3D):void {
//			context.setDepthTest(true, Context3DCompareMode.LESS_EQUAL);
		}
	}
}