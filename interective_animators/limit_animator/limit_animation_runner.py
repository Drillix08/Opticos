from manim import *

#config.frame_width = 8  # Default is 14 units wide
#config.frame_height = 8  # Default is 8 units high

class hello(Scene):
    def __init__(self, color = RED, function = "x", approach = 0, side = -1, **kwargs):
        super().__init__(**kwargs)
        self.function = function
        self.color = color
        self.approach = approach
        self.side = side

    #Function that is graphed out and used to find output values at each frame
    def func(self, fstr, x, op):
        if isinstance(x, (np.float32, np.float64)):
            x = float(x)

        x = str(x)
        #replaces instances where number are concated with x to be <num>*x
        i = 0
        while(i < len(fstr)):
            if (fstr[i] == "x"):
                if (fstr[i - 1].isdigit() and i != 0):
                    fstr = fstr[:i] + "*" + x + fstr[i+1:]
                else:
                    fstr = fstr[:i] + x + fstr[i+1:]
            i += 1
        
        #Replaces instances of - between two  numbers to be +-
        i = 0
        while(i < len(fstr)):
            #Notes checks that theres no e character befor the minus sign to accomodate <num>e-n scientific representation
            if (fstr[i] == "-" and fstr[i - 1] != "+" and fstr[i - 1] != "e" and i != 0):
                fstr = fstr[:i] + "+-1*" + fstr[i+1:]
            i += 1
        
        #divide string into different parts based on the current operation
        nums = fstr.split(op)
        
        #For each part if it's a number, leave it, otherwise repeat 
        #previous steps using next operation of next highest precedence
        for i in range(0, len(nums)):
            if not(nums[i].isdigit()):
                if (op == "+"):
                    nums[i] = self.func(nums[i], 'x', '*')
                elif (op == "*"):
                    nums[i] = self.func(nums[i], 'x', '^')
                    
        #Perfrom nums[0] <op> nums[1] <op> ... <op> nums[len(nums - 1)]
        
        total = float(nums[0])
        for i in range(1, len(nums)):
            if (op == '+'):
                total += float(nums[i])
            elif (op == "*"):
                total *= float(nums[i])
            elif (op == "^"):
                total = total ** float(nums[i])
        
        return total
             
    def construct(self):

        #-------------------------------------------------
        #Customizable parameters
        scale = 1
        backgroundColor = BLACK
        functionColor = self.color

        #approach = 0 #value x approaches
        #side = -1 #-1 to approach from left, 1 to approach from right

                        
            #return -1 * x**2 + 2
        #-------------------------------------------------

        
        self.camera.background_color = backgroundColor

        #initializes the x and y axes along with the range of values they display
        ax = Axes(
            x_range=[-5, 5], y_range=[-5, 5], axis_config={"include_tip": False},
            x_length = 7,
            y_length = 7
        )
        labels = ax.get_axis_labels(x_label="x", y_label="f(x)").scale(scale) # Labels each axis

        #Draw graph that plot out function defined by func()
        graph = ax.plot(lambda x: self.func(self.function, x, "+"), color = functionColor, discontinuities=[1])

        graph_group = VGroup(ax, graph)
        graph_group.scale(scale) 
        graph_group.to_corner(UR)

        #In manim, a value tracker is an object that displays a constantly updated value
        #By default it starts at some initial value and increases or decreases at a constant rate
        #until it reaches it's defined ending value
        xTracker = ValueTracker(4*self.side)

        #Every frame the x and y value of the point gets updated by getting the current value of xTracker. The exact value gets directly displayed
        #for x and for y the value from the value tracker is plugged into the method func() and the output is what the y value gets set equal to
        coordsRect = Rectangle(width = 4.6, height = 2, color = BLUE).to_edge(UL).shift([-0.5, 0.5, 0])
        x_value = always_redraw(lambda: DecimalNumber(num_decimal_places = 5).to_edge(UL).shift([1, 0.3, 0]).set_value(xTracker.get_value()))
        y_value = always_redraw(lambda: DecimalNumber(num_decimal_places = 5).to_edge(UL).shift([1.7, -0.75, 0]).set_value(self.func(self.function, xTracker.get_value(), "+")))

        #Define starting point at the initial point xTracker is defined to
        initial_point = [ax.coords_to_point(xTracker.get_value(), self.func(self.function, xTracker.get_value(), "+"))]
        dot = Dot(point = initial_point).scale(scale) #Creates point that moves along function

        #Updates the x-coordinate of the point to match the most recent value of xTracker
        #also plugs the x-coordinate into func() to get the y-value
        dot.add_updater(lambda x: x.move_to(ax.c2p(xTracker.get_value(), self.func(self.function, xTracker.get_value(), "+"))))

        #Draws text on screen using Latex
        xText = MathTex(r"x = ").to_edge(UL).shift([-0.3, 0.2, 0])
        functionText = MathTex(r"f(x) = ").to_edge(UL).shift([-0.3, -0.7, 0])
        limitText = MathTex(r"\lim \limits_{x \to 0^-} f(x) = " + str(self.func(self.function, self.approach, "+"))).to_edge(UL).shift([0, -2.75, 0])
        
        #Add all defined elements to the scene
        self.add(ax, labels, graph, dot, coordsRect, x_value, xText, y_value, functionText)
        
        #Run value tracker, starts from -4 and and at -0.05
        self.play(xTracker.animate.set_value(self.approach + 0.05*self.side), run_time = 3)
        
        #Since the actual values from the value tracker are a bit messy at the end (due to the nature of computer calculations)
        #The final values are manually set to slightly neater numbers that better explain the concept of a limit
        self.remove(x_value)
        self.remove(y_value)
        #x_value = DecimalNumber(num_decimal_places = 5).to_edge(UL).shift([1, 0, 0]).set_value(-0.00001)
        #y_value = DecimalNumber(num_decimal_places = 5).to_edge(UL).shift([1.8, -1, 0]).set_value(1.99999)
        if self.func(self.function, self.approach + self.side*0.05, "+") > self.func(self.function, self.approach, "+"):
            offset = -1
        else:
            offset = 1
        x_value = DecimalNumber(num_decimal_places = 5).to_edge(UL).shift([1, 0.3, 0]).set_value(self.approach + self.side*0.00001)
        y_value = DecimalNumber(num_decimal_places = 5).to_edge(UL).shift([1.7, -0.75, 0]).set_value(self.func(self.function, self.approach, "+") + offset*self.side*0.00001)
        self.add(x_value)
        self.add(y_value)
        
        #Display text that shows the value of the limit
        self.play(FadeIn(limitText))
        
        self.wait(3)