using ProgressMeter

bx = 3
by = 3
box_size = bx * by
cell_size = box_size * box_size

mutable struct Solver
    bx::Int64
    by::Int64
    box_size::Int64
    cell_size::Int64
    puzzle::Array{Int64,2}
    candidates::Array{Array{Array{Bool,1},1},1}
    updateFlag::Bool
    function Solver(bx::Int64,by::Int64)
        cand = [[[true for i in 1:box_size] for j in 1:box_size] for l in 1:box_size]
        new(bx,by,bx*by,(bx*by)^2,zeros(Int64,(9,9)),cand,false)
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
function DeleteCandidate(solver::Solver,x::Int64,y::Int64,n::Int64)
    solver.candidates[y][x][n] = false
    return solver
end
function PutNumber(solver::Solver,x::Int64,y::Int64,n::Int64)
    if solver.candidates[y][x][n] == false
        return solver
    end
    #return solver
    solver.puzzle[y,x] = n
    px = div(x-1,bx) * bx + 1
    py = div(y-1,by) * by + 1
    for i in 1:box_size
        solver = DeleteCandidate(solver,x,y,i)
        solver = DeleteCandidate(solver,x,i,n)
        solver = DeleteCandidate(solver,i,y,n)
        solver = DeleteCandidate(solver,px+mod(i-1,bx),py+div(i-1,bx),n)
    end
    return solver
end
function SetPuzzle(solver::Solver,puz::Array{Int64,2})
    solver.puzzle = zeros(Int64,(9,9))
    cand = [[[true for i in 1:box_size] for j in 1:box_size] for l in 1:box_size]
    solver.candidates = cand
    #println("aaa")
    for y in 1:box_size
        for x in 1:box_size
            if puz[y,x] != 0
                solver = PutNumber(solver,x,y,puz[y,x])
            end
        end
    end
    return solver
end
function Singles(solver::Solver)
    for y in 1:box_size
        for x in 1:box_size
            count = 0
            for cand in solver.candidates[y][x]
                if cand == true
                    count += 1
                end
            end
            if count != 1
                continue
            end
            solver = PutNumber(solver,x,y,findfirst(solver.candidates[y][x],true))
            solver.updateFlag = true
        end
    end
    for i in 1:box_size
        for n in 1:box_size
            count = [[],[],[]]
            px = mod(i-1,bx) * bx + 1
            py = div(i-1,bx) * by + 1
            for j in 1:box_size
                if solver.candidates[i][j][n] == true
                    append!(count[1],[j,i])
                end
                if solver.candidates[j][i][n] == true
                    append!(count[2],[i,j])
                end
                if solver.candidates[py+div(j-1,bx)][px+mod(j-1,bx)][n] == true
                    append!(count[3],[px+mod(j-1,bx),py+div(j-1,bx)])
                end
            end
            for c in count
                if length(c) == 2
                    solver = PutNumber(solver,c[1],c[2],n)
                    solver.updateFlag = true
                end
            end
        end
    end
    return solver
end
function Solve(solver::Solver)
    while true
        solver.updateFlag = false
        solver = Singles(solver)
        #ToStringFromPuzzle(solver.puzzle)
        if solver.updateFlag
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


puz17 = [zeros(Int64,(9,9)) for i in 1:49157]
lines = open("17puz49157.txt","r") do fp
    readlines(fp)
end
count = 0
progress = Progress(49157)
for i in 1:49157
    puz = zeros(Int64,(9,9))
    for y in 1:box_size
        for x in 1:box_size
            if lines[i][(y-1)*box_size+x] != '.'
                puz[y,x] = Int64(lines[i][(y-1)*box_size+x]) - 48
            end
        end
    end
    solver = Solver(3,3)
    solver = SetPuzzle(solver,puz)
    if Solve(solver)
        count += 1
    end
    next!(progress)
end
