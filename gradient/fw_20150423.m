function [x_opt, f_opt, x_path] = fw_20150423(fun, grad, A, rhs, x0, opts)
% function x_opt = fw_20150423(fun, grad, A, rhs, x0, opts)
%
% Use the Frank-Wolfe algorithm to solve the problem 
%
%    argmin_x fun(x) : A x <= rhs
%
% Inputs
% fun: objective, scalar function of n variables
% grad: gradient, n-dimensional vector function of n variables
% A: n x m constraint matrix
% rhs: m x 1 constraint right-hand side
% x0: n x 1 initial guess
% opts: (optional) struct with four fields
%     opts.max_iter: stop after this many iterations
%     opts.f_tol: stop after the 'improvement' is less than f_tol, where
%         improvement = (f_old-f_new)/max([abs(f_new) abs(f_old) 1])
%     opts.linesearch_method: either 'exact' or 'backtracking'. 'exact'
%         is probably faster for well-behaved objectives, but less robust.
%         Defaults to 'backtracking'
%     opts.avg_p: when using the search direction p, first average it with
%         the previous p. This can help with zig-zagging. False by default.
%     opts.verbose: print stuff at each iteration. False by default.
% Output
% x_opt: optimal value for x
% x_path: value of x at each iteration

    if (nargin < 6), opts = []; end;
    if (~isfield(opts, 'max_iter')), opts.max_iter = 15; end;
    if (~isfield(opts, 'f_tol')), opts.f_tol = 1e-6; end;
    if (~isfield(opts, 'linesearch_method')),
        opts.linesearch_method = 'backtracking';
    end;
    if (~isfield(opts, 'avg_p')), opts.avg_p = 0; end;
    if (~isfield(opts, 'verbose')), opts.verbose = 0; end;

    params.outputflag = 0;
    model.A = A;
    model.rhs = rhs;
    model.sense = '<';
        
    function [p, g] = compute_p(x)
        % p is the Frank-Wolfe search direction
        % g is the gradient of the objective evaluated at the point x
        g = grad(x);
        model.obj = g;
        result = gurobi(model, params);
        y = result.x;
        p = y-x;
    end

    % Exact line-search. Can be bad for ill-behaved (non-convex) functions
    function [alpha, fun_evals] = compute_alpha_exact(x, p)
        fun1D = @(alpha) fun(x + alpha*p);
        [alpha,~,~,output] = fminbnd(fun1D, 0, 1);
    	fun_evals = output.funcCount;
    end

    % Backtracking line-search
    function [alpha, fun_evals] = compute_alpha_bt(x, p, g)
        c = 1e-3;
        r = .5;
        alpha = 1;
        f0 = fun(x);
        f = fun(x + alpha*p);
        fun_evals = 2;
        while (f > f0 + c*alpha*g'*p)
            alpha = r*alpha;
            f = fun(x + alpha*p);
            fun_evals = fun_evals + 1;
        end
    end

    function [alpha, fun_evals] = compute_alpha(x, p, g)
        if (strcmp(opts.linesearch_method, 'exact'))
            [alpha, fun_evals] = compute_alpha_exact(x, p);
        else
            [alpha, fun_evals] = compute_alpha_bt(x, p, g);
        end
    end

    function pprint(k, f, alpha, x)
        [sorted, idx] = sort(x, 'descend');
        nz = find(sorted > 1e-3);
        attack = [idx(nz) sorted(nz)]';
        fprintf('%2d obj=%g step=%.2f [', k, f, alpha);
        fprintf('%d %.2f; ', attack)
        fprintf(']\n')
    end
        
    k = 0;
    f_old = fun(x0);
    if (opts.verbose), pprint(k, f_old, nan, x0); end
    converged = 0;
    p_old = zeros(size(x0));
    x_k = x0;
    x_path = [x0];
    while (~converged),
        k = k+1;
        [p_k, g_k] = compute_p(x_k);
        if (opts.avg_p)
            p_k = .5*(p_old+p_k);
            p_old = p_k;
        end
        alpha_k = compute_alpha(x_k, p_k, g_k);
        x_k = x_k + alpha_k*p_k;
        x_path = [x_path x_k];
        f_k = fun(x_k);
        
        if (opts.verbose), pprint(k, f_k, alpha_k, x_k); end

        improvement = (f_old-f_k)/max([abs(f_k) abs(f_old) 1]);
        if (k >= opts.max_iter || improvement < opts.f_tol)
            converged = 1;
        end
        f_old = f_k;
    end
    x_opt = x_k;
    f_opt = f_k;
    if (k >= opts.max_iter),
        warning('Failed to converge after %d iterations', opts.max_iter);
    end
end
