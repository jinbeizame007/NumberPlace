# coding:utf-8
from copy import deepcopy
from operator import itemgetter
from tqdm import tqdm
from time import time
from random import *

class Solver:
    def __init__(self, b_x, b_y):
        self.errorFlag = False
        self.updateFlag = False
        self.b_x = b_x
        self.b_y = b_y
        self.box_size = b_x * b_y
        self.cell_size = self.box_size * self.box_size
        self.puz = [0 for i in range(self.cell_size)]
        self.candidates = [[True for i in range(self.box_size)] for j in range(self.cell_size)]
        self.answer = [0 for i in range(self.cell_size)]
    def ToStringFromPuzzle(self):
        par = '+'
        for i in range(self.box_size//self.b_x):
            for j in range(self.b_x):
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
                for x in range(self.box_size*self.b_x):
                    if x%self.b_x == 0 and x != 0:
                        line += ' '
                    if self.candidates[y*self.box_size+x//self.b_x][y_*self.b_x+x%self.b_x] == True:
                        line += str(y_*self.b_x+x%self.b_x+1)
                    else:
                        line += '.'
                print(line)
            if y != self.box_size-1:
                print('')
    def SetPuzzle(self,puz):
        self.puz = [0 for i in range(self.cell_size)]
        self.candidates = [[True for i in range(self.box_size)] for j in range(self.cell_size)]
        for i,p in enumerate(puz):
            if p != 0:
                self.PutNumber(i,p)
    def DeleteCandidate(self,p,n):
        if self.candidates[p][n] == False:
            return
        self.candidates[p][n] = False
        count = self.candidates[p].count(True)
        if count == 0 and self.puz[p] == 0:
            self.errorFlag = True
            return
    def PutNumber(self,p,n):
        if self.candidates[p][n-1] == False:
            return
        self.updateFlag = True
        self.puz[p] = n
        n = n - 1
        p_x = (p%self.box_size)//self.b_x
        p_y = p//(self.box_size*self.b_y)
        for i in range(self.box_size):
            self.DeleteCandidate(p,i)
            # 横
            self.DeleteCandidate((p//self.box_size)*self.box_size+i, n)
            # 縦
            self.DeleteCandidate((p%self.box_size)+(i*self.box_size), n)
            # BOX内
            self.DeleteCandidate(p_y*self.box_size*self.b_y+self.box_size*(i//self.b_x)+p_x*self.b_x+(i%self.b_x), n)
    def Singles(self):
        for i,cand in enumerate(self.candidates):
            if cand.count(True) == 1:
                self.PutNumber(i,cand.index(True)+1)
                self.updateFlag = True
                if self.errorFlag == True:
                    return False
        # 縦,横,BOX内で候補が１つだけの数字はその場所で確定する
        for i in range(self.box_size):
            x = (i%self.b_x) * self.b_x
            y = (i//self.b_x) * self.b_y
            p = y * self.box_size + x
            for n in range(self.box_size):
                count = [[],[],[]]
                for j in range(self.box_size):
                    if self.candidates[i*self.box_size+j][n] == True:
                        count[0].append(i*self.box_size+j)
                    if self.candidates[j*self.box_size+i][n] == True:
                        count[1].append(j*self.box_size+i)
                    if self.candidates[p+j%self.b_x+(j//self.b_x)*self.box_size][n] == True:
                        count[2].append(p+j%self.b_x+(j//self.b_x)*self.box_size)
                #if len(count[0]) + len(count[1]) + len(count[2]) == 0:
                #    self.errorFlag = True
                for c in count:
                    if len(c) == 1:
                        self.PutNumber(c[0],n+1)
                        self.updateFlag = True
                        if self.errorFlag == True:
                            return False
    def Solve(self):
        while True:
            self.updateFlag = False
            self.Singles()
            if self.updateFlag and not self.errorFlag:
                continue
            break
        if self.puz.count(0) == 0:
            return True
        else:
            return False
    def CalcScore(self):
        score = 0
        for cand in self.candidates:
            score += cand.count(True) ** 2
        return score

class Generator:
    def __init__(self, bx, by):
        self.bx = bx
        self.by = by
        self.box_size = bx * by
        self.cell_size = self.box_size * self.box_size
        self.puz = [0 for i in range(self.cell_size)]
        self.score = 1000000
        self.solver = Solver(bx, by)
    def ToStringFromPuzzle(self):
        par = '+'
        for i in range(self.box_size//self.bx):
            for i in range(self.bx):
                par += '-'
            par += '+'
        print(par)
        line = ''
        for i,p in enumerate(self.puz):
            if i%self.box_size == 0 and i != 0:
                line += '|'
                print(line)
                line = ''
                if i%(self.box_size*self.by) == 0:
                    print(par)
            if i%self.bx == 0:
                line += '|'
            line += str(p)
        line += '|'
        print(line)
        print(par)
    def CheckRule(self, p, n):
        if self.puz[p] != 0:
            return False
        px = (p%self.box_size)//self.bx
        py = p//(self.box_size*self.by)
        for i in range(self.box_size):
            if self.puz[(p//self.box_size)*self.box_size+i] == n:
                return False
            if self.puz[(p%self.box_size)+(i*self.box_size)] == n:
                return False
            if self.puz[py*self.box_size*self.by+self.box_size*(i//self.bx)+px*self.bx+(i%self.bx)] == n:
                return False
        return True
    def init_puz(self, clue_count):
        self.puz = [0 for i in range(self.cell_size)]
        count = 0
        while count < clue_count:
            flag = True
            p = randint(0,self.cell_size-1)
            n = randint(1,self.box_size)
            if self.CheckRule(p,n):
                count += 1
                self.puz[p] = n
        self.solver.SetPuzzle(self.puz[:])
        self.score = self.solver.CalcScore()
    def LocalSearch(self):
        puzzle = self.puz[:]
        for p in range(self.cell_size):
            puz = puzzle[:]
            if puz[p] == 0:
                continue
            puz[p] = 0
            for q in range(self.cell_size):
                for n in range(1,self.box_size+1):
                    if self.CheckRule(q,n):
                        puz[q] = n
                        self.solver.SetPuzzle(puz[:])
                        score = self.solver.CalcScore()
                        if score < self.score:
                            self.score = score
                            self.puz = puz[:]
                            return True
                        puz[q] = 0
        return False
    def Generate(self, clue_count):
        self.init_puz(clue_count)
        for i in tqdm(range(100000)):
            if self.LocalSearch() == False:
                self.init_puz(clue_count)
                continue
            self.solver.SetPuzzle(self.puz[:])
            if self.solver.Solve():
                self.solver.ToStringFromPuzzle()
                return True

solver = Solver(b_x=3,b_y=3)
# p104
puz_hard = [4,0,0,0,9,0,0,0,7,
        0,3,0,0,0,8,0,2,0,
        0,0,7,0,0,0,5,0,0,
        0,2,0,0,0,0,0,0,0,
        9,0,0,0,5,0,0,0,4,
        0,0,0,0,0,0,0,8,0,
        0,0,8,0,0,0,3,0,0,
        0,9,0,2,0,0,0,5,0,
        5,0,0,0,4,0,0,0,1]

puz_hard2 = [4,0,0,0,0,2,0,0,3,
            0,0,0,0,4,0,1,0,0,
            0,6,0,0,0,1,0,0,0,
            9,0,1,0,0,0,0,0,0,
            0,4,0,0,0,0,0,8,0,
            0,0,0,0,0,0,7,0,6,
            0,0,0,9,0,0,0,5,0,
            0,0,9,0,3,0,0,0,0,
            5,0,0,8,0,0,0,0,4]

# p258
puz_easy = [0,0,0,0,1,0,0,0,0,
            0,9,7,8,0,3,5,4,0,
            0,8,1,0,7,0,2,6,0,
            0,2,0,0,5,0,0,3,0,
            9,0,6,4,0,7,1,0,2,
            0,1,0,0,9,0,0,7,0,
            0,4,5,0,3,0,6,2,0,
            0,7,2,5,0,6,3,8,0,
            0,0,0,0,2,0,0,0,0]

"""
puz17 = []
f = open('17puz49157.txt')
lines = f.readlines()
for l in lines:
    line = []
    for i in range(81):
        if l[i] == '.':
            line.append(0)
        else:
            line.append(int(l[i]))
    puz17.append(line[:])

solver = Solver(3,3)
count = 0
for puz in puz17[0:100]:
    solver = Solver(3,3)
    solver.SetPuzzle(puz)#
    if solver.Solve():
        count += 1
print(count)
"""
#solver.SetPuzzle(puz_easy)
#print(solver.Solve())
#solver.ToStringFromPuzzle()
generator = Generator(3,3)
generator.Generate(20)
#generator.ToStringFromPuzzle()
#solver.SetPuzzle(generator.puz[:])
#print(solver.Solve())
#solver.ToStringFromPuzzle()
