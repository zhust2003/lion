package lion.engine.renderer
{
	import flash.geom.Rectangle;
	
	import lion.engine.cameras.Camera;
	import lion.engine.core.Scene;

	public interface IRenderer
	{
		function render(scene:Scene, camera:Camera, viewport:Rectangle):void;
	}
}