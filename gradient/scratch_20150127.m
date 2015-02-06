%%

mpc = 'case9.m';
subset = [1 4 7 8];

mpc = 'case14.m';
subset = [1 2 3 7];

mpc = 'case57.m';
subset = [1 2 8 15 17];
%m.initial_guess = [2.1899 1.3754 1.5562 1.4676 0.0012 0.51936];

%mpc = 'case118.m';
%subset = [7 8 9 51 135];

%mpc = 'case2383wp.m';
%subset = [50,51,95,168,31,57];

%%
clear m;
m.mpc = mpc;
m.subset = subset;
m.gamma_max = 2.5;
m.K = 3;
m.Lnorm = 1;
m.obj_type = 'angle';
m.opf_obj_mult = 0;

m.initial_guess = random_attack(length(m.subset), m.gamma_max, m.K);
%m.initial_guess = 1e3*[0.0001    0.0023    0.0024    0.0012    0.0012];
%m.initial_guess = zeros(1, length(m.subset));

disp('starting');
[gamma_opt, val, val_opf] = fw_attack_20150124(m);