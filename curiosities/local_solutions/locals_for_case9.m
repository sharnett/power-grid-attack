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
mpc = loadcase(case9);
mpc.bus(:, [PD QD]) = .6*mpc.bus(:, [PD QD]);
mpc.gen(:, QMIN) = -5;

opt = mpoption('out.all', 0, 'verbose', 0, 'opf.ac.solver', 'pdipm');

r = runopf(mpc, opt);
r.bus(:, VM)
r.gen(:, [PG QG])
r.f

%%
opt = mpoption('out.all', 0, 'verbose', 0, 'opf.ac.solver', 'tralm');

r = runopf(mpc, opt);
r.bus(:, VM)
r.gen(:, [PG QG])
r.f