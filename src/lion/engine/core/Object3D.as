package lion.engine.core
{
	import flash.geom.Matrix3D;
	
	import lion.engine.math.Euler;
	import lion.engine.math.Matrix4;
	import lion.engine.math.Quaternion;
	import lion.engine.math.Vector3;

	/**
	 * 基本的三维物体类 
	 * 树形结构
	 * @author Dalton
	 * 
	 */	
	public class Object3D
	{
		public var parent:Object3D;
		public var children:Vector.<Object3D>;
		public var id:uint;
		public static var objectIDCount:uint = 0;
		private var name:String;
		public var position:Vector3;
		
		// 对外使用欧拉角
		// 对内通过四元数计算
		public var rotation:Euler;
		private var quaternion:Quaternion;
		private var matrix:Matrix4;
		public var matrixWorld:Matrix4;
		public var scale:Vector3;
		private var up:Vector3;
		public var visible:Boolean;
		
		public var userData:Object;
		
		// 阴影相关
		// 是否产生阴影
		public var castShadow:Boolean = false;
		// 是否接收阴影
		public var receiveShadow:Boolean = false;
		
		/**
		 * 坐标轴常量 
		 */		
		private static const X_AXIS:Vector3 = new Vector3(1, 0, 0);
		private static const Y_AXIS:Vector3 = new Vector3(0, 1, 0);
		private static const Z_AXIS:Vector3 = new Vector3(0, 0, 1);
		
		public function Object3D()
		{
			id = objectIDCount++;
			parent = null;
			children = new Vector.<Object3D>();
			name = '';
			position = new Vector3();
			scale = new Vector3(1, 1, 1);
			matrix = new Matrix4();
			matrixWorld = new Matrix4();
			up = new Vector3(0, 1, 0);
			quaternion = new Quaternion();
			rotation = new Euler();
			quaternion.euler = rotation;
			rotation.quaternion = quaternion;
			visible = true;
		}
		
		/**
		 * 沿着X轴旋转 
		 * @param angle
		 * @return 
		 * 
		 */		
		public function rotateX(angle:Number):Object3D {
			return rotateOnAxis(X_AXIS, angle);
		}
		
		/**
		 * 沿着Y轴旋转 
		 * @param angle
		 * @return 
		 * 
		 */		
		public function rotateY(angle:Number):Object3D {
			return rotateOnAxis(Y_AXIS, angle);
		}
		
		/**
		 * 沿着Z轴旋转 
		 * @param angle
		 * @return 
		 * 
		 */		
		public function rotateZ(angle:Number):Object3D {
			return rotateOnAxis(Z_AXIS, angle);
		}
		
		/**
		 * 沿着任意轴旋转 
		 * @param axis
		 * @param angle
		 * @return 
		 * 
		 */		
		public function rotateOnAxis(axis:Vector3, angle:Number):Object3D {
			var q:Quaternion = new Quaternion();
			q.setFromAxisAngle(axis, angle);
			quaternion.multiply(q);
			return this;
		}
		
		/**
		 * 朝向某个向量
		 * 主要用在摄像机 
		 * @param v
		 * 
		 */		
		public function lookAt(v:Vector3):void {
			var m:Matrix4 = new Matrix4();
			m.lookAt(this.position, v, this.up);
			
			quaternion.setFromRotationMatrix(m);
		}
		
		/**
		 * X平移 
		 * @param dist
		 * @return 
		 * 
		 */		
		public function translateX(dist:Number):Object3D {
			return translate(X_AXIS, dist);
		}
		
		/**
		 * Y平移 
		 * @param dist
		 * @return 
		 * 
		 */		
		public function translateY(dist:Number):Object3D {
			return translate(Y_AXIS, dist);
		}
		
		/**
		 * Z平移 
		 * @param dist
		 * @return 
		 * 
		 */		
		public function translateZ(dist:Number):Object3D {
			return translate(Z_AXIS, dist);
		}
		
		/**
		 * 沿着轴平移 
		 * @param axis
		 * @param dist
		 * @return 
		 * 
		 */		
		public function translate(axis:Vector3, dist:Number):Object3D {
			var v:Vector3 = new Vector3();
			v.copy(axis);
			this.position.add(v.multiply(dist));
			
			return this;
		}
		
		/**
		 * 增加子元素 
		 * @param o
		 * 
		 */		
		public function add(o:Object3D):void {
			if (o === this) {
				throw new Error("自己无法增加到自己的子对象中！");
				return;
			}
			
			if (o.parent) {
				o.parent.remove(o);
			}
			o.parent = this;
			children.push(o);
		}
		
		/**
		 * 移除子元素 
		 * @param o
		 * 
		 */		
		public function remove(o:Object3D):void {
			var index:int = this.children.indexOf(o);
			if (index !== -1) {
				o.parent = null;
				children.splice(index, 1);
			}
		}
		
		/**
		 * 按ID获取物体 
		 * @param id
		 * @param recursive
		 * @return 
		 * 
		 */		
		public function getObjectByID(id:uint, recursive:Boolean = false):Object3D {
			for each (var o:Object3D in children) {
				if (o.id === id) {
					return o;
				}
				if (recursive) {
					var child:Object3D = o.getObjectByID(id);
					if (child) {
						return child;
					}
				}
			}
			return null;
		}
		
		/**
		 * 按名称获取物体 
		 * @param name
		 * @param recursive
		 * @return 
		 * 
		 */		
		public function getObjectByName(name:String, recursive:Boolean = false):Object3D {
			for each (var o:Object3D in children) {
				if (o.name === name) {
					return o;
				}
				if (recursive) {
					var child:Object3D = o.getObjectByName(name);
					if (child) {
						return child;
					}
				}
			}
			return null;
		}
		
		/**
		 * 本地坐标到世界坐标转换 
		 * @param v
		 * @return 
		 * 
		 */		
		public function localToWorld(v:Vector3):Vector3 {
			return v.applyMatrix4(matrixWorld);
		}
		
		/**
		 * 世界坐标到本地坐标转换 
		 * @param v
		 * @return 
		 * 
		 */		
		public function worldToLocal(v:Vector3):Vector3 {
			var im:Matrix4 = new Matrix4();
			return v.applyMatrix4(im.getInverse(matrixWorld));
		}
		
		/**
		 * 更新自身矩阵，比如自身的旋转平移缩放等 
		 * 
		 */		
		public function updateMatrix():void {
			matrix.compose(position, quaternion, scale);
		}
		
		/**
		 * 更新世界矩阵 
		 * 
		 */		
		public function updateMatrixWorld():void {
			// 更新自身矩阵
			updateMatrix();
			
			// 乘以父矩阵
			if (parent) {
				matrixWorld.multiplyMatrices(this.parent.matrixWorld, this.matrix);
			} else {
				matrixWorld.copy(matrix);
			}
			
			// 更新所有子
			for each (var o:Object3D in children) {
				o.updateMatrixWorld();
			}
		}
	}
}