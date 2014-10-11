function [result] = attack(mpc, x)
    result = mpc;
    result.branch(:, 3:4) = [x x] .* result.branch(:, 3:4);
    alg = 545; % try 545 (scpdipmopf) or 550 (tralmopf)
    opt = mpoption('OUT_ALL', 0, 'VERBOSE', 0, 'OPF_ALG', alg);
    %opt = mpoption('OUT_ALL', 0, 'VERBOSE', 0);
    result = runopf(result, opt);
end