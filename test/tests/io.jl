using DataFrames
using Plots
using Spec
using AlioAnalysis
import AlioAnalysis: RunData
using Base.Test

function test_io()
  # Run 1
  with_pre() do
    base = joinpath("/tmp/aliotest")
    nested = joinpath("/tmp/aliotest/nested")
    rm(base, recursive=true, force=true)
    rm(nested, recursive=true, force=true)
    mkdir(base)
    mkdir(nested)
    jldpath1 = joinpath(base, "df1.jld2")
    jldpath2 = joinpath(nested, "df2.jld2")
    jldpath3 = joinpath(nested, "df3.jld2")
    rdpath1 = joinpath(base, "rd1.rd")
    rdpath2 = joinpath(nested, "rd2.rd")
    rdpath3 = joinpath(nested, "rd3.rd")

    n = 1000
    rundata1 = RunData(:runname => :exrun1,
                       :time => now(),
                       :desc => "An example run",
                       :completed => false)

    df1 = DataFrame(runname = [:exrun1 for i=1:n],
                    iteration = 1:n,
                    loss = [exp(-0.001i)*rand() for i=1:n],
                    time = 10*[exp(-0.001i)*rand() for i=1:n])

    savedf(jldpath1, df1)
    savedict(rdpath1, rundata1)

    # Run 2
    n = 700
    rundata2 = RunData(:runname => :exrun2,
                       :time => now(),
                       :desc => "An example run")

    df2 = DataFrame(runname = [:exrun2 for i=1:n],
                    iteration = 1:n,
                    loss = [exp(-0.005i)*rand() for i=1:n],
                    time = 10*[exp(-0.005i)*rand() for i=1:n],
                    error = 10*[exp(-0.005i)*rand() for i=1:n])

    savedf(jldpath2, df2)
    savedict(rdpath2, rundata2)

    # TODO: Need another stage to manage all the data frames
    rds = [rundata1, rundata2]
    dfs = [df1, df2]
    dfsloaded = map(loaddf, [jldpath1, jldpath2])

    @test all(map(==, dfs, dfsloaded)) # Test saving and loading ok

    cutoff = now() # Will exclude data saved after this cut off

    # Run 3: Make some more data (to test it will be excluded because of cutoff)
    rundata3 = RunData(:runname => :exrun3,
                       :time => cutoff,
                       :desc => "An example run")

     df3 = DataFrame(runname = [:exrun3 for i=1:n],
                     iteration = 1:n,
                     loss = [exp(-0.005i)*rand() for i=1:n],
                     time = 10*[exp(-0.005i)*rand() for i=1:n],
                     error = 10*[exp(-0.005i)*rand() for i=1:n])

    savedf(jldpath3, df3)
    savedict(rdpath3, rundata3)
    # Load data from /tmp
    rds, dfs = walkrundata(base), walkdfdata(base)

    # Filter rds and dfs, to only include df1 and df2 and only associated dfs
    rdfilter(rd::RunData) = rd[:time] < cutoff
    rds_ = filter(rdfilter, rds)

    function dffilter(df::DataFrame, rd::RunData)
      # Make sure data has colums :loss and :time
      a = all((haskey(df, colname) for colname in [:loss, :time]))

      # Make sure run data is here
      b = rd ∈ rds_
      a & b
    end

    # Pair of DataFrame and RunData
    dfrds = map(df->rundata(df, rds), dfs)

    dfs_ = DataFrame[]
    for (df, rd) in zip(dfs, dfrds)
      if dffilter(df, rd)
        push!(dfs_, df)
      end
    end

    @test rundata1 ∈ rds_
    @test rundata2 ∈ rds_
    @test rundata3 ∉ rds_

    @test df1 ∈ dfs_
    @test df2 ∈ dfs_
    @test df3 ∉ dfs_

    # Cleanup
    rm(base, recursive=true, force=true)
    rm(nested, recursive=true, force=true)

    # # TODO: save in /tmp/df2.df
    # data = combinedata(dfs, rds, :iteration, [:loss, :time])
    #
    # # Figure out filter
    #
    # # plotlinechart(data)
    # # summarize(data)
  end
end

test_io()
