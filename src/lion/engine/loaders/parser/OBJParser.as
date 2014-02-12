package lion.engine.loaders.parser
{
	import lion.engine.core.Surface;
	import lion.engine.geometries.Geometry;
	import lion.engine.math.Vector2;
	import lion.engine.math.Vector3;

	/**
	 * maya 
	 * @author Dalton
	 * 
	 */	
	public class OBJParser extends Parser
	{
		public var vertices:Vector.<Vector3>;
		public var geometry:Geometry;
		private var normals:Vector.<Vector3>;
		
		public function OBJParser()
		{
			super();
		}
		
		override public function get type():String {
			return 'obj';
		}
		
		override public function parse(data:*):void {
			var content:String = data as String;
			var lines:Array = content.split('\r\n');
			
			for each (var line:String in lines) {
				line = line.replace(/^ $/g, '');
				if (line.length <= 0) continue;
				parseLine(line);
			}
			
			dispatchEvent(new ParserEvent(ParserEvent.COMPLETE));
		}
		
		private function parseLine(line:String):void {
			var cmd:Array = line.split(/\s/);
			switch(cmd[0]) {
				case 'g': {
					parseGroup(cmd[1]);
					break;
				}
				// 顶点
				case 'v': {
					parseVertices(new Vector3(Number(cmd[1]), Number(cmd[2]), Number(cmd[3])));
					break;
				}
				// 顶点法线
				case 'vn': {
					parseNormals(new Vector3(Number(cmd[1]), Number(cmd[2]), Number(cmd[3])));
					break;
				}
				case 'f': {
					var v1:String = cmd[1];
					var v2:String = cmd[2];
					var v3:String = cmd[3];
					parseFace(v1, v2, v3);
				}
				default: {
					break;
				}
			}
		}
		
		// 1/4/7 顶点/纹理/法相索引
		private function parseFace(v1:String, v2:String, v3:String):void
		{
			var indexArray1:Array = v1.split('/');
			var indexArray2:Array = v2.split('/');
			var indexArray3:Array = v3.split('/');
			var face:Surface = new Surface(uint(indexArray1[0]) - 1, uint(indexArray2[0]) - 1, uint(indexArray3[0]) - 1);
			face.vertexNormals = [normals[uint(indexArray1[2]) - 1], normals[uint(indexArray2[2]) - 1], normals[uint(indexArray3[2]) - 1]];
			geometry.faces.push(face);
			geometry.faceVertexUvs.push(new <Vector2>[new Vector2(0, 0), 
													new Vector2(0, 0), 
													new Vector2(0, 0)]); 
		}
		
		private function parseVertices(v:Vector3):void
		{
			geometry.vertices.push(v);
		}
		
		private function parseNormals(v:Vector3):void
		{
			normals.push(v);
		}
		
		private function parseGroup(name:String):void
		{
			geometry = new Geometry();
			vertices = new Vector.<Vector3>();
			normals = new Vector.<Vector3>();
		}
	}
}