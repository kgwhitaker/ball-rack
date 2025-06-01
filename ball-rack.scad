//
// A holder for balls. Wool Dryer Balls.  Lacrosse Balls.  Whatever balls you want to hold. 
//

// The Belfry OpenScad Library, v2:  https://github.com/BelfrySCAD/BOSL2
include <BOSL2/std.scad>

// *** Model Parameters ***
/* [Model Parameters] */

// Diameter of the ball in millimeters.  Include spacing so that it is not too tight.
// 64mm for a lacrosse ball, 80mm for a wool dryer ball.
ball_diameter = 64;

// Number of balls to hold in each column.
balls_per_column = 2;

// Number of columns
columns = 1;

// Thickness of the walls for the holder.
wall_thickness = 2;

// Percentage of a single ball to trim off the top of the ball rack.
// This is to let the top of the ball show out the top, and lets a 
// three ball rack fit in a 210mm tall printer.
// 0.50 = 50% of the ball diameter.  0=Ball is fully enclosed.
trim_top_pct = 0; // [0:0.1:1]

// Set to true to put cutouts on the sides of the holder.
side_cutouts = true;

/* [Feeder Tray] */

// If true, the ball holder will have a ball feeder at the bottom.
// Otherwise the balls need to be pulled from the top.
feeder_tray = false;

//
// Scale for the feeder tray, if desired.  This will make the catch tray 
// a percentage of the ball diameter.  I think the aesthetics are better if the catch 
// tray is less than the diameter of the ball.  1=No scaling.
feeder_scale = 0.6; // [0.1:0.1:1]

/* [Screw Mount] */

// Keyhole for screw mounting of the ball holder.
screw_mount = false;

// Screw Head Diameter for the mounting screw.
screw_head_diameter = 12;

// Screw Shaft Diameter for the mounting screw.
screw_shaft_diameter = 6;

// *** "Private" variables ***
/* [Hidden] */

// OpenSCAD System Settings
$fa = 1;
$fs = 0.4;

// *** Calculated Global Vars *** 

// Radius of the notch cutout curved edges.  Calculate at 20% of the ball diameter.
notch_radius = ball_diameter * 0.20;

// Number of walls to accommodate the columns
walls = (columns - 1) + 2;

// Radius of the fillets for the outer edges of the holder.
fillet_radius = 2;

// Overall dimensions width of the holder
width = (walls * wall_thickness) + (ball_diameter * columns);
height = (balls_per_column * ball_diameter) - (ball_diameter * trim_top_pct) + wall_thickness; // 1 wall at the bottom
depth = ball_diameter + (wall_thickness * 2); // front and back walls. 

// Width of the cutouts on the sides.  1/2 of the ball diameter.
notch_width = (ball_diameter / 2); 

// Put a hole in the bottom to reduce filament use and center the ball in the holder.
//
// Parameters:
//
// column - The column number of the ball rack to place the hole in.
//
module bottom_hole(column = 0) {
    hole_diameter = ball_diameter / 2; 
    translate([
        (column * (ball_diameter) + (ball_diameter / 2)) + wall_thickness, 
        (ball_diameter / 2) + wall_thickness, 
        0]) {

        sphere(r = hole_diameter / 2);
    }
}

// 
// Notch on the outer edge of the holder.
//
// Parameters:
//
// x_pos - The x position of the notch.
//
module outer_notch(x_pos) {
    translate([
        x_pos, 
        (ball_diameter / 2) - (notch_width / 2) + wall_thickness, 
        notch_width + wall_thickness]) 
        {
            cuboid([2 * wall_thickness, notch_width, balls_per_column * ball_diameter], 
                anchor=FRONT+LEFT+BOT, rounding=notch_radius, edges=[BOT], except=[LEFT, RIGHT]);
        }
}

//
// Screw Keyhole for hanging the holder.
//
// Parameters:
//
// x_pos - The x position of the notch.
//
module screw_hole(x_pos) {
    translate([
        x_pos, 
        -(wall_thickness / 2), 
        height - (screw_head_diameter * 2.5)]) 
        {
            screw_keyhole(screw_head_diameter, screw_shaft_diameter, (wall_thickness * 2), TOP+LEFT);
        }
}

// 
// Notch for the front of the holder.
//
// Parameters:
//
// column - The column number of the ball rack to place the notch in.
// rounded - If true, round the edges on the bottom of the notch.
//
module front_notch(column = 0, rounded = true) {
    relative_z = notch_width + wall_thickness; 
    translate([
        (((ball_diameter + wall_thickness) * column) + (notch_width / 2) + wall_thickness),
        ball_diameter - wall_thickness,
        relative_z])
    {
        if (rounded) {
            cuboid([notch_width, 4 * wall_thickness, height], 
                anchor=FRONT+LEFT+BOT, rounding=notch_radius, edges=[BOT], except=[FRONT, BACK]);
        } else {
            cuboid([notch_width, 4 * wall_thickness, height], 
                anchor=FRONT+LEFT+BOT);
        }

        // Rounds the top corners of the notch
        translate([0,0,relative_z]) {
            // the 0.1 addition to the height is to handle rounding errors that were causing a very thin bridge.
            cuboid([notch_width, 4 * wall_thickness, height - (relative_z * 2) + 0.1], anchor=FRONT+LEFT+BOT, rounding=-(notch_radius / 2), edges=[TOP], except=[FRONT, BACK]);
        }         
    }
}

// 
// Creates a ramp for the feeder tray.
// 
// Parameters:
//
// column - The column number of the ball rack to place the notch in.
//
module feeder_ramp(column = 0) {
    translate([column * (ball_diameter + wall_thickness) + wall_thickness,
        ball_diameter,
        0]) {
        rotate([0, 0, -90]) {
            prismoid(
                size1=[ball_diameter,ball_diameter], 
                size2=[0,ball_diameter], 
                shift=[(ball_diameter / 2),0], 
                h=(ball_diameter * 0.75), 
                anchor=BOT+LEFT+FRONT
                );
        }
    }
}

//
// Creates the feeder catcher tray.
//
module feeder_tray() {    
    translate([0,ball_diameter,0]) {
        cuboid([width, depth * feeder_scale, (ball_diameter / 2)], anchor=FRONT+LEFT+BOT, rounding=fillet_radius,  except=BOT);
    }
}

//
// Feeder "tube" for the feeder tray. Cutout from the column into the front feeder tray.
//
// Parameters:
//
// column - The column number of the ball rack to place the notch in.
//
module feeder_tube(column = 0) {

    // bottom part of cutout using rounded corners.
    translate(
        [column * (wall_thickness + ball_diameter) + wall_thickness, 
        ball_diameter - (wall_thickness * 3), 
        wall_thickness]) {

            // the 0.1 in the height is to force an overlap of the bottom half and the top half of the cutout.
            cuboid([ball_diameter, ((ball_diameter + (wall_thickness * 4)) * feeder_scale), ((ball_diameter / 2) - wall_thickness + 0.1)], 
                anchor=FRONT+LEFT+BOT, 
                rounding=(fillet_radius * 2),   
                except=[FRONT, TOP]);
        }

    // Top part of the cutout using a chamfer at the top to avoid overhangs when printing.
    translate(
        [column * (wall_thickness + ball_diameter) + wall_thickness, 
        ball_diameter - (wall_thickness * 3), 
        (ball_diameter / 2)]) {
            cuboid([ball_diameter, ball_diameter + (wall_thickness * 4), (ball_diameter * 1.25)], 
                anchor=FRONT+LEFT+BOT, 
                chamfer=(ball_diameter / 2),   
                except=[FRONT, BACK, BOT]);
        }

}

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


//
// Main function build the model in its entirety.
//
module build_model() {
    // Creates the overall ball holder.
    difference() {

        // Outer cube that defines the overall ball holder.
        union() {
            cuboid([width, depth, height], anchor=FRONT+LEFT+BOT, rounding=fillet_radius,  except=BOT);
            if (feeder_tray) feeder_tray();
        }   

        
        // Builds the columns of the ball holder.
        for (i = [0 : columns - 1]) {
        
            // Inner cube (hollow part). one for each row separated by a wall.   
            translate([(i * (ball_diameter + wall_thickness) + wall_thickness), 
                wall_thickness, wall_thickness]) {            
                cuboid([ball_diameter, ball_diameter, height], anchor=FRONT+LEFT+BOT, rounding=(fillet_radius * 2));
            }

            if (feeder_tray) {
                front_notch(i, false);
                feeder_tube(i);
            } else {
                // Notch in the front of the holder. Curved for the non-feeder version.
                front_notch(i, true);

                // Bottom hole to reduce filament use and center the ball in the holder.
                bottom_hole(i);
            }
        }    
        
        // Put a notch on the left and right sides to reduce filament use.
        if (side_cutouts) {
            // Right notch
            outer_notch(x_pos = -1 * (wall_thickness / 2));

            // Left notch
            outer_notch(x_pos = width - (wall_thickness + (wall_thickness / 2)));
        }


        // Put in a keyhole for the screw to hang the holder.
        if (screw_mount) {
            // Right Screw Keyhole
            screw_hole(x_pos = screw_head_diameter);

            // Left Screw Keyhole
            screw_hole(x_pos = width - (screw_head_diameter / 2) - wall_thickness - screw_head_diameter);
        }
    } // end difference

    if (feeder_tray) {
        // Layer in feeder ramps for the feeder tray.
        for (i = [0 : columns - 1]) {
            feeder_ramp(i);
        }

    }

}

// Build the model.
build_model();
