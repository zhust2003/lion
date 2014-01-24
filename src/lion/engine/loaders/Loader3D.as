package lion.engine.loaders
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import lion.engine.core.Object3D;
	import lion.engine.loaders.parser.MD2Parser;
	import lion.engine.loaders.parser.Parser;
	
	public class Loader3D extends Object3D
	{
		private var loader:URLLoader;
		private var parser:Parser;
		
		public function Loader3D()
		{
			super();
			
			loader = new URLLoader();
		}
		
		public function load(r:URLRequest):void {
			var extension:String = getExtension(r.url);
			switch (extension) {
				case '.md2':
					parser = new MD2Parser();
					loader.dataFormat = URLLoaderDataFormat.BINARY;
					break;
				default:
					trace('not default parser');
			}
			
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load(r);
		}
		
		private function getFileName(url:String):String {
			return url.slice(url.lastIndexOf('/'));
		}
		
		private function getExtension(url:String):String {
			return url.slice(url.lastIndexOf('.'));
		}
		
		public function removeAllListener():void {
			loader.removeEventListener(Event.COMPLETE, onComplete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
		}
		
		protected function onError(event:IOErrorEvent):void
		{
			// TODO Auto-generated method stub
			
		}
		
		protected function onComplete(event:Event):void
		{
			parser.parse(loader.data);
		}
	}
}