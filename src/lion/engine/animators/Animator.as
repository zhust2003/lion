package lion.engine.animators
{
	import flash.utils.getTimer;
	
	import lion.engine.core.Mesh;
	import lion.engine.geometries.Geometry;
	import lion.engine.materials.Material;

	/**
	 * 基本动画器
	 * 包含多个Animation 
	 * @author Dalton
	 * 
	 */	
	public class Animator extends Mesh
	{
		private var startTime:int;
		protected var time:uint;
		
		public function Animator(g:Geometry, m:Material)
		{
			super(g, m);
		}
		
		public function play(name:String):void {
			
		}
		
		public function start():void {
			startTime = getTimer();
			time = 0;
		}
		
		public function update():void
		{
			time = getTimer() - startTime;
		}
		
		override public function updateMatrixWorld():void {
			super.updateMatrixWorld();
			
			update();
		}
	}
}