import numpy as np

class Solver:
    def __init__(self, b_x, b_y):
        self.b_x = b_x
        self.b_y = b_y
        self.box_size = b_x * b_y
        self.cell_size = self.box_size * self.box_size
        self.puz = [0 for i in range(self.cell_size)]
        self.candidates = [[True for i in range(b_x*b_y+1)] for j in range(self.cell_size)]
        self.answer = [0 for i in range(self.cell_size)]
    def ToStringFromPuzzle(self):
        par = '+'
        for i in range(self.box_size/self.b_x):
            for i in range(self.b_x):
                par += '-'
            par += '+'
        print(par)
        line = ''
        for i,p in enumerate(self.puz):
            if i%self.box_size == 0 and i != 0:
                line += '|'
                print(line)
                line = ''
                if i%(self.box_size*self.b_y) == 0:
                    print(par)
            if i%self.b_x == 0:
                line += '|'
            line += str(p)
        line += '|'
        print(line)
        print(par)
    def ToStringFromCandidates(self):
        for y in range(self.box_size):
            for y_ in range(self.b_y):
                line = ''
                for x in range(self.box_size*self.box_w):
                     if self.candidates[y*self.box_size+x//self.b_x][y_*self.box_size+x%self.b_x] == True:
                         line += str(y_*self.box_size+x%self.b_x)
    def DeleteCandidate(self,p,n):
        self.candidates[p][n] = False
    def PutNumber(self,p,n):
        self.puz[p] = n
        p_x = (p%self.box_size)//self.b_x
        p_y = p//self.box_size
        for i in range(self.box_size):
            self.candidates[(p//self.box_size)+i][n] = False
            self.candidates[(p%self.box_size)*(i*self.box_size)][n] = False
            self.candidates[p_y+(self.box_size*(i//self.d_x))+p_x+(i%self.b_x)]
        """
        for i in range(self.b_x*self.b_x):
            self.candidates[(p%(self.b_x*self.b_x))+i][n] = False
        for i in range(self.b_y*self.b_y):
            self.candidates[(p%(self.b_y*self.b_y))+i][n] = False
        for i in range(self.b_x*self.b_y):
            self.candidates[(p%())]
        """

solver = Solver(b_x=3,b_y=2)
solver.ToStringFromPuzzle()
