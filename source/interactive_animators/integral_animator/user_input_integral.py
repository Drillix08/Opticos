from manim import *
import math
# Controls the background color of the scene
background_color = rgb_to_color((0.16, 0.16, 0.16))

# Determines integral range to be solved for. Axis will automatically adjust to fit the range.
integral_xRange = [0, 2]

# The color of integral estimate boxes that appear under the graph
integral_box_color_outline = rgb_to_color((0.0, 0.0, 0.0))
integral_box_color_fill = rgb_to_color((0.6, 0.4, 0.6))

# Controls color of integral estimate boxes that are moved to the area number.
# Handles positive and negative colors
sum_of_integral_boxes_outline_positive = rgb_to_color((0.0, 0.0, 0.0))
#sum_of_integral_boxes_fill_positive = rgb_to_color((0.0, 0.6, 0.6))
sum_of_integral_boxes_fill_positive = rgb_to_color((0.0, 255.0, 0.0))
sum_of_integral_boxes_outline_negative = rgb_to_color((0.0, 0.0, 0.0))
#sum_of_integral_boxes_fill_negative = rgb_to_color((0.6, 0.4, 0.0))
sum_of_integral_boxes_fill_negative = rgb_to_color((255.0, 0.0, 0.0))

# Controls the outline and color of the box to the right of the graph that shows the area under the curve.
box_of_area_under_curve_outline = rgb_to_color((6.0, 6.0, 0.0))
box_of_area_under_curve_fill = rgb_to_color((0.6, 0.6, 0.0))

# Controls function color and function
function_color = rgb_to_color((0.2, 0.6, 0.8))
def continuous_function(x):
    #return x**5-x
    return math.sin(x - 1)
    #return 1/x