rng(8675);

%mpc = 'case2383wp.m';
%subset = 1:2896;
mpc = 'case57.m';
subset = 1:80;

%%
clear m;
m.mpc = mpc;
m.subset = subset;
m.gamma_max = 2.5;
m.K = 3;
m.Lnorm = 1;
m.obj_type = 'angle';

disp('starting');

opts.max_iter = 10;
[gamma_opt, val] = fw_attack_20150427(m, opts);