%%

%mpc = 'case9.m';
%subset = [1 4 7 8];

%mpc = 'case14.m';
%subset = [1 2 3 7];

%mpc = 'case57.m'; 
%subset = [1 2 8 15 17];
%m.initial_guess = [2.1899 1.3754 1.5562 1.4676 0.0012 0.51936];

mpc = 'case118.m';
subset = [7 8 9 51 135];

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

%m.initial_guess = random_attack(length(m.subset), m.gamma_max, m.K);
%m.initial_guess = [0 1.3 2.49 2.5 1.05];
m.initial_guess = [0 1.5 2.5 2.5 1];
%m.initial_guess = zeros(1, length(m.subset));

disp('starting');
[gamma_opt, val, val_opf] = fw_attack_20150124(m);

%%
mpc = loadcase3(m.mpc);
n_lines = size(mpc.branch, 1);

%%
x = [0 1.5 2.5 2.5 1];
gamma = zeros(n_lines, 1);
gamma(m.subset) = x;

%%
result = attack(mpc, ones(size(gamma))+gamma);
f = objective(result, m.obj_type, m.Lnorm);
f_opf = m.opf_obj_mult*result.f;
f = f + f_opf

%%
f1 = @(gamma) attack(mpc, ones(size(gamma))+gamma);
f2 = @(result) objective(result, m.obj_type, m.Lnorm);
f3 = @(result) m.opf_obj_mult*result.f;
f4 = @(result) f2(result) + f3(result);
f5 = @(gamma) f4(f1(gamma));

z = zeros(n_lines, 1);
e8 = z; e8(8) = 1;
e135 = z; e135(135) = 1;
gamma0 = z; gamma0(9) = 2.5; gamma0(51) = 2.5;
f6 = @(a, b) f5(gamma0 + a*e8 + b*e135);

%%

x = [0 1.5 2.5 2.5 1];
gamma = zeros(n_lines, 1);
gamma(m.subset) = x;
f5(gamma)

%%
n = 50;
dx = 2.5/n;
M = zeros(2.5/dx);
for i=1:n,
    a = (i-1)*dx;
    for j=1:n,
        b = (j-1)*dx;
        if (a+b) > 2.5,
            M(i, j) = 0;
        else
            M(i, j) = f6(a, b);
        end
    end
end

%%
imagesc(0:dx:2.5, 0:dx:2.5, M', [min(min(M(M>0))) max(max(M))]);
cmap = CubeHelix(256,0.5,-1.5,1.2,1.0);
axis image; axis xy; colorbar; colormap(cmap);
