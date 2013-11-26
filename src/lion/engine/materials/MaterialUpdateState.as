package lion.engine.materials
{
	import flash.display3D.Context3D;
	import flash.geom.Matrix3D;
	
	import lion.engine.lights.Light;
	import lion.engine.math.Vector3;
	import lion.engine.renderer.base.RenderableElement;
	import lion.engine.textures.BaseTexture;

	public class MaterialUpdateState
	{
		public var context:Context3D;
		public var numDirectionalLights:int;
		public var numPointLights:int;
		public var lights:Vector.<Light>;
		
		public var normalMatrix:Matrix3D;
		public var matrix:Matrix3D;
		public var viewProjectionMatrix:Matrix3D;
		public var cameraPosition:Vector3;
		public var renderElement:RenderableElement;
		public var depthViewProjectionMatrix:Matrix3D;
		public var depthTexture:BaseTexture;
		
		public function MaterialUpdateState()
		{
		}
		
		public function reset():void {
			numDirectionalLights = 0;
			numPointLights = 0;
			lights = null;
		}
	}
}