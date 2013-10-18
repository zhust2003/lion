package lion.examples
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display3D.Context3DTriangleFace;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	
	import lion.engine.cameras.OrthographicCamera;
	import lion.engine.cameras.PerspectiveCamera;
	import lion.engine.core.Mesh;
	import lion.engine.core.Scene;
	import lion.engine.geometries.CubeGeometry;
	import lion.engine.geometries.PlaneGeometry;
	import lion.engine.geometries.SphereGeometry;
	import lion.engine.materials.BaseMaterial;
	import lion.engine.materials.LambertMaterial;
	import lion.engine.materials.Material;
	import lion.engine.materials.WireframeMaterial;
	import lion.engine.math.MathUtil;
	import lion.engine.math.Matrix3;
	import lion.engine.math.Vector3;
	import lion.engine.renderer.SoftRenderer;
	import lion.engine.renderer.Stage3DRenderer;
	import lion.engine.textures.BitmapTexture;
	import lion.engine.utils.InputManager;
	import lion.games.controls.EditorControl;
	import lion.games.controls.FirstPersonControl;
	
	[SWF(frameRate="60", width="600", height="600", backgroundColor="#0")]
	public class Stage3DExample extends Sprite
	{
		private var renderer:Stage3DRenderer;
//		private var renderer:SoftRenderer;
		private var scene:Scene;
		private var plane:Mesh;
		private var camera:PerspectiveCamera;
//		private var camera:OrthographicCamera;
		private var viewport:Rectangle;
		private var info:TextField;
		private var cube:Mesh;
		private var angle:Number = 0;
		private var sphere:Mesh;
		private var startX:Number;
		private var startY:Number;
		private var center:Vector3;
//		private var control:FirstPersonControl;
		private var control:EditorControl;
		
		[Embed(source="../../test", mimeType="application/octet-stream")]
		private var c:Class;
		[Embed(source="../../../assets/t.png", mimeType="image/png")]
		private var t:Class;
		[Embed(source="../../../assets/earth.jpg", mimeType="image/jpeg")]
		private var e:Class;
		private var cube2:Mesh;
		
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
			scene = new Scene();
			
			// 创建一个立方体
			var p:CubeGeometry = new CubeGeometry(10, 10, 10);
			var b:BitmapData = (new t()).bitmapData;
			var m:LambertMaterial = new LambertMaterial();
			m.texture = new BitmapTexture(b, false);
			
			cube = new Mesh(p, m);
			cube.position.set(0, 0, 0);
			scene.add(cube);
			
			// 创建一个面片
			var p2:CubeGeometry = new CubeGeometry(10, 10, 10);
			var m1:LambertMaterial = new LambertMaterial();
			m1.texture = new BitmapTexture(b);
			
			cube2 = new Mesh(p2, m1);
			cube2.position.set(0, 20, 0);
			scene.add(cube2);
			
			// 创建一个面片
			var p4:PlaneGeometry = new PlaneGeometry(10, 10);
			var m3:LambertMaterial = new LambertMaterial();
			m3.texture = new BitmapTexture(b);
			m3.side = Context3DTriangleFace.NONE;
			
			plane = new Mesh(p4, m3);
			plane.position.set(20, 0, 0);
			plane.rotation.x = -1.57;
			scene.add(plane);
			
			// 创建一个圆
			var p3:SphereGeometry = new SphereGeometry(10, 16, 16);
			var eb:BitmapData = (new e()).bitmapData;
			var m2:LambertMaterial = new LambertMaterial();
			m2.texture = new BitmapTexture(eb);
			
			sphere = new Mesh(p3, m2);
			sphere.position.set(-20, 0, 0);
			scene.add(sphere);
			
			// 创建一个摄像机
			camera = new PerspectiveCamera(60, 1);
//			camera = new OrthographicCamera(-50, 50, 50, -50);
			camera.position.set(0, 20, 50);
			center = new Vector3(0, 0, 0);
			camera.lookAt(center);
			scene.add(camera);
			
			// 创建一个渲染器
			renderer = new Stage3DRenderer(stage);
//			renderer = new SoftRenderer();
//			addChild(renderer.container);
			
			// 信息栏
			info = new TextField();
			var format:TextFormat = new TextFormat();
			format.color = 0xFFFFFF;
			info.defaultTextFormat = format;
			info.setTextFormat(format);
			addChild(info);
			
			// 摄像机控制器
//			control = new FirstPersonControl(camera, stage);
			control = new EditorControl(camera, stage, new Vector3());
			
			
			
			viewport = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			InputManager.instance.init(stage);
			
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		protected function update(event:Event):void
		{
			cube.rotation.y += 0.01;
			sphere.rotation.y -= 0.01;
			plane.rotation.x += 0.01;
			info.text = 'draw count:' + renderer.drawCount.toString();
			control.update();
			renderer.render(scene, camera, viewport);
		}
	}
}