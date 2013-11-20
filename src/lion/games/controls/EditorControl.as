package lion.games.controls
{
	import flash.display.Stage;
	import flash.events.MouseEvent;
	
	import lion.engine.cameras.Camera;
	import lion.engine.math.Matrix3;
	import lion.engine.math.Vector3;

	/**
	 * 编辑器摄像机控制
	 * 永远朝向中心，鼠标控制转向，放大缩小 
	 * @author Dalton
	 * 
	 */	
	public class EditorControl
	{
		private var camera:Camera;
		private var stage:Stage;
		private var startX:Number;
		private var startY:Number;
		private var vector:Vector3;
		private var center:Vector3;
		
		public function EditorControl(camera:Camera, stage:Stage, center:Vector3)
		{
			this.camera = camera;
			this.stage = stage;
			this.center = center || new Vector3();
			this.vector = new Vector3();
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		}
		
		protected function onMouseWheel(event:MouseEvent):void
		{
			var delta:Number = event.delta;
			zoom(new Vector3(0, 0, -delta));
		}
		
		private function zoom(dist:Vector3):void
		{
			var normalMatrix:Matrix3 = new Matrix3();
			normalMatrix.getNormalMatrix(camera.matrixWorld);
			// 法向向量
			dist.applyMatrix3(normalMatrix);
			dist.multiply(vector.copy(center).sub(camera.position).length * 0.01);
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
			
			vector.copy(camera.position).sub(center);
			
			var theta:Number = Math.atan2(vector.x, vector.z);
			var phi:Number = Math.atan2(Math.sqrt(vector.x * vector.x + vector.z * vector.z), vector.y);
			
			theta += -mx * 0.005;
			phi += -my * 0.005;
			
			var EPS:Number = 0.000001;
			
			phi = Math.max(EPS, Math.min(Math.PI - EPS, phi));
			
			var radius:Number = vector.length;
			
			vector.x = radius * Math.sin(phi) * Math.sin(theta);
			vector.y = radius * Math.cos(phi);
			vector.z = radius * Math.sin(phi) * Math.cos(theta);
			
			camera.position.copy(center).add(vector);
			camera.lookAt(center);
			
			startX = event.stageX;
			startY = event.stageY;
		}
		
		public function update():void {
			
		}
		
		public function dispose():void {
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
	}
}