%%
mpc = 'case9.m';
x = loadcase(mpc);
n_lines = size(x.branch, 1);
subset = 1:n_lines;

clear m;
m.mpc = mpc;
m.subset = subset;
m.gamma_max = 2.5;
m.K = 3;
m.Lnorm = 1;
m.obj_type = 'angle';

%%
clear opts;
%opts.retry_on_fail = 1;
opts.opf_alg = 'ipopt';
setenv('OMP_NUM_THREADS', '1');
opts.runtime_diagnostics = 1;

%%
[gamma_opt, val] = fw_attack_20150427(m, opts)

%%
clear m;
m.mpc = 'case9.m';
opts.opf_alg='pdipm';
opts.retry_on_fail=1;
m.gamma_max=2.9;
m.K=3;
m.obj_type='angle';
m.Lnorm=1;
gamma=[2.9 0 0 0 0 0 0 2.9 2.9 ]';

mpc = loadcase3(mpc);
attack(mpc, gamma, 'sdpopf', 1)