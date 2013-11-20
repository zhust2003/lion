package lion.games.controls
{
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import lion.engine.cameras.Camera;
	import lion.engine.math.Matrix3;
	import lion.engine.math.Vector3;
	import lion.engine.utils.InputManager;

	/**
	 * 第一人称射击摄像机控制
	 * 方向由键盘控制，镜头由鼠标控制 
	 * @author Dalton
	 * 
	 */	
	public class FirstPersonControl
	{
		private var vector:Vector3;
		private var camera:Camera;
		private var stage:Stage;
		private var startX:Number;
		private var startY:Number;
		
		public function FirstPersonControl(camera:Camera, stage:Stage)
		{
			this.camera = camera;
			this.stage = stage;
			
			vector = new Vector3();
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		/**
		 * 沿着法线移动 
		 * @param dist
		 * 
		 */		
		protected function move(dist:Vector3):void {
			// 获取摄像机的法线变换矩阵
			var normalMatrix:Matrix3 = new Matrix3();
			normalMatrix.getNormalMatrix(camera.matrixWorld);
			
			// 法向向量
			dist.applyMatrix3(normalMatrix);
			camera.position.add(dist);
		}
		
		protected function onMouseDown(event:MouseEvent):void
		{
			event.preventDefault();
			startX = event.stageX;
			startY = event.stageY;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		protected function onMouseUp(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		protected function onMouseMove(event:MouseEvent):void
		{
			var mx:Number = event.stageX - startX;
			var my:Number = event.stageY - startY;
			
			camera.rotation.x += -my * 0.005;
			camera.rotation.y += -mx * 0.005;
			
			startX = event.stageX;
			startY = event.stageY;
		}
		
		public function update():void {
			if (InputManager.instance.keyDown(Keyboard.W)) {
				move(new Vector3(0, 0, -1));
			}
			if (InputManager.instance.keyDown(Keyboard.S)) {
				move(new Vector3(0, 0, 1));
			}
			if (InputManager.instance.keyDown(Keyboard.D)) {
				move(new Vector3(1, 0, 0));
			}
			if (InputManager.instance.keyDown(Keyboard.A)) {
				move(new Vector3(-1, 0, 0));
			}
		}
		
		public function dispose():void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
	}
}