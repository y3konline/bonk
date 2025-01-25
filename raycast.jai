Ray :: struct {
    origin: Vector3;
    dir: Vector3;
}

RaycastHit :: struct {
    t: float;
    point: Vector3;
    normal: Vector3;
}

//=====================
// raycast_shape
//
// Raycasts against a given shape determined at runtime.
//---------------------
raycast_shape :: (ray: Ray, shape: AnyShape, pose: Pose) -> bool, RaycastHit {
    if shape.variant == {
        case .BOX;
            has_hit, hit := raycast_box(ray, shape.box, pose);
            return has_hit, hit;

        case .SPHERE;
            has_hit, hit := raycast_sphere(ray, shape.sphere, pose.p);
            return has_hit, hit;

        case;
            assert(false, "Unimplemented raycast variant: %", shape.variant);
            return false, .{};
    }
}

//=====================
// raycast_aabb
//
// Using the "Slab" method from section 5.3.3 of Real-Time Collision Detection by Christer Ericson.
//---------------------
raycast_aabb :: (ray: Ray, aabb: AABB) -> bool, RaycastHit {
    EPSILON :: 0.000001;
    tmin := 0.0;
    tmax := FLOAT32_MAX;

    // for all three slabs (X, Y, Z)
    for i : 0..2 {
        p := ray.origin.component[i];
        d := ray.dir.component[i];
        amin := aabb.min.component[i];
        amax := aabb.max.component[i];

        if abs(d) < EPSILON {
            // Ray is parallel to slab. No hit if origin not within slab
            if (p < amin || p > amax) return false, .{};
        } else {
            // Compute intersection t value of ray with near and far plane of slab
            ood: float = 1.0 / d;
            t1 := (amin - p) * ood;
            t2 := (amax - p) * ood;
            // Make t1 be intersection with near plane, t2 with far plane
            if t1 > t2 Swap(*t1, *t2);
            // Compute the intersection of slab intersection intervals
            tmin = max(tmin, t1);
            tmax = min(tmax, t2);
            // Exit with no collision as soon as slab intersection becomes empty
            if (tmin > tmax) return false, .{};
        }
    }
    // Ray intersects all 3 slabs
    return true, .{
        t = tmin,
        point = ray.origin + ray.dir * tmin,
    };
}

//=====================
// raycast_box
//
// Re-using our Ray-AABB function, by first transforming the Ray into the OBB's local space,
// then transforming the result back into world space.
//---------------------
raycast_box :: (ray: Ray, box: Box, pose: Pose) -> bool, RaycastHit {
    inv_rotation := conjugate(pose.q);
    local_ray := Ray.{
        origin = rotate(ray.origin-pose.p, inv_rotation),
        dir = rotate(ray.dir, inv_rotation),
    };
    local_aabb := AABB.{
        min = -box.extents,
        max = box.extents,
    };

    has_hit, local_hit := raycast_aabb(local_ray, local_aabb);
    if !has_hit return false, .{};

    return true, .{
        t = local_hit.t,
        point = pose.p + rotate(local_hit.point, pose.q),
    };
}

//=====================
// raycast_segment
//---------------------
raycast_segment :: (a: Ray, b: Segment) -> bool, RaycastHit {
    // @TODO
    UNIMPLEMENTED();
}

//=====================
// raycast_triangle
//
// Using Section 5.3.6 of Real-Time Collision Detection by Christer Ericson
//---------------------
raycast_triangle :: (ray: Ray, tri: Triangle) -> bool, RaycastHit {
    ab := tri.p2 - tri.p1;
    ac := tri.p3 - tri.p1;
    qp := -ray.dir;

    // Compute triangle normal. Can be precalculated or cached if intersecting multiple
    // segments against the same triangle.
    n := cross(ab, ac);

    // Compute denominator d. If d <= 0, segment is parallel to or points away from triangle,
    // so exit early
    d := dot(qp, n);
    if (d <= 0.0) return false, .{};

    // Compute intersection t value of pq with plane of triangle.
    // A ray intersects if 0 <= t. Segment intersects if 0 <= t <= 1.
    // Delay dividing by d until intersection has been found to pierce triangle.
    ap := ray.origin - tri.p1;
    t := dot(ap, n);
    if (t < 0.0) return false, .{};
    // if (t > d) return false, .{}; // For segment; exclude this code line for a ray test

    // Compute barycentric coordinate components and test if within bounds
    e := cross(qp, ap);
    v := dot(ac, e);
    if (v < 0.0 || v > d) return false, .{};
    w := -dot(ab, e);
    if (w < 0.0 || v + w > d) return false, .{};

    // Segment/ray intersects triangle.
    // Perform delayed division and compute the last barycentric coordinate component
    ood := 1.0 / d;
    t *= ood;
    v *= ood;
    w *= ood;
    u := 1.0 - v - w;

    return true, RaycastHit.{
        t = t,
        point = ray.origin + ray.dir * t,
        normal = normalize(n),
    };
}

//=====================
// raycast_plane
//
// Using section 5.3.1 of Real Time Collision Detection by Christer Ericson.
// Note, this does not explicitly handle division by zero, but assuming IEEE-754 this will still be correct.
// See section 11.2.2 on infinity arithmetic for details.
//---------------------
raycast_plane :: (ray: Ray, plane: Plane) -> bool, RaycastHit {
    t := (plane.distance - dot(plane.normal, ray.origin)) / dot(plane.normal, ray.dir);
    if t >= 0.0 {
        return true, RaycastHit.{
            t = t,
            point = ray.origin + t * ray.dir,
            normal = plane.normal,
        };
    }
    return false, .{};
}

//=====================
// raycast_sphere
//
// Using Section 5.3.2 of Real-Time Collision Detection by Christer Ericson
//---------------------
raycast_sphere :: (ray: Ray, s: Sphere, spos: Vector3) -> bool, RaycastHit {
    m := ray.origin - spos;
    b := dot(m, ray.dir);
    c := dot(m, m) - s.radius*s.radius;
    // Exit if r's origin outside s (c > 0) and r pointing away from s (b > 0)
    if (c > 0.0 && b > 0.0) return false, .{};
    discr := b*b - c;
    // A negtyative discriminant corresponds to ray missing sphere
    if (discr < 0.0) return false, .{};
    // Ray now found to intersect sphere, compute smallest t value of intersection
    t := -b - sqrt(discr);
    // If t is negative, ray started inside sphere so clamp t to zero
    if (t < 0.0) t = 0.0;

    return true, RaycastHit.{
        t = t,
        point = ray.origin + ray.dir * t,
    }; // @TODO - normal?
} @Tested

//=====================
// raycast_capsule
//---------------------
raycast_capsule :: (a: Ray, b: Capsule) -> bool, RaycastHit {
    // @TODO
    UNIMPLEMENTED();
}

//=====================
// raycast_heightfield
//
// This is a case where we have a 2D Heightfield, but a 3D Ray.
// My idea for how to handle it is this:
//
// 1. Convert the 3D ray into a 2D Ground ray, basically by removing the Y (assuming Y-Up).
// 2. Do the 2D Ray - 2D Uniform Grid method from Section 7.4.2 of Real Time Collision Detection by Christer Ericson.
// 3. Now we have the cells that the ray touches. From here we can triangulate those cells and do 3D Ray vs 3D Triangle.
//---------
raycast_heightfield :: (a: Ray, b: Heightfield) -> bool, RaycastHit {
    // has_hit := false;
    // result: RaycastHit;
    // result.t = 1.0;

    // // Broad Phase: find relevant heightfield cells
    // // Compute swept bounds
    // end_pose := pose;
    // end_pose.p += dir * distance;
    // start_aabb := Sphere.compute_aabb(swept_sphere, pose);
    // end_aabb   := Sphere.compute_aabb(swept_sphere, end_pose);
    // swept_aabb := merge_aabb(start_aabb, end_aabb);

    // // Narrow Phase: For each cell in the bounds, generate two triangles and do "sweep capsule vs. triangle".
    // // We will keep the earliest collision (smallest t value).
    // for cell : Heightfield.iter_region(hfield, swept_aabb) {
    //     tri_a, tri_b := Heightfield.triangulate_cell(cell);

    //     has_hit_a, hit_a := sweep_sphere_triangle(swept_sphere, pose, dir, distance, tri_a);
    //     has_hit_b, hit_b := sweep_sphere_triangle(swept_sphere, pose, dir, distance, tri_b);

    //     if has_hit_a && hit_a.t < result.t {
    //         has_hit = true;
    //         result = hit_a;
    //     }
    //     if has_hit_b && hit_b.t < result.t {
    //         has_hit = true;
    //         result = hit_b;
    //     }
    // }

    // return has_hit, result;
}
