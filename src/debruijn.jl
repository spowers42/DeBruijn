module DeBruijn
using Graphs
export build_debruijn, eulerian_walk, path2sequence

flatten{T}(a::Array{T,1}) = any(map(x->isa(x,Array),a))? flatten(vcat(map(flatten,a)...)): a
flatten{T}(a::Array{T}) = reshape(a,prod(size(a)))
flatten(a)=a

function build_debruijn(kmer::Array{ASCIIString})
  #todo remove error edges not found in the spectrum
  nodes = [kmer[1][1:end-1]; [a[2:end] for a in kmer]]
  g = graph(nodes, ExEdge{ASCIIString}[])
  for v1 in g.vertices
    for v2 in g.vertices
      if v1[2:end] == v2[1:end-1] && in(string(v1[1:end],v2[end]), kmer)
        add_edge!(g, v1, v2)
      end
    end
  end
  return g
end

function connected_edges(G, start)
  #returns a list of edges from graph G that are reachable from start.
end

function eulerian_walk(debruijn, starting_node)
  #simple version implementing Fleury's algorithm
  unvisited = copy(edges(debruijn))
  path = [starting_node]
  current_node = starting_node
  while length(unvisited)>0
    e = find_next_edge(current_node, unvisited)
    if e == null
      println("no edge")
      return path
      #select a new node from the unvisted list
    else
      push!(path, e.target)
      current_node = e.target
      idx = findin(unvisited, [e])[1]
      splice!(unvisited, idx)
    end
  end
  return path
end

function path2sequence(path)
    sequence = join([path[1]; [n[end] for n in path[2:end]]])
    return sequence
end

function find_next_edge(current, edge_list)
  #given the current node and a list of possible edges find all edges starting at that node
  applicable = filter(edge->edge.source == current, edge_list)
  if length(applicable)>0
    #alternatively select randomly with applicable[rand(1:end)]
    return applicable[1]
  else
    return null
  end
end

end
