# Play around with this for multi-processing. IncrementalCPA benefits also from threading, tweak env variable JULIA_NUM_THREADS
# addprocs(2)

using Distributed
using Jlsca.Sca
using Jlsca.Trs
using Jlsca.Align
@everywhere using Jlsca.Sca
@everywhere using Jlsca.Trs
@everywhere using Jlsca.Align


if length(ARGS) < 1
  print("no input trace\n")
  return
end

filename = ARGS[1]
direction = (length(ARGS) > 1 && ARGS[2] == "BACKWARD" ? BACKWARD : FORWARD)
params = getParameters(filename, direction)
if params == nothing
  throw(ErrorException("Params cannot be derived from filename, assign and config your own here!"))
  # params = DpaAttack(AesSboxAttack(),IncrementalCPA())
end

analysis = IncrementalCPA()
analysis.leakages = params.analysis.leakages
params.analysis = analysis

@everywhere begin
    trs = InspectorTrace($filename)
    getTrs() = trs
end

numberOfTraces = length(trs)

@time ret = sca(DistributedTrace(getTrs), params, 1, numberOfTraces)
