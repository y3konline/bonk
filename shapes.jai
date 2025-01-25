ShapeVariant :: enum {
    INVALID;
    SEGMENT;
    CYLINDER;
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
        segment:     Segment;
        cylinder:    Cylinder;
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
            case;
                assert(false, "AnyShape.compute_local_aabb variant not implemented: %\n", shape.variant);
                return .{};
        }
    }

    compute_aabb :: (shape: AnyShape, pose: Pose) -> AABB {
        if shape.variant == {
            case .SPHERE;  return Sphere.compute_aabb(shape.sphere, pose);
            case .CAPSULE; return Capsule.compute_aabb(shape.capsule, pose);
            case;
                assert(false, "compute_aabb variant not implemented: %\n", shape.variant);
                return .{};
        }
    }
}

Segment :: struct {
    p1: Vector3;
    p2: Vector3;
#place p1;
    points: [2] Vector3;
}

Cylinder :: struct {
    p1: Vector3;
    p2: Vector3;
    radius: float;
#place p1;
    points: [2] Vector3;
}

Triangle :: struct {
    p1: Vector3;
    p2: Vector3;
    p3: Vector3;
#place p1;
    points: [3] Vector3;

    barycentric :: (using triangle: Triangle, point: Vector3) -> u: float, v: float, w: float {
        v0 := p2 - p1;
        v1 := p3 - p1;
        v2 := point - p1;

        d00 := dot(v0, v0);
        d01 := dot(v0, v1);
        d11 := dot(v1, v1);
        d20 := dot(v2, v0);
        d21 := dot(v2, v1);
        denom := d00 * d11 - d01 * d01;
        v := (d11 * d20 - d01 * d21) / denom;
        w := (d00 * d21 - d01 * d20) / denom;
        u := 1.0 - v - w;

        return u, v, w;
    }

    contains_point :: (using triangle: Triangle, point: Vector3) -> bool {
        u, v, w := Triangle.barycentric(triangle, point);
        return v >= 0.0 && w >= 0.0 && (v+w) <= 1.0;
    }

    compute_plane :: (using triangle: Triangle) -> Plane {
        plane: Plane;

        edge1 := xyz(p2.x - p1.x, p2.y - p1.y, p2.z - p1.z);
        edge2 := xyz(p3.x - p1.x, p3.y - p1.y, p3.z - p1.z);

        plane.normal = normalize(cross(edge1, edge2));
        plane.distance = -(plane.normal.x * p1.x + plane.normal.y * p1.y + plane.normal.z * p1.z);

        return plane;
    }
}

Plane :: struct {
    normal: Vector3;
    distance: float;
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
    heights: [..] float;
    cell_size_x: float;
    cell_size_z: float;

    RegionIter :: struct {
        heightfield: *Heightfield;
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

    get_world_pos :: (using hf: Heightfield, cx: int, cz: int) -> Vector3 {
        y := hf.heights[cz * samples_x + cx];

        world_width  := (cast(float) samples_x) * cell_size_x;
        world_length := (cast(float) samples_z) * cell_size_z;

        x := cx * cell_size_x - world_width/2;
        z := cz * cell_size_z - world_length/2;

        return .{x,y,z};
    }

    get_height_from_world :: (using hf: Heightfield, x: float, z: float) -> float {
        print("x: %\nz: %\n", x, z);
        print("cell_size_x: %\ncell_size_z: %\n", cell_size_x, cell_size_z);
        world_width  := (cast(float) samples_x) * cell_size_x;
        world_length := (cast(float) samples_z) * cell_size_z;
        cx := cast(int) floor((x+world_width/2)  / cell_size_x);
        cz := cast(int) floor((z+world_length/2) / cell_size_z);
        return heights[cz * samples_x + cx];
    }

    iter_region :: (using hf: *Heightfield, aabb: AABB) -> RegionIter {
        using region: RegionIter;
        region.heightfield = hf;

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
for_expansion :: (region: *Heightfield.RegionIter, body: Code, flags: For_Flags) #expand {
    i := 0;
    for cz : region.min_cell_z..region.max_cell_z {
        for cx : region.min_cell_x..region.max_cell_x {
            defer i += 1;

            // Each cell has corners (x,z), (x+1,z), (x,z+1), (x+1,z+1)
            `it := Heightfield.Cell.{
                p00 = Heightfield.get_world_pos(region.heightfield, cx,   cz),
                p10 = Heightfield.get_world_pos(region.heightfield, cx+1, cz),
                p01 = Heightfield.get_world_pos(region.heightfield, cx,   cz+1),
                p11 = Heightfield.get_world_pos(region.heightfield, cx+1, cz+1),
            };
            `it_index := i;
            `it_x := cx;
            `it_z := cz;

            #insert body;
        }
    }
}
