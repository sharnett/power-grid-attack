%%
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
m.opf_obj_mult = 0;

clear opts;
opts.max_iter = 250;

%%
%m.initial_guess = random_attack_exp(length(m.subset), m.gamma_max, m.K);

[gamma_opt, val] = fw_attack_20151009(m, opts);
% 183.93 202.62
[sorted, idx] = sort(gamma_opt, 'descend');
top_lines = idx(1:3)
% 35 46 36

%%
disp('removing line 35 from the attack');
m.subset = subset;
m.subset(35) = [];
[gamma_opt, val] = fw_attack_20151009(m, opts);
% 188.052 196.286 (50)
[sorted, idx] = sort(gamma_opt, 'descend');
top_lines = idx(1:3)
% 8 15 16

%%
disp('removing line 46 from the attack');
m.subset = subset;
m.subset(46) = [];
[gamma_opt, val] = fw_attack_20151009(m, opts);
val
% 186.43 196.29 (50)
[sorted, idx] = sort(gamma_opt, 'descend');
top_lines = idx(1:3)
% 8 15 16

%%
disp('removing line 36 from the attack');
m.subset = subset;
m.subset(36) = [];
[gamma_opt, val] = fw_attack_20151009(m, opts);
val
% 187.7 196.29 (50)
[sorted, idx] = sort(gamma_opt, 'descend');
top_lines = idx(1:3)
% 8 15 16

%%
disp('removing line 8 from the attack');
m.subset = subset;
m.subset(8) = [];
[gamma_opt, val] = fw_attack_20151009(m, opts);
val
% 183.93
[sorted, idx] = sort(gamma_opt, 'descend');
top_lines = idx(1:3)
% 35 46 36

%%
disp('removing lines 8 and 35 from the attack');
m.subset = subset;
m.subset([8 35]) = [];
[gamma_opt, val] = fw_attack_20151009(m, opts);
val
% 186.48
[sorted, idx] = sort(gamma_opt, 'descend');
top_lines = idx(1:3)
% 15 16 17

%%
disp('removing lines 15 and 35 from the attack');
m.subset = subset;
m.subset([15 35]) = [];
[gamma_opt, val] = fw_attack_20151009(m, opts);
val
% 178.9
[sorted, idx] = sort(gamma_opt, 'descend');
top_lines = idx(1:3)
% 8 16 17

%%
disp('removing lines 16 and 35 from the attack');
m.subset = subset;
m.subset([16 35]) = [];
[gamma_opt, val] = fw_attack_20151009(m, opts);
val
% 181.17
[sorted, idx] = sort(gamma_opt, 'descend');
top_lines = idx(1:3)
% 8 15 2

%%
disp('removing lines 8, 15, and 35 from the attack');
m.subset = subset;
m.subset([8 15 35]) = [];
[gamma_opt, val] = fw_attack_20151009(m, opts);
val
% 170.35
[sorted, idx] = sort(gamma_opt, 'descend');
top_lines = idx(1:3)
% 16 17 20