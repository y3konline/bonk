main :: () {
    TEST(_intersect_segment_cylinder);
    TEST(_intersect_segment_cylinder_exclude_endcaps);
    TEST(_intersect_segment_capsule);
    TEST(_intersect_segment_sphere);

    TEST(_raycast_sphere);

    TEST(_sweep_sphere_triangle);
    TEST(_sweep_sphere_box);
}

_intersect_segment_cylinder :: () {
    CASE("", #code {
        seg := Segment.{xyz(-3.48, 4.72, 0), xyz(1.91, -5.46, 7.85)};
        cyl := Cylinder.{xyz(0, -3, 0), xyz(0, 0, 7), 3};
        hit, t := intersect_segment_cylinder(seg, cyl);
        EXPECT(hit == true);
    });
    CASE("", #code {
        seg := Segment.{xyz(2.48, 4.72, 0), xyz(1.91, -5.46, -4.29)};
        cyl := Cylinder.{xyz(0, -3, 0), xyz(0, 0, 7), 3};
        hit, t := intersect_segment_cylinder(seg, cyl);
        EXPECT(hit == false);
    });
    CASE("", #code {
        seg := Segment.{xyz(-3.48, 8.72, 4), xyz(1.91, -5.46, 10)};
        cyl := Cylinder.{xyz(0, -3, 0), xyz(0, 0, 7), 3};
        hit, t := intersect_segment_cylinder(seg, cyl);
        EXPECT(hit == false);
    });
    CASE("", #code {
        seg := Segment.{xyz(-3.48, 8.72, 7), xyz(1.91, -5.46, 8)};
        cyl := Cylinder.{xyz(0, -3, 0), xyz(0, 0, 7), 3};
        hit, t := intersect_segment_cylinder(seg, cyl);
        EXPECT(hit == true);
    });
}

_intersect_segment_cylinder_exclude_endcaps :: () {
    CASE("", #code {
        seg := Segment.{xyz(2.48, 4.72, 8.64), xyz(1.91, -5.46, -4.29)};
        cyl := Cylinder.{xyz(0, -3, 0), xyz(0, 4, 7), 3};
        hit, t := intersect_segment_cylinder(seg, cyl, exclude_endcaps=true);
        EXPECT(hit == false);
    });
    CASE("", #code {
        seg := Segment.{xyz(-3.48, 4.72, 0), xyz(1.91, -5.46, 7.85)};
        cyl := Cylinder.{xyz(0, -3, 0), xyz(0, 4, 7), 3};
        hit, t := intersect_segment_cylinder(seg, cyl, exclude_endcaps=true);
        EXPECT(hit == true);
    });
    CASE("", #code {
        seg := Segment.{xyz(2.48, 4.72, 0), xyz(1.91, -5.46, -4.29)};
        cyl := Cylinder.{xyz(0, -3, 0), xyz(0, 0, 7), 3};
        hit, t := intersect_segment_cylinder(seg, cyl, exclude_endcaps=true);
        EXPECT(hit == false);
    });
    CASE("", #code {
        seg := Segment.{xyz(-3.48, 8.72, 4), xyz(1.91, -5.46, 10)};
        cyl := Cylinder.{xyz(0, -3, 0), xyz(0, 0, 7), 3};
        hit, t := intersect_segment_cylinder(seg, cyl, exclude_endcaps=true);
        EXPECT(hit == false);
    });
    CASE("", #code {
        seg := Segment.{xyz(-3.48, 8.72, 7), xyz(1.91, -5.46, 8)};
        cyl := Cylinder.{xyz(0, -3, 0), xyz(0, 0, 7), 3};
        hit, t := intersect_segment_cylinder(seg, cyl, exclude_endcaps=true);
        EXPECT(hit == true);
    });
}

_intersect_segment_capsule :: () {
    CASE("", #code {
        seg := Segment.{xyz(-3.48, 4.72, 0), xyz(1.91, -5.46, 7.85)};
        hit, t := intersect_segment_capsule(seg, xyz(0, -3, 0), xyz(0, 0, 7), 3);
        EXPECT(hit == true);
    });
    CASE("", #code {
        seg := Segment.{xyz(2.48, 4.72, 0), xyz(1.91, -5.46, -4.29)};
        hit, t := intersect_segment_capsule(seg, xyz(0, -3, 0), xyz(0, 0, 7), 3);
        EXPECT(hit == false);
    });
    CASE("", #code {
        seg := Segment.{xyz(-3.48, 8.72, 4), xyz(1.91, -5.46, 10)};
        hit, t := intersect_segment_capsule(seg, xyz(0, -3, 0), xyz(0, 0, 7), 3);
        EXPECT(hit == true);
    });
    CASE("", #code {
        seg := Segment.{xyz(-3.48, 8.72, 7), xyz(1.91, -5.46, 8)};
        hit, t := intersect_segment_capsule(seg, xyz(0, -3, 0), xyz(0, 0, 7), 3);
        EXPECT(hit == true);
    });
}

_intersect_segment_sphere :: () {
    CASE("", #code {
        s := Sphere.{5};
        spos := xyz(15, 0, 0);
        // through sphere
        hit, t := intersect_segment_sphere(Segment.{xyz(0,0,0), xyz(20, 0, 0)}, s, spos);
        EXPECT(hit == true);
    });
}

_raycast_sphere :: () {
    CASE("", #code {
        s := Sphere.{5};
        spos := xyz(15, 0, 0);
        // cast towards sphere
        hit, t := raycast_sphere(Ray.{xyz(0,0,0), xyz(1,0,0)}, s, spos);
        EXPECT(hit == true);
        // cast away from sphere
        hit, t = raycast_sphere(Ray.{xyz(0,0,0), xyz(-1,0,0)}, s, spos);
        EXPECT(hit == false);
        // miss sphere
        hit, t = raycast_sphere(Ray.{xyz(0,6,0), xyz(1,0,0)}, s, spos);
        EXPECT(hit == false);
        // graze sphere
        hit, t = raycast_sphere(Ray.{xyz(0,5,0), xyz(1,0,0)}, s, spos);
        EXPECT(hit == true);
        // barely miss sphere
        hit, t = raycast_sphere(Ray.{xyz(0,5.01,0), xyz(1,0,0)}, s, spos);
        EXPECT(hit == false);
    });
}

_sweep_sphere_triangle :: () {
    CASE("", #code {
        tri := Triangle.{xyz(5, -3, 0), xyz(5, 3, 0), xyz(5, 0, 5)};
        has_hit, hit := sweep_sphere_triangle(Sphere.{1}, .{p=xyz(0,0,0)}, xyz(1,0,0), 10, tri);
        EXPECT(has_hit == true);
    });
    CASE("", #code {
        tri := Triangle.{xyz(5, -3, 2), xyz(5, 3, 2), xyz(5, 0, 7)};
        has_hit, hit := sweep_sphere_triangle(Sphere.{1}, .{p=xyz(0,0,0)}, xyz(1,0,0), 10, tri);
        EXPECT(has_hit == false);
    });
    CASE("", #code {
        tri := Triangle.{xyz(5, -3, 1.1), xyz(5, 3, 1.1), xyz(5, 0, 7)};
        has_hit, hit := sweep_sphere_triangle(Sphere.{1}, .{p=xyz(0,0,0)}, xyz(1,0,0), 10, tri);
        EXPECT(has_hit == false);
    });
    CASE("", #code {
        tri := Triangle.{xyz(5, -3, 1), xyz(5, 1, 1), xyz(5, 0, 7)};
        has_hit, hit := sweep_sphere_triangle(Sphere.{1}, .{p=xyz(0,0,0)}, xyz(1,0,0), 10, tri);
        EXPECT(has_hit == true);
    });
}

_sweep_sphere_box :: () {
    CASE("Sphere moving towards box", #code {
        sc := xyz(0,0,0);
        sphere := Sphere.{1};
        dir := xyz(1,1,1);
        box := Box.{xyz(1)};
        box_pos := xyz(5, 5, 5);
        has_hit, hit := sweep_sphere_box(sphere, .{p=sc}, dir, 100, box, .{p=box_pos});
        EXPECT(has_hit == true);
    });
    CASE("Sphere moving away from box", #code {
        sc := xyz(0,0,0);
        sphere := Sphere.{1};
        dir := xyz(1,1,1);
        box := Box.{xyz(1)};
        box_pos := xyz(-5, -5, -5);
        has_hit, hit := sweep_sphere_box(sphere, .{p=sc}, dir, 100, box, .{p=box_pos});
        EXPECT(has_hit == false);
    });
    CASE("Sphere directly heading towards box", #code {
        sc := xyz(0,0,0);
        sphere := Sphere.{1};
        dir := xyz(1,0,0);
        box := Box.{xyz(2)};
        box_pos := xyz(5, 0, 0);
        has_hit, hit := sweep_sphere_box(sphere, .{p=sc}, dir, 10, box, .{p=box_pos});
        EXPECT(has_hit == true);
    });
    CASE("Sphere moving parallel to the box (no collision)", #code {
        sc := xyz(0,0,0);
        sphere := Sphere.{1};
        dir := xyz(0,1,0);
        box := Box.{xyz(2)};
        box_pos := xyz(5, 0, 0);
        has_hit, hit := sweep_sphere_box(sphere, .{p=sc}, dir, 10, box, .{p=box_pos});
        EXPECT(has_hit == false);
    });
    CASE("Sphere with larger radius colliding with box", #code {
        sc := xyz(0,0,0);
        sphere := Sphere.{3};
        dir := xyz(1,0,0);
        box := Box.{xyz(2)};
        box_pos := xyz(5, 0, 0);
        has_hit, hit := sweep_sphere_box(sphere, .{p=sc}, dir, 10, box, .{p=box_pos});
        EXPECT(has_hit == true);
    });
    CASE("Sphere moving directly towards box but not reaching within the given distance", #code {
        sc := xyz(0,0,0);
        sphere := Sphere.{1};
        dir := xyz(1,0,0);
        box := Box.{xyz(2)};
        box_pos := xyz(20, 0, 0);
        has_hit, hit := sweep_sphere_box(sphere, .{p=sc}, dir, 10, box, .{p=box_pos});
        EXPECT(has_hit == false);
    });
    CASE("Sphere touching the box at the start position (already colliding)", #code {
        sc := xyz(4, 0, 0);
        sphere := Sphere.{1};
        dir := xyz(1,0,0);
        box := Box.{xyz(2)};
        box_pos := xyz(5, 0, 0);
        has_hit, hit := sweep_sphere_box(sphere, .{p=sc}, dir, 10, box, .{p=box_pos});
        EXPECT(has_hit == true);
    });
    CASE("Sphere moving away from the box", #code {
        sc := xyz(10,0,0);
        sphere := Sphere.{1};
        dir := xyz(1,0,0);
        box := Box.{xyz(2)};
        box_pos := xyz(5, 0, 0);
        has_hit, hit := sweep_sphere_box(sphere, .{p=sc}, dir, 10, box, .{p=box_pos});
        EXPECT(has_hit == false);
    });
    CASE("Sphere moving diagonally and grazing the corner of the box", #code {
        sc := xyz(0,0,0);
        sphere := Sphere.{1};
        dir := xyz(1,1,0);
        box := Box.{xyz(2)};
        box_pos := xyz(5, 5, 0);
        has_hit, hit := sweep_sphere_box(sphere, .{p=sc}, dir, 10, box, .{p=box_pos});
        EXPECT(has_hit == true);
    });
    CASE("Sphere exactly aligned with box edge but not touching", #code {
        sc := xyz(0, 0, 0);
        sphere := Sphere.{1};
        dir := xyz(-1,0,0);
        box := Box.{xyz(2)};
        box_pos := xyz(4, 2, 0);
        has_hit, hit := sweep_sphere_box(sphere, .{p=sc}, dir, 10, box, .{p=box_pos});
        EXPECT(has_hit == false);
    });

    CASE("Collision with -X face gives -X normal", #code {
        sc := xyz(0, 0, 0);
        sphere := Sphere.{1};
        dir := xyz(1,0,0.5);
        box := Box.{xyz(5)};
        box_pos := xyz(10, 0, 0);
        has_hit, hit := sweep_sphere_box(sphere, .{p=sc}, dir, 10, box, .{p=box_pos});
        EXPECT(hit.normal == xyz(-1, 0, 0));
    });
    CASE("Collision with +X face gives +X normal", #code {
        sc := xyz(10, 0, 0);
        sphere := Sphere.{1};
        dir := xyz(-1,0,0.5);
        box := Box.{xyz(5)};
        box_pos := xyz(0, 0, 0);
        has_hit, hit := sweep_sphere_box(sphere, .{p=sc}, dir, 10, box, .{p=box_pos});
        EXPECT(hit.normal == xyz(1, 0, 0));
    });
    CASE("Collision with -Y face gives -Y normal", #code {
        sc := xyz(0, 0, 0);
        sphere := Sphere.{1};
        dir := xyz(0,1,0.5);
        box := Box.{xyz(5)};
        box_pos := xyz(0, 10, 0);
        has_hit, hit := sweep_sphere_box(sphere, .{p=sc}, dir, 10, box, .{p=box_pos});
        EXPECT(hit.normal == xyz(0, -1, 0));
    });
    CASE("Collision with +Y face gives +Y normal", #code {
        sc := xyz(0, 10, 0);
        sphere := Sphere.{1};
        dir := xyz(0,-1,0.5);
        box := Box.{xyz(5)};
        box_pos := xyz(0, 0, 0);
        has_hit, hit := sweep_sphere_box(sphere, .{p=sc}, dir, 10, box, .{p=box_pos});
        EXPECT(hit.normal == xyz(0, 1, 0));
    });
    CASE("Collision with -Z face gives -Z normal", #code {
        sc := xyz(0, 0, 0);
        sphere := Sphere.{1};
        dir := xyz(0,0.5,1.0);
        box := Box.{xyz(5)};
        box_pos := xyz(0, 0, 10);
        has_hit, hit := sweep_sphere_box(sphere, .{p=sc}, dir, 10, box, .{p=box_pos});
        EXPECT(hit.normal == xyz(0, 0, -1));
    });
    CASE("Collision with +Z face gives +Z normal", #code {
        sc := xyz(0, 0, 10);
        sphere := Sphere.{1};
        dir := xyz(0,0.5,-1.0);
        box := Box.{xyz(5)};
        box_pos := xyz(0, 0, 0);
        has_hit, hit := sweep_sphere_box(sphere, .{p=sc}, dir, 10, box, .{p=box_pos});
        EXPECT(hit.normal == xyz(0, 0, 1));
    });

    CASE("Sphere colliding with a corner of the box", #code {
        sc := xyz(0,0,0);
        sphere := Sphere.{1};
        dir := xyz(1,1,1);
        box := Box.{xyz(2)};
        box_pos := xyz(5, 5, 5);
        has_hit, hit := sweep_sphere_box(sphere, .{p=sc}, dir, 10, box, .{p=box_pos});
        print("normal: %\n", hit.normal);
        EXPECT(has_hit == true);
        EXPECT(hit.normal == normalize(xyz(-1, -1, -1)));
    });
    CASE("Sphere grazing past the corner of the box", #code {
        sc := xyz(0,0,0);
        sphere := Sphere.{1};
        dir := xyz(1,1,0);
        box := Box.{xyz(2)};
        box_pos := xyz(5, 5, 0);
        has_hit, hit := sweep_sphere_box(sphere, .{p=sc}, dir, 10, box, .{p=box_pos});
        EXPECT(has_hit == true);
        EXPECT(hit.normal != xyz(0,0,0));
    });
    CASE("Sphere barely missing the corner of the box", #code {
        sc := xyz(0,0,0);
        sphere := Sphere.{1};
        dir := xyz(1,1,0);
        box := Box.{xyz(2)};
        box_pos := xyz(7, 7, 0);
        has_hit, hit := sweep_sphere_box(sphere, .{p=sc}, dir, 4.2, box, .{p=box_pos});
        EXPECT(has_hit == false);
    });
    CASE("Sphere grazing corner of box at diagonal angle", #code {
        sc := xyz(0,0,0);
        sphere := Sphere.{1};
        dir := xyz(1,1,1);
        box := Box.{xyz(2)};
        box_pos := xyz(5, 5, 5);
        has_hit, hit := sweep_sphere_box(sphere, .{p=sc}, dir, 10, box, .{p=box_pos});
        EXPECT(has_hit == true);
        EXPECT(hit.normal != xyz(0,0,0));
    });
    CASE("Sphere approaching corner from below", #code {
        sc := xyz(0, -5, 0);
        sphere := Sphere.{1};
        dir := xyz(1,1,1);
        box := Box.{xyz(2)};
        box_pos := xyz(5, 0, 5);
        has_hit, hit := sweep_sphere_box(sphere, .{p=sc}, dir, 10, box, .{p=box_pos});
        EXPECT(has_hit == true);
        EXPECT(hit.normal != xyz(0,0,0));
    });
    CASE("Sphere moving parallel to the corner edge", #code {
        sc := xyz(0, 0, 0);
        sphere := Sphere.{1};
        dir := xyz(1,1,0);
        box := Box.{xyz(2)};
        box_pos := xyz(5, 5, 0);
        has_hit, hit := sweep_sphere_box(sphere, .{p=sc}, dir, 10, box, .{p=box_pos});
        EXPECT(has_hit == true);
        EXPECT(hit.normal != xyz(0,0,0));
    });
    CASE("Sphere approaching a far corner but stopping before impact", #code {
        sc := xyz(0, 0, 0);
        sphere := Sphere.{1};
        dir := xyz(1,1,1);
        box := Box.{xyz(2)};
        box_pos := xyz(10, 10, 10);
        has_hit, hit := sweep_sphere_box(sphere, .{p=sc}, dir, 5, box, .{p=box_pos});
        EXPECT(has_hit == false);
    });

    CASE("Sphere colliding with -X edge", #code {
        sc := xyz(0, 0, 0);
        sphere := Sphere.{1};
        dir := xyz(1,0,0);
        box := Box.{xyz(2)};
        box_pos := xyz(5,0,0);
        box_rot: Quaternion;
        set_from_axis_and_angle(*box_rot, xyz(0,1,0), PI/2);
        has_hit, hit := sweep_sphere_box(sphere, .{p=sc}, dir, 5, box, .{p=box_pos, q=box_rot});
        EXPECT(has_hit == true);
        EXPECT(length(hit.normal - xyz(-1,0,0)) < 0.00001);
    });

    CASE("Sphere colliding with -X,-Z edge", #code {
        sc := xyz(-1, 0, -1);
        sphere := Sphere.{1};
        dir := normalize(xyz(1,0,1));
        box := Box.{xyz(3)};
        box_pos := xyz(5,0,5);
        has_hit, hit := sweep_sphere_box(sphere, .{p=sc}, dir, 10, box, .{p=box_pos});
        EXPECT(has_hit == true);
        EXPECT(length(hit.normal - normalize(xyz(-1,0,-1))) < 0.00001);
    });
    CASE("Sphere colliding with +X,-Z edge", #code {
        sc := xyz(5, 0, 0);
        sphere := Sphere.{1};
        dir := normalize(xyz(-1,0,1));
        box := Box.{xyz(3)};
        box_pos := xyz(0,0,5);
        has_hit, hit := sweep_sphere_box(sphere, .{p=sc}, dir, 10, box, .{p=box_pos});
        EXPECT(has_hit == true);
        EXPECT(length(hit.normal - normalize(xyz(1,0,-1))) < 0.00001);
    });
    CASE("Sphere colliding with +X,+Z edge", #code {
        sc := xyz(5, 0, 5);
        sphere := Sphere.{1};
        dir := normalize(xyz(-1,0,-1));
        box := Box.{xyz(3)};
        box_pos := xyz(0,0,0);
        has_hit, hit := sweep_sphere_box(sphere, .{p=sc}, dir, 10, box, .{p=box_pos});
        EXPECT(has_hit == true);
        EXPECT(length(hit.normal - normalize(xyz(1,0,1))) < 0.00001);
    });

    CASE("Sphere skewering thin box", #code {
        sc := xyz(0, 0, 0);
        sphere := Sphere.{3};
        dir := normalize(xyz(1,0,0));
        box := Box.{xyz(5, 5, 1)};
        box_pos := xyz(10, 0, 0);
        has_hit, hit := sweep_sphere_box(sphere, .{p=sc}, dir, 10, box, .{p=box_pos});
        EXPECT(has_hit == true);
        print("hit: %\n", hit);
        EXPECT(length(hit.normal - normalize(xyz(-1,0,0))) < 0.00001);
    });
}


#import,file "module.jai";

#import "Basic";
#import "Math";
#import "Print_Color";

#add_context test_success: bool;

EXPECT :: (condition: bool, reason: string = "") #expand {
    if !condition {
        // `assert(condition, reason);
        context.test_success = false;
    }
}

TEST :: (fn: (), call := #caller_code) #expand {
    arg0 :: #run get_argument_name(call);

    print("┌──────────────────────────────────────────────────────────────────────────────\n");
    print("│ [TEST] %\n", arg0);

    fn();
    print("└──────────────────────────────────────────────────────────────────────────────\n");
}

CASE :: (name: string, code: Code) #expand {
    context.test_success = true;

    #insert code;

    print("│ ");
    if context.test_success {
        print_color("✓ [PASS] %", name, color=.GREEN);
    } else {
        print_color("× [FAIL] %", name, color=.RED);
    }
    print("\n");
}


get_argument_name :: (call: Code, index := 0) -> string {
    #import "Compiler";

    root := compiler_get_nodes(call);
    if root.kind == .PROCEDURE_CALL {
        proc_call := cast(*Code_Procedure_Call) root;
        arg := cast(*Code_Ident) proc_call.arguments_sorted[index];
        return arg.name;
    } else {
        err :: "expected a procedure code node";
        assert(false, err);
        return err;
    }
};