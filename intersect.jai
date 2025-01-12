IntersectHit :: struct {
    penetration_depth: float;
    contact_point: Vector3;
    contact_normal: Vector3;
}

//=====================
// intersect_segment_cylinder
//
// Using Section 5.3.7 of Real-Time Collision Detection by Christer Ericson
//---------------------
intersect_segment_cylinder :: (seg: Segment, cyl: Cylinder, $exclude_endcaps := false) -> bool, t: float {
    EPSILON :: 0.00001;
    t: float;

    d := cyl.p2 - cyl.p1;
    m := seg.p1 - cyl.p1;
    n := seg.p2 - seg.p1;

    md := dot(m, d);
    nd := dot(n, d);
    dd := dot(d, d);

    // Test if segment is fully outside either endcap of cylinder
    if md < 0.0 && md + nd < 0.0 {
        return false, -1; // Segment outside cyl.p1
    }
    if md > dd && md + nd > dd {
        return false, -1; // Segment outside cyl.p2
    }

    nn := dot(n, n);
    mn := dot(m, n);
    a := dd * nn - nd * nd;
    k := dot(m, m) - cyl.radius * cyl.radius;
    c := dd * k - md * md;

    if abs(a) < EPSILON {
        // Segment runs parallel to cylinder axis
        if (c > 0.0) return false, -1; // 'a', and thus the segment, lie outside cylinder
        // Now known that segment intersects cylinder; figure out how it intersects
        #if exclude_endcaps {
            // When excluding endcaps, parallel segments do not intersect the lateral surface
            return false, -1;
        } else {
            if (md < 0.0) t = -mn / nn; // Intersect segment against cyl.p1 endcap
            else if (md > dd) t = (nd - mn) / nn; // Intersect segment against cyl.p2 endcap
            else t = 0.0;
            return true, t;
        }
    }

    b := dd * mn - nd * md;
    discr := b * b - a * c;
    if (discr < 0.0) return false, -1; // No real roots; no intersection

    t = (-b - sqrt(discr)) / a;
    if (t < 0.0 || t > 1.0) return false, -1; // Intersection lies outside segment

    // Check if the intersection point lies outside the cylinder's height and intersects with endcaps
    if md + t * nd < 0.0 {
        // Intersection outside cylinder on cyl.p1 side
        if (nd <= 0.0) return false, -1; // Segment pointing away from endcap
        t = -md / nd;
        #if exclude_endcaps { return true, t; }
        // Keep intersection if Dot(S(t) - p, S(t) - p) <= r^2
        return k + 2 * t * (mn + t * nn) <= 0.0, t;
    } else if md + t * nd > dd {
        // Intersection outside cylinder on cyl.p2 side
        if (nd >= 0.0) return false, -1; // Segment pointing away from endcap
        t = (dd - md) / nd;
        #if exclude_endcaps { return true, t; }
        // Keep intersection if Dot(S(t) - q, S(t) - q) <= r^2
        return k + dd - 2 * md + t * (2 * (mn - nd) + t * nn) <= 0.0, t;
    }

    // Segment intersects cylinder between the endcaps; t is correct
    return true, t;
} @Tested

//=====================
// intersect_segment_sphere
//
// Using Section 5.3.2 of Real-Time Collision Detection by Christer Ericson
// This re-uses raycast_sphere, constructing a Ray based on the origin of p1 and direction from p1 to p2 on the Segment.
//---------------------
intersect_segment_sphere :: (seg: Segment, s: Sphere, spos: Vector3, $exclude_endcaps := false) -> bool, t: float {
    dist := distance(seg.p1, seg.p2);
    dir := (seg.p2-seg.p1)/dist;
    ray := Ray.{seg.p1, dir};

    has_hit, hit := raycast_sphere(ray, s, spos);

    // Ensure the detected intersection does not lie beyond the end of the segment.
    if hit.t <= dist {
        return has_hit, hit.t;
    } else {
        return false, -1;
    }
}

//=====================
// Capsule-Heightfield
// Heightfield-Capsule
//---------------------
intersect :: (a: Capsule, b: Heightfield) -> bool, IntersectHit #symmetric {
    // 1. Compute bounding box of capsule
    // 2. Determine which cells in the heightfield to check
    // 3. Split each cell into 2 triangles
    // 4. Do Capsule-Triangle collision for each cell triangle
    // 5. Accumulate results
}


//=====================
// AnyShape-AnyShape
//
// Dispatches an intersection test between any two shapes of unknown type at runtime.
//---------------------
intersect :: (a: AnyShape, b: AnyShape) -> bool, IntersectHit #expand {
    if a.variant == {
        case .SEGMENT;     has_hit, hit := intersect(a.segment,     b); return has_hit, hit;
        case .CYLINDER;    has_hit, hit := intersect(a.cylinder,    b); return has_hit, hit;
        case .TRIANGLE;    has_hit, hit := intersect(a.triangle,    b); return has_hit, hit;
        case .PLANE;       has_hit, hit := intersect(a.plane,       b); return has_hit, hit;
        case .BOX;         has_hit, hit := intersect(a.box,         b); return has_hit, hit;
        case .SPHERE;      has_hit, hit := intersect(a.sphere,      b); return has_hit, hit;
        case .CAPSULE;     has_hit, hit := intersect(a.capsule,     b); return has_hit, hit;
    }
}

//=====================
// Segment-AnyShape
// AnyShape-Segment
//---------------------
intersect :: (a: Segment, b: AnyShape) -> bool, IntersectHit #symmetric #expand {
    if b.variant == {
        case; assert(false, "Unimplemented intersect: Segment-%", b.variant);
    }
}

//=====================
// Triangle-AnyShape
// AnyShape-Triangle
//---------------------
intersect :: (a: Triangle, b: AnyShape) -> bool, IntersectHit #symmetric #expand {
    if b.variant == {
        case; assert(false, "Unimplemented intersect: Triangle-%", b.variant);
    }
}

//=====================
// Plane-AnyShape
// AnyShape-Plane
//---------------------
intersect :: (a: Plane, b: AnyShape) -> bool, IntersectHit #symmetric #expand {
    if b.variant == {
        case; assert(false, "Unimplemented intersect: Plane-%", b.variant);
    }
}

//=====================
// Box-AnyShape
// AnyShape-Box
//---------------------
intersect :: (a: Box, b: AnyShape) -> bool, IntersectHit #symmetric #expand {
    if b.variant == {
        case; assert(false, "Unimplemented intersect: Box-%", b.variant);
    }
}

//=====================
// Sphere-AnyShape
// AnyShape-Sphere
//---------------------
intersect :: (a: Sphere, b: AnyShape) -> bool, IntersectHit #symmetric #expand {
    if b.variant == {
        case; assert(false, "Unimplemented intersect: Sphere-%", b.variant);
    }
}

//=====================
// Capsule-AnyShape
// AnyShape-Capsule
//---------------------
intersect :: (a: Capsule, b: AnyShape) -> bool, IntersectHit #symmetric #expand {
    if b.variant == {
        case; assert(false, "Unimplemented intersect: Capsule-%", b.variant);
    }
}
