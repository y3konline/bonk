SweepHit :: struct {
    t: float;
    point: Vector3;
    normal: Vector3;
}

//=====================
// sweep
//
// Sweeps any shape against any given shape, determined at runtime.
//---------------------
sweep :: (swept_shape: AnyShape, pose: Pose, dir: Vector3, distance: float, against_shape: AnyShape) -> bool, SweepHit #expand {
    if #complete swept_shape.variant == {
        case .LINE;        has_hit, hit := sweep_segment\      _shape(swept_shape.segment,     pose, dir, distance, against_shape); return has_hit, hit;
        case .TRIANGLE;    has_hit, hit := sweep_triangle\  _shape(swept_shape.triangle, pose, dir, distance, against_shape); return has_hit, hit;
        case .PLANE;       has_hit, hit := sweep_plane\     _shape(swept_shape.plane,    pose, dir, distance, against_shape); return has_hit, hit;
        case .BOX;         has_hit, hit := sweep_box\       _shape(swept_shape.box,      pose, dir, distance, against_shape); return has_hit, hit;
        case .SPHERE;      has_hit, hit := sweep_sphere\    _shape(swept_shape.sphere,   pose, dir, distance, against_shape); return has_hit, hit;
        case .CAPSULE;     has_hit, hit := sweep_capsule\   _shape(swept_shape.capsule,  pose, dir, distance, against_shape); return has_hit, hit;
        case .HEIGHTFIELD; assert(false, "Heightfields cannot be swept"); return false, .{};
    }
}

//=====================
// sweep_segment_shape
//---------------------
sweep_segment_shape :: (swept_segment: Segment, pose: Pose, dir: Vector3, distance: float, against_shape: AnyShape) -> bool, SweepHit #expand {
    if against_shape.variant == {
        // case .LINE;        has_hit, hit := sweep_segment_segment(swept_segment, b.segment);        return has_hit, hit;
        // case .TRIANGLE;    has_hit, hit := sweep_segment_triangle(swept_segment, b.triangle);    return has_hit, hit;
        // case .PLANE;       has_hit, hit := sweep_segment_plane(swept_segment, b.plane);       return has_hit, hit;
        // case .AABB;        has_hit, hit := sweep_segment_aabb(swept_segment, b.aabb);        return has_hit, hit;
        // case .OBB;         has_hit, hit := sweep_segment_obb(swept_segment, b.obb);         return has_hit, hit;
        // case .SPHERE;      has_hit, hit := sweep_segment_sphere(swept_segment, b.sphere);      return has_hit, hit;
        // case .CAPSULE;     has_hit, hit := sweep_segment_capsule(swept_segment, b.capsule);     return has_hit, hit;
        // case .HEIGHTFIELD; has_hit, hit := sweep_segment_heightfield(swept_segment, b.heightfield); return has_hit, hit;

        case; assert(false, "Unimplemented sweep: Segment-%", against_shape.variant);
    }
}

//=====================
// sweep_shape_segment
//---------------------
sweep_shape_segment :: (swept_shape: AnyShape, pose: Pose, dir: Vector3, distance: float, against_segment: Segment) -> bool, SweepHit #expand {
    if swept_shape.variant == {
        // case .LINE;        has_hit, hit := sweep_segment\      _segment(swept_shape.segment, against_segment); return has_hit, hit;
        // case .TRIANGLE;    has_hit, hit := sweep_triangle\  _segment(a.triangle,       against_segment); return has_hit, hit;
        // case .PLANE;       has_hit, hit := sweep_plane\     _segment(a.plane,          against_segment); return has_hit, hit;
        // case .AABB;        has_hit, hit := sweep_aabb\      _segment(a.aabb,           against_segment); return has_hit, hit;
        // case .OBB;         has_hit, hit := sweep_obb\       _segment(a.obb,            against_segment); return has_hit, hit;
        // case .SPHERE;      has_hit, hit := sweep_sphere\    _segment(a.sphere,         against_segment); return has_hit, hit;
        // case .CAPSULE;     has_hit, hit := sweep_capsule\   _segment(a.capsule,        against_segment); return has_hit, hit;
        // case .HEIGHTFIELD; has_hit, hit := sweep_heightfield_segment(a.heightfield,    against_segment); return has_hit, hit;

        case; assert(false, "Unimplemented sweep: %-Segment", swept_shape.variant);
    }
}

//=====================
// sweep_triangle_shape
//---------------------
sweep_triangle_shape :: (swept_triangle: Triangle, pose: Pose, dir: Vector3, distance: float, against_shape: AnyShape) -> bool, SweepHit #expand {
    if against_shape.variant == {
        case; assert(false, "Unimplemented sweep: Triangle-%", against_shape.variant);
    }
}

//=====================
// sweep_plane_shape
//---------------------
sweep_plane_shape :: (swept_plane: Plane, pose: Pose, dir: Vector3, distance: float, against_shape: AnyShape) -> bool, SweepHit #expand {
    if against_shape.variant == {
        case; assert(false, "Unimplemented sweep: Plane-%", against_shape.variant);
    }
}

//=====================
// sweep_box_shape
//---------------------
sweep_box_shape :: (swept_box: Box, pose: Pose, dir: Vector3, distance: float, against_shape: AnyShape) -> bool, SweepHit #expand {
    if against_shape.variant == {
        case; assert(false, "Unimplemented sweep: Box-%", against_shape.variant);
    }
}

//=====================
// sweep_sphere_shape
//---------------------
sweep_sphere_shape :: (swept_sphere: Sphere, pose: Pose, dir: Vector3, distance: float, shape: AnyShape) -> bool, SweepHit #expand {
    if shape.variant == {
        case .PLANE;
            has_hit, hit := sweep_sphere_plane(swept_sphere, pose, dir, distance, shape.plane);
            return has_hit, hit;
        case .TRIANGLE;
            has_hit, hit := sweep_sphere_triangle(swept_sphere, pose, dir, distance, shape.triangle);
            return has_hit, hit;
        case .HEIGHTFIELD;
            has_hit, hit := sweep_sphere_heightfield(swept_sphere, pose, dir, distance, shape.heightfield);
            return has_hit, hit;
        case; assert(false, "Unimplemented sweep: Sphere-%", against_shape.variant);
    }
}

//=====================
// sweep_sphere_plane
//
// Using section 5.5.3 of Real-Time Collision Detection by Christer Ericson.
//---------------------
sweep_sphere_plane :: (swept_sphere: Sphere, pose: Pose, dir: Vector3, distance: float, plane: Plane) -> bool, SweepHit #expand {
    result: SweepHit;
    result.t = 1.0;

    move := dir * distance;

    // Compute distance of sphere center to plane
    dist_to_plane := dot(plane.normal, pose.p);

    if abs(dist_to_plane) <= swept_sphere.radius {
        // The sphere is already overlapping the plane. Set time of intersection to zero and point to sphere center.
        result.t = 0.0;
        result.point = pose.p;
        return true, result;
    }

    denom := dot(plane.normal, move);
    if denom * dist_to_plane >= 0.0 {
        // No intersection as sphere moving parallel to or away from plane
        return false, .{};
    }
    // Sphere is moving towards the plane

    // Use +r in computations if sphere in front of plane, else -r
    r := ifx dist_to_plane > 0.0 then swept_sphere.radius else -swept_sphere.radius;
    result.t = (r - dist_to_plane) / denom;
    result.point = pose.p + result.t*move - r*plane.normal;
    return true, result;
}

//=====================
// sweep_sphere_triangle
//
// Using section 5.5.6 of Real-Time Collision Detection by Christer Ericson.
// 1. Check if the sphere intersects the triangle's plane
//   1a. If so, test if point of earliest contact (on the plane) is inside the triangle
//      1ai. If so, we found the earliest intersection already and can exit with this
// 2. Otherwise, sweep the sphere against each triangle edge.
//   2a. If at least one edge hit, return the edge with the lowest `t` value
// 3. Otherwise, do a raycast of the sphere's center against 3 spheres positioned on each of the triangle's 3 vertices.
//---------------------
sweep_sphere_triangle :: (swept_sphere: Sphere, pose: Pose, dir: Vector3, distance: float, tri: Triangle) -> bool, SweepHit #expand {
    // Check if the sphere intersects the triangle's plane
    tri_plane := Triangle.compute_plane(tri);
    has_hit_plane, hit_plane := sweep_sphere_plane(swept_sphere, pose, dir, distance, tri_plane);
    if has_hit_plane {
        // Test if hit point is inside the triangle
        if Triangle.contains_point(tri, hit_plane.point) {
            return true, hit_plane;
        }
    }

    seg := Segment.{pose.p, pose.p + dir*distance};

    // Sweep the sphere against each triangle edge
    // Do a intersect(Segment, Cylinder) to achieve this
    {
        edge_12 := Cylinder.{tri.p1, tri.p2, swept_sphere.radius};
        edge_23 := Cylinder.{tri.p2, tri.p3, swept_sphere.radius};
        edge_31 := Cylinder.{tri.p3, tri.p1, swept_sphere.radius};
        hit1, t1 := intersect_segment_cylinder(seg, edge_12, exclude_endcaps=true);
        hit2, t2 := intersect_segment_cylinder(seg, edge_23, exclude_endcaps=true);
        hit3, t3 := intersect_segment_cylinder(seg, edge_31, exclude_endcaps=true);
        if hit1 || hit2 || hit3 {
            t := FLOAT32_MAX;
            if hit1 then t = min(t, t1);
            if hit2 then t = min(t, t2);
            if hit3 then t = min(t, t3);
            return true, SweepHit.{t=t}; // @TODO point, normal?
        }
    }

    // Raycast the sphere's center against 3 spheres positioned on each of the triangle's 3 vertices
    {
        hit1, t1 := intersect_segment_sphere(seg, swept_sphere, tri.p1);
        hit2, t2 := intersect_segment_sphere(seg, swept_sphere, tri.p2);
        hit3, t3 := intersect_segment_sphere(seg, swept_sphere, tri.p3);
        if hit1 || hit2 || hit3 {
            t := FLOAT32_MAX;
            if hit1 then t = min(t, t1);
            if hit2 then t = min(t, t2);
            if hit3 then t = min(t, t3);
            return true, SweepHit.{t=t}; // @TODO point, normal?
        }
    }

    // No hit
    return false, .{};
}

//=====================
// sweep_capsule_heightfield
//---------------------
sweep_sphere_heightfield :: (swept_sphere: Sphere, pose: Pose, dir: Vector3, distance: float, hfield: *Heightfield) -> bool, SweepHit #expand {
    has_hit := false;
    result: SweepHit;
    result.t = 1.0;

    // Broad Phase: find relevant heightfield cells
    // Compute swept bounds
    end_pose := pose;
    end_pose.p += dir * distance;
    start_aabb := Sphere.compute_aabb(swept_sphere, pose);
    end_aabb   := Sphere.compute_aabb(swept_sphere, end_pose);
    swept_aabb := merge_aabb(start_aabb, end_aabb);

    // Narrow Phase: For each cell in the bounds, generate two triangles and do "sweep capsule vs. triangle".
    // We will keep the earliest collision (smallest t value).
    for cell : Heightfield.iter_region(hfield, swept_aabb) {
        tri_a, tri_b := Heightfield.triangulate_cell(cell);

        has_hit_a, hit_a := sweep_sphere_triangle(swept_sphere, pose, dir, distance, tri_a);
        has_hit_b, hit_b := sweep_sphere_triangle(swept_sphere, pose, dir, distance, tri_b);

        if has_hit_a && hit_a.t < result.t {
            has_hit = true;
            result = hit_a;
        }
        if has_hit_b && hit_b.t < result.t {
            has_hit = true;
            result = hit_b;
        }
    }

    return has_hit, result;
}

//=====================
// sweep_capsule_shape
//---------------------
sweep_capsule_shape :: (swept_capsule: Capsule, pose: Pose, dir: Vector3, distance: float, against_shape: AnyShape) -> bool, SweepHit #expand {
    if against_shape.variant == {
        case .TRIANGLE;
            has_hit, hit := sweep_capsule_triangle(swept_capsule, dir, distance, pose, against_shape.triangle);
            return has_hit, hit;
        case .HEIGHTFIELD;
            has_hit, hit := sweep_capsule_heightfield(swept_capsule, dir, distance, pose, against_shape.heightfield);
            return has_hit, hit;
        case;
            assert(false, "Unimplemented sweep: Capsule-%", against_shape.variant);
    }
}


//=====================
// sweep_capsule_triangle
//---------------------
sweep_capsule_triangle :: (swept_capsule: Capsule, pose: Pose, dir: Vector3, distance: float, against_triangle: Triangle) -> bool, SweepHit #expand {
    UNIMPLEMENTED();
}


//=====================
// sweep_capsule_heightfield
//---------------------
sweep_capsule_heightfield :: (swept_capsule: Capsule, pose: Pose, dir: Vector3, distance: float, hfield: *Heightfield) -> bool, SweepHit #expand {
    has_hit := false;
    result: SweepHit;
    result.t = 1.0;

    // Broad Phase: find relevant heightfield cells
    // Compute swept bounds
    end_pose := pose;
    end_pose.position += dir * distance;
    start_aabb := Capsule.compute_aabb(swept_capsule, pose);
    end_aabb   := Capsule.compute_aabb(swept_capsule, end_pose);
    swept_aabb := merge_aabb(start_aabb, end_aabb);

    // Find the heightfield cell indices that are within the swept bounds
    region := Heightfield.compute_region(hfield, swept_aabb);

    // Narrow Phase: For each cell in the bounds, generate two triangles and do "sweep capsule vs. triangle".
    // We will keep the earliest collision (smallest t value).
    for cell : Heightfield.iter_region(hfield, swept_aabb) {
        tri_a, tri_b := Heightfield.triangulate_cell(cell);

        has_hit_a, hit_a := sweep_capsule_triangle(swept_capsule, pose, dir, distance, tri_a);
        has_hit_b, hit_b := sweep_capsule_triangle(swept_capsule, pose, dir, distance, tri_b);

        if has_hit_a && hit_a.t < result.t {
            has_hit = true;
            result = hit_a;
        }
        if has_hit_b && hit_b.t < result.t {
            has_hit = true;
            result = hit_b;
        }
    }

    return has_hit, result;
}
