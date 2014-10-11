%%
[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, VA, ...
    BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
    TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;
[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
    QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;

%%
K = 5;
attack_level = 3.0;
mpc = 'case118.m';
%mpc = 'case300.m';
%mpc = 'case2383wp.m';
mpc = loadcase(mpc);
opt = mpoption('OUT_ALL', 0, 'VERBOSE', 0);

%%
mpc = dedupe_lines(mpc);
mpc = dedupe_gens(mpc);
mpc = transform_case(mpc);
mpc = set_up_opf(mpc);
n_lines = size(mpc.branch, 1);
z = ones(n_lines, 1);
iter = 0;

%%
iter = iter+1;
result = attack(mpc, z);
if (result.success < 1), disp('**********FAIL**********'); end
%top_k_lines = get_top_k_lines(result, K);
top_k_lines = get_top_k_mst_lines(result, K);
%top_k_lines'
w = ones(n_lines, 1);
w(top_k_lines) = attack_level;
z = .5*(w+z);

fprintf('attack size: %.4f\n', (sum(z) - length(z))/K+1);

[attacks, attacked_lines] = sort(z, 'descend');
i = max(find(attacks-1));
max_ang_diff = max(get_branch_angle_diffs(result))
nonzero_attacks = [attacked_lines(1:i)'; attacks(1:i)']
