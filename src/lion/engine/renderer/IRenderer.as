package lion.engine.renderer
{
	import lion.engine.cameras.Camera;
	import lion.engine.core.Scene;

	public interface IRenderer
	{
		public function render(scene:Scene, camera:Camera):void;
	}
}