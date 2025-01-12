main :: () {
    TEST(_intersect_segment_cylinder);
    TEST(_intersect_segment_cylinder_exclude_endcaps);

    TEST(_intersect_segment_sphere);

    TEST(_raycast_sphere);

    TEST(_sweep_sphere_triangle);
}

_intersect_segment_cylinder :: () {
    {
        seg := Segment.{xyz(-3.48, 4.72, 0), xyz(1.91, -5.46, 7.85)};
        cyl := Cylinder.{xyz(0, -3, 0), xyz(0, 0, 7), 3};
        hit, t := intersect_segment_cylinder(seg, cyl);
        EXPECT(hit == true);
    }
    {
        seg := Segment.{xyz(2.48, 4.72, 0), xyz(1.91, -5.46, -4.29)};
        cyl := Cylinder.{xyz(0, -3, 0), xyz(0, 0, 7), 3};
        hit, t := intersect_segment_cylinder(seg, cyl);
        EXPECT(hit == false);
    }
    {
        seg := Segment.{xyz(-3.48, 8.72, 4), xyz(1.91, -5.46, 10)};
        cyl := Cylinder.{xyz(0, -3, 0), xyz(0, 0, 7), 3};
        hit, t := intersect_segment_cylinder(seg, cyl);
        EXPECT(hit == false);
    }
    {
        seg := Segment.{xyz(-3.48, 8.72, 7), xyz(1.91, -5.46, 8)};
        cyl := Cylinder.{xyz(0, -3, 0), xyz(0, 0, 7), 3};
        hit, t := intersect_segment_cylinder(seg, cyl);
        EXPECT(hit == true);
    }
}

_intersect_segment_cylinder_exclude_endcaps :: () {
    {
        // Test curved part only
        seg := Segment.{xyz(2.48, 4.72, 8.64), xyz(1.91, -5.46, -4.29)};
        cyl := Cylinder.{xyz(0, -3, 0), xyz(0, 4, 7), 3};
        hit, t := intersect_segment_cylinder(seg, cyl, exclude_endcaps=true);
        EXPECT(hit == false);
    }
    {
        seg := Segment.{xyz(-3.48, 4.72, 0), xyz(1.91, -5.46, 7.85)};
        cyl := Cylinder.{xyz(0, -3, 0), xyz(0, 4, 7), 3};
        hit, t := intersect_segment_cylinder(seg, cyl, exclude_endcaps=true);
        EXPECT(hit == true);
    }
    {
        seg := Segment.{xyz(2.48, 4.72, 0), xyz(1.91, -5.46, -4.29)};
        cyl := Cylinder.{xyz(0, -3, 0), xyz(0, 0, 7), 3};
        hit, t := intersect_segment_cylinder(seg, cyl, exclude_endcaps=true);
        EXPECT(hit == false);
    }
    {
        seg := Segment.{xyz(-3.48, 8.72, 4), xyz(1.91, -5.46, 10)};
        cyl := Cylinder.{xyz(0, -3, 0), xyz(0, 0, 7), 3};
        hit, t := intersect_segment_cylinder(seg, cyl, exclude_endcaps=true);
        EXPECT(hit == false);
    }
    {
        seg := Segment.{xyz(-3.48, 8.72, 7), xyz(1.91, -5.46, 8)};
        cyl := Cylinder.{xyz(0, -3, 0), xyz(0, 0, 7), 3};
        hit, t := intersect_segment_cylinder(seg, cyl, exclude_endcaps=true);
        EXPECT(hit == true);
    }
}

_intersect_segment_sphere :: () {
    {
        s := Sphere.{5};
        spos := xyz(15, 0, 0);
        // through sphere
        hit, t := intersect_segment_sphere(Segment.{xyz(0,0,0), xyz(20, 0, 0)}, s, spos);
        EXPECT(hit == true);
    }
}

_raycast_sphere :: () {
    {
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
    }
}

_sweep_sphere_triangle :: () {
    tri := Triangle.{xyz(5, -3, 0), xyz(5, 3, 0), xyz(5, 0, 5)};
    has_hit, hit := sweep_sphere_triangle(Sphere.{1}, .{p=xyz(0,0,0)}, xyz(1,0,0), 10, tri);
    EXPECT(has_hit == true);

    tri = Triangle.{xyz(5, -3, 2), xyz(5, 3, 2), xyz(5, 0, 7)};
    has_hit, hit = sweep_sphere_triangle(Sphere.{1}, .{p=xyz(0,0,0)}, xyz(1,0,0), 10, tri);
    EXPECT(has_hit == false);

    tri = Triangle.{xyz(5, -3, 1.1), xyz(5, 3, 1.1), xyz(5, 0, 7)};
    has_hit, hit = sweep_sphere_triangle(Sphere.{1}, .{p=xyz(0,0,0)}, xyz(1,0,0), 10, tri);
    EXPECT(has_hit == false);

    tri = Triangle.{xyz(5, -3, 1), xyz(5, 1, 1), xyz(5, 0, 7)};
    has_hit, hit = sweep_sphere_triangle(Sphere.{1}, .{p=xyz(0,0,0)}, xyz(1,0,0), 10, tri);
    EXPECT(has_hit == true);
}


#import,file "module.jai";

#import "Basic";
#import "Math";
#import "Print_Color";

EXPECT :: (condition: bool, reason: string = "") #expand {
    print(".");
    if !condition {
        print_color("FAILED", color=.RED);
        `assert(condition, reason);
    }
}

TEST :: (fn: (), call := #caller_code) #expand {
    arg0 :: #run get_argument_name(call);

    print("┌──────────────────────────────────────────────────────────────────────────────┐\n");
    print("  [Test] % ", arg0);

    fn();
    print_color(" SUCCESS\n", color=.GREEN);
    // print("│\n");
    print("└──────────────────────────────────────────────────────────────────────────────┘\n");
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