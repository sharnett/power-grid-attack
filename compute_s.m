function s = compute_s(branch_data)
% average of 'to' and 'from' apparent power on each branch

    [F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
        TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
        ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;

    norm2 = @(x) sqrt(sum(abs(x).^2, 1));
    from = norm2(branch_data(:, [PF QF])');
    to = norm2(branch_data(:, [PT QT])');
    s = .5*(from+to);
end