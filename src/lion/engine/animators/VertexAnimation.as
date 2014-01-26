package lion.engine.animators
{
	import lion.engine.geometries.Geometry;

	/**
	 * 具体的动画，比如待机，移动等 
	 * @author Dalton
	 * 
	 */	
	public class VertexAnimation
	{
		// 动画名
		public var name:String;
		// 每帧的多边形数据
		protected var frames:Vector.<Geometry> = new Vector.<Geometry>();
		// 每帧的持续时间		
		protected var durations:Vector.<uint> = new Vector.<uint>();
		/**
		 * 总时间 
		 */				
		protected var totalDuration:uint = 0;
		
		public function VertexAnimation()
		{
		}
		
		public function addFrame(g:Geometry, duration:uint):void {
			frames.push(g);
			durations.push(duration);
			totalDuration += duration;
		}
	}
}