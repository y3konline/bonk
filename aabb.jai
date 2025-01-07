AABB :: struct {
    min: Vector3;
    max: Vector3;
}

// If the point is outside the bounds of the AABB, the AABB will be
// expanded to include the point.
aabb_expand :: (aabb: *AABB, point: Vector3) {
    if point.x > aabb.max.x then aabb.max.x = point.x;
    if point.y > aabb.max.y then aabb.max.y = point.y;
    if point.z > aabb.max.z then aabb.max.z = point.z;

    if point.x < aabb.min.x then aabb.min.x = point.x;
    if point.y < aabb.min.y then aabb.min.y = point.y;
    if point.z < aabb.min.z then aabb.min.z = point.z;
}
aabb_expand :: (aabb: *AABB, expand_by: AABB) {
    aabb_expand(aabb, expand_by.min);
    aabb_expand(aabb, expand_by.max);
}

merge_aabb :: inline (a: AABB, b: AABB) -> AABB {
    out: AABB;
    out.min.x = min(a.min.x, b.min.x);
    out.min.y = min(a.min.y, b.min.y);
    out.min.z = min(a.min.z, b.min.z);
    out.max.x = max(a.max.x, b.max.x);
    out.max.y = max(a.max.y, b.max.y);
    out.max.z = max(a.max.z, b.max.z);
    return out;
}
