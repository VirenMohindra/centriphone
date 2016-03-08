// From https://github.com/nicovuignier/centriphone
// This is an openSCAD variant

thickness = 2;
rounding = 2;
// The base
base_width = 113;
base_height = 101.5;
base_fin_width = 25;
base_fin_height = 45;
//
base_slot_width = 3;
base_slot_height = 21;
base_slot_xoff = 25;
base_slot_yoff = 53;
//
base_hole_width = 32;
base_hole_height = 39;
base_hole_yoff = 45;
//
camera_x = 44;
camera_y = 62;
camera_yoff = 34;
camera_height = 20;
camera_wall = 1;
camera_button_dia = 16;
camera_button_yoff = 83;
camera_button_zoff = 11;
//
fin_xoff = 34;
fin_yoff = 29;
//
thread_dia = 1;
tie1_yoff = 8;
tie23_xoff = 46.5;
tie23_yoff = 95.5;
// specials
cyl_res = 72; //  rounding on corners
Delta = 0.1;  // for overlaps and nice well behaved STL output
// shapes
baseplate_2D = [[-Delta,0],[10,0],[35,27],[33,59],[56.5,102],[-Delta,102]];
fin = [[0,0],[50,72],[-50,72]];


//-------------------------------------------
// reference file if you have it to compare:
color("cyan")
rotate([0,0,180])
translate([0,1,0])
    import("Centripro-v01.stl");

//-------------------------------------------
// The modules

module tieline() {
    // two cylinders and a bridging link
    translate([0,0,-thickness/2])
    cylinder(h=thickness*2,d=thread_dia,center=true,$fn=cyl_res);
    translate([0,thickness*2,-thickness/2])
        cylinder(h=thickness*2,d=thread_dia,center=true,$fn=cyl_res);
    translate([0,thickness,0])
    rotate([90,0,0])
    cylinder(h=thickness*2,d=thread_dia,center=true,$fn=cyl_res);
}

module baseplate() {
    minkowski() {
        linear_extrude(height=thickness) {
            union() {
                polygon(points=baseplate_2D);
                mirror([1,0,0])
                    polygon(points=baseplate_2D);
                }

        }
        // rounding
        cylinder(h=0.1, d=rounding, center=true, $fn=cyl_res);
    }
}

module base_slot() {
    translate([base_slot_xoff, base_slot_yoff,-thickness-Delta])
        cube(size=[base_slot_width, base_slot_height, thickness+Delta*2]);
}
module base_hole() {
    translate([-base_hole_width/2, base_hole_yoff,-thickness-Delta])
        cube(size=[base_hole_width, base_hole_height, thickness+Delta*2]);
}

module reset_button() {
    translate([50,camera_button_yoff,camera_button_zoff])
    rotate([0,90,0])
        cylinder(h=100, d=camera_button_dia, center=true, $fn=cyl_res);
}

module camera_mount() {
    difference() {
        linear_extrude(height=camera_height, convexity = 4) {
                translate([-camera_x/2,camera_yoff,0])
                difference() {
                    // outside thickness
                    square([camera_x, camera_y]);
                    // inside void
                    offset(r=-camera_wall)
                        square([camera_x, camera_y]);
                }
        }
        // access cylinder
        reset_button();
    }
}

module fin() {
        translate([-fin_xoff-thickness,fin_yoff,-thickness/2])
        rotate([0,90,0])
        linear_extrude(height=thickness) {
            offset(r=2)
                polygon(points=fin);
        }

}

//
module centipro() {
    difference() {
        // translate([-base_width/2,0,-thickness])
        translate([0,0,-thickness])
        baseplate();
        // subtract holes
        base_slot();
        mirror([1,0,0])
            base_slot();
        //
        base_hole();
        // tieline holes
        translate([0,tie1_yoff,0])
            tieline();
        translate([tie23_xoff,tie23_yoff,0])
        rotate([0,0,-58])
            tieline();
        translate([-tie23_xoff,tie23_yoff,0])
        rotate([0,0,58])
            tieline();
    }
    // add on the camera mount
    camera_mount();
    // fins
    fin();
    difference() {
        mirror([1,0,0])
            fin();
        // hole
        reset_button();
    }
}

centipro();
