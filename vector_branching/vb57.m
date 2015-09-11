%%
mpc = 'case57.m';
n = 80;
subset = 1:n;

%m.initial_guess = [2.1899 1.3754 1.5562 1.4676 0.0012 0.51936];

%%
rng(8675);

clear m;
m.mpc = mpc;
m.subset = subset;
m.gamma_max = 2.75;
m.K = 3;
m.Lnorm = 1;
m.obj_type = 'angle';

%a = [8 2.21; 15 1.69; 16 1.42; 17 1.33; 35 .8];
%nz = a(:, 1);
%y = a(:, 2);
%x0 = zeros(1, n);
%x0(nz) = y;
%m.initial_guess = x0;

clear opts;
opts.max_iter = 25;
%opts.opf_alg = 'tralm';

[gamma_opt, val] = fw_attack_20150427(m, opts);

%%
%[35 3.00; 36 3.00; 46 3.00; ]

a = [35 36 46];
k = 3;
%alg = 'ipopt'; setenv('OMP_NUM_THREADS', '2');
alg = 'sdpopf';
%alg = 'tralm';
%alg = 'pdipm';

z = zeros(n, 1);
z(a) = k;
x = ones(n, 1) + z;

mpc = loadcase3(m.mpc);
result = mpc;
result.branch(:, 3:4) = [x x] .* result.branch(:, 3:4);
opt = mpoption('opf.ac.solver', alg);
%opt = mpoption('out.all', 0, 'verbose', 0, 'opf.ac.solver', alg);
result = runopf(result, opt);
objective(result, 'angle', 1)
%result.bus(:, 8:9)