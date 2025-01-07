//=========================================================
// ██████   ██████  ███    ██ ██   ██ ██
// ██   ██ ██    ██ ████   ██ ██  ██  ██
// ██████  ██    ██ ██ ██  ██ █████   ██
// ██   ██ ██    ██ ██  ██ ██ ██  ██
// ██████   ██████  ██   ████ ██   ██ ██
//---------------------------------------------------------
// Simple 3D game collision library for Jai.
//=========================================================

IntersectHit :: struct {
    penetration_depth: float;
    contact_point: Vector3;
    contact_normal: Vector3;
}

//=====================
// AnyShape-AnyShape
//---------------------
intersect :: (a: AnyShape, b: AnyShape) -> bool, IntersectHit #expand {
    if #complete a.variant == {
        case .LINE;        has_hit, hit := intersect(a.line,        b); return has_hit, hit;
        case .TRIANGLE;    has_hit, hit := intersect(a.triangle,    b); return has_hit, hit;
        case .PLANE;       has_hit, hit := intersect(a.plane,       b); return has_hit, hit;
        case .BOX;         has_hit, hit := intersect(a.box,         b); return has_hit, hit;
        case .SPHERE;      has_hit, hit := intersect(a.sphere,      b); return has_hit, hit;
        case .CAPSULE;     has_hit, hit := intersect(a.capsule,     b); return has_hit, hit;
        case .HEIGHTFIELD; has_hit, hit := intersect(a.heightfield, b); return has_hit, hit;
    }
}

//=====================
// Line-AnyShape
// AnyShape-Line
//---------------------
intersect :: (a: Line, b: AnyShape) -> bool, IntersectHit #symmetric #expand {
    if b.variant == {
        case; assert(false, "Unimplemented intersect: Line-%", b.variant);
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

//=====================
// Heightfield-AnyShape
// AnyShape-Heightfield
//---------------------
intersect :: (a: Heightfield, b: AnyShape) -> bool, IntersectHit #symmetric #expand {
    if b.variant == {
        case; assert(false, "Unimplemented intersect: Heightfield-%", b.variant);
    }
}

//=====================
// Line-Line
//---------------------
intersect :: (a: Line, b: Line) -> bool, IntersectHit {
    // @TODO
    UNIMPLEMENTED();
}

//=====================
// Plane-Plane
//---------------------
intersect :: (a: Plane, b: Plane) -> bool, IntersectHit {
    // @TODO
    UNIMPLEMENTED();
}

//=====================
// Box-Box
//---------------------
intersect :: (a: Box, b: Box) -> bool, IntersectHit {
    // @TODO
    UNIMPLEMENTED();
}

//=====================
// Sphere-Sphere
//---------------------
intersect :: (a: Sphere, b: Sphere) -> bool, IntersectHit {
    // @TODO
    UNIMPLEMENTED();
}

//=====================
// Capsule-Capsule
//---------------------
intersect :: (a: Capsule, b: Capsule) -> bool, IntersectHit {
    // @TODO
    UNIMPLEMENTED();
}

//=====================
// Box-Sphere
// Sphere-Box
//---------------------
intersect :: (a: Box, b: Sphere) -> bool, IntersectHit #symmetric {
    // @TODO
    UNIMPLEMENTED();
}

//=====================
// Box-Capsule
// Capsule-Box
//---------------------
intersect :: (a: Box, b: Capsule) -> bool, IntersectHit #symmetric {
    // @TODO
    UNIMPLEMENTED();
}

//=====================
// Line-Box
// Box-Line
//---------------------
intersect :: (a: Line, b: Box) -> bool, IntersectHit #symmetric {
    // @TODO
    UNIMPLEMENTED();
}

//=====================
// Line-Plane
// Plane-Line
//---------------------
intersect :: (a: Line, b: Plane) -> bool, IntersectHit #symmetric {
    // @TODO
    UNIMPLEMENTED();
}

//=====================
// Capsule-Triangle
// Triangle-Capsule
//---------------------
intersect :: (a: Capsule, b: Triangle) -> bool, IntersectHit #symmetric {
    // @TODO
    UNIMPLEMENTED();
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
