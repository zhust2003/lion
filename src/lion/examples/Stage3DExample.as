package lion.examples
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.display3D.Context3DTriangleFace;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	
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
	import lion.engine.materials.BaseMaterial;
	import lion.engine.materials.Material;
	import lion.engine.materials.VertexLitMaterial;
	import lion.engine.materials.WireframeMaterial;
	import lion.engine.math.MathUtil;
	import lion.engine.math.Matrix3;
	import lion.engine.math.Vector2;
	import lion.engine.math.Vector3;
	import lion.engine.math.Vector4;
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
		private var camera:Camera;
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
		// 样条箱
		private var c:Class;
		[Embed(source="../../../assets/t.png", mimeType="image/png")]
		private var t:Class;
		[Embed(source="../../../assets/earth.jpg", mimeType="image/jpeg")]
		private var e:Class;
		
		// 草
		[Embed(source="../../../assets/grass.jpg", mimeType="image/jpeg")]
		private var g:Class;
		
		// 经典的西洋棋盘
		[Embed(source="../../../assets/checkerboard.jpg", mimeType="image/jpeg")]
		private var CheckerBoard:Class;
		private var cube2:Mesh;
		private var light:DirectionalLight;
		private var light2:PointLight;
		private var lastTime:int = 0;
		private var fpsSum:int = 0;
		private var fpsCount:int = 0;
		private var fpsAvg:int = 0;
		private var fps:int;
		private var button:Sprite;
		
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
			var m:VertexLitMaterial = new VertexLitMaterial();
			m.texture = new BitmapTexture(b, false);
			
			cube = new Mesh(p, m);
			cube.position.set(-20, 0, 0);
			scene.add(cube);
			
			// 创建多个
//			for (var i:int = 0; i < 100; i++) {
//				var p:CubeGeometry = new CubeGeometry(10, 10, 10);
//				var b:BitmapData = (new t()).bitmapData;
//				var m:VertexLitMaterial = new VertexLitMaterial();
//				m.ambient = new Vector4(MathUtil.randf(0, 1), MathUtil.randf(0, 1), MathUtil.randf(0, 1));
////				m.texture = new BitmapTexture(b, false);
//				
//				var cube1:Mesh = new Mesh(p, m);
//				cube1.position.set(MathUtil.randf(-200, 200), MathUtil.randf(0, 200), MathUtil.randf(-200, 200));
//				scene.add(cube1);
//			}
			
			// 创建一个立方体
			var p2:CubeGeometry = new CubeGeometry(10, 10, 10);
			var m1:VertexLitMaterial = new VertexLitMaterial();
			m1.texture = new BitmapTexture(b);
			
			cube2 = new Mesh(p2, m1);
			cube2.position.set(0, 20, 0);
			scene.add(cube2);
			
			// 创建一个圆
			var p3:SphereGeometry = new SphereGeometry(10, 32, 32);
			var eb:BitmapData = (new e()).bitmapData;
			var m2:VertexLitMaterial = new VertexLitMaterial();
//			m2.ambient = new Vector4(0.1, 0, 0.5);
			m2.texture = new BitmapTexture(eb);
			
			sphere = new Mesh(p3, m2);
			sphere.position.set(0, 0, 0);
			scene.add(sphere);
			
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
			plane.position.set(0, -20, 0);
			plane.rotation.x = -1.57;
			scene.add(plane);
			
			// 创建一个摄像机
			camera = new PerspectiveCamera(75, 1);
//			camera = new OrthographicCamera(-50, 50, 50, -50, 0.1, 30000);
			camera.position.set(0, 40, 60);
			center = new Vector3(0, 0, 0);
			camera.lookAt(center);
			scene.add(camera);
			
			// 创建一个光线
			light = new DirectionalLight(0xFFFFFF, 1.5);
			light.castShadow = true;
			light.position.set(- 40, 80, 20);
			light.position.x = 40 * MathUtil.cosd(angle);
			light.position.z = 40 * MathUtil.sind(angle);
			light.lookAt(new Vector3(0, 0, 0));
			scene.add(light);
			
//			// 光源位置
//			camera = new OrthographicCamera(-50, 50, 50, -50, 0.1, 30000);
//			light.updateMatrixWorld();
//			camera.position.getPositionFromMatrix(light.matrixWorld);
//			// 光源方向
//			var normalMatrix:Matrix3 = new Matrix3();
//			normalMatrix.getNormalMatrix(light.matrixWorld);
//			camera.lookAt(center);
//			camera.updateMatrixWorld();
			
			// 创建一个点光源
			light2 = new PointLight(0xFF0000, 1.5, 200);
			light2.position.set(camera.position.x + 40, camera.position.y + 40, camera.position.z - 40);
//			scene.add(light2);
			
			// 创建一个渲染器
			renderer = new Stage3DRenderer(stage);
//			renderer = new SoftRenderer();
//			addChild(renderer.container);
			
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
//			control = new FirstPersonControl(camera, stage);
			control = new EditorControl(camera, stage, new Vector3());
			
			
			
			viewport = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			InputManager.instance.init(stage);
			
			addEventListener(Event.ENTER_FRAME, update);
			
			setInterval(onUpdateProfile, 1000);
			setupFullScreenButton();
		}
		
		private function setupFullScreenButton():void
		{
			button = new Sprite();
			var g:Graphics =    button.graphics;
			
			var clrBlack:uint = 0x000000;
			var clrWhite:uint = 0xffffff;
			
			var coordinates:Array = [
				[clrBlack, 0, 0, 30, 30],
				[clrWhite, 5, 5, 20, 20],
				[clrBlack, 7, 7, 16, 16],
				[clrBlack, 0, 10, 30, 10],
				[clrBlack, 10, 0, 10, 30]
			];
			
			for (var c:int; c < coordinates.length; c++) {
				var command:Array = coordinates[c];
				g.beginFill(command[0]);
				g.drawRoundRect(command[1], command[2], command[3], command[4], 6, 6);
				g.endFill();
			}
			
			button.useHandCursor = true;
			button.buttonMode = true;
			button.addEventListener(MouseEvent.CLICK, onToggleFullScreen);
			
			addChild(button);
			
			button.x = stage.stageWidth - button.width;
			button.y = stage.stageHeight - button.height;
			stage.addEventListener(Event.RESIZE, onResize);
		}
		
		protected function onResize(event:Event):void
		{
			trace('reconfig button x y', stage.stageWidth, stage.stageHeight);
			button.x = stage.stageWidth - button.width;
			button.y = stage.stageHeight - button.height;
		}
		
		public function onToggleFullScreen(e:Event=null):void {
			if (stage.displayState !== StageDisplayState.NORMAL) {
				stage.displayState = StageDisplayState.NORMAL;
			} else {
				stage.displayState = StageDisplayState.FULL_SCREEN;
			}
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
//			camera.far += 1;
//			camera.updateProjectionMatrix();
			cube.rotation.y += 0.01;
			sphere.rotation.y -= 0.01;
			
			// 让光照沿着y轴旋转
			angle += 1;
			light.position.x = 40 * MathUtil.cosd(angle);
			light.position.z = 40 * MathUtil.sind(angle);
			light.lookAt(new Vector3(0, 0, 0));
			
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