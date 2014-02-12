package lion.engine.loaders.parser
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	
	import lion.engine.animators.VertexAnimation;
	import lion.engine.animators.VertexAnimatorSet;
	import lion.engine.core.Surface;
	import lion.engine.geometries.Geometry;
	import lion.engine.materials.Material;
	import lion.engine.materials.WireframeMaterial;
	import lion.engine.math.Vector2;
	import lion.engine.math.Vector3;

	/**
	 * Quake2 顶点动画 
	 * @author Dalton
	 * 
	 */	
	public class MD2Parser extends Parser
	{
		/**
		 * 头结构 
		 */		
		private var header:MD2Header;
		
		private var bytes:ByteArray;
		/**
		 * 每一帧，对应多个顶点数据 
		 */		
		private var frames:Vector.<MD2Frame>;
		/**
		 * 所有三角形 坐标及纹理坐标，都是索引
		 */		
		private var triangles:Vector.<MD2Triangle>;
		/**
		 * 所有纹理UV坐标 
		 */		
		private var texCoords:Vector.<Vector2>;
		/**
		 * 纹理名
		 */		
		private var skins:Vector.<String>;
		
		/**
		 * 通过MD2创建的几何体 
		 */		
		public var geometry:Geometry;
		public var material:Material;
		private var skinLoader:Loader;
		
		public var animatorSet:VertexAnimatorSet;
		private var animations:Dictionary;
		private var prevClip:VertexAnimation;
		
		public function MD2Parser()
		{
			super();
		}
		
		override public function get type():String {
			return 'md2';
		}
		
		override public function parse(data:*):void {
			bytes = data as ByteArray;
			bytes.endian = Endian.LITTLE_ENDIAN;
			
			if (! parseHeader()) {
				return;
			}
			geometry = new Geometry();
			parseFrames();
			parseUV();
			parseTriangles();
			parseSkin();
			
			if (skins.length <= 0) {
				material = new WireframeMaterial();
			} else {
			}
			
			dispatchEvent(new ParserEvent(ParserEvent.COMPLETE));
		}
		
		private function parseSkin():void
		{
			bytes.position = header.offsetSkins;
			
			skins = new Vector.<String>(header.numSkins);
			for (var i:int = 0; i < header.numSkins; ++i) {
				var s:String = bytes.readUTFBytes(64);
				skins[i] = s;
			}
		}
		
		private function parseUV():void
		{
			bytes.position = header.offsetTexCoords;
			
			texCoords = new Vector.<Vector2>(header.numTexCoords);
			
			for (var i:int = 0; i < header.numTexCoords; ++i) {
				var t:Vector2 = new Vector2();
				t.x = bytes.readUnsignedShort() / header.skinWidthPx;
				t.y = bytes.readUnsignedShort() / header.skinHeightPx;
				
				texCoords[i] = t;
			}
		}
		
		private function parseTriangles():void
		{
			bytes.position = header.offsetTriangles;
			
			triangles = new Vector.<MD2Triangle>(header.numTriangles);
			
			// 为了计算法线
			var ab:Vector3 = new Vector3();
			var bc:Vector3 = new Vector3();
			var normal:Vector3 = new Vector3();
			
			var faces:Vector.<Surface> = new Vector.<Surface>();
			var faceVertexUvs:Vector.<Vector.<Vector2>> = new Vector.<Vector.<Vector2>>();
			
			for (var i:int = 0; i < header.numTriangles; ++i) {
				var t:MD2Triangle = new MD2Triangle();
				
				t.vertexIndices = new Vector.<uint>(3);
				t.vertexIndices[0] = bytes.readUnsignedShort();
				t.vertexIndices[1] = bytes.readUnsignedShort();
				t.vertexIndices[2] = bytes.readUnsignedShort();
				
				t.textureIndices = new Vector.<uint>(3);
				t.textureIndices[0] = bytes.readUnsignedShort();
				t.textureIndices[1] = bytes.readUnsignedShort();
				t.textureIndices[2] = bytes.readUnsignedShort();
				
				triangles[i] = t;
				
				// 逆时针建模
				var face:Surface = new Surface(t.vertexIndices[0], t.vertexIndices[1], t.vertexIndices[2]);
				face.normal = normal.crossVectors(bc.subVectors(geometry.vertices[face.c], geometry.vertices[face.b]),
												  ab.subVectors(geometry.vertices[face.b], geometry.vertices[face.a]));
				
				// 临时
				faces.push(face);
				faceVertexUvs.push(new <Vector2>[texCoords[t.textureIndices[0]], 
														  texCoords[t.textureIndices[1]], 
														  texCoords[t.textureIndices[2]]]); 
			}
			
			geometry.faces = faces;
			geometry.faceVertexUvs = faceVertexUvs;
			
			// 所有动画帧的多边形的面都需要设置
			for each (var animation:VertexAnimation in animatorSet.animations) {
				for each (var g:Geometry in animation.frames) {
					g.faces = faces;
					g.faceVertexUvs = faceVertexUvs;
				}
			}
		}
		
		private function parseFrames():void
		{
			bytes.position = header.offsetFrames;
			
			animatorSet = new VertexAnimatorSet();
			animations = new Dictionary(true);
			frames = new Vector.<MD2Frame>(header.numFrames);
			
			for (var i:int = 0; i < header.numFrames; ++i) {
				var f:MD2Frame = new MD2Frame();
				f.scale = new Vector.<Number>();
				f.scale[0] = bytes.readFloat();
				f.scale[1] = bytes.readFloat();
				f.scale[2] = bytes.readFloat();
				
				f.trans = new Vector.<Number>();
				f.trans[0] = bytes.readFloat();
				f.trans[1] = bytes.readFloat();
				f.trans[2] = bytes.readFloat();
				
				f.name = readFrameName();

				f.vertices = new Vector.<MD2Vertex>(header.numVertices);
				
				var g:Geometry = new Geometry();
				
				for (var j:int = 0; j < header.numVertices; ++j) {
					var v:MD2Vertex = new MD2Vertex();
					v.x = bytes.readUnsignedByte() * f.scale[0] + f.trans[0];
					v.y = bytes.readUnsignedByte() * f.scale[1] + f.trans[1];
					v.z = bytes.readUnsignedByte() * f.scale[2] + f.trans[2];
					// 保留位
					bytes.readUnsignedByte();
					f.vertices[j] = v;
					
					g.vertices.push(new Vector3(v.x, v.z, v.y));
					
					// 临时测试
					if (i == 0) {
						geometry.vertices.push(new Vector3(v.x, v.z, v.y));
					}
				}
				
				var clip:VertexAnimation = animations[f.name];
				
				// 如果是新的动画
				if (! clip) {
					if (prevClip) {
						animatorSet.addAnimation(prevClip);
					}
					
					clip = new VertexAnimation();
					clip.name = f.name;
					
					animations[f.name] = clip;
					
					prevClip = clip;
				}
				clip.addFrame(g, 1000 / 6);
				
				
				frames[i] = f;
			}
			
			// 增加最后一个动画
			if (prevClip) {
				animatorSet.addAnimation(prevClip);
			}
		}
		
		private function readFrameName():String
		{
			var name:String = "";
			var k:uint = 0;
			for (var j:uint = 0; j < 16; j++) {
				var ch:uint = bytes.readUnsignedByte();
				
				if (uint(ch) > 0x39 && uint(ch) <= 0x7A && k == 0)
					name += String.fromCharCode(ch);
				
				if (uint(ch) >= 0x30 && uint(ch) <= 0x39)
					k++;
			}
			return name;
		}
		
		private function parseHeader():Boolean {
			header = new MD2Header();
			header.magicNum = bytes.readInt();
			header.version = bytes.readInt();
			header.skinWidthPx = bytes.readInt();
			header.skinHeightPx = bytes.readInt();
			header.frameSize = bytes.readInt();
			header.numSkins = bytes.readInt();
			header.numVertices = bytes.readInt();
			header.numTexCoords = bytes.readInt();
			header.numTriangles = bytes.readInt();
			header.numGLCommands = bytes.readInt();
			header.numFrames = bytes.readInt();
			header.offsetSkins = bytes.readInt();
			header.offsetTexCoords = bytes.readInt();
			header.offsetTriangles = bytes.readInt();
			header.offsetFrames = bytes.readInt();
			header.offsetGlCommands = bytes.readInt();
			header.fileSize = bytes.readInt();
			
			if (header.magicNum != 844121161 || header.version != 8) {
				return false;
			}
			return true;
		}
	}
}

class MD2Header
{
	public var magicNum:int; //Always IDP2 (844121161)
	public var version:int;  //8
	public var skinWidthPx:int;  
	public var skinHeightPx:int; 
	public var frameSize:int; 
	public var numSkins:int; 
	public var numVertices:int; 
	public var numTexCoords:int; 
	public var numTriangles:int; 
	public var numGLCommands:int; 
	public var numFrames:int; 
	public var offsetSkins:int; 
	public var offsetTexCoords:int; 
	public var offsetTriangles:int; 
	public var offsetFrames:int; 
	public var offsetGlCommands:int; 
	public var fileSize:int; 
}

class MD2Triangle {
	public var vertexIndices:Vector.<uint>;
	public var textureIndices:Vector.<uint>;
}

class MD2TexCoords {
	public var u:Number;
	public var v:Number;
}
class MD2Vertex {
	public var x:Number;
	public var y:Number;
	public var z:Number;
}

class MD2Frame {
	public var scale:Vector.<Number>;
	public var trans:Vector.<Number>;
	public var name:String;
	
	public var vertices:Vector.<MD2Vertex>;
}