package lion.engine.loaders.parser
{
	import flash.events.Event;
	
	public class ParserEvent extends Event
	{
		public static const COMPLETE:String = 'complete';
		
		public function ParserEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}