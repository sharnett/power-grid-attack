function [result, success] = attack(mpc, x, alg, verbose)
    if (nargin < 4), verbose = 0; end
    if (nargin < 3), alg = 'pdipm'; end % or tralm
    result = mpc;
    result.branch(:, 3:4) = [x x] .* result.branch(:, 3:4);
    opt = mpoption('out.all', 0, 'verbose', 0, 'opf.ac.solver', alg);
    result = runopf(result, opt);
    success = result.success;
    if (~success && verbose), disp('attack failed to converge'); end
end