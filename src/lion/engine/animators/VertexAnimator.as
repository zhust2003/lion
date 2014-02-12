package lion.engine.animators
{
	import lion.engine.geometries.Geometry;
	import lion.engine.materials.Material;
	import lion.engine.math.Vector3;
	import lion.engine.utils.Interpolation;

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
		private var currentFrame:uint;
		private var nextFrame:int;
		
		public function VertexAnimator(g:Geometry, m:Material, animatorSet:VertexAnimatorSet)
		{
			this.animatorSet = animatorSet;
			super(g, m);
		}
		
		override public function play(name:String):void {
			if (currentAnimationName == name) {
				return;
			}
			currentAnimationName = name;
			currentAnimation = animatorSet.getAnimation(name);
			
		}
		
		
		override public function update():void {
			super.update();
			
			if (! currentAnimation) return;
			
			// 如果超过总持续时间，则回滚
			var totalDuration:uint = currentAnimation.totalDuration;
			var looping:Boolean = currentAnimation.looping;
			var lastFrame:uint = currentAnimation.frames.length - 1;
			if (looping && (time >= totalDuration || time < 0)) {
				time %= totalDuration;
				if (time < 0)
					time += totalDuration;
			}
			
			// 找到当前帧
			currentFrame = 0;
			nextFrame = 0;
			
			var dur:uint = 0, frameTime:uint;
			var durations:Vector.<uint> = currentAnimation.durations;
			
			if (! looping && time >= totalDuration) {
				currentFrame = lastFrame;
				nextFrame = lastFrame;
			} else if (! looping && time <= 0) {
				currentFrame = 0;
				nextFrame = 1;
			} else {
				do {
					frameTime = dur;
					dur += durations[nextFrame];
					currentFrame = nextFrame++;
				} while (time > dur);
				
				// 停在最后一帧
				if (currentFrame == currentAnimation.frames.length - 1) {
					nextFrame = currentFrame;
				}
			}
			
			
			var nowGeometry:Geometry = currentAnimation.frames[currentFrame];
			var nextGeometry:Geometry = currentAnimation.frames[nextFrame];
			
			// 无插值
//			geometry = nowGeometry;
			
			// 两帧插值
			var smoothGeometry:Geometry = new Geometry();
			smoothGeometry.faces = nowGeometry.faces;
			smoothGeometry.faceVertexUvs = nowGeometry.faceVertexUvs;
			
			var k:Number = (time - frameTime) / durations[currentFrame];
			for (var i:String in nowGeometry.vertices) {
				var va:Vector3 = nowGeometry.vertices[i];
				var vb:Vector3 = nextGeometry.vertices[i];
				var v:Vector3 = new Vector3();
				v.x = Interpolation.linearInterpolate(va.x, vb.x, k);
				v.y = Interpolation.linearInterpolate(va.y, vb.y, k);
				v.z = Interpolation.linearInterpolate(va.z, vb.z, k);
				smoothGeometry.vertices.push(v);
			}
			geometry = smoothGeometry;
		}
	}
}