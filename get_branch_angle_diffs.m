function ang_diffs_ext = get_branch_angle_diffs(mpc_ext)

[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, VA, ...
    BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;

[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
    TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;

mpc_int = ext2int(mpc_ext);
n_lines_int = size(mpc_int.branch, 1);
ang_diffs_int = zeros(n_lines_int, 1);
for i = 1:n_lines_int,
    fbus = mpc_int.branch(i, F_BUS);
    tbus = mpc_int.branch(i, T_BUS);
    fang = mpc_int.bus(fbus, VA);
    tang = mpc_int.bus(tbus, VA);
    ang_diffs_int(i) = abs(fang-tang);
end

ang_diffs_ext = i2e_data(mpc_int, ang_diffs_int, 0, 'branch');