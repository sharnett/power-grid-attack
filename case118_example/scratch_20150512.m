rng(8675);

mpc = 'case118.m';
subset = 1:186;

%%
clear m;
m.mpc = mpc;
m.subset = subset;
%m.gamma_max = 2.5;
%m.gamma_max = 8;
m.gamma_max = 5;
m.K = 3;
m.Lnorm = 1;
m.obj_type = 'angle';

disp('starting');

clear opts;
opts.max_iter = 100;
opts.runtime_diagnostics = 1;
%opts.opf_alg = 'tralm';
[gamma_opt, val] = fw_attack_20150427(m, opts);

% 
