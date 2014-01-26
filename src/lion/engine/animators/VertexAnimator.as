package lion.engine.animators
{
	/**
	 * 早期的顶点动画 (MD2)
	 * @author Dalton
	 * 
	 */	
	public class VertexAnimator extends Animator
	{
		private var animatorSet:VertexAnimatorSet;
		private var currentAnimation:VertexAnimation;
		private var currentAnimationName:String;
		
		public function VertexAnimator(animatorSet:VertexAnimatorSet)
		{
			this.animatorSet = animatorSet;
		}
		
		public function play(name:String):void {
			if (currentAnimationName == name) {
				return;
			}
			currentAnimationName = name;
			currentAnimation = animatorSet.getAnimation(name);
			
		}
		
		
		public function update():void {
			super.update();
			
		}
	}
}