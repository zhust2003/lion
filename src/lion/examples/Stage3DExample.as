package lion.examples
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import lion.engine.renderer.Stage3DRenderer;
	
	[SWF(frameRate="60", width="600", height="600", backgroundColor="#0")]
	public class Stage3DExample extends Sprite
	{
		private var renderer:Stage3DRenderer;
		
		public function Stage3DExample()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
		}
		
		protected function onAddToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddToStage);
			
			init();
		}
		
		public function init():void {
			trace('init');
			renderer = new Stage3DRenderer(stage);
			
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		protected function update(event:Event):void
		{
			renderer.render(null, null, null);
		}
	}
}