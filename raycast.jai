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
raycast_shape :: (ray: Ray, shape: AnyShape) -> bool, RaycastHit {
    if shape.variant == {
        case .AABB;
            has_hit, hit := raycast_aabb(ray, shape.aabb);
            return has_hit, hit;
        case .OBB;
            has_hit, hit := raycast_obb(ray, shape.obb);
            return has_hit, hit;

        case;
            assert(false, "Unimplemented raycast variant: %", shape.variant);
    }
}

//=====================
// raycast_aabb
//
// Using the "Slab" method from section 5.3.3 of Real-Time Collision Detection by Christer Ericson.
//---------------------
raycast_aabb :: (ray: Ray, aabb: AABB) -> bool, RaycastHit {
    EPSILON :: 0.0001;
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
    inv_rotation := conjugate(obb.rotation);
    local_ray := Ray.{
        origin = rotate(ray.origin-obb.center, inv_rotation),
        dir = rotate(ray.dir, inv_rotation),
    };
    local_aabb := AABB.{
        min = -obb.extents,
        max = obb.extents,
    };

    has_hit, local_hit := raycast_aabb(local_ray, local_aabb);
    if !has_hit return false, .{};

    return true, .{
        t = local_hit.t,
        point = rotate(local_hit.point, obb.rotation),
    };
}

//=====================
// raycast_line
//---------------------
raycast_line :: (a: Ray, b: Line) -> bool, RaycastHit {
    // @TODO
    UNIMPLEMENTED();
}

//=====================
// raycast_triangle
//---------------------
raycast_triangle :: (a: Ray, b: Triangle) -> bool, RaycastHit {
    // @TODO
    UNIMPLEMENTED();
}

//=====================
// raycast_plane
//---------------------
raycast_plane :: (a: Ray, b: Plane) -> bool, RaycastHit {
    // @TODO
    UNIMPLEMENTED();
}

//=====================
// raycast_sphere
//---------------------
raycast_sphere :: (a: Ray, b: Sphere) -> bool, RaycastHit {
    // @TODO
    UNIMPLEMENTED();
}

//=====================
// raycast_capsule
//---------------------
raycast_capsule :: (a: Ray, b: Capsule) -> bool, RaycastHit {
    // @TODO
    UNIMPLEMENTED();
}

//=====================
// raycast_heightfield
//---------
raycast_heightfield :: (a: Ray, b: Heightfield) -> bool, RaycastHit {
    // @TODO
    UNIMPLEMENTED();
}
