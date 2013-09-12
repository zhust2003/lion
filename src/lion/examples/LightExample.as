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
	import lion.engine.lights.DirectionalLight;
	import lion.engine.materials.BaseMaterial;
	import lion.engine.materials.Material;
	import lion.engine.materials.WireframeMaterial;
	import lion.engine.math.Vector3;
	import lion.engine.renderer.SoftRenderer;
	
	[SWF(frameRate="60", width="600", height="600", backgroundColor="#0")]
	public class LightExample extends Sprite
	{
		private var scene:Scene;
		private var plane:Mesh;
		private var camera:PerspectiveCamera;
		private var renderer:SoftRenderer;
		private var viewport:Rectangle;
		private var light:DirectionalLight;
		public function LightExample()
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
//			var p:PlaneGeometry = new PlaneGeometry(20, 20, 10, 10);
			var p:CubeGeometry = new CubeGeometry(10, 10, 10);
			var m:Material = new BaseMaterial();
//			var m:Material = new WireframeMaterial();
			
			plane = new Mesh(p, m);
			plane.rotation.x = -1.57;
			scene.add(plane);
			
			// 创建一个摄像机
			camera = new PerspectiveCamera(60, 1);
			camera.position.set(0, 10, 30);
			camera.lookAt(new Vector3(0, 0, 0));
			scene.add(camera);
			
			// 创建一个平型光
			light = new DirectionalLight(0xffffff);
			light.position.set(0, 50, 20).normalize();
			scene.add(light);
			
			// 创建一个渲染器
			renderer = new SoftRenderer();
			addChild(renderer.container);
			
			
			viewport = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		protected function update(event:Event):void
		{
//			plane.rotation.z += 0.01;
			//			plane.rotation.x += 0.01;
			//			camera.rotation.y += 0.01;
			renderer.render(scene, camera, viewport);
		}
	}
}