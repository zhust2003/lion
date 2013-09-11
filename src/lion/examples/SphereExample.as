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
	import lion.engine.geometries.SphereGeometry;
	import lion.engine.materials.Material;
	import lion.engine.materials.WireframeMaterial;
	import lion.engine.math.Vector3;
	import lion.engine.renderer.SoftRenderer;

	[SWF(frameRate="60", width="600", height="600", backgroundColor="#0")]
	public class SphereExample extends Sprite
	{
		private var scene:Scene;
		private var plane:Mesh;
		private var camera:PerspectiveCamera;
		private var renderer:SoftRenderer;
		private var viewport:Rectangle;
		private var sphere:Mesh;
		
		public function SphereExample()
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
			// 创建一个面片
			var p:PlaneGeometry = new PlaneGeometry(10, 10, 2, 2);
			
			plane = new Mesh(p, new WireframeMaterial());
			plane.rotation.x = -1.57;
			scene.add(plane);
			
			var s:SphereGeometry = new SphereGeometry(5);
			
			sphere = new Mesh(s, new WireframeMaterial());
			sphere.position.y = 5;
			scene.add(sphere);
			
			// 创建一个摄像机
			camera = new PerspectiveCamera(60, 1);
			camera.position.set(0, 20, 20);
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
			sphere.rotation.y += 0.01;
			plane.rotation.z += 0.01;
//			camera.rotation.y += 0.01;
			renderer.render(scene, camera, viewport);
		}
	}
}