function mpc = loadcase3(mpc)

opt = mpoption('OUT_ALL', 0, 'VERBOSE', 0);
mpc = runpf(mpc, opt);
[mpc, setup_success] = set_up_opf(mpc);
if ~setup_success,
    error('failed to set up the problem');
end