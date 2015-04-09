using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using Random = UnityEngine.Random;

public static class MathUtil
{
    private static float MyEpsilon = 0.00001f;
    private const float AngleDegEpisilon = 0.001f;
    private const float LineTouchesEpsilon = 0.01f;
    private const float LineTouchesEpsilonSq = LineTouchesEpsilon * LineTouchesEpsilon;

    public const double EPSILON = 0.0001f;

    public static Vector2 GetEllipseVector2FromAngle(float angle, float a, float b)
    {
        // See: http://stackoverflow.com/questions/11309596/how-to-get-a-point-on-an-ellipses-outline-given-an-angle

        var c = Mathf.Cos(angle);
        var s = Mathf.Sin(angle);
        var ta = s / c;
        var tt = ta * a / b;
        var d = 1.0f / Mathf.Sqrt(1f + tt * tt);
        var x = CopySign(a * d, c);
        var y = CopySign(b * tt * d, s);

        return new Vector2(x, y);
    }

    // Return copySignTo with the sign of copySignFrom
    public static float CopySign(float copySignTo, float copySignFrom)
    {
        return Mathf.Abs(copySignTo) * Mathf.Sign(copySignFrom);
    }

    public static bool IsPointBoundedByEllipse(float pointX, float pointY, float ellipseX, float ellipseY, float a, float b)
    {
        // See: http://math.stackexchange.com/questions/76457/check-if-a-point-is-within-an-ellipse

        float dx = pointX - ellipseX;
        float dy = pointY - ellipseY;
        float v = (dx * dx) / (a * a) + (dy * dy) / (b * b);

        return v <= 1;
    }

    public static Vector3 ClosestPointOnLine(Vector3 vA, Vector3 vB, Vector3 vPoint)
    {
        // See: http://forum.unity3d.com/threads/8114-math-problem?p=59715&viewfull=1#post59715

        var vVector1 = vPoint - vA;
        var vVector2 = (vB - vA).normalized;
     
        var d = Vector3.Distance(vA, vB);
        var t = Vector3.Dot(vVector2, vVector1);
     
        if (t <= 0)
            return vA;
     
        if (t >= d)
            return vB;
     
        var vVector3 = vVector2 * t;
     
        var vClosestPoint = vA + vVector3;

        return vClosestPoint;
    }

	// See: http://www.blackpawn.com/texts/pointinpoly/default.html
	public static bool TriangleContainsOrTouches(Vector2 p1, Vector2 p2, Vector2 p3, Vector2 pos) {
		// Compute vectors
		var v0x = p3.x - p1.x;
		var v0y = p3.y - p1.y;
		var v1x = p2.x - p1.x;
		var v1y = p2.y - p1.y;
		var v2x = pos.x - p1.x;
		var v2y = pos.y - p1.y;

		// Compute dot products
		var dot00 = v0x * v0x + v0y * v0y;
		var dot01 = v0x * v1x + v0y * v1y;
		var dot02 = v0x * v2x + v0y * v2y;
		var dot11 = v1x * v1x + v1y * v1y;
		var dot12 = v1x * v2x + v1y * v2y;
		
		// Compute barycentric coordinates
		var invDenom = 1 / (dot00 * dot11 - dot01 * dot01);
		var u = (dot11 * dot02 - dot01 * dot12) * invDenom;
		var v = (dot00 * dot12 - dot01 * dot02) * invDenom;

		// Check if point is in triangle
		var triangleContains = (u > 0) && (v > 0) && (u + v < 1);

		if (triangleContains) {
			// So it is in the triangle? Well, check if the triangle actually IS a triangle,
			// and not just 3 points on a line, because that would return a false positive sometimes... 
			if (PtLineDist(p1, p2, p3) > LineTouchesEpsilon) {
				return true;
			}
		}
		
		if (PtSegDistSq(p1, p2, pos) <= LineTouchesEpsilonSq)
			return true;

		if (PtSegDistSq(p2, p3, pos) <= LineTouchesEpsilonSq)
			return true;

		if (PtSegDistSq(p3, p1, pos) <= LineTouchesEpsilonSq)
			return true;

		return false;
	}

    public static float PtLineDist(Vector2 l1, Vector2 l2, Vector3 point)
    {
        // given a line based on two points, and a point away from the line,
        // find the perpendicular distance from the point to the line.
        // see http://mathworld.wolfram.com/Point-LineDistance2-Dimensional.html
        // for explanation and defination.

        return Mathf.Abs((l2.x - l1.x) * (l1.y - point.y) - (l1.x - point.x) * (l2.y - l1.y)) /
               Mathf.Sqrt(Mathf.Pow(l2.x - l1.x, 2) + Mathf.Pow(l2.y - l1.y, 2));
    }

    public static float DistanceSq(Vector2 a, Vector2 b)
    {
        var dx = a.x - b.x;
        var dy = a.y - b.y;
        return dx * dx + dy * dy;
    }

    // Source: http://stackoverflow.com/questions/849211/shortest-distance-between-a-point-and-a-line-segment
    private static float PtSegDistSq(Vector2 v, Vector2 w, Vector2 p)
    {
        var l2 = DistanceSq(v, w);
        if (l2 == 0)
            return DistanceSq(p, v);

        var t = ((p.x - v.x) * (w.x - v.x) + (p.y - v.y) * (w.y - v.y)) / l2;
        if (t < 0)
            return DistanceSq(p, v);

        if (t > 1)
            return DistanceSq(p, w);

        return DistanceSq(p, new Vector2(v.x + t * (w.x - v.x),
                                         v.y + t * (w.y - v.y)));
    }

    public static float PtSegDist(Vector2 v, Vector2 w, Vector2 p)
    {
        return Mathf.Sqrt(PtSegDistSq(v, w, p));
    }

    // Following is a corrected version of http://stackoverflow.com/questions/2255842/detecting-coincident-subset-of-two-coincident-line-segments

    private static float[] OverlapIntervals(float ub1, float ub2)
    {
        float l = Math.Min(ub1, ub2);
        float r = Math.Max(ub1, ub2);
        float A = Math.Max(0, l);
        float B = Math.Min(1, r);
        if (A > B) // no intersection
            return new float[] { };
        else if (A == B)
            return new float[] { A };
        else // if (A < B)
            return new float[] { A, B };
    }

    // IMPORTANT: a1 and a2 cannot be the same, e.g. a1--a2 is a true segment, not a point
    // b1/b2 may be the same (b1--b2 is a point)
    private static Vector2[] OneDIntersection(Vector2 a1, Vector2 a2, Vector2 b1, Vector2 b2)
    {
        //float ua1 = 0.0f; // by definition
        //float ua2 = 1.0f; // by definition
        float ub1, ub2;

        float denomx = a2.x - a1.x;
        float denomy = a2.y - a1.y;

        if (Math.Abs(denomx) > Math.Abs(denomy))
        {
            ub1 = (b1.x - a1.x) / denomx;
            ub2 = (b2.x - a1.x) / denomx;
        }
        else
        {
            ub1 = (b1.y - a1.y) / denomy;
            ub2 = (b2.y - a1.y) / denomy;
        }

        List<Vector2> ret = new List<Vector2>();
        float[] interval = OverlapIntervals(ub1, ub2);
        foreach (float f in interval)
        {
            float x = a2.x * f + a1.x * (1.0f - f);
            float y = a2.y * f + a1.y * (1.0f - f);
            Vector2 p = new Vector2(x, y);
            ret.Add(p);
        }
        return ret.ToArray();
    }

    private static bool PointOnLine(Vector2 p, Vector2 a1, Vector2 a2)
    {
        double d = PtSegDistSq(a1, a2, p);
        return d < MyEpsilon;
    }

    public static Vector2? GetLineSegLineSegIntersection(Vector2 a1, Vector2 a2, Vector2 b1, Vector2 b2)
    {
        var result = GetLineSegLineSegIntersectionInterval(a1, a2, b1, b2);
        if (result.Length == 0)
            return null;

        if (result.Length == 1)
            return result[0];

        return (result[0] + result[1]) / 2f;
    }

    public static bool PointEqualEpsilon(this Vector2 a, Vector2 b)
    {
        if (a.Equals(b))
            return true;

        var distance = Vector3.Distance(a, b);
        return (distance <= MyEpsilon);
    }

    // this is the general case. Really really general
    public static Vector2[] GetLineSegLineSegIntersectionInterval(Vector2 a1, Vector2 a2, Vector2 b1, Vector2 b2)
    {
        // PointEqualsEpsilon is needed, or this for example falsely returns true:
        // MathUtil.CheckLineSegLineSegIntersection(new Vector2(-7.642176f, -3.406708f), new Vector2(-7.642176f, -3.406707f), new Vector2(0f, -3f), new Vector2(1f, -4f)));

        if (a1.PointEqualEpsilon(a2) && b1.PointEqualEpsilon(b2))
        {
            // both "segments" are points, return either point
            if (a1.PointEqualEpsilon(b1))
                return new Vector2[] { a1 };
            else // both "segments" are different points, return empty set
                return new Vector2[] { };
        }
        else if (b1.PointEqualEpsilon(b2)) // b is a point, a is a segment
        {
            if (PointOnLine(b1, a1, a2))
                return new Vector2[] { b1 };
            else
                return new Vector2[] { };
        }
        else if (a1.PointEqualEpsilon(a2)) // a is a point, b is a segment
        {
            if (PointOnLine(a1, b1, b2))
                return new Vector2[] { a1 };
            else
                return new Vector2[] { };
        }

        // at this point we know both a and b are actual segments

        float ua_t = (b2.x - b1.x) * (a1.y - b1.y) - (b2.y - b1.y) * (a1.x - b1.x);
        float ub_t = (a2.x - a1.x) * (a1.y - b1.y) - (a2.y - a1.y) * (a1.x - b1.x);
        float u_b = (b2.y - b1.y) * (a2.x - a1.x) - (b2.x - b1.x) * (a2.y - a1.y);

        // Infinite lines intersect somewhere
        if (!(-MyEpsilon < u_b && u_b < MyEpsilon))   // e.g. u_b != 0.0
        {
            float ua = ua_t / u_b;
            float ub = ub_t / u_b;
            if (0.0f <= ua && ua <= 1.0f && 0.0f <= ub && ub <= 1.0f)
            {
                // Intersection
                return new Vector2[] {
                    new Vector2(a1.x + ua * (a2.x - a1.x),
                        a1.y + ua * (a2.y - a1.y)) };
            }
            else
            {
                // No Intersection
                return new Vector2[] { };
            }
        }
        else // lines (not just segments) are parallel or the same line
        {
            // Coincident
            // find the common overlapping section of the lines
            // first find the distance (squared) from one point (a1) to each point
            if ((-MyEpsilon < ua_t && ua_t < MyEpsilon)
               || (-MyEpsilon < ub_t && ub_t < MyEpsilon))
            {
                if (a1.Equals(a2)) // danger!
                    return OneDIntersection(b1, b2, a1, a2);
                else // safe
                    return OneDIntersection(a1, a2, b1, b2);
            }
            else
            {
                // Parallel
                return new Vector2[] { };
            }
        }
    }

    public static bool CheckLineSegLineSegIntersection(Vector2 point1, Vector2 point2, Vector2 point3, Vector2 point4)
    {
        return GetLineSegLineSegIntersectionInterval(point1, point2, point3, point4).Length > 0;
    }

    public static float Det(float a, float b, float c, float d) {
		return a * d - b * c;
	}

	public static bool PolygonContainsOrTouches(Vector2[] points, Vector2 pos)
	{
        if (PolygonContains(points, pos))
        {
            //Debug.Log("Polygon contains!");
            return true;
        }

	    if (points.Length < 3)
	        return false;

	    var previousPoint = points[points.Length - 1];
        for (int i = 0; i < points.Length; i++)
        {
            var currentPoint = points[i];
            if (PtSegDistSq(previousPoint, currentPoint, pos) <= LineTouchesEpsilonSq)
            {
                //Debug.Log(String.Format("PtSegDist ({0} to {1} for point {2} is {3}", previousPoint, currentPoint, pos, PtSegDist(previousPoint, currentPoint, pos)));
                return true;
            }

            previousPoint = currentPoint;
        }

	    return false;
	}

    public static bool CheckPolygonLineIntersection(Vector2[] points, Vector2 lineFrom, Vector2 lineTo)
    {
        var startPoint = points[points.Length - 1];
        foreach (var point in points)
        {
            if (CheckLineSegLineSegIntersection(startPoint, point, lineFrom, lineTo))
            {
                /*
                Debug.Log(String.Format("CheckLineIntersection: ({0}|{1}) - ({2}|{3}) / ({4}|{5}) - ({6}|{7})", startPoint.x, startPoint.y, point.x, point.y, lineFrom.x, lineFrom.y, lineTo.x, lineTo.y));
                if (PointOnLine(startPoint, lineFrom, lineTo))
                    Debug.Log("...and point on line.");
                if (startPoint.Equals(point))
                    Debug.Log("...and first two points equal");
                if (lineFrom.Equals(lineTo))
                    Debug.Log("...and latter two points equal");
                 */
                return true;
            }

            startPoint = point;
        }

        return false;
    }

    // See: http://www.exaflop.org/docs/cgafaq/cga2.html
    private static bool PolygonContains(Vector2[] points, Vector2 pos)
    {
        int crossings = 0;
        for (int i = 0, j = points.Length - 1; i < points.Length; j = i++)
        {
            if ((((points[i].y <= pos.y) && (pos.y < points[j].y)) || ((points[j].y <= pos.y) && (pos.y < points[i].y)))
                && (pos.x < (points[j].x - points[i].x) * (pos.y - points[i].y) / (points[j].y - points[i].y) + points[i].x))
            {

                crossings++;
            }
        }
        return (crossings % 2) != 0;
    }

    // See: http://csharphelper.com/blog/2014/09/determine-where-a-line-intersects-a-circle-in-c
    public static List<Vector2> CircleIntersections(Vector2 circleCenter, float radius, Vector2 lineFrom, Vector2 lineTo, bool lineSeg)
    {
        float dx, dy, A, B, C, det, t;

        dx = lineTo.x - lineFrom.x;
        dy = lineTo.y - lineFrom.y;

        A = dx * dx + dy * dy;
        B = 2 * (dx * (lineFrom.x - circleCenter.x) + dy * (lineFrom.y - circleCenter.y));
        C = (lineFrom.x - circleCenter.x) * (lineFrom.x - circleCenter.x) + (lineFrom.y - circleCenter.y) * (lineFrom.y - circleCenter.y) - radius * radius;

        det = B * B - 4 * A * C;
        if ((A <= 0.0000001) || (det < 0))
        {
            return null;
        }

        List<Vector2> list = new List<Vector2>();

        if (det == 0)
        {
            // One solution.
            t = -B / (2 * A);
            var point = new Vector2(lineFrom.x + t * dx, lineFrom.y + t * dy);
            if ((!lineSeg) || (PtSegDistSq(lineFrom, lineTo, point) <= LineTouchesEpsilonSq))
            {
                list.Add(point);
            }
        }
        else
        {
            // Two solutions.
            t = (float)((-B + Math.Sqrt(det)) / (2 * A));
            var point1 = new Vector2(lineFrom.x + t * dx, lineFrom.y + t * dy);
            if ((!lineSeg) || (PtSegDistSq(lineFrom, lineTo, point1) <= LineTouchesEpsilonSq))
            {
                list.Add(point1);
            }

            t = (float)((-B - Math.Sqrt(det)) / (2 * A));
            var point2 = new Vector2(lineFrom.x + t * dx, lineFrom.y + t * dy);
            if ((!lineSeg) || (PtSegDistSq(lineFrom, lineTo, point2) <= LineTouchesEpsilonSq))
            {
                list.Add(point2);
            }
        }

        if (list.Count == 0)
            return null;

        return list;
    }

    // See: http://csharphelper.com/blog/2014/09/determine-where-a-line-intersects-a-circle-in-c
    public static bool CheckCircleIntersection(Vector2 circleCenter, float radius, Vector2 lineFrom, Vector2 lineTo, bool lineSeg)
    {
        /*
        Debug.Log(String.Format("Debug.Log(MathUtil.CheckCircleIntersection(new Vector2({0}f, {1}f), {2}f, new Vector2({3}f, {4}f), new Vector2({5}f, {6}f), {7}));",
                                circleCenter.x, circleCenter.y, radius, lineFrom.x, lineFrom.y, lineTo.x, lineTo.y, lineSeg.ToString().ToLowerInvariant()));
         */

        float dx, dy, A, B, C, det, t;

        dx = lineTo.x - lineFrom.x;
        dy = lineTo.y - lineFrom.y;

        A = dx * dx + dy * dy;
        B = 2 * (dx * (lineFrom.x - circleCenter.x) + dy * (lineFrom.y - circleCenter.y));
        C = (lineFrom.x - circleCenter.x) * (lineFrom.x - circleCenter.x) + (lineFrom.y - circleCenter.y) * (lineFrom.y - circleCenter.y) - radius * radius;

        det = B * B - 4 * A * C;
        if ((A <= 0.0000001) || (det < 0))
        {
            return false;
        }

        if (det == 0)
        {
            // One solution.
            t = -B / (2 * A);
            var point = new Vector2(lineFrom.x + t * dx, lineFrom.y + t * dy);
            if ((!lineSeg) || (PtSegDistSq(lineFrom, lineTo, point) <= LineTouchesEpsilonSq))
            {
                return true;
            }
        }
        else
        {
            // Two solutions.
            t = (float)((-B + Math.Sqrt(det)) / (2 * A));
            var point1 = new Vector2(lineFrom.x + t * dx, lineFrom.y + t * dy);
            if ((!lineSeg) || (PtSegDistSq(lineFrom, lineTo, point1) <= LineTouchesEpsilonSq))
            {
                return true;
            }

            t = (float)((-B - Math.Sqrt(det)) / (2 * A));
            var point2 = new Vector2(lineFrom.x + t * dx, lineFrom.y + t * dy);
            if ((!lineSeg) || (PtSegDistSq(lineFrom, lineTo, point2) <= LineTouchesEpsilonSq))
            {
                return true;
            }
        }

        return false;
    }

    public static float[] GetAnglesOfProjectileTrajectory(Vector2 targetPosition, float speed)
    {
        // See: http://stackoverflow.com/questions/1972315/need-help-deciphering-a-formula-for-projectile-motion

        var x = targetPosition.x;
        var y = targetPosition.y;
        var gravity = -Physics.gravity.y;

        var tmp = Mathf.Pow(speed, 4) - gravity * (gravity * Mathf.Pow(x, 2) + 2 * y * Mathf.Pow(speed, 2));

        if (tmp < 0)
            return null;

        var angle1 = Mathf.Atan2(Mathf.Pow(speed, 2) + Mathf.Sqrt(tmp), gravity * x);
        var angle2 = Mathf.Atan2(Mathf.Pow(speed, 2) - Mathf.Sqrt(tmp), gravity * x);

        return new[] { angle1, angle2 };
    }

    public static bool IsEqualOrBetween(float value, float min, float max)
    {
        return (min <= value) && (value <= max);
    }

    public static float ClampOrCenterBetweenRanges(float value, float min, float max)
    {
        if (min >= max)
        {
            return (min + max) / 2f;
        }

        if (value < min)
        {
            return min;
        }

        if (value > max)
        {
            return max;
        }

        return value;
    }

    public static float LerpOverflow(float a, float b, float percent)
    {
        float delta = b - a;
        return a + delta * percent;
    }

    public static float GetCenterAngleDeg(float angle1, float angle2)
    {
        angle1 = NormalizeAngleDeg360(angle1);
        angle2 = NormalizeAngleDeg360(angle2);

        float center = (angle1 + angle2) / 2f;

        // If the delta is too big, take the other (nearer) center
        if (Mathf.Abs(angle1 - angle2) > 180)
            center -= 180;

        return center;
    }

    public static float NormalizeAngleDeg360(float angle)
    {
        while (angle < 0)
            angle += 360;

        if (angle > 360)
            angle %= 360;

        return angle;
    }

    public static float NormalizeAngleDeg180(float angle)
    {
        while (angle < -180)
            angle += 360;

        while (angle > 180)
            angle -= 360;

        return angle;
    }

    public static float Map(float sourceValue, float sourceFrom, float sourceTo, float targetFrom, float targetTo)
    {
        float sourceRange = sourceTo - sourceFrom;
        float targetRange = targetTo - targetFrom;

        float percent = Mathf.Clamp01((sourceValue - sourceFrom) / sourceRange);

        float targetValue = targetFrom + targetRange * percent;

        return targetValue;
    }

    public static float MapJoystick(float sourceValue, float sourceFrom, float sourceTo, float deadzone = 0f, bool fullRangeBetweenDeadzoneAndOne = false)
    {
        var percent = Map(sourceValue, sourceFrom, sourceTo, -1, 1);

        if (Mathf.Abs(percent) <= deadzone)
            return 0;

        if (fullRangeBetweenDeadzoneAndOne && (deadzone > 0f))
        {
            if (percent < 0)
            {
                return Map(percent, -1f, -deadzone, -1f, 0f);
            }
            else
            {
                return Map(percent, deadzone, 1f, 0f, 1f);
            }
        }

        return percent;
    }

    public static Vector2 RandomOnUnitCircle
    {
        get
        {
            var angle = Random.Range(0f, Mathf.PI * 2);
            return new Vector2(Mathf.Cos(angle), Mathf.Sin(angle));
        }
    }

    public static int RandomSign
    {
        get { return (Random.value < 0.5f) ? -1 : 1; }
    }

    public static Vector2[] GetCornerPoints(this Rect rect)
    {
        return new[]
                   {
                       new Vector2(rect.xMin, rect.yMin),
                       new Vector2(rect.xMax, rect.yMin),
                       new Vector2(rect.xMax, rect.yMax),
                       new Vector2(rect.xMin, rect.yMax)
                   };
    }

    public static Vector2 GetClosestPoint(this Rect rect, Vector2 point)
    {
        if (rect.Contains(point))
            return point;

        var cornerPoints = rect.GetCornerPoints();

        var closestPoint = new Vector2();
        var closestPointDistanceSqr = float.PositiveInfinity;
        
        var previousCornerPoint = cornerPoints[cornerPoints.Length - 1];
        for (int i = 0; i < cornerPoints.Length; i++)
        {
            var cornerPoint = cornerPoints[i];
            Vector2 currentClosestPoint = ClosestPointOnLine(previousCornerPoint, cornerPoint, point);
            var currentDistanceSqr = (currentClosestPoint - point).sqrMagnitude;
            if (currentDistanceSqr < closestPointDistanceSqr)
            {
                closestPoint = currentClosestPoint;
                closestPointDistanceSqr = currentDistanceSqr;
            }

            previousCornerPoint = cornerPoint;
        }

        return closestPoint;
    }

    public static bool IsSameAngle(float angle1, float angle2)
    {
        if (angle1 == angle2)
            return true;

        return Mathf.Abs(Mathf.DeltaAngle(angle1, angle2)) < AngleDegEpisilon;
    }
}
