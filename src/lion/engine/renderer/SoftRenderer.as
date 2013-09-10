package lion.engine.renderer
{
	import flash.display.Graphics;
	
	import lion.engine.cameras.Camera;
	import lion.engine.core.Scene;
	
	/**
	 * 软件渲染 
	 * @author Dalton
	 * 
	 */	
	public class SoftRenderer implements IRenderer
	{
		private var _context:Graphics;
		
		public function SoftRenderer()
		{
		}
		
		public function render(scene:Scene, camera:Camera):void
		{
			scene.updateMatrixWorld();
		}
		
		public function drawTriangle(x0:Number, y0:Number, x1:Number, y1:Number, x2:Number, y2:Number):void {
//			_context.drawTriangles()
			_context.moveTo(x0, y0);
			_context.lineTo(x1, y1);
			_context.lineTo(x2, y2);
		}
	}
}