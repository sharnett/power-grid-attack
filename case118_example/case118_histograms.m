function [mpc, weak_result, med_result, strong_result] = case118_histograms()
mpc = 'case118.m';
subset = 1:186;

%%
clear m;
m.mpc = mpc;
m.subset = subset;
m.gamma_max = 2.5;
m.K = 3;
m.Lnorm = 1;
m.obj_type = 'angle';
m.opf_obj_mult = 0;

%%
%fw_attack_20150211(m);

%%
mpc = loadcase3(m.mpc);
n = length(m.subset);
o = ones(n, 1);

attacks = [66 67 96; 12 64 184; 104 115 128];
n_attacks = size(attacks, 1);
attacks = [zeros(n_attacks, 3) attacks];

%%
function result = do_attack(a)
    g = zeros(n, 1);
    g(a) = m.gamma_max;    
    result = attack(mpc, o+g);
end

%%
for i=1:n_attacks,
    result = do_attack(attacks(i, 4:end));
    
    h = result.f;
    f = objective(result, 'angle', m.Lnorm);
    f2 = objective(result, 'magnitude', m.Lnorm);
    attacks(i, [1 2 3]) = [f f2 h];
end

%%
sorted = sortrows(attacks, 1);

null = [objective(mpc, 'angle', m.Lnorm)
        objective(mpc, 'magnitude', m.Lnorm)
        0]'
weak = sorted(1, :)
med = sorted(ceil((n_attacks+1)/2), :)
strong = sorted(end, :)

weak_result = do_attack(weak(4:end));
med_result = do_attack(med(4:end));
strong_result = do_attack(strong(4:end));

%%
null_gen = mpc.gen(:, [2 3])
weak_gen = weak_result.gen(:, [2 3])
med_gen = med_result.gen(:, [2 3])
strong_gen = strong_result.gen(:, [2 3])

end
