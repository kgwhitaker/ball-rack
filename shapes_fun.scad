// 
// Collection of reusable shapes.
//

include <BOSL2/std.scad>

// 
// Creates a keyhole shape for a screw
//
// Parameters:
//
// screw_head_diameter: The diameter of the screw head
// screw_shaft_diameter: The diameter of the screw shaft
// keyhole_depth: The depth of the keyhole
// anchor: The anchor point for the keyhole.  See BOSL2/attachments.scad for anchor points.
//
module screw_keyhole(screw_head_diameter, screw_shaft_diameter, keyhole_depth, anchor) {
    rotate([-90, 0, 0]) {
        linear_extrude(height = keyhole_depth) {
            keyhole(l=screw_head_diameter, r1=(screw_head_diameter /2), r2=(screw_shaft_diameter / 2), anchor=anchor);
        }
    }
}
