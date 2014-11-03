cases = {'case9.m', 'case14.m', 'case57.m', 'case118.m', ...
         'case2383wp.m', 'case3120sp.m'};
attack_levels = [1.1, 2.0, 3.0, 5.0];
Ks = [2, 3, 4, 5, 8];
%methods = {'top_k', 'max_mismatch'};

%cases = {'case9.m', 'case14.m'};
%attack_levels = [1.1, 2.0];
%Ks = [2, 3];
methods = {'max_mismatch'};

logfilename = sprintf('log_%s.txt', datestr(now, 'yyyymmdd_HHMMSS'));
logfile = fopen(logfilename, 'w');

for i = 1:length(cases),
    mpc = cases{i};
    for j = 1:length(attack_levels),
        attack_level = attack_levels(j);
        for k = 1:length(Ks),
            K = Ks(k);
            for m = 1:length(methods),
                method = methods{m};
                fprintf('%s max_attack=%g K=%g %s\n', mpc, attack_level, ...
                    K, method);
                fprintf(logfile, '%s max_attack=%g K=%g %s\n', mpc, ...
                    attack_level, K, method);
                tic;
                [z, last_repeated, objectives, success] = ...
                    attack_heuristic(method, mpc, K, attack_level);
                fprintf(logfile, 'runtime: %gs\n', toc);
                if ~success,
                    fprintf(logfile, 'failed, see matlab\n\n');
                    continue;
                end
                fprintf(logfile, 'objectives\n');
                fprintf(logfile, 'L1,L2,Linf\n');
                fprintf(logfile, '%f,%f,%f\n', objectives(1:last_repeated, :)');
                fprintf(logfile, 'attacks\n');
                for ii=1:last_repeated,
                    [attacks, attacked_lines] = sort(z(ii, :), 'descend');
                    ind = find(attacks-1, 1, 'last');
                    fprintf(logfile, '%d,', attacked_lines(1:ind-1));
                    fprintf(logfile, '%d\n', attacked_lines(ind));
                    fprintf(logfile, '%g,', attacks(1:ind-1));
                    fprintf(logfile, '%g\n', attacks(ind));
                end
                fprintf(logfile, '\n');
            end
        end
    end
end