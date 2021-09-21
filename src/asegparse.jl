module asegparse

using DataFrames, CSV, JSON

function handle_colheader(line::String)
  return (line |> split)[3:end]
end

function handle_dataline(line::String)::Vector{String}
  return line |> strip |> split
end

function handle_metaline(line::String; delim::Char='_')::Union{Pair{String,String},Nothing}
  line == "# " && return nothing
  segments = split(strip(line[2:end]))
  key = popfirst!(segments)
  value = join(segments, delim)
  return key => value
end

function process_aseglines(path::String)
  reachedData = false
  metavec = Vector{Pair{String,String}}(undef,0)
  datavec = Vector{Vector{String}}(undef,0)
  aseglines = readlines(path)
  for (id,line) in enumerate(aseglines)
    if line[1] == '#'
      metaline = handle_metaline(line)
      !isnothing(metaline) && push!(metavec, metaline)
    elseif !reachedData
      reachedData = true
      colheader = handle_colheader(aseglines[id-1])
      !isnothing(colheader) && push!(datavec, colheader)
    else
      dataline = handle_dataline(line)
      !isnothing(dataline) && push!(datavec, dataline)
    end
  end
  return metavec, datavec
end

# May want to put this into a more generic utils.jl file
function filterout!(condition::Function, data)
  targets = copy(filter(condition, data))
  filter!(!condition, data)
  return targets
end

const MetaData = begin
  Dict{
    String, 
    Union{
      Vector{String},
      Dict{String,String}
    }
  }
end

# Leaves the metadata in somewhat of a rough format
# Subject to improvement in the future
function handle_meta(metadata::Vector{Pair{String,String}})::MetaData
  measures = last.(filterout!(entry -> first(entry) == "Measure", metadata))
  tablecol = last.(filterout!(entry -> first(entry) == "TableCol", metadata))
  @assert (metadata |> keys |> length) == (metadata |> keys |> unique |> length)
  return Dict(
    "measures" => measures,
    "tablecol" => tablecol,
    "info" => Dict(metadata)
  )
end

function write_metadata(path::String, meta::MetaData)::Nothing
  target = splitext(path)
  if last(target) != ".json"
    @debug "Incorrect or no extension given. Concatenating .json to path)."
    path = join([first(target), "json"], '.')
  end
  @info "Writing metadata to $path"
  write(path, JSON.json(meta))
  return nothing
end

function write_data(path::String, data::Vector{Vector{String}})::Nothing
  target = splitext(path)
  if last(target) != ".csv"
    @debug "Incorrect or no extension given. Concatenating .csv to path)."
    path = join([first(target), "csv"], '.')
  end
  @info "Writing data to $path"
  write(path, join(join.(data, ','), '\n'))
  return nothing
end

function main(args)::Nothing
  isdir(args[1]) || error("$(args[1]) is not subject directory") |> throw
  subjdir = args[1]
  statsdir = joinpath(subjdir, "stats")
  asegfile = joinpath(statsdir, "aseg.stats")
  isfile(asegfile) || error("$asegfile does not exist") |> throw
  outdir = joinpath(subjdir, "output")
  isdir(outdir) || mkdir(outdir)
  meta, data = process_aseglines(asegfile)
  metadata = handle_meta(meta)
  metapath = joinpath(outdir, "asegstats_meta.json")
  datapath = joinpath(outdir, "asegstats_data.csv")
  write_data(datapath, data)
  write_metadata(metapath, metadata)
  @info "aseg.stats was parsed without error - outputs can be found in $outdir"
end

function __init__()::Nothing
  interactive = isinteractive() 
  interactive && @debug "Running interactively"
  interactive || begin
    @debug "Running non-interactively"
    isempty(ARGS) && error("No arguments given. Must give path to subject directory as first argument.") |> throw
    main(ARGS)
  end
  return nothing
end

end # module

