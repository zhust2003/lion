package lion.engine.renderer
{
	import com.adobe.utils.AGALMiniAssembler;
	import com.adobe.utils.PerspectiveMatrix3D;
	
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	import lion.engine.cameras.Camera;
	import lion.engine.core.Scene;
	
	public class Stage3DRenderer implements IRenderer
	{
		private var stage:Stage;
		private var stage3D:Stage3D;
		private var context:Context3D;
		
		
		public const zNear:Number = 1;
		public const zFar:Number = 500;
		
		public const fov:Number = 45;
		
		private var indexList:IndexBuffer3D;
		private var vertexes:VertexBuffer3D;
		
		private var projection:PerspectiveMatrix3D = new PerspectiveMatrix3D();
		private var model:Matrix3D = new Matrix3D();
		private var view:Matrix3D = new Matrix3D();
		private var finalTransform:Matrix3D = new Matrix3D();
		
		//For rotating the cube
		private const pivot:Vector3D = new Vector3D();
		
		private const VERTEX_SHADER:String =
			"m44 op, va0, vc0    \n" +    // 4x4 matrix transform 
			"mov v0, va1"; //copy color to varying variable v0
		
		private const FRAGMENT_SHADER:String = 
			"mov oc, v0"; //Set the output color to the value interpolated from the three triangle vertices 
		
		private var vertexAssembly:AGALMiniAssembler = new AGALMiniAssembler();
		private var fragmentAssembly:AGALMiniAssembler = new AGALMiniAssembler();
		private var programPair:Program3D;
		
		public function Stage3DRenderer(stage:Stage, renderMode:String="auto", profile:String="baselineConstrained")
		{
			this.stage = stage;
			trace('stage3D length:', this.stage.stage3Ds.length);
			
			if (this.stage.stage3Ds.length > 0) {
				this.stage3D = this.stage.stage3Ds[0];
				stage3D.addEventListener(Event.CONTEXT3D_CREATE, onCreate);
				stage3D.addEventListener(ErrorEvent.ERROR, onError);
				
				var requestContext3D:Function = stage3D.requestContext3D;
				if (requestContext3D.length == 1) requestContext3D(renderMode);
				else requestContext3D(renderMode, profile);
				
				
				//Compile shaders
				// 两个可编程管线，顶点着色器跟像素着色器
				vertexAssembly.assemble(Context3DProgramType.VERTEX, VERTEX_SHADER, false);
				fragmentAssembly.assemble(Context3DProgramType.FRAGMENT, FRAGMENT_SHADER, false);  
			}
		}
		
		protected function onError(event:ErrorEvent):void
		{
			if (event.errorID == 3702)
				trace("This application is not correctly embedded (wrong wmode value)");
			else
				trace("Stage3D error: " + event.text);
		}
		
		protected function onCreate(event:Event):void
		{
			init();
		}
		
		protected function init():void {
			context = stage3D.context3D;
			context.enableErrorChecking = true;
			trace("Display Driver:", context.driverInfo);
			
			setupScene();
		}
		
		private function setupScene():void
		{
			context.enableErrorChecking = true; //Can slow rendering - only turn on when developing/testing
			context.configureBackBuffer(stage.stageWidth, stage.stageHeight, 2, false);
			context.setCulling(Context3DTriangleFace.BACK);
			
			//Create vertex index list for the triangles forming a cube
			var triangles:Vector.<uint> = Vector.<uint>( [ 
				2,1,0, //front face
				3,2,0,
				4,7,5, //bottom face
				7,6,5,
				8,11,9, //back face
				9,11,10,
				12,15,13, //top face
				13,15,14,
				16,19,17, //left face
				17,19,18,
				20,23,21, //right face
				21,23,22
			] );
			// 索引数组
			indexList = context.createIndexBuffer(triangles.length);
			indexList.uploadFromVector(triangles, 0, triangles.length);
			
			//Create vertexes - cube faces do not share vertexes
			const dataPerVertex:int = 6;
			var vertexData:Vector.<Number> = Vector.<Number>(
				[
					// x,y,z r,g,b format
					0,0,0, 1,0,0, //front face
					0,1,0, 1,0,0,
					1,1,0, 1,0,0,
					1,0,0, 1,0,0,
					
					0,0,0, 0,1,0, //bottom face
					1,0,0, 0,1,0,
					1,0,1, 0,1,0,
					0,0,1, 0,1,0,
					
					0,0,1, 1,0,0, //back face
					1,0,1, 1,0,0,
					1,1,1, 1,0,0,
					0,1,1, 1,0,0,
					
					0,1,1, 0,1,0, //top face
					1,1,1, 0,1,0,
					1,1,0, 0,1,0,
					0,1,0, 0,1,0,
					
					0,1,1, 0,0,1, //left face
					0,1,0, 0,0,1,
					0,0,0, 0,0,1,
					0,0,1, 0,0,1,
					
					1,1,0, 0,0,1, //right face
					1,1,1, 0,0,1,
					1,0,1, 0,0,1,
					1,0,0, 0,0,1
				]
			);
			// 顶点数组
			vertexes = context.createVertexBuffer(vertexData.length/dataPerVertex, dataPerVertex);
			vertexes.uploadFromVector(vertexData, 0, vertexData.length/dataPerVertex);
			
			//Identify vertex data inputs for vertex program
			context.setVertexBufferAt(0, vertexes, 0, Context3DVertexBufferFormat.FLOAT_3); //va0 is position
			context.setVertexBufferAt(1, vertexes, 3, Context3DVertexBufferFormat.FLOAT_3); //va1 is color
			
			//Upload programs to render context
			programPair = context.createProgram();
			programPair.upload(vertexAssembly.agalcode, fragmentAssembly.agalcode);
			context.setProgram(programPair);
			
			//Set up 3D transforms
			projection.perspectiveFieldOfViewRH(fov, stage.stageWidth/stage.stageHeight, zNear, zFar);            
			view.appendTranslation(0, 0, -2);    //Move view back
			model.appendTranslation(-.5, -.5, -.5); //center cube on origin
		}
		
		public function render(scene:Scene, camera:Camera, viewport:Rectangle):void
		{
			//Rotate model on each frame
			model.appendRotation(.5, Vector3D.Z_AXIS, pivot);
			model.appendRotation(.5, Vector3D.Y_AXIS, pivot);
			model.appendRotation(.5, Vector3D.X_AXIS, pivot);
			
			//Combine transforms
			finalTransform.identity();
			finalTransform.append(model);
			finalTransform.append(view);
			finalTransform.append(projection);
			
			//Pass the final transform to the vertex shader as program constant, vc0
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, finalTransform, true);
			
			//Clear is required before drawTriangles on each frame
//			context.clear(.3,.3,.3);
			context.clear(0, 0, 0);
			
			//Draw the 12 triangles that make up the cube
			context.drawTriangles(indexList, 0, 12);
			
			//Show the frame
			context.present();
		}
	}
}