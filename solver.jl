#using ProfileView
#using ProgressMeter
#using Base.Threads

const bx = 3
const by = 3
const box_size = bx * by
const cell_size = box_size * box_size
#bx = 3
#by = 3
#box_size = bx * by
#cell_size = box_size * box_size
global updateFlag = [false]

type Solver
    puzzle::Array{Int64,2}
    candidates::Array{Array{Array{Bool,1},1},1}
    function Solver()
        cand = [[[true for i in 1:box_size] for j in 1:box_size] for l in 1:box_size]
        new(zeros(Int64,(9,9)),cand)
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
function ToStringFromCandidates(cand::Array{Array{Array{Bool,1},1},1})
    for y in 1:box_size
        for y_ in 1:by
            for x in 1:box_size
                if x != 1
                    print(" ")
                end
                for x_ in 1:bx
                    if cand[y][x][(y_-1)*bx+x_] == true
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
function DeleteCandidate(candidates::Array{Array{Array{Bool,1},1},1},x::Int64,y::Int64,n::Int64)
    candidates[y][x][n] = false
end
function PutNumber(puzzle::Array{Int64,2},candidates::Array{Array{Array{Bool,1},1},1},x::Int64,y::Int64,n::Int64)
    if candidates[y][x][n] == false
        #println("false")
        return
    end
    puzzle[y,x] = n
    px = div(x-1,bx) * bx + 1
    py = div(y-1,by) * by + 1
    for i in 1:box_size
        candidates[y][x][i] = false
        candidates[y][i][n] = false
        candidates[i][x][n] = false
        candidates[py+div(i-1,bx)][px+mod(i-1,bx)][n] = false
    end
end
function SetPuzzle(puzzle::Array{Int64,2},candidates::Array{Array{Array{Bool,1},1},1},puz::Array{Int64,2})
    """
    for y in 1:box_size
        for x in 1:box_size
            puzzle[y,x] = 0
            for n in 1:box_size
                candidates[y][x][n] = true
            end
        end
    end
    """
    for y in 1:box_size
        for x in 1:box_size
            if puz[y,x] != 0
                PutNumber(puzzle,candidates,x,y,puz[y,x])
            end
        end
    end
end
function Singles(puzzle::Array{Int64,2},candidates::Array{Array{Array{Bool,1},1},1})
    n2 = 0
    for y in 1:box_size
        for x in 1:box_size
            count = 0
            for cand in candidates[y][x]
                if cand == true
                    count += 1
                end
            end
            if count != 1
                continue
            end
            PutNumber(puzzle,candidates,x,y,findfirst(candidates[y][x],true))
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
            px = mod(i-1,bx) * bx + 1
            py = div(i-1,bx) * by + 1
            for j in 1:box_size
                if candidates[i][j][n] == true
                    #append!(count[1],[j,i])
                    count[1,1] = j
                    count[1,2] = i
                    count2[1] += 1
                end
                if candidates[j][i][n] == true
                    #append!(count[2],[i,j])
                    count[2,1] = i
                    count[2,2] = j
                    count2[2] += 1
                end
                if candidates[py+div(j-1,bx)][px+mod(j-1,bx)][n] == true
                    #append!(count[3],[px+mod(j-1,bx),py+div(j-1,bx)])
                    count[3,1] = px+mod(j-1,bx)
                    count[3,2] = py+div(j-1,bx)
                    count2[3] += 1
                end
            end
            for j in 1:3
                if count2[j] == 1
                    PutNumber(puzzle,candidates,count[j,1],count[j,2],n)
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
        #ToStringFromPuzzle(solver.puzzle)
        #println(updateFlag[1][1])
        if updateFlag[1]
            continue
        end
        break
    end
    #ToStringFromPuzzle(solver.puzzle)
    for y in 1:box_size
        for x in 1:box_size
            if solver.puzzle[y,x] == 0
                return false
            end
        end
    end
    return true
end
function CalcScore(solver::Solver)
    #ToStringFromPuzzle(solver.puzzle)
    score = 0
    for cand in solver.candidates
        for can in cand
            score_ = 0
            for c in can
                if c == true
                    score_ += 1
                end
            end
            score += score_^2
        end
    end
    return score
end

mutable struct Generator
    puzzle::Array{Int64,2}
    score::Int64
    solver::Solver
    scoreFlag::Bool
    function Generator()
        new(zeros(Int64,(9,9)),100000,Solver(),false)
    end
end
function CheckRule(cand::Array{Array{Array{Bool,1},1},1},x::Int64,y::Int64,n::Int64)
    return cand[y][x][n]
    """
    px = div(x-1,bx) * bx + 1
    py = div(y-1,by) * by + 1
    for i in 1:box_size
        if puz[x,i] == n
            return false
        end
        if puz[i,y] == n
            return false
        end
        if puz[py+div(i-1,bx),px+mod(i-1,bx)] == n
            return false
        end
    end
    return true
    """
end
function init_puz(generator::Generator, clue_count::Int64)
    generator.solver.puzzle = zeros(Int64,(9,9))
    count = 0
    while count < clue_count
        x = rand(1:box_size)
        y = rand(1:box_size)
        n = rand(1:box_size)
        if CheckRule(generator.solver.candidates,x,y,n)
            count += 1
            PutNumber(generator.solver.puzzle,generator.solver.candidates,x,y,n)
        end
    end
    generator.puzzle = copy(generator.solver.puzzle)
    generator.score = CalcScore(generator.solver)
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
                        if CheckRule(solver.candidates,x,y,n)
                            puz[y,x] = n
                            generator.solver = Solver()
                            SetPuzzle(generator.solver.puzzle,generator.solver.candidates,puz)
                            score = CalcScore(generator.solver)
                            if score < generator.score
                                #prInt64ln(score)
                                #ToStringFromPuzzle(puz)
                                generator.puzzle = copy(puz)
                                generator.score = score
                                SetPuzzle(generator.solver.puzzle,generator.solver.candidates, puz)
                                generator.scoreFlag = true
                                return generator
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
    generator = init_puz(generator,clue_count)
    while true
        generator.scoreFlag = false
        generator = LocalSearch(generator)
        if generator.scoreFlag ==  false
            generator = Generator()
            generator = init_puz(generator,clue_count)
            continue
        end
        #generator.solver = Solver(3,3)
    #    generator.solver = SetPuzzle(generator.solver, generator.puzzle)
        if Solve(generator.solver)
            ToStringFromPuzzle(generator.puzzle)
            ToStringFromPuzzle(generator.solver.puzzle)
            return true
        end
        #next!(progress)
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
#SetPuzzle(solver.puzzle,solver.candidates,puz_easy)
#println(Solve(solver))

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
        end
        #next!(progress)
    end
    println(count)

end
#Profile.clear()
#@profile solve_puz17()
#Profile.print(format=:flat)
#@time solve_puz17()

function test()
    for i in 1:20
        generator = Generator()
        generator = init_puz(generator,21)
        ToStringFromPuzzle(generator.solver.puzzle)
        Generate(generator,21)
    end
end

@time test()
