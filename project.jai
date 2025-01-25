project_vec_on_plane :: (vec: Vector3, plane: Plane) -> Vector3 {
    EPSILON :: 0.000001;
    sqr_mag := dot(plane.normal, plane.normal);
    if sqr_mag < EPSILON return vec;

    dot_value := dot(vec, plane.normal);
    return Vector3.{
        vec.x - plane.normal.x * dot_value / sqr_mag,
        vec.y - plane.normal.y * dot_value / sqr_mag,
        vec.z - plane.normal.z * dot_value / sqr_mag
    };
}
