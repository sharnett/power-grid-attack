function [gamma_opt, val] = fw_attack_20151009(m, opts)

% m is a struct with the following fields:
%
% mpc - (string) the filename of a MATPOWER case
% subset - an array of line numbers to consider for attack
% obj_type - one of 'magnitude' or 'angle'
% Lnorm - one of {inf, 1, 2}
% gamma_max - the maximum attack per line
% K - the max number of lines at full attack
% forced - an array of line numbers which are 'forced into' the attack, i.e. gamma_i >= gamma_max/2 

    if nargin < 2, opts = []; end;
    if (~isfield(opts, 'max_iter')), opts.max_iter = 15; end;
    if (~isfield(opts, 'f_tol')), opts.f_tol = 1e-6; end;
    if (~isfield(opts, 'verbose')), opts.verbose = 1; end;

    mpc = loadcase3(m.mpc);
    n_lines = size(mpc.branch, 1);
    n = length(m.subset);
    
    function dump(gamma)
        % write out some stuff to file to help figure out why it failed
        t = datestr(now, 'yyyymmdd-HHMMSS');
        fid = fopen(sprintf('failure_%s_%s.txt', t, m.mpc), 'w');
        fprintf(fid, '%s\n', m.mpc);
        fprintf(fid, 'gamma_max=%g\n', m.gamma_max);
        fprintf(fid, 'K=%g\n', m.K);
        fprintf(fid, 'obj_type=%s\n', m.obj_type);
        fprintf(fid, 'Lnorm=%g\n', m.Lnorm);
        fprintf(fid, 'gamma=[');
        fprintf(fid, '%g ', gamma);
        fprintf(fid, '];\n');
        fclose(fid);
    end
    
    function [f, success] = fun(gamma)
        [result, success] = attack(mpc, ones(n_lines, 1)+gamma, 'ipopt');
        if (~success),
            dump(gamma);
            error('failed to converge; objective');
        end
        f = -objective(result, m.obj_type, m.Lnorm);
    end

    function [g, success] = grad(gamma0)
        e = 1e-6;
        f0 = fun(gamma0);
        g0 = zeros(n, 1);
        for i=1:n,
            line = m.subset(i);
            gamma = gamma0;
            gamma(line) = gamma(line) + e;
            [f, success] = fun(gamma);
            if (~success),
                dump(gamma);
                error('failed to converge; grad %d', i);
            end
            g0(i) = (f - f0)/e;
        end
        g = zeros(n_lines, 1);
        g(m.subset) = g0;
    end
    
    gamma0 = zeros(n_lines, 1);
    if (isfield(m, 'forced')),
        gamma0(m.forced) = m.gamma_max/2;
    end
    if (isfield(m, 'initial_guess')),
        gamma0(m.subset) = m.initial_guess;
    end
    
    A = sparse([ones(1, n_lines); eye(n_lines)]);
    rhs = [m.K*m.gamma_max; m.gamma_max*ones(n_lines, 1)];
    if (isfield(m, 'forced')),
        I = eye(n_lines);
        A = [A; -I(m.forced, :)];
        rhs = [rhs; -m.gamma_max/2*ones(size(m.forced))];
    end
    [gamma_opt, val] = fw_20150423(@fun, @grad, A, rhs, ...
        gamma0, opts);

end
