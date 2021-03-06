## General ##

"Initial `:loss` value from run"
init(run::DataFrame, on::Symbol) = run[:loss][1]

"Get the optimal `:loss` value from a run"
function optimal(run::DataFrame, on::Symbol)
  df = @from i in run begin
       @orderby ascending(i.loss)
       @select i
       @collect DataFrame
  end
  df[on][1]
end

"Join data from different callbacks from a run on :iteration"
joincallbacks(dfs::Vector{DataFrame}) = manyjoin(:iteration, dfs...)

"Join data from different runs"
joinruns(f::Function, runs::Vector{DataFrame}) = [f(run, :loss) for run in runs]

## Specific Tests / Plots ##

function test_initialhist(nruns=100)
  carr = TestArrows.xy_plus_x_arr()
  dfs = [min_naive(carr, 1.0) for i = 1:nruns]
  runs = [manyjoin(:iteration, df...) for df in dfs]
end

"Overlapping Plot of histogram before and after optimization"
function init_vs_optim(runs)
  initdata = [init(run, :loss) for run in runs]
  optimaldata = [optimal(run, :loss) for run in runs]
  initdata, optimaldata
end

function naive(carr::CompArrow, nruns::Integer, targety...)
  dfs = [min_naive(carr, targety...) for i = 1:nruns]
  runs = [manyjoin(:iteration, df...) for df in dfs]
  initdata, optimaldata = init_vs_optim(runs)
end

function pi(carr::CompArrow, nruns::Integer, targety...)
  dfs = [min_domainϵ(carr, targety...) for i = 1:nruns]
  runs = [manyjoin(:iteration, df...) for df in dfs]
  initdata, optimaldata = init_vs_optim(runs)
end

function compare(carr::CompArrow, nruns::Integer)
  @show rand_f_in = rand(length(▸(carr)))
  targety = carr(rand_f_in...)
  initdata_pi, optimaldata_pi = pi(carr, nruns, targety...)
  initdata_naive, optimaldata_naive = naive(carr, nruns, targety...)
  @show initdata_pi, optimaldata_pi
  @show initdata_naive, optimaldata_naive
  histogram(log.([initdata_pi,
             optimaldata_pi,
             initdata_naive,
             optimaldata_naive]),
             labels=["init_pi" "optim_pi" "init_naive" "optim_naive"],
            #  normalize=true,
             α=0.5,
             xlabel="Loss",
             ylabel="Count")
  title!("Comparing initial and optimized losses")
end
