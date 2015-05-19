%%
mpc = 'case1354pegase.m';
n_lines = 1991;
attack_line = 1;

%%
gamma_max = 2;
K = 2;
Lnorm = 1;
obj_type = 'angle';

z = zeros(n_lines, 1);
z(attack_line) = 1;

%%
mpc = loadcase3(mpc);

f1 = @(gamma) attack(mpc, ones(size(gamma))+gamma);
f2 = @(result) objective(result, obj_type, Lnorm);
f3 = @(gamma) f2(f1(gamma));
f4 = @(x) f3(x*z);

%%
f4(1)