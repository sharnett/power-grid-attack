function [result] = attack(mpc, x, alg)
    result = mpc;
    result.branch(:, 3:4) = [x x] .* result.branch(:, 3:4);
    if (nargin < 3),
        alg = 545; % try 545 (scpdipmopf) or 550 (tralmopf)
    end
    opt = mpoption('OUT_ALL', 0, 'VERBOSE', 0, 'OPF_ALG', alg);
    result = runopf(result, opt);
end