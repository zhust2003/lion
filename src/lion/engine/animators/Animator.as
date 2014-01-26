package lion.engine.animators
{
	import flash.utils.getTimer;

	/**
	 * 基本动画器
	 * 包含多个Animation 
	 * @author Dalton
	 * 
	 */	
	public class Animator
	{
		private var startTime:int;
		
		public function Animator()
		{
		}
		
		public function start():void {
			startTime = getTimer();
		}
		
		public function update():void
		{
			var dt:uint = getTimer() - startTime;
			
		}
	}
}