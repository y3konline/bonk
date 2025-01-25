//=========================================================
// ██████   ██████  ███    ██ ██   ██ ██
// ██   ██ ██    ██ ████   ██ ██  ██  ██
// ██████  ██    ██ ██ ██  ██ █████   ██
// ██   ██ ██    ██ ██  ██ ██ ██  ██
// ██████   ██████  ██   ████ ██   ██ ██
//---------------------------------------------------------
// Simple 3D game collision library for Jai.
//=========================================================

Pose :: struct {
    p: Vector3;     // the position of the shape in world space.
    q: Quaternion;  // the rotation of the shape in world space.
}

#load "aabb.jai";
#load "intersect.jai";
#load "project.jai";
#load "raycast.jai";
#load "shapes.jai";
#load "sweep.jai";

#scope_module

#import "Basic";
#import "Math";

UNIMPLEMENTED :: () #expand {
    assert(false, "Not implemented");
    `return false, .{};
}
