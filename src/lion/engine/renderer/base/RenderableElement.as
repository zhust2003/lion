package lion.engine.renderer.base
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	
	import lion.engine.core.Mesh;
	import lion.engine.core.Object3D;
	import lion.engine.materials.WireframeMaterial;
	import lion.engine.math.Matrix4;

	/**
	 * 渲染的基本元素 
	 * @author Dalton
	 * 
	 */
	public class RenderableElement {
		public var id:int;
		public var z:Number;
		public var model:Matrix4;
		public var indexList:Vector.<uint>;
		public var triangleCount:uint;
		public var object:Object3D;
		public var vertexList:Vector.<Number>;
		public var context:Context3D;
		
		private var indexes:IndexBuffer3D;
		private var vertexes:VertexBuffer3D;
		
		public function render():void {
			// 绘制三角形
			context.drawTriangles(indexes, 0, triangleCount);
		}
		
		public function initVertexBuffer():void {
			// 顶点数组
			var dataPerVertex:int = 8;
			if (Mesh(object).material is WireframeMaterial) {
				dataPerVertex = 11;
			}
			vertexes = context.createVertexBuffer(vertexList.length/dataPerVertex, dataPerVertex);
			vertexes.uploadFromVector(vertexList, 0, vertexList.length/dataPerVertex);
		}
		
		public function initIndexBuffer():void {
			// 索引数组
			indexes = context.createIndexBuffer(indexList.length);
			indexes.uploadFromVector(indexList, 0, indexList.length);
		}
		
		
		public function setPositionBuffer(index:uint = 0):void {
			context.setVertexBufferAt(0, vertexes, 0, Context3DVertexBufferFormat.FLOAT_3); // va0 is position
		}
		
		public function setUVBuffer(index:uint):void {
			context.setVertexBufferAt(index, vertexes, 3, Context3DVertexBufferFormat.FLOAT_2); // va1 is uv
		}
		
		public function setNormalBuffer(index:uint):void {
			context.setVertexBufferAt(index, vertexes, 5, Context3DVertexBufferFormat.FLOAT_3); // va2 is normal
		}
		
		public function setDistanceBuffer(index:uint):void {
			context.setVertexBufferAt(index, vertexes, 8, Context3DVertexBufferFormat.FLOAT_3); // va3 is dist
		}
		
		public function dispose():void {
			// 清理顶点数据
			vertexes.dispose();
			// 清理索引数据
			indexes.dispose();
		}
	}
}
