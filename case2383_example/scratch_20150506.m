rng(8675);
%%

%mpc = 'case9.m';
%subset = [1 4 7 8];

%mpc = 'case14.m';
%subset = [1 2 3 7];
%subset = 1:20;

%mpc = 'case57.m'; 
%subset = [1 2 8 15 17];
%subset = 1:80;
%m.initial_guess = [2.1899 1.3754 1.5562 1.4676 0.0012 0.51936];

%mpc = 'case118.m';
%subset = [7 8 9 51 135];
%subset = 1:186;

mpc = 'case2383wp.m';
%subset = [50,51,95,168,31,57];
%subset = [31,50,51,57,95,168];
subset = 1:2896;

%%
clear m;
m.mpc = mpc;
m.subset = subset;
m.gamma_max = 2.5;
m.K = 3;
m.Lnorm = 1;
m.obj_type = 'angle';
m.opf_obj_mult = 0;

%m.initial_guess = random_attack(length(m.subset), m.gamma_max, m.K);
m.initial_guess = random_attack2(length(m.subset), m.gamma_max, m.K);

%nz = [ 38    42    66    67    68    96   139   174];
%y =  [1.9  0.05   1.4   1.6  0.07   2.4  0.04  0.01];
%nz = [ 38    66    67   96];
%y =  [1.9   1.4   1.6  2.4];
%x0 = zeros(1, 186);
%x0(nz) = y;
%m.initial_guess = x0;

%14 0.078145 38 66 67 68 96 109
%565.64 0 1.9527 1.3933 1.4861 0.058984 2.5 0.10891

%14 0.054123 38 66 67 68 96
%565.87 0 1.9397 1.4554 1.5385 0.037068 2.4707

%m.initial_guess = [0 1.3 2.49 2.5 1.05];
%m.initial_guess = [0 1.5 2.5 2.5 1];
%m.initial_guess = zeros(1, length(m.subset));

disp('starting');
%[gamma_opt, val, val_opf] = fw_attack_20150124(m);
%[gamma_opt, val, val_opf] = fw_attack_20150211(m);

opts.max_iter = 10;
[gamma_opt, val, val_opf] = fw_attack_20150211(m, opts);
