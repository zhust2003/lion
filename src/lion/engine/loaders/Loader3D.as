package lion.engine.loaders
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.TriangleCulling;
	import flash.display3D.Context3DTriangleFace;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import lion.engine.animators.Animator;
	import lion.engine.animators.VertexAnimator;
	import lion.engine.core.Mesh;
	import lion.engine.core.Object3D;
	import lion.engine.loaders.parser.MD2Parser;
	import lion.engine.loaders.parser.OBJParser;
	import lion.engine.loaders.parser.Parser;
	import lion.engine.loaders.parser.ParserEvent;
	import lion.engine.materials.VertexLitMaterial;
	import lion.engine.materials.WireframeMaterial;
	import lion.engine.textures.BitmapTexture;
	
	public class Loader3D extends Object3D
	{
		private var loader:URLLoader;
		private var parser:Parser;
		private var skinLoader:Loader;
		private var mesh:Mesh;
		
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
				case '.obj':
					parser = new OBJParser();
					loader.dataFormat = URLLoaderDataFormat.TEXT;
					break;
				default:
					trace('not default parser');
			}
			
			parser.addEventListener(ParserEvent.COMPLETE, onParseComplete);
			
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load(r);
		}
		
		public function setSkin(r:URLRequest):void {
			skinLoader = new Loader();
			skinLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadSkinComplete);
			skinLoader.load(r);
		}
		
		protected function onLoadSkinComplete(event:Event):void
		{
			skinLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadSkinComplete);
			var b:BitmapData = Bitmap(skinLoader.content).bitmapData;
			var m:VertexLitMaterial = new VertexLitMaterial();
			m.texture = new BitmapTexture(b);
//			m.side = Context3DTriangleFace.BACK;
			mesh.material = m;
		}
		
		protected function onParseComplete(event:Event):void
		{
			parser.removeEventListener(ParserEvent.COMPLETE, onParseComplete);
			
			switch(parser.type)
			{
				case 'md2':
				{
					var md2:MD2Parser = parser as MD2Parser;
					mesh = new VertexAnimator(md2.geometry, md2.material, md2.animatorSet);
					VertexAnimator(mesh).play('frame');
					add(mesh);
					break;
				}
				case 'obj':
				{
					var obj:OBJParser = parser as OBJParser;
					mesh = new Mesh(obj.geometry, new VertexLitMaterial());
					add(mesh);
					break;
				}
				default:
				{
					break;
				}
			}
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