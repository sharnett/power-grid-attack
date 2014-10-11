function top_k_lines = get_top_k_mst_lines(mpc, K)

[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
    TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;

% |P_km| + |P_mk| for real power flows P over edges {k, m}
tree_lines = mst(mpc);
sum_real_flows = sum(abs(mpc.branch(:, [PF PT])), 2);

[~, sort_indices] = sort(sum_real_flows(tree_lines));
top_k_lines = tree_lines(sort_indices(end-K+1:end));