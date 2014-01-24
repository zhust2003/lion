package lion.engine.loaders.parser
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

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
		private var texCoords:Vector.<MD2TexCoords>;
		/**
		 * 纹理名
		 */		
		private var skins:Vector.<String>;
		
		public function MD2Parser()
		{
			super();
		}
		
		override public function parse(data:*):void {
			bytes = data as ByteArray;
			bytes.endian = Endian.LITTLE_ENDIAN;
			
			parseHeader();
			parseFrames();
			parseTriangles();
			parseUV();
			parseSkin();
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
			
			texCoords = new Vector.<MD2TexCoords>(header.numTexCoords);
			
			for (var i:int = 0; i < header.numTexCoords; ++i) {
				var t:MD2TexCoords = new MD2TexCoords();
				t.u = bytes.readUnsignedShort() / header.skinWidthPx;
				t.v = bytes.readUnsignedShort() / header.skinHeightPx;
				
				texCoords[i] = t;
			}
		}
		
		private function parseTriangles():void
		{
			bytes.position = header.offsetTriangles;
			
			triangles = new Vector.<MD2Triangle>(header.numTriangles);
			
			for (var i:int = 0; i < header.numTriangles; ++i) {
				var t:MD2Triangle = new MD2Triangle();
				t.textureIndices = new Vector.<uint>(3);
				t.textureIndices[0] = bytes.readUnsignedShort();
				t.textureIndices[1] = bytes.readUnsignedShort();
				t.textureIndices[2] = bytes.readUnsignedShort();
				
				t.vertexIndices = new Vector.<uint>(3);
				t.vertexIndices[0] = bytes.readUnsignedShort();
				t.vertexIndices[1] = bytes.readUnsignedShort();
				t.vertexIndices[2] = bytes.readUnsignedShort();
				
				triangles[i] = t;
			}
		}
		
		private function parseFrames():void
		{
			bytes.position = header.offsetFrames;
			
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
				for (var j:int = 0; j < header.numVertices; ++j) {
					var v:MD2Vertex = new MD2Vertex();
					v.x = bytes.readUnsignedByte() * f.scale[0] + f.trans[0];
					v.y = bytes.readUnsignedByte() * f.scale[1] + f.trans[1];
					v.z = bytes.readUnsignedByte() * f.scale[2] + f.trans[2];
					// 保留位
					bytes.readUnsignedByte();
					f.vertices[j] = v;
				}
				
				frames[i] = f;
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