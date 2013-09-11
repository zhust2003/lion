package lion.examples
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import lion.engine.cameras.PerspectiveCamera;
	import lion.engine.core.Mesh;
	import lion.engine.core.Scene;
	import lion.engine.geometries.CubeGeometry;
	import lion.engine.geometries.PlaneGeometry;
	import lion.engine.materials.Material;
	import lion.engine.materials.WireframeMaterial;
	import lion.engine.math.Vector3;
	import lion.engine.renderer.SoftRenderer;

	[SWF(frameRate="60", width="600", height="600", backgroundColor="#0")]
	public class CubeExample extends Sprite
	{
		private var scene:Scene;
		private var plane:Mesh;
		private var camera:PerspectiveCamera;
		private var renderer:SoftRenderer;
		private var viewport:Rectangle;
		
		public function CubeExample()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
		}
		
		protected function onAddToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddToStage);
			
			init();
		}
		
		public function init():void {
			scene = new Scene();
			
			// 创建一个面片
			var p:CubeGeometry = new CubeGeometry(10, 10, 10);
			var m:Material = new WireframeMaterial();
			
			plane = new Mesh(p, m);
			scene.add(plane);
			
			// 创建一个摄像机
			camera = new PerspectiveCamera(60, 1);
			camera.position.set(0, 10, 20);
			camera.lookAt(new Vector3(0, 0, 0));
			scene.add(camera);
			
			// 创建一个渲染器
			renderer = new SoftRenderer();
			addChild(renderer.container);
			
			
			viewport = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		protected function update(event:Event):void
		{
			plane.rotation.y += 0.01;
//			plane.rotation.x += 0.01;
//			camera.rotation.y += 0.01;
			renderer.render(scene, camera, viewport);
		}
	}
}