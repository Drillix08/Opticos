from manim import *

class LogScalingExample(Scene):
    def construct(self):
        ax = Axes(
            x_range=[0, 10, 1],
            y_range=[-2, 6, 1],
            tips=False,
            axis_config={"include_numbers": True},
            y_axis_config={"scaling": LogBase(custom_labels=True)},
        )

        # x_min must be > 0 because log is undefined at 0.
        graph = ax.plot(lambda x: x ** 2, x_range=[0.001, 10], use_smoothing=False)
        self.add(ax, graph)


class NegitiveTest(Scene):
    def construct(self):
        ax = Axes(
            x_range=[-10, 10, 1],
            y_range=[-1000, 1000, 100],
            tips=False,
            axis_config={"include_numbers": True},
        )

        # x_min must be > 0 because log is undefined at 0.
        graph = ax.plot(lambda x: (-1 * x) ** 3, x_range=[-10, 10], use_smoothing=False)
        self.add(ax, graph)


class DefinitionOfADerivitive(Scene):

    def construct(self):
        whatever = 2



    # I stole this function from david
    #Function that is graphed out and used to find output values at each frame
    def func(self, fstr, x, op):
        if isinstance(x, (np.float32, np.float64)):
            x = float(x)
        x = str(x)

        #The following code segment parses the string representing the function the user inputted
        #replaces instances where number are concated with x to be <num>*x
        if (fstr[0:2] == "-x"):
            fstr = "-1*" + fstr[1:len(fstr)]
        i = 0
        while(i < len(fstr)):
            if (fstr[i] == "x"):
                if (fstr[i - 1].isdigit() and i != 0):
                    fstr = fstr[:i] + "*" + x + fstr[i+1:]
                else:
                    fstr = fstr[:i] + x + fstr[i+1:]
            i += 1
        if (fstr[0:2] == "--"):
            fstr = "-1*" + fstr[1:len(fstr)]

        #Replaces instances of - between two  numbers to be +-
        i = 0
        while(i < len(fstr)):
            #Notes checks that theres no e character befor the minus sign to accomodate <num>e-n scientific representation
            if (fstr[i] == "-" and fstr[i - 1] != "+" and fstr[i - 1] != "*" and fstr[i - 1] != "e" and i != 0):
                fstr = fstr[:i] + "+-1*" + fstr[i+1:]
            i += 1
            #print(x, 4)
        #divide string into different parts based on the current operation
        nums = fstr.split(op)
        
        #For each part if it's a number, leave it, otherwise repeat 
        #previous steps using next operation of next highest precedence
        for i in range(0, len(nums)):
            if not(nums[i].isdigit()):
                if (op == "+"):
                    nums[i] = self.func(nums[i], x, '*')
                elif (op == "*"):
                    nums[i] = self.func(nums[i], x, '^')
                    
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
            


    def derivitve_calc(self, a):
        h = 0.00000000001
        return (func(a+h) - func(a))/h

    def construct(self):
        h = 0.00000000001

        plane = NumberPlane(x_range = [-10, 10, 1], x_length = 4, 
                            y_range = [-10, 10, 1], y_length = 4).add_coordinates()
        
        ax = Axes(
            x_range=[-10, 10, 1],
            y_range=[-10, 10, 1],
            tips=False,
            axis_config={"include_numbers": True},
        ) 
        # x_min must be > 0 because log is undefined at 0.
        graph = ax.plot(lambda x: (x*3) ** 2, x_range=[-10, 10, 0.1], use_smoothing=True)
        graph2 = ax.plot(lambda v: (((v-h)*3)**2 - (v*3)**2)/h, x_range=[-10, 10, 0.1], use_smoothing=True)

        #self.add(ax, graph)
        #self.add(ax, graph2)

        self.play(FadeIn(ax),
                  Succession(
                      Add(graph2)
                  )
                  
                  
                  )
        #self.play(Create(graph.animate(lag_ratio=0.2, run_time=1.5)))
        self.play(Create(graph2))


