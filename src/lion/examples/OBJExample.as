package lion.examples
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display3D.Context3DTriangleFace;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	
	import lion.engine.cameras.PerspectiveCamera;
	import lion.engine.core.Mesh;
	import lion.engine.core.Scene;
	import lion.engine.geometries.PlaneGeometry;
	import lion.engine.lights.DirectionalLight;
	import lion.engine.loaders.Loader3D;
	import lion.engine.materials.VertexLitMaterial;
	import lion.engine.math.Vector2;
	import lion.engine.math.Vector3;
	import lion.engine.math.Vector4;
	import lion.engine.renderer.Stage3DRenderer;
	import lion.engine.textures.BitmapTexture;
	import lion.games.controls.EditorControl;
	
	[SWF(frameRate="60", width="600", height="600", backgroundColor="#0")]
	public class OBJExample extends Sprite
	{
		// 经典的西洋棋盘
		[Embed(source="../../../assets/checkerboard.jpg", mimeType="image/jpeg")]
		private var CheckerBoard:Class;
		
		
		private var plane:Mesh;
		private var scene:Scene;
		private var camera:PerspectiveCamera;
		private var light:DirectionalLight;
		private var renderer:Stage3DRenderer;
		private var info:TextField;
		private var viewport:Rectangle;
		private var control:EditorControl;
		private var lastTime:int;
		private var fps:int;
		private var fpsSum:int;
		private var fpsCount:int;
		private var fpsAvg:Number;
		private var center:Vector3;
		
		
		public function OBJExample()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
		}
		
		protected function onAddToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddToStage);
			
			init();
		}
		
		
		public function init():void {
			scene = new Scene();
			
			// 创建一个地面
			var p4:PlaneGeometry = new PlaneGeometry(400, 400, 10, 10);
			var gb:BitmapData = (new CheckerBoard()).bitmapData;
			var m3:VertexLitMaterial = new VertexLitMaterial();
			m3.texture = new BitmapTexture(gb);
			m3.texture.wrap = "wrap";
			m3.texture.repeat = new Vector2(10, 10);
			
			// 双面渲染
			m3.side = Context3DTriangleFace.NONE;
			m3.specular = new Vector4(0, 0, 0);
			
			plane = new Mesh(p4, m3);
			plane.receiveShadow = true;
			plane.rotation.x = -1.57;
			scene.add(plane);
			
			// 增加一个md2模型
			var model:Loader3D = new Loader3D();
			model.scale.multiply(10);
			model.load(new URLRequest('../assets/obj/lantern_genie.obj'));
			scene.add(model);
			
			// 创建一个摄像机
			camera = new PerspectiveCamera(75, 1);
			camera.position.set(0, 40, 60);
			center = new Vector3(0, 0, 0);
			camera.lookAt(center);
			scene.add(camera);
			
			// 创建一个光线
			light = new DirectionalLight(0xFFFFFF, 1.5);
			light.position.set(- 40, 80, 20);
			light.lookAt(new Vector3(0, 0, 0));
			light.castShadow = true;
			scene.add(light);
			
			// 创建一个渲染器
			renderer = new Stage3DRenderer(stage);
			
			// 信息栏
			info = new TextField();
			var format:TextFormat = new TextFormat('_sans', 12, 0xffffff, true);
			info.defaultTextFormat = format;
			info.setTextFormat(format);
			info.selectable = false;
			info.autoSize = TextFieldAutoSize.LEFT;
			info.opaqueBackground = 0x0;
			addChild(info);
			
			// 摄像机控制器
			control = new EditorControl(camera, stage, new Vector3());
			
			viewport = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			
			addEventListener(Event.ENTER_FRAME, update);
			
			setInterval(onUpdateProfile, 1000);
		}
		
		private function onUpdateProfile():void
		{
			info.text = '';
			info.text = 'draw count:' + renderer.drawCount.toString() + '\n';
			info.appendText('fps:' + fps + '\n');
			info.appendText('fpsAvg:' + fpsAvg + '\n');
			info.appendText('driver:' + renderer.context.driverInfo + '\n');
			info.appendText('memory:' + Number(System.privateMemory / 1024 / 1024).toFixed(2) + 'mb \n');
		}
		
		protected function update(event:Event):void
		{
			
			var nowTime:int = getTimer();
			var time:Number = nowTime - lastTime;
			fps = 0;
			if (time != 0) {
				fps = Math.floor(1000 / time);
			}
			fpsSum += fps;
			fpsCount++;
			fpsAvg = Math.floor(fpsSum/fpsCount);
			
			control.update();
			renderer.render(scene, camera, viewport);
			
			lastTime = nowTime;
		}
	}
}