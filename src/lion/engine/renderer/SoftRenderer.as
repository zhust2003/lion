package lion.engine.renderer
{
	import lion.engine.cameras.Camera;
	import lion.engine.core.Scene;
	
	/**
	 * 软件渲染 
	 * @author Dalton
	 * 
	 */	
	public class SoftRenderer implements IRenderer
	{
		public function SoftRenderer()
		{
		}
		
		public function render(scene:Scene, camera:Camera):void
		{
			scene.updateMatrixWorld();
		}
	}
}