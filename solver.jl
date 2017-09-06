function ToStringFromPuzzle()#puz::Array{Int32,1})
    par = "+---+---+---+"
    println(par)

struct Solver
    bx::Int
    by::Int
    box_size::Int
    cell_size::Int
    puz::Array{Int64,1}
    candidates::Array{Int64,2}
end

ToStringFromPuzzle()
