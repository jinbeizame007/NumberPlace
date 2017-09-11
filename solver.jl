#using ProfileView
#using ProgressMeter
#using Base.Threads

const bx = 3
const by = 3
const box_size = bx * by
const cell_size = box_size * box_size
global updateFlag = [false]
global errorFlag = [false]

type Solver
    puzzle::Array{Int64,2}
    candidates::Array{Int64,3}
    function Solver()
        new(zeros(Int64,(box_size,box_size)),ones(Int64,(box_size,box_size,box_size)))
    end
end
function ToStringFromPuzzle(puz::Array{Int64,2})
    par = "+---+---+---+"
    line = ""
    for y in 1:box_size
        if y % 3 == 1
            println(par)
        end
        for x in 1:box_size
            if x % 3 == 1
                print("|")
            end
            print(puz[y,x])
        end
        println("|")
    end
    println(par)
end
function ToStringFromCandidates(cand::Array{Int64,3})
    for y in 1:box_size
        for y_ in 1:by
            for x in 1:box_size
                if x != 1
                    print(" ")
                end
                for x_ in 1:bx
                    if cand[y,x,(y_-1)*bx+x_] == 1
                        print((y_-1)*bx+x_)
                    else
                        print(".")
                    end
                end
            end
            println("")
        end
        println("")
    end
end
function DeleteCandidate(puzzle::Array{Int64,2},candidates::Array{Int64,3},y::Int64,x::Int64,n::Int64)
    if puzzle[y,x] != 0
        return
    end
    candidates[y,x,n] = 0
    count = 0
    for i in 1:box_size
        if candidates[y,x,i] == 1
            count += 1
        end
    end
    if count == 0
        errorFlag[1] = true
    end
end
function PutNumber(puzzle::Array{Int64,2},candidates::Array{Int64,3},x::Int64,y::Int64,n::Int64)
    if candidates[y,x,n] == 0
        errorFlag[1] = true
        return
    end
    for i in 1:box_size
        candidates[y,x,i] = 0
    end
    candidates[y,x,n] = 1
    puzzle[y,x] = n
    px = (x-1)÷bx * bx + 1
    py = (y-1)÷by * by + 1
    for i in 1:box_size
        DeleteCandidate(puzzle,candidates,y,x,i)
        DeleteCandidate(puzzle,candidates,y,i,n)
        DeleteCandidate(puzzle,candidates,i,x,n)
        DeleteCandidate(puzzle,candidates,py+(i-1)÷bx,px+(i-1)%bx,n)
    end
end
function SetPuzzle(puzzle::Array{Int64,2},candidates::Array{Int64,3},puz::Array{Int64,2})
    errorFlag[1] = false
    for y in 1:box_size
        for x in 1:box_size
            puzzle[y,x] = 0
            for n in 1:box_size
                candidates[y,x,n] = 1
            end
        end
    end
    #puzzle = zeros(Int64,(box_size,box_size))
    #candidates = ones(Int64,(box_size,box_size,box_size))
    for y in 1:box_size
        for x in 1:box_size
            if puz[y,x] != 0
                PutNumber(puzzle,candidates,x,y,puz[y,x])
            end
        end
    end
end
function Singles(puzzle::Array{Int64,2},candidates::Array{Int64,3})
    if errorFlag[1]
        return
    end
    n2 = 0
    for y in 1:box_size
        for x in 1:box_size
            count = 0
            if puzzle[y,x] != 0
                continue
            end
            for n in 1:box_size
                if candidates[y,x,n] == 1
                    count += 1
                    if count>1
                        break
                    end
                    n2 = n
                end
            end
            if count != 1
                continue
            end
            PutNumber(puzzle,candidates,x,y,n2)#findfirst(candidates[y,x],1))
            if errorFlag[1] == true
                updateFlag[1] = false
                return
            end
            updateFlag[1] = true
        end
    end
    count2 = zeros(Int64,3)
    count = zeros(Int64,(3,2))
    for i in 1:box_size
        #count2 = zeros(Int64,(box_size,3))
        for n in 1:box_size
            for j in 1:3
                for l in 1:2
                    count[j,l] = 0
                end
                count2[j] = 0
            end
            #count = zeros(Int64,(3,2))#[[],[],[]]
            #count2 = zeros(Int64,3)
            px = (i-1)%bx * bx + 1
            py = (i-1)÷bx * by + 1

            for j in 1:box_size
                if count2[1] < 2 && candidates[i,j,n] == 1
                    count[1,1] = j
                    count[1,2] = i
                    count2[1] += 1
                end
                if count2[2] < 2 && candidates[j,i,n] == 1
                    count[2,1] = i
                    count[2,2] = j
                    count2[2] += 1
                end
                if count2[3] < 2 && candidates[py+(j-1)÷bx,px+(j-1)%bx,n] == 1
                    count[3,1] = px+(j-1)%bx
                    count[3,2] = py+(j-1)÷bx
                    count2[3] += 1
                end
                if count2[1]>=2 && count2[2]>=2 && count2[3]>=2
                    break
                end
            end
            for j in 1:3
                if count2[j] == 0
                    updateFlag[1] = false
                    errorFlag[1] = true
                    return
                end
                if count2[j] == 1 && puzzle[count[j,2],count[j,1]] == 0
                    PutNumber(puzzle,candidates,count[j,1],count[j,2],n)
                    if errorFlag[1] == true
                        updateFlag[1] = false
                        return
                    end
                    updateFlag[1] = true
                end
            end
        end
    end
end
function Solve(solver::Solver)
    while true
        updateFlag[1] = false
        Singles(solver.puzzle,solver.candidates)
        if errorFlag[1]
            return false
        end
        if updateFlag[1]
            continue
        end
        break
    end
    for y in 1:box_size
        for x in 1:box_size
            if solver.puzzle[y,x] == 0
                return false
            end
        end
    end
    return true
end
function CalcScore(candidates::Array{Int64,3})
    if errorFlag[1]
        return 10000000
    end
    score = 0
    for y in 1:box_size
        for x in 1:box_size
            score_ = 0
            for n in 1:box_size
                if candidates[y,x,n] == 1
                    score_ += 1
                end
            end
            score += score_^2
        end
    end
    return score
end
"""
mutable struct Generator
    puzzle::Array{Int64,2}
    score::Int64
    solver::Solver
    scoreFlag::Bool
    function Generator()
        new(zeros(Int64,(9,9)),100000,Solver(),false)
    end
end
function CheckRule(puzzle::Array{Int64,2},cand::Array{Int64,3},x::Int64,y::Int64,n::Int64)
    if cand[y,x,n]==1 && puzzle[y,x]==0
        return true
    else
        return false
    end
end
function LocalSearch(generator::Generator)
    #println("")
    #ToStringFromPuzzle(generator.solver.puzzle)
    #ToStringFromPuzzle(generator.puzzle)
    for y_ in 1:box_size
        for x_ in 1:box_size
            puz = deepcopy(generator.solver.puzzle)
            if puz[y_,x_] == 0
                continue
            end
            n_ = puz[y_,x_]
            puz[y_,x_] = 0
            #SetPuzzle(generator.solver.puzzle,generator.solver.candidates,puz)
            for y in 1:box_size
                for x in 1:box_size
                    if puz[y,x] != 0
                        continue
                    end
                    for n in 1:box_size
                        solver = Solver()
                        SetPuzzle(solver.puzzle,solver.candidates,puz)
                        if CheckRule(solver.puzzle,solver.candidates,x,y,n)
                            puz[y,x] = n
                            PutNumber(solver.puzzle,solver.candidates,x,y,n)
                            Solve(solver)
                            score = CalcScore(solver.candidates)
                            if score < generator.score
                                #ToStringFromPuzzle(puz)
                                generator = Generator()
                                generator.puzzle = deepcopy(puz)
                                generator.score = score
                                SetPuzzle(generator.solver.puzzle,generator.solver.candidates,puz)
                                generator.scoreFlag = true
                                return generator
                            end
                            puz[y,x] = 0
                        end
                    end
                end
            end
            #puz[y_,x_] = n_
        end
    end
    return generator
end
"""

mutable struct Generator
    puzzle::Array{Int64,2}
    score::Int64
    solver::Solver
    scoreFlag::Bool
    function Generator()
        new(zeros(Int64,(9,9)),100000,Solver(),false)
    end
end
function CheckRule(puzzle::Array{Int64,2},cand::Array{Int64,3},x::Int64,y::Int64,n::Int64)
    if cand[y,x,n]==1 && puzzle[y,x]==0
        return true
    else
        return false
    end
end
function init_puz(generator::Generator, clue_count::Int64)
    #generator.solver = Solver()
    generator.solver.puzzle = zeros(Int64,(9,9))
    generator.solver.candidates = ones(Int64,(9,9,9))
    count = 0
    while count < clue_count
        x = rand(1:box_size)
        y = rand(1:box_size)
        n = rand(1:box_size)
        if generator.solver.candidates[y,x,n] == 1 && generator.solver.puzzle[y,x] == 0
            count += 1
            PutNumber(generator.solver.puzzle,generator.solver.candidates,x,y,n)
        end
    end
    generator.puzzle = copy(generator.solver.puzzle)
    generator.score = CalcScore(generator.solver.candidates)
    return generator
end
function LocalSearch(generator::Generator)
    puzzle = copy(generator.puzzle)
    for y_ in 1:box_size
        for x_ in 1:box_size
            puz = copy(puzzle)
            if puz[y_,x_] == 0
                continue
            end
            puz[y_,x_] = 0
            solver = Solver()
            SetPuzzle(solver.puzzle,solver.candidates,puz)
            for y in 1:box_size
                for x in 1:box_size
                    for n in 1:box_size
                        if CheckRule(solver.puzzle,solver.candidates,x,y,n)
                            puz[y,x] = n
                            solver = Solver()
                            SetPuzzle(solver.puzzle,solver.candidates,puz)
                            Solve(solver)
                            #ToStringFromPuzzle(solver.puzzle)
                            if errorFlag[1] == false
                                score = CalcScore(solver.candidates)
                                if score < generator.score
                                    generator = Generator()
                                    generator.puzzle = copy(puz)
                                    generator.score = score
                                    SetPuzzle(generator.solver.puzzle,generator.solver.candidates, puz)#solver.puzzle)
                                    generator.scoreFlag = true
                                    return generator
                                end
                            end
                            puz[y,x] = 0
                        end
                    end
                end
            end
        end
    end
    return generator
end
function Generate(generator::Generator, clue_count::Int64)
    while true
        generator.scoreFlag = false
        generator = LocalSearch(generator)
        if generator.scoreFlag == false
            break
        end
    end
    if Solve(generator.solver)# && errorFlag[1]==false
        ToStringFromPuzzle(generator.puzzle)
        ToStringFromPuzzle(generator.solver.puzzle)
        return true
    else
        return false
    end
end

puz_easy = [0 0 0 0 1 0 0 0 0
            0 9 7 8 0 3 5 4 0
            0 8 1 0 7 0 2 6 0
            0 2 0 0 5 0 0 3 0
            9 0 6 4 0 7 1 0 2
            0 1 0 0 9 0 0 7 0
            0 4 5 0 3 0 6 2 0
            0 7 2 5 0 6 3 8 0
            0 0 0 0 2 0 0 0 0]
puz_hard = [4 0 0 0 9 0 0 0 7
            0 3 0 0 0 8 0 2 0
            0 0 7 0 0 0 5 0 0
            0 2 0 0 0 0 0 0 0
            9 0 0 0 5 0 0 0 4
            0 0 0 0 0 0 0 8 0
            0 0 8 0 0 0 3 0 0
            0 9 0 2 0 0 0 5 0
            5 0 0 0 4 0 0 0 1]

#solver = Solver()
#SetPuzzle(solver.puzzle,solver.candidates,puz_hard)
#ToStringFromPuzzle(solver.puzzle)
#Solve(solver)
#ToStringFromPuzzle(solver.puzzle)
#ToStringFromCandidates(solver.candidates)

function solve_puz17()
    puz17 = [zeros(Int64,(9,9)) for i in 1:49157]
    lines = open("17puz49157.txt","r") do fp
        readlines(fp)
    end
    count = 0
    #progress = Progress(49157)
    #solver = Solver()
    for i in 1:49157
        puz = zeros(Int64,(9,9))
        for y in 1:box_size
            for x in 1:box_size
                if lines[i][(y-1)*box_size+x] != '.'
                    puz[y,x] = Int64(lines[i][(y-1)*box_size+x]) - 48
                end
            end
        end
        solver = Solver()
        SetPuzzle(solver.puzzle,solver.candidates,puz)
        if Solve(solver)
            count += 1
            #ToStringFromPuzzle(solver.puzzle)
        end
        #next!(progress)
    end
    println(count)
end
#Profile.clear()
#@profile solve_puz17()##
#Profile.print(format=:flat)
#@time solve_puz17()
"""
function test()
    #for i in 1:20
    generator = Generator()
    generator = init_puz(generator,18)
    Generate(generator,18)
    #end
end
"""
#@time test()
#Profile.clear()
#@profile test()
#Profile.print(format=:flat)

#@time Generate(generator,21)
#ToStringFromPuzzle(generator.solver.puzzle)
#ToStringFromCandidates(generator.solver.candidates)
#ToStringFromPuzzle(generator.solver.puzzle)
#Profile.clear()
function test(clue::Int64)
    count = 0
    generator = Generator()
    generator = init_puz(generator,clue)
    while Generate(generator,clue) == false
        count += 1
        println(count)
        generator = Generator()
        generator = init_puz(generator,clue)
    end
end
@time test(17)
#println(count)
#Profile.print(format=:flat)
