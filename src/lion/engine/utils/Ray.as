package lion.engine.utils
{
	import lion.engine.math.Box;
	import lion.engine.math.Plane;
	import lion.engine.math.Sphere;
	import lion.engine.math.Vector3;

	/**
	 * 光线 
	 * @author Dalton
	 * 
	 */	
	public class Ray
	{
		/**
		 * 起点 
		 */		
		private var _origin:Vector3;
		
		/**
		 * 朝向 
		 */		
		private var _direction:Vector3;
		
		public function Ray(origin:Vector3, direction:Vector3)
		{
			_origin = origin;
			_direction = direction;
		}
		
		/**
		 * 是否与盒子相交 
		 * @return 
		 * 
		 */		
		public function intersectBox(box:Box):Vector3 {
			// http://www.scratchapixel.com/lessons/3d-basic-lessons/lesson-7-intersecting-simple-shapes/ray-box-intersection/
			
			var tmin:Number,tmax:Number,tymin:Number,tymax:Number,tzmin:Number,tzmax:Number;
			var invdirx:Number = 1 / _direction.x,
				invdiry:Number = 1 / _direction.y,
				invdirz:Number = 1 / _direction.z;
			
			// 得到与x=min,x=max相交的t位置
			if (invdirx >= 0) {
				tmin = (box.min.x - _origin.x) * invdirx;
				tmax = (box.max.x - _origin.x) * invdirx;
			} else { 
				tmin = (box.max.x - _origin.x) * invdirx;
				tmax = (box.min.x - _origin.x) * invdirx;
			}	
			
			if (invdiry >= 0) {				
				tymin = (box.min.y - _origin.y) * invdiry;
				tymax = (box.max.y - _origin.y) * invdiry;
			} else {
				tymin = (box.max.y - _origin.y) * invdiry;
				tymax = (box.min.y - _origin.y) * invdiry;
			}
			
			// 如果先碰到了tymax，后碰到了tmin，则不相交
			// 如果先碰到了tmax，后碰到了tymin，则不相交
			if ((tmin > tymax) || (tymin > tmax)) return null;
			
			// These lines also handle the case where tmin or tmax is NaN
			// (result of 0 * Infinity). x !== x returns true if x is NaN
			
			if (tymin > tmin || isNaN(tmin)) tmin = tymin;
			
			if (tymax < tmax || isNaN(tmax)) tmax = tymax;
			
			if (invdirz >= 0) {				
				tzmin = (box.min.z - _origin.z) * invdirz;
				tzmax = (box.max.z - _origin.z) * invdirz;
			} else {
				tzmin = (box.max.z - _origin.z) * invdirz;
				tzmax = (box.min.z - _origin.z) * invdirz;
			}
			
			if ((tmin > tzmax) || (tzmin > tmax)) return null;
			
			if (tzmin > tmin || isNaN(tmin)) tmin = tzmin;
			
			if (tzmax < tmax || isNaN(tmax)) tmax = tzmax;
			
			// 如果最大的t在射线的反向，则相交点不可用，因为是射线后续延长线上的相交
			
			if (tmax < 0) return null;
			
			return this.at(tmin >= 0 ? tmin : tmax);
		}
		
		/**
		 * 经过t后的点位置 
		 * @param t
		 * @return 
		 * 
		 */		
		public function at(t:Number):Vector3 {
			var r:Vector3 = new Vector3();
			return r.copy(_direction).multiply(t).add(_origin);
		}
		
		/**
		 * 点到射线的最近距离 
		 * @param p
		 * @return 
		 * 
		 */		
		public function distanceToPoint(p:Vector3):Number {
			var final:Vector3 = p.clone();
			final.sub(_origin);
			var projection:Number = _direction.dot(final);
			
			// 如果是在反向，则应该是到射线初始点的距离
			if (projection < 0) {
				return p.dist(_origin);
			}
			
			var v:Vector3 = new Vector3();
			v.copy(_direction);
			// 如果不考虑射线反方向的点，则应该是点到射线的投影点的距离
			var dir:Vector3 = v.multiply(projection);
			final.sub(dir);
			
			return final.length;
		}
		
		/**
		 * 是否与球相交 
		 * @param s
		 * @return 
		 * 
		 */		
		public function isIntersectionSphere(s:Sphere):Boolean {
			return distanceToPoint(s.center) <= s.radius;
		}
		
		/**
		 * 是否与面相交 
		 * @param p
		 * @return 
		 * 
		 */		
		public function isIntersectionPlane(p:Plane):Boolean {
			// 如果射线端点在平面法向量同向，则法向量与射线方向点乘为负则相交
			// 如果射线端点在平面法向量反向，则法向量与射线方向点乘为正则相交
			
			var distToPoint:Number = p.distanceToPoint(_origin);
			// 如果端点在平面上，则返回相交
			if (distToPoint == 0) {
				return true;
			}
			
			var denominator:Number = p.normal.dot(_direction);
			
			if (denominator * distToPoint < 0) {
				return true;
			}
			return false;
		}
		
		/**
		 * 射线与三角形的交点 
		 * 因为所有模型基本单位都是三角形，所以这个可以最精确的运算出交点
		 * @param a
		 * @param b
		 * @param c
		 * @return 
		 * 
		 * 参考 http://www.cnblogs.com/graphics/archive/2010/08/09/1795348.html
		 */		
		public function intersectTriangle(v0:Vector3, v1:Vector3, v2:Vector3):Vector3 {
			var E1:Vector3 = new Vector3().subVectors(v1, v0);
			var E2:Vector3 = new Vector3().subVectors(v2, v0);
			var P:Vector3 = new Vector3().crossVectors(_direction, E2);
			var det:Number = E1.dot(P);
			var T:Vector3 = new Vector3();
			// keep det > 0, modify T accordingly
			if (det > 0) {
				T.subVectors(_origin, T);
			} else {
				T.subVectors(T, _origin);
				det = -det;
			}
			if (det < 0.0001) {
				return null;
			}
			var u:Number, v:Number, t:Number;
			// Calculate u and make sure u <= 1
			u = T.dot(P);
			if (u < 0.0 || u > det) {
				return null;
			}
			
			var Q:Vector3 = new Vector3().crossVectors(T, E1);
			v = _direction.dot(Q);
			if (v < 0.0 || u + v > det) {
				return null;
			}
			
			t = E2.dot(Q);
			var invDet:Number = 1.0 / det;
			t *= invDet;
			u *= invDet;
			v *= invDet;
			
			return at(t);
		}
	}
}