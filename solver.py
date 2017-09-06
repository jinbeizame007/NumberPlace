# coding:utf-8
import numpy as np
from copy import deepcopy
from operator import itemgetter
from tqdm import tqdm
from time import time

class Solver:
    def __init__(self, b_x, b_y):
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
        for i,p in enumerate(puz):
            if p != 0:
                self.PutNumber(i,p)
    def DeleteCandidate(self,p,n):
        self.candidates[p][n] = False
    def PutNumber(self,p,n):
        self.puz[p] = n
        n = n - 1
        p_x = (p%self.box_size)//self.b_x
        p_y = p//(self.box_size*self.b_y)
        for i in range(self.box_size):
            self.candidates[p][i] = False
            # 横
            self.candidates[(p//self.box_size)*self.box_size+i][n] = False
            # 縦
            self.candidates[(p%self.box_size)+(i*self.box_size)][n] = False
            # BOX内
            self.candidates[p_y*self.box_size*self.b_y+self.box_size*(i//self.b_x)+p_x*self.b_x+(i%self.b_x)][n] = False
    def CheckAnsweable(self):
        log = []
        log2 = []
        for step in tqdm(range(1000000)):
            start = time()
            # 確定した場所は埋める
            flag = True
            while flag:
                flag = False
                # 候補の数字が1つだけの場合は埋める
                for i,cand in enumerate(self.candidates):
                    if cand.count(True) == 1:
                        self.PutNumber(i,cand.index(True)+1)
                        flag = True
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
                            if self.candidates[i*self.box_size+j][n] == True:
                                count[1].append(i*self.box_size+j)
                            if self.candidates[p+j%self.b_x+(j//self.b_x)*self.box_size][n] == True:
                                count[2].append(p+j%self.b_x+(j//self.b_x)*self.box_size)
                        for c in count:
                            if len(c) == 1:
                                self.PutNumber(c[0],n+1)
                                flag = True

            if self.puz.count(0) == 0:
                return True

            # 候補が無くなったら１つ前に戻す
            # 各セルに各数字を置いた際の削除可能な候補の数を求める
            start=time()
            count = []
            for i,cand in enumerate(self.candidates):
                can_count = cand.count(True)
                for j,c in enumerate(cand):
                    if c == True:
                        # [セル番号*box_size + セル内の数字]
                        count.append([i*self.box_size+j,can_count])
            # ログ：puz, candidates, 優先度順の候補
            if len(count) == 0:
                self.puz = deepcopy(log[-1][0])
                self.candidates = deepcopy(log[-1][1])
                while len(log[-1][2]) == 0:
                    del log[-1]
                    self.puz = log[-1][0][:]
                    self.candidates = deepcopy(log[-1][1])
            else:
                start = time()
                count.sort(key=itemgetter(1))
                log.append([self.puz[:], deepcopy(self.candidates), count])
            # セル番号,数字
            start = time()
            self.PutNumber(log[-1][2][0][0]//self.box_size, log[-1][2][0][0]%self.box_size+1)
            del log[-1][2][0]
            if self.puz.count(0) == 0:
                return True
            if len(log) == 0:
                return False
            if count==0:
                if self.puz.count(0) == 0:
                    return True
                else:
                    return False


solver = Solver(b_x=3,b_y=3)
# p104
puz = [4,0,0,0,9,0,0,0,7,
        0,3,0,0,0,8,0,2,0,
        0,0,7,0,0,0,5,0,0,
        0,2,0,0,0,0,0,0,0,
        9,0,0,0,5,0,0,0,4,
        0,0,0,0,0,0,0,8,0,
        0,0,8,0,0,0,3,0,0,
        0,9,0,2,0,0,0,5,0,
        5,0,0,0,4,0,0,0,1]
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

solver.SetPuzzle(puz)
print(solver.CheckAnsweable())
solver.ToStringFromPuzzle()

"""
while True:
    p, n = map(int, input().split())
    solver.PutNumber(p, n)
    solver.ToStringFromPuzzle()
    #print(solver.CheckAnsweable())
    solver.ToStringFromCandidates()
"""
