from manim import *


class BigPenis(Scene):
    def construct(self):
        circle = Circle().shift([1, -2, 0])  # create a circle
        circle2 = Circle().shift([-1,-2, 0])
        #circle2.next_to(circle, RIGHT)
        rect = Rectangle(width = 2, height = 4, color = PINK).shift([0, 1, 0])

        circle.set_fill(BLUE, opacity=0.5)  # set the color and transparency
        circle2.set_fill(BLUE, opacity=0.5)  # set the color and transparency
        rect.set_fill(PINK, opacity=0.5)  # set the color and transparency


        self.play(Create(circle))  # show the circle on screen
        self.play(Create(circle2))  # show the circle on screen 
        self.play(Create(rect))  # show the circle on screen 



