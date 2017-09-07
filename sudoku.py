# -*- coding: utf-8 -*-
"""
Created on Thu Sep  7 11:54:24 2017

@author: hayakawa_t
"""
import time

def str2puz(s):
    puz = []
    for c in s:
        if c == '\n':
            break
        if c == '.':
            puz.append(0)
        else:
            puz.append(int(c))
    return puz


class Solver:
    def __init_house2cells(self):
        self.__house2cells = []
        # box
        for i in range(self.board_size):
            bx = i % self.box_size_y * self.box_size_x
            by = i // self.box_size_y * self.box_size_y
            box = []
            for j in range(self.board_size):
                x = bx + j % self.box_size_x
                y = by + j // self.box_size_x
                box.append(x + y * self.board_size)
            self.__house2cells.append(box)
        # row
        for y in range(self.board_size):
            row = []
            for x in range(self.board_size):
                row.append(x + y * self.board_size)
            self.__house2cells.append(row)
        # column
        for x in range(self.board_size):
            column = []
            for y in range(self.board_size):
                column.append(x + y * self.board_size)
            self.__house2cells.append(column)

    def __init_cell2houses(self):
        self.__cell2houses = [[] for i in range(self.grid_size)]
        self.__cell2housepos = [[] for i in range(self.grid_size)]
        for i in range(len(self.__house2cells)):
            for j in range(len(self.__house2cells[i])):
                self.__cell2houses[self.__house2cells[i][j]].append(i)
                self.__cell2housepos[self.__house2cells[i][j]].append(j)

    def __init_cell2cells(self):
        self.__cell2cells = [[] for i in range(self.grid_size)]
        for i in range(self.grid_size):
            for j in self.__cell2houses[i]:
                for k in self.__house2cells[j]:
                    if i !=k:
                        self.__cell2cells[i].append(k)
            self.__cell2cells[i] = list(set(self.__cell2cells[i]))

    def __init_num2othernums(self):
        self.__num2othernums = [[] for i in range(self.board_size)]
        for i in range(self.board_size):
            for j in range(self.board_size):
                if i != j:
                    self.__num2othernums[i].append(j)

    def __init_bit2num(self):
        self.__bit2num = {}
        for i in range(self.board_size):
            self.__bit2num[1 << i] = i

    def __init__(self, box_size_x, box_size_y):
        self.box_size_x = box_size_x
        self.box_size_y = box_size_y
        self.board_size = self.box_size_x * self.box_size_y
        self.grid_size = self.board_size * self.board_size

        self.__init_house2cells()
        self.__init_cell2houses()
        self.__init_cell2cells()
        self.__init_num2othernums()
        self.__init_bit2num()

    def deleteCandidate(self, p, n):
        if (self.__candidates[p] & (1 << n)) == 0:
            return
        if self.error_flag == True:
            return

        self.__candidates[p] &= ~(1 << n)
        for (h_i, h_p) in zip(self.__cell2houses[p], self.__cell2housepos[p]):
            self.__house_candidates[h_i][n] &= ~(1 << h_p)

        for h_i in self.__cell2houses[p]:
            count = bin(self.__house_candidates[h_i][n]).count('1')
            if count == 0:
                self.error_flag = True
                return
            if count == 1:
                h_p = self.__bit2num[self.__house_candidates[h_i][n]]
                self.putNumber(self.__house2cells[h_i][h_p], n)

        count = bin(self.__candidates[p]).count('1')
        if count == 0:
            self.error_flag = True
            return
        if count == 1:
            self.putNumber(p, self.__bit2num[self.__candidates[p]])

    def putNumber(self, p, n):
        if self.error_flag == True:
            return
        if self.answer[p] != 0:
            if self.answer[p] != n + 1:
                self.error_flag = True
            return
        
        if (self.__candidates[p] & (1 << n)) == 0:
            self.error_flag = True
            return

        self.answer[p] = n + 1
        self.space_count -= 1

        for i in self.__cell2cells[p]:
            self.deleteCandidate(i, n)
        for i in self.__num2othernums[n]:
            self.deleteCandidate(p, i)

    def setPuzzle(self, puz):
        self.answer = [0 for i in range(self.grid_size)]
        self.space_count = self.grid_size
        x1ff = (1 << self.board_size) - 1
        self.__candidates = [x1ff for i in range(self.grid_size)]
        self.__house_candidates = [[x1ff for i in range(self.board_size)] for j in range(len(self.__house2cells))]
        self.error_flag = False

        for i, n in enumerate(puz):
            if i == self.grid_size:
                return
            if n > 0:
                self.putNumber(i, n - 1)

    def isSolved(self):
        if self.error_flag == True:
            return False
        if self.space_count != 0:
            return False
        return True



solver = Solver(3,3)
f = open('17puz49157.txt')
line = f.readline()
puzzle_count = 0
solved_count = 0
start = time.time()
while line:
    puzzle_count += 1
    solver.setPuzzle(str2puz(line))
    if solver.isSolved() == True:
        solved_count += 1
    line = f.readline()

    if puzzle_count % 1000 == 0:
        elapsed_time = time.time() - start
        print('{0} : {1}/{2}'.format(elapsed_time, solved_count, puzzle_count))

elapsed_time = time.time() - start
print('{0} : {1}/{2}'.format(elapsed_time, solved_count, puzzle_count))
