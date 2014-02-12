package lion.engine.animators
{
	import flash.utils.Dictionary;

	/**
	 * 顶点动画集，用来公用所有一样的动画 
	 * @author Dalton
	 * 
	 */	
	public class VertexAnimatorSet
	{
		public var animations:Dictionary = new Dictionary();
		
		public function VertexAnimatorSet()
		{
		}
		
		public function addAnimation(animation:VertexAnimation):void {
			if (animations[animation.name]) {
				return;
			}
			animations[animation.name] = animation;
		}
		
		public function hasAnimation(name:String):Boolean
		{
			return animations[name] != null;
		}
		
		public function getAnimation(name:String):VertexAnimation
		{
			return animations[name];
		}
	}
}