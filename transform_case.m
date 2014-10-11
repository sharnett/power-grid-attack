function result = transform_case(mpc)
[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, VA, ...
    BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
    TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;
[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
    QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;

mpc = loadcase(mpc);
% turn off susceptances, tap ratio, phase shift
% turn on all branches and generators
mpc.branch(:, [BR_B, TAP, SHIFT]) = 0;
mpc.branch(:, BR_STATUS) = 1;
mpc.gen(:, GEN_STATUS) = 1;

gen_bus_mask = mpc.bus(:, BUS_TYPE) > 1;
gen_buses = mpc.bus(gen_bus_mask, :);

% set bus type to 1 if it doesn't appear in the generator list
mistake_buses = setdiff(gen_buses(:, BUS_I), mpc.gen(:, GEN_BUS));
mpc.bus(mistake_buses, BUS_TYPE) = 1;
gen_bus_mask = mpc.bus(:, BUS_TYPE) > 1;
gen_buses = mpc.bus(gen_bus_mask, :);

% ASSUMES GENS OCCUR IN SAME ORDER AS BUSES!
% when a generator bus also has demand, adjust the generator output
% so that the demands are zero. Note this doesn't need to be done
% for reactive power since that isn't held fixed in the usual power
% flow calculation
d = gen_buses(:, PD);
mpc.gen(:, PG) = mpc.gen(:, PG) - d;
mpc.bus(gen_bus_mask, [PD QD]) = 0;

mpc.bus(:, [GS, BS]) = 0;
mpc.gen(:, PMIN) = 0;
%mpc.branch(:, RATE_A) = 10*mpc.branch(:, RATE_A);

opt = mpoption('OUT_ALL', 0, 'VERBOSE', 0);
result = runpf(mpc, opt);