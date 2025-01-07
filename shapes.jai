//=========================================================
// ██████   ██████  ███    ██ ██   ██ ██
// ██   ██ ██    ██ ████   ██ ██  ██  ██
// ██████  ██    ██ ██ ██  ██ █████   ██
// ██   ██ ██    ██ ██  ██ ██ ██  ██
// ██████   ██████  ██   ████ ██   ██ ██
//---------------------------------------------------------
// Simple 3D game collision library for Jai.
//=========================================================

ShapeVariant :: enum {
    LINE;
    TRIANGLE;
    PLANE;
    BOX;
    SPHERE;
    CAPSULE;
    HEIGHTFIELD;
}

AnyShape :: struct {
    variant: ShapeVariant;
    union {
        line:        Line;
        triangle:    Triangle;
        plane:       Plane;
        box:         Box;
        sphere:      Sphere;
        capsule:     Capsule;
        heightfield: Heightfield;
    }

    compute_local_aabb :: (shape: AnyShape) -> AABB {
        if shape.variant == {
            case .SPHERE;  return Sphere.compute_local_aabb(shape.sphere);
            case .CAPSULE; return Capsule.compute_local_aabb(shape.capsule);
        }
    }

    compute_aabb :: (shape: AnyShape, pose: Pose) -> AABB {
        if shape.variant == {
            case .SPHERE;  return Sphere.compute_aabb(shape.sphere, pose);
            case .CAPSULE; return Capsule.compute_aabb(shape.capsule, pose);
        }
    }
}

Line :: struct {
    p1: Vector3;
    p2: Vector3;
#place p1;
    points: [2] Vector3;
}

Triangle :: struct {
    p1: Vector3;
    p2: Vector3;
    p3: Vector3;
#place p1;
    points: [3] Vector3;
}

Plane :: struct {
    normal: Vector3;
    distance: Vector3;
}

Box :: struct {
    extents: Vector3;
}

Sphere :: struct {
    radius: float;

    compute_local_aabb :: (sphere: Sphere) -> AABB {
        aabb: AABB;
        radius_xyz := xyz(sphere.radius);
        aabb.min = -radius_xyz;
        aabb.max =  radius_xyz;
        return aabb;
    }

    compute_aabb :: (sphere: Sphere, pose: Pose) -> AABB {
        aabb: AABB;
        radius_xyz := xyz(sphere.radius);
        aabb.min = pose.p - radius_xyz;
        aabb.max = pose.p + radius_xyz;
        return aabb;
    }
}

Capsule :: struct {
    radius: float;
    height: float;

    AXIS :: Vector3.{0, 1, 0}; // capsules in Bonk are Y-up

    compute_local_aabb :: (capsule: Capsule) -> AABB {
        aabb: AABB;

        end1 := 0.5 * capsule.height * AXIS;
        end2 := 0.5 * capsule.height * AXIS;

        // initialize aabb
        aabb.min = min(end1, end2);
        aabb.max = max(end1, end2);
        // extend aabb by the radius along each axis
        radius_xyz := xyz(capsule.radius);
        aabb.min -= radius_xyz;
        aabb.max += radius_xyz;

        return aabb;
    }

    compute_aabb :: (capsule: Capsule, pose: Pose) -> AABB {
        aabb: AABB;

        posed_axis := rotate(AXIS, pose.q);
        end1 := pose.p - (0.5 * capsule.height * posed_axis);
        end2 := pose.p + (0.5 * capsule.height * posed_axis);

        // initialize aabb to capsule line endpoints
        aabb.min = min(end1, end2);
        aabb.max = max(end1, end2);
        // extend aabb by the radius along each axis
        radius_xyz := xyz(capsule.radius);
        aabb.min -= radius_xyz;
        aabb.max += radius_xyz;

        return aabb;
    }
}

Heightfield :: struct {
    samples_x: int;
    samples_z: int;
    heights: [] float;
    cell_size_x: float;
    cell_size_z: float;

    RegionIter :: struct {
        min_cell_x: int;
        min_cell_z: int;
        max_cell_x: int;
        max_cell_z: int;
    }

    Cell :: struct {
        p00: Vector3;
        p10: Vector3;
        p01: Vector3;
        p11: Vector3;
    }

    get_world_pos :: (using hf: Heightfield, x: int, z: int) -> Vector3 {

    }

    iter_region :: (using hf: Heightfield, aabb: AABB) -> RegionIter {
        using region: RegionIter;

        min_cell_x = cast(int) floor(aabb.min.x / cell_size_x);
        max_cell_x = cast(int) floor(aabb.max.x / cell_size_x);
        min_cell_z = cast(int) floor(aabb.min.z / cell_size_z);
        max_cell_z = cast(int) floor(aabb.max.z / cell_size_z);

        if min_cell_x < 0 then min_cell_x = 0;
        if min_cell_z < 0 then min_cell_z = 0;
        if max_cell_x > samples_x-1 then max_cell_x = samples_x-1;
        if max_cell_z > samples_z-1 then max_cell_z = samples_z-1;

        return region;
    }

    triangulate_cell :: (using cell: Cell) -> Triangle, Triangle {
        a := Triangle.{p00, p10, p01};
        b := Triangle.{p10, p11, p01};
        return a, b;
    }
}
//=====================
// Heightfield.RegionIter for_expansion
//
// Iterates all cells within the region.
// Gives access to `it_cx` and `it_cz` for the iterator cell X and Z coordinates.
// `it` is the current cell.
// `it_index` is a running count of iterations so far, starting from 0.
//---------------------
for_expansion :: (hf: *Heightfield.RegionIter, body: Code, flags: For_Flags) #expand {
    i := 0;
    for cz : region.min_cell_z..region.max_cell_z {
        for cx : region.min_cell_x..region.max_cell_x {
            defer i += 1;

            // Each cell has corners (x,z), (x+1,z), (x,z+1), (x+1,z+1)
            `it := Cell.{
                p00 = Heightfield.get_world_pos(hf, cx,   cz),
                p10 = Heightfield.get_world_pos(hf, cx+1, cz),
                p01 = Heightfield.get_world_pos(hf, cx,   cz+1),
                p11 = Heightfield.get_world_pos(hf, cx+1, cz+1),
            };
            `it_index := i;
            `it_x := cx;
            `it_z := cz;

            #insert body;
        }
    }
}
