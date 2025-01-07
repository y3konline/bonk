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
        case .LINE;        has_hit, hit := sweep_line\      _shape(swept_shape.line,     pose, dir, distance, against_shape); return has_hit, hit;
        case .TRIANGLE;    has_hit, hit := sweep_triangle\  _shape(swept_shape.triangle, pose, dir, distance, against_shape); return has_hit, hit;
        case .PLANE;       has_hit, hit := sweep_plane\     _shape(swept_shape.plane,    pose, dir, distance, against_shape); return has_hit, hit;
        case .BOX;         has_hit, hit := sweep_box\       _shape(swept_shape.box,      pose, dir, distance, against_shape); return has_hit, hit;
        case .SPHERE;      has_hit, hit := sweep_sphere\    _shape(swept_shape.sphere,   pose, dir, distance, against_shape); return has_hit, hit;
        case .CAPSULE;     has_hit, hit := sweep_capsule\   _shape(swept_shape.capsule,  pose, dir, distance, against_shape); return has_hit, hit;
        case .HEIGHTFIELD; assert(false, "Heightfields cannot be swept"); return false, .{};
    }
}

//=====================
// sweep_line_shape
//---------------------
sweep_line_shape :: (swept_line: Line, pose: Pose, dir: Vector3, distance: float, against_shape: AnyShape) -> bool, SweepHit #expand {
    if against_shape.variant == {
        // case .LINE;        has_hit, hit := sweep_line_line(swept_line, b.line);        return has_hit, hit;
        // case .TRIANGLE;    has_hit, hit := sweep_line_triangle(swept_line, b.triangle);    return has_hit, hit;
        // case .PLANE;       has_hit, hit := sweep_line_plane(swept_line, b.plane);       return has_hit, hit;
        // case .AABB;        has_hit, hit := sweep_line_aabb(swept_line, b.aabb);        return has_hit, hit;
        // case .OBB;         has_hit, hit := sweep_line_obb(swept_line, b.obb);         return has_hit, hit;
        // case .SPHERE;      has_hit, hit := sweep_line_sphere(swept_line, b.sphere);      return has_hit, hit;
        // case .CAPSULE;     has_hit, hit := sweep_line_capsule(swept_line, b.capsule);     return has_hit, hit;
        // case .HEIGHTFIELD; has_hit, hit := sweep_line_heightfield(swept_line, b.heightfield); return has_hit, hit;

        case; assert(false, "Unimplemented sweep: Line-%", against_shape.variant);
    }
}

//=====================
// sweep_shape_line
//---------------------
sweep_shape_line :: (swept_shape: AnyShape, pose: Pose, dir: Vector3, distance: float, against_line: Line) -> bool, SweepHit #expand {
    if swept_shape.variant == {
        // case .LINE;        has_hit, hit := sweep_line\      _line(swept_shape.line, against_line); return has_hit, hit;
        // case .TRIANGLE;    has_hit, hit := sweep_triangle\  _line(a.triangle,       against_line); return has_hit, hit;
        // case .PLANE;       has_hit, hit := sweep_plane\     _line(a.plane,          against_line); return has_hit, hit;
        // case .AABB;        has_hit, hit := sweep_aabb\      _line(a.aabb,           against_line); return has_hit, hit;
        // case .OBB;         has_hit, hit := sweep_obb\       _line(a.obb,            against_line); return has_hit, hit;
        // case .SPHERE;      has_hit, hit := sweep_sphere\    _line(a.sphere,         against_line); return has_hit, hit;
        // case .CAPSULE;     has_hit, hit := sweep_capsule\   _line(a.capsule,        against_line); return has_hit, hit;
        // case .HEIGHTFIELD; has_hit, hit := sweep_heightfield_line(a.heightfield,    against_line); return has_hit, hit;

        case; assert(false, "Unimplemented sweep: %-Line", swept_shape.variant);
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
    dist_to_plane := dot(plane.n, pose.p + swept_sphere.center);

    if abs(dist_to_plane) <= swept_sphere.radius {
        // The sphere is already overlapping the plane. Set time of intersection to zero and point to sphere center.
        result.t = 0.0;
        result.point = swept_sphere.center;
        return true, result;
    }

    denom := dot(plane.normal, move);
    if denom * dist_to_plane >= 0.0 {
        // No intersection as sphere moving parallel to or away from plane
        return false, .{};
    }
    // Sphere is moving towards the plane

    // Use +r in computations if sphere in front of plane, else -r
    r := ifx dist_to_plane > 0.0 then sphere.radius else -sphere.radius;
    result.t = (r - dist_to_plane) / denom;
    result.point = pose.p + swept_sphere.center + t*move - r*plane.normal;
    return true, result;
}

//=====================
// sweep_sphere_triangle
//---------------------
sweep_sphere_triangle :: (swept_sphere: Sphere, pose: Pose, dir: Vector3, distance: float, tri: Triangle) -> bool, SweepHit #expand {

}

//=====================
// sweep_capsule_heightfield
//---------------------
sweep_sphere_heightfield :: (swept_sphere: Sphere, pose: Pose, dir: Vector3, distance: float, hfield: Heightfield) -> bool, SweepHit #expand {
    has_hit := false;
    result: SweepHit;
    result.t = 1.0;

    // Broad Phase: find relevant heightfield cells
    // Compute swept bounds
    end_pose := pose;
    end_pose.position += dir * distance;
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
sweep_capsule_heightfield :: (swept_capsule: Capsule, pose: Pose, dir: Vector3, distance: float, hfield: Heightfield) -> bool, SweepHit #expand {
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
