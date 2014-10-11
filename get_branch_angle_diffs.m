function ang_diffs = get_branch_angle_diffs(mpc),

[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, VA, ...
    BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;

[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
    TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;

n = size(mpc.branch, 1);
ang_diffs = zeros(n, 1);
for i = 1:n,
    fbus = mpc.branch(i, F_BUS);
    tbus = mpc.branch(i, T_BUS);
    fang = mpc.bus(fbus, VA);
    tang = mpc.bus(tbus, VA);
    ang_diffs(i) = abs(fang-tang);
end