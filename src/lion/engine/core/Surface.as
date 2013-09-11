package lion.engine.core
{
	import lion.engine.math.Color;
	import lion.engine.math.Vector3;

	/**
	 * 三角形面片 
	 * @author Dalton
	 * 
	 */	
	public class Surface
	{
		// 颜色
		private var color:Color;
		// 法线
		private var normal:Vector3;
		
		// 顶点索引
		public var a:int;
		public var b:int;
		public var c:int;
		
		public function Surface(a:int, b:int, c:int, normal:Vector3 = null, color:Color = null)
		{
			this.a = a;
			this.b = b;
			this.c = c;
			
			this.normal = normal || new Vector3();
			this.color = color || new Color();
		}
	}
}