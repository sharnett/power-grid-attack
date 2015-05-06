function [gamma_opt, val] = fw_attack_20150427(m, opts)

% m is a struct with the following fields:
%
% mpc - (string) the filename of a MATPOWER case
% subset - an array of line numbers to consider for attack
% obj_type - one of 'magnitude' or 'angle'
% Lnorm - one of {inf, 1, 2}
% gamma_max - the maximum attack per line
% K - the max number of lines at full attack

    if nargin < 2, opts = []; end;
    if (~isfield(opts, 'max_iter')), opts.max_iter = 15; end;
    if (~isfield(opts, 'f_tol')), opts.f_tol = 1e-6; end;
    if (~isfield(opts, 'verbose')), opts.verbose = 1; end;
    if (~isfield(opts, 'opf_alg')), opts.opf_alg = 'pdipm'; end;

    mpc = loadcase3(m.mpc);
    n_lines = size(mpc.branch, 1);
    
    function [f, success] = fun(gamma)
        [result, success] = attack(mpc, ones(n_lines, 1)+gamma, ...
            opts.opf_alg);
        f = -objective(result, m.obj_type, m.Lnorm);
    end

    function [f, success] = fun_wrapped(gamma)
        [f, success] = fun(gamma);
        if (~success), fprintf('failed to converge; objective\n'); end
    end

    function g = grad(gamma0)
        e = 1e-6;
        f0 = fun(gamma0);
        n = length(m.subset);
        g0 = zeros(n, 1);
        for i=1:n,
            line = m.subset(i);
            gamma = gamma0;
            gamma(line) = gamma(line) + e;
            [f, success] = fun(gamma);
            if (~success), fprintf('failed to converge; grad %d\n', i); end
            g0(i) = (f - f0)/e;
        end
        g = zeros(n_lines, 1);
        g(m.subset) = g0;
    end
    
    gamma0 = zeros(n_lines, 1);
    if (isfield(m, 'initial_guess')),
        gamma0(m.subset) = m.initial_guess;
    end
    
    A = sparse([ones(1, n_lines); eye(n_lines)]);
    rhs = [m.K*m.gamma_max; m.gamma_max*ones(n_lines, 1)];
    [gamma_opt, val] = fw_20150423(@fun_wrapped, @grad, A, rhs, ...
        gamma0, opts);

end
