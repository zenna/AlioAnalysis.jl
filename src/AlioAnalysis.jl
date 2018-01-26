"""
AlioAnalysis has four pillars

1. Arrows
  An `Arrow` is a dataflow program from `Arrows.jl`

2. Runs
  Arrows are executed in a run.

3. Datasets
  Runs accumulate data which is stored in datasets

4. Reports
  Datasets are analyzed, and summarized into graphs, tables, statistics.
  Reports are the desired output of using AlioAnalysis

The following are typically many-many relationships:
  (Arrow, Runs)
  (Runs, Datasets)
  (Datasets, Reports)

For example there can be many arrows involved in one run, and each arrow may be
inboled in many runs.
"""
module AlioAnalysis

using Arrows
using DataFrames
using Plots
using NamedTuples
using Query
using DataArrays
using TSne
using NLopt
using Spec
import IterTools: imap

import Arrows: Err, add!, idϵ, domϵ, TraceSubArrow, trace_port, TraceValue, TraceAbValues
# using JLD2

import Base: gradient

export savedict,
       log_dir,
       prodsample,
       genorrun,
       dorun,
       netpi,
       invnet,
       train,
       plus,
       optimizenet,
       genloss,
       Options,
       savedf,
       loaddf,
       loadrundata,
       walkrundata,
       walkdfdata,
       rundata,
       RunData,
       combinedata,
       plotlinechart,

       # Optimization
       optimize,
       verify_loss,
       verify_optim,
       domain_ovrl

include("util/misc.jl")             # Genral Utils
include("util/generators.jl")       # Genral Utils

include("rundata.jl")
include("analysis/space.jl")
include("analysis/io.jl")

include("transform/transforms.jl")
include("transform/supervised.jl")
include("transform/pia.jl")
include("transform/reparam.jl")

include("optim/callbacks.jl")
include("optim/optimizenet.jl")
include("optim/gradient.jl")
include("optim/loss.jl")
include("optim/optimize.jl")
include("optim/pointwise.jl")
include("optim/util.jl")

end
