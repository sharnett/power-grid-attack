tic;
format short g;
format compact;
%%

mpc = 'case118.m';
subset = 1:186;
%mpc = 'case9.m';
%subset = 1:9;

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
m.opf_obj_mult = 0;

mpc = loadcase3(m.mpc);
n = length(m.subset);
o = ones(n, 1);

attacks = nchoosek(1:n, 3);
attacks = attacks(randperm(size(attacks, 1)), :);

%attacks = attacks(1:16, :);
%%
sing_wrn = 'MATLAB:nearlySingularMatrix';
warning('off', sing_wrn);

parfor i=1:size(attacks, 1),
    a = attacks(i, :)';
    g = zeros(n, 1);
    g(a) = m.gamma_max;
    
    lastwarn('', '');
    [result, success] = attack(mpc, o+g);
    [~, msgidlast] = lastwarn;
    
    lastwarn('', '');
    if (strcmp(msgidlast, sing_wrn)),
        [result, success] = attack(mpc, o+g, 'tralm');
    end
    [~, msgidlast] = lastwarn;
    if (strcmp(msgidlast, sing_wrn)),
        disp('singular even with trust region');
    end
    if (~success),
        disp('opf after attack failed to converge');
    end
    
    f = objective(result, m.obj_type, m.Lnorm);
    f2 = objective(result, 'magnitude', m.Lnorm);
    disp([f f2 a']);
end

warning('on', sing_wrn);

toc
