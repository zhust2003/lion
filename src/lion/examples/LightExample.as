package lion.examples
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import lion.engine.cameras.Camera;
	import lion.engine.cameras.OrthographicCamera;
	import lion.engine.cameras.PerspectiveCamera;
	import lion.engine.core.Mesh;
	import lion.engine.core.Scene;
	import lion.engine.geometries.CubeGeometry;
	import lion.engine.geometries.PlaneGeometry;
	import lion.engine.geometries.SphereGeometry;
	import lion.engine.lights.DirectionalLight;
	import lion.engine.lights.PointLight;
	import lion.engine.materials.VertexLitMaterial;
	import lion.engine.materials.Material;
	import lion.engine.materials.WireframeMaterial;
	import lion.engine.math.Vector3;
	import lion.engine.renderer.SoftRenderer;
	
	[SWF(frameRate="60", width="600", height="600", backgroundColor="#0")]
	public class LightExample extends Sprite
	{
		private var scene:Scene;
		private var cube:Mesh;
		private var camera:Camera;
		private var renderer:SoftRenderer;
		private var viewport:Rectangle;
		private var light:DirectionalLight;
		private var info:TextField;
		private var plane:Mesh;
		private var sphere:Mesh;
		private var light2:PointLight;
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
			var p:CubeGeometry = new CubeGeometry(10, 10, 10);
			var m:Material = new VertexLitMaterial();
			
			cube = new Mesh(p, m);
			cube.rotation.y = 14.1;
			cube.position.z = -10;
			scene.add(cube);
			
			var p2:PlaneGeometry = new PlaneGeometry(50, 50, 5, 5);
			var m2:Material = new VertexLitMaterial();
			plane = new Mesh(p2, m2);
			plane.rotation.x = -1.57;
			plane.position.z = -10;
			plane.position.y = -10;
			scene.add(plane);
			
			// 创建一个球
			var p3:SphereGeometry = new SphereGeometry(10, 16, 16);
			var m3:Material = new VertexLitMaterial();
			sphere = new Mesh(p3, m3);
			sphere.position.x = 30;
			sphere.position.z = -100;
			scene.add(sphere);
			
			// 创建一个摄像机
//			camera = new OrthographicCamera(-50, 50, -50, 50);
			camera = new PerspectiveCamera(60, 1);
			camera.position.set(0, 10, 30);
			camera.lookAt(new Vector3(0, 0, 0));
			scene.add(camera);
			
			// 创建一个平型光
			light = new DirectionalLight(0xffffff);
			light.position.set(0, 10, 30).normalize();
			scene.add(light);
			
			// 创建一个点光源
			light2 = new PointLight(0xf70000, 1, 50);
			light2.position.set(0, 30, -10);
			scene.add(light2);
			
			// 创建一个渲染器
			renderer = new SoftRenderer();
			addChild(renderer.container);
			
			// 信息栏
			info = new TextField();
			var format:TextFormat = new TextFormat();
			format.color = 0xFFFFFF;
			info.defaultTextFormat = format;
			info.setTextFormat(format);
			addChild(info);
			
			viewport = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		protected function update(event:Event):void
		{
			cube.rotation.y += 0.01;
			cube.rotation.x += 0.01;
//			cube.scale.x += 0.001;
//			cube.scale.y += 0.001;
//			cube.scale.z += 0.001;
			info.text = cube.rotation.y.toFixed(2);
			sphere.rotation.y += 0.02;
			renderer.render(scene, camera, viewport);
		}
	}
}