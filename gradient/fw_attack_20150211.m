function [gamma_opt, val, val_opf] = fw_attack_20150124(m, opts)

% m is a struct with the following fields:
%
% mpc - (string) the filename of a MATPOWER case
% subset - an array of line numbers to consider for attack
% obj_type - one of 'magnitude' or 'angle'
% Lnorm - one of {inf, 1, 2}
% gamma_max - the maximum attack per line
% K - the max number of lines at full attack
% opf_obj_mult - the amount of OPF objective to add into the attack obj

    if nargin < 2, opts = []; end;
    if (~isfield(opts, 'max_iter')), opts.max_iter = 15; end;
    if (~isfield(opts, 'f_tol')), opts.f_tol = 1e-6; end;
    if (~isfield(opts, 'overshoot_iter')), opts.overshoot_iter = 0; end;
    if (~isfield(opts, 'overshoot_mult')), opts.overshoot_mult = 1; end;
    if (~isfield(opts, 'verbose')), opts.verbose = 1; end;

    mpc = loadcase3(m.mpc);
    n_lines = size(mpc.branch, 1);
    
    function [f, f_opf] = fun(gamma)
        result = attack(mpc, ones(n_lines, 1)+gamma);
        f = objective(result, m.obj_type, m.Lnorm);
        f_opf = m.opf_obj_mult*result.f;
        f = f + f_opf;
    end

    function g = grad(gamma0)
        e = 1e-6;
        f0 = fun(gamma0);
        n = length(m.subset);
        g0 = zeros(n, 1);
        parfor i=1:n,
            line = m.subset(i);
            gamma = gamma0;
            gamma(line) = gamma(line) + e;
            %f = fun(gamma);
            f = fun3(gamma, mpc, n_lines, m)
            g0(i) = (f - f0)/e;
        end
        g = zeros(n_lines, 1);
        g(m.subset) = g0;
    end

    params.outputflag = 0;
    model.A = sparse(ones(1, n_lines));
    model.rhs = m.K*m.gamma_max;
    model.ub = m.gamma_max*ones(1, n_lines);
    model.sense = '<';
    model.modelsense = 'max';
        
    function p = compute_p(gamma)
        model.obj = grad(gamma);
        result = gurobi(model, params);
        y = result.x;
        p = y-gamma;
    end

    function [alpha, fun_evals] = compute_alpha(gamma, p)
        fun2 = @(alpha) -fun(gamma + alpha*p);
        [alpha,~,~,output] = fminbnd(fun2, 0, 1);
    	fun_evals = output.funcCount;
    end

    %TODO: tidy this up
    
    gamma_k = zeros(n_lines, 1);
    if (isfield(m, 'initial_guess')),
        gamma_k(m.subset) = m.initial_guess;
    end
    
    if (opts.verbose),
        [f_k, f_opf] = fun(gamma_k);
        nz = find(gamma_k);
        disp([0 f_k; nan f_opf; nz gamma_k(nz)]');
    end
        
    k = 1;
    f_old = -1e16;
    converged = 0;
    while (~converged),
        p_k = compute_p(gamma_k);
        alpha_k = compute_alpha(gamma_k, p_k);
        % overshoot first several iterations to help with zig-zag
        if (k <= opts.overshoot_iter),
            alpha_k = min([opts.overshoot_mult*alpha_k 1]);
        end
        gamma_k = gamma_k + alpha_k*p_k;
        [f_k, f_opf] = fun(gamma_k);
        
        if (opts.verbose),
            nz = find(gamma_k > 1e-3);
            disp([k f_k; alpha_k f_opf; nz gamma_k(nz)]');
        end
        
        k = k+1;
        improvement = (f_k-f_old)/max([abs(f_k) abs(f_old) 1]);
        f_old = f_k;
        if (k >= opts.max_iter || improvement < opts.f_tol)
            converged = 1;
        end
    end
    gamma_opt = gamma_k;
    [val, val_opf] = fun(gamma_opt);

end
