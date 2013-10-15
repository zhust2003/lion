package lion.engine.geometries
{
	import lion.engine.core.Surface;
	import lion.engine.math.Vector2;
	import lion.engine.math.Vector3;

	/**
	 * 球面 
	 * @author Dalton
	 * 
	 */	
	public class SphereGeometry extends Geometry
	{
		private var radius:Number;
		private var widthSegments:int;
		private var heightSegments:int;
		private var phiStart:Number;
		private var phiLength:Number;
		private var thetaStart:Number;
		private var thetaLength:Number;
		public function SphereGeometry(radius:Number = 50, 
									   widthSegments:int = 8, 
									   heightSegments:int = 6, 
									   phiStart:Number = 0, 
									   phiLength:Number = Math.PI * 2, 
									   thetaStart:Number = 0, 
									   thetaLength:Number = Math.PI)
		{
			super();
			
			this.radius = radius;
			this.widthSegments = widthSegments;
			this.heightSegments = heightSegments;
			this.phiStart = phiStart;
			this.phiLength = phiLength;
			this.thetaStart = thetaStart;
			this.thetaLength = thetaLength;
			
			var x:int, y:int, indices:Array = [], uvs:Array = [];
			
			// 增加顶点
			for (y = 0; y <= heightSegments; y++) {
				var indicesRow:Array = [];
				var uvsRow:Array = [];
				
				for (x = 0; x <= widthSegments; x++) {
					var u:Number = x / widthSegments;
					var v:Number = y / heightSegments;
					var vertex:Vector3 = new Vector3();
					vertex.x = - radius * Math.cos(phiStart + u * phiLength) * Math.sin(thetaStart + v * thetaLength);
					vertex.y = radius * Math.cos(thetaStart + v * thetaLength);
					vertex.z = radius * Math.sin(phiStart + u * phiLength) * Math.sin(thetaStart + v * thetaLength);
					
					vertices.push(vertex);
					indicesRow.push(this.vertices.length - 1);
					uvsRow.push( new Vector2(u, 1 - v));
				}
				
				indices.push(indicesRow);
				uvs.push(uvsRow);
			}
			
			
			// 增加面
			for ( y = 0; y < this.heightSegments; y ++ ) {
				
				for ( x = 0; x < this.widthSegments; x ++ ) {
					
					var v1:int = indices[y][x + 1];
					var v2:int = indices[y][x];
					var v3:int = indices[y + 1][x];
					var v4:int = indices[y + 1][x + 1];
					
					var n1:Vector3 = this.vertices[v1].clone().normalize();
					var n2:Vector3 = this.vertices[v2].clone().normalize();
					var n3:Vector3 = this.vertices[v3].clone().normalize();
					var n4:Vector3 = this.vertices[v4].clone().normalize();
					
					var uv1:Vector2 = uvs[y][x + 1].clone();
					var uv2:Vector2 = uvs[y][x].clone();
					var uv3:Vector2 = uvs[y + 1][x].clone();
					var uv4:Vector2 = uvs[y + 1][x + 1].clone();
					
					var f:Surface;
					
					// 顶部跟底部是三角形
					if (Math.abs(this.vertices[v1].y) === this.radius) {
						
						f = new Surface(v1, v3, v4);
						f.vertexNormals = [n1, n3, n4];
						f.normal = new Vector3().add(n1).add(n3).add(n4).divide(3);
						this.faces.push(f);
						this.faceVertexUvs.push([uv1, uv3, uv4]);
						
					} else if (Math.abs(this.vertices[v3].y) === this.radius) {
						
						f = new Surface(v1, v2, v3);
						f.vertexNormals = [n1, n2, n3];
						f.normal = new Vector3().add(n1).add(n2).add(n3).divide(3);
						this.faces.push(f);
						this.faceVertexUvs.push([uv1, uv2, uv3]);
						
					} else {
						
						// 这里就是四边形了
						f = new Surface(v1, v2, v4);
						f.vertexNormals = [n1, n2, n4];
						f.normal = new Vector3().add(n1).add(n2).add(n3).divide(3);
						this.faces.push(f);
						this.faceVertexUvs.push([uv1, uv2, uv4]);
						
						f = new Surface(v2, v3, v4);
						f.vertexNormals = [n2, n3, n4];
						f.normal = new Vector3().add(n2).add(n3).add(n4).divide(3);
						this.faces.push(f);
						this.faceVertexUvs.push([uv2, uv3, uv4]);
						
					}
				}
			}
			computeCentroids();
		}
	}
}