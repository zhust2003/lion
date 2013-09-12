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
		public var normal:Vector3;
		
		// 顶点发现
		public var vertexNormals:Array
		
		// 顶点索引
		public var a:int;
		public var b:int;
		public var c:int;
		
		// 面心
		public var centroid:Vector3;
		
		public function Surface(a:int, b:int, c:int, normal:Vector3 = null, color:Color = null)
		{
			this.a = a;
			this.b = b;
			this.c = c;
			
			this.normal = normal || new Vector3();
			this.color = color || new Color();
			this.centroid = new Vector3();
		}
	}
}