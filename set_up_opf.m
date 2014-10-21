function [mpc, success] = set_up_opf(mpc)
%%
[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, VA, ...
    BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
    TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;
[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
    QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;

%% increase branch limits
max_F = max(sqrt(sum(mpc.branch(:, [PF QF]).^2, 2)));
max_T = max(sqrt(sum(mpc.branch(:, [PT QT]).^2, 2)));
mpc.branch(:, RATE_A) = 2*max([max_F, max_T]);

% since the bus injections are totally fake at this point reset generator
% limits
bound = 2*max(max(abs(mpc.gen(:, [PG, QG]))));
mpc.gen(:, [PMAX QMAX]) = bound;
mpc.gen(:, [PMIN QMIN]) = -bound;

%%
% set OPF costs to penalize squared difference from the generator outputs
% of the unattacked tree

n = size(mpc.gen, 1);
original_p = mpc.gen(:, 2);
original_q = mpc.gen(:, 3);

mpc.gencost = zeros(2*n, 7);
mpc.gencost(:, 1) = 2; % polynomial type cost function
mpc.gencost(:, 4) = 3; % number of terms in the polynomial

mpc.gencost(1:n, 5) = 1; % quadratic term
mpc.gencost(1:n, 6) = -2*original_p; % linear term
mpc.gencost(1:n, 7) = original_p.^2; % constant term
mpc.gencost((n+1):2*n, 5) = 1;
mpc.gencost((n+1):2*n, 6) = -2*original_q;
mpc.gencost((n+1):2*n, 7) = original_q.^2;

%%
% Allow the voltages to vary between .75 and 1.25 or something like that

v_min = .7;
v_max = 1.25;
mpc.bus(:, 12) = v_max;
mpc.bus(:, 13) = v_min;

%%
% this should do basically nothing
alg = 545; % try 545 (scpdipmopf) or 550 (tralmopf)
opt = mpoption('OUT_ALL', 0, 'VERBOSE', 0, 'OPF_ALG', alg);
mpc2 = runopf(mpc, opt);
success = 1;
if (mpc2.success < 1),
    disp('opf failed to converge');
    success = 0;
    return;
end
diff = norm(mpc.gen(:, 2:3) - mpc2.gen(:, 2:3));
tol = 1e-3;
if diff > tol,
   disp('ERROR: difference between opf and pf larger than tolerance');
   fprintf('%f %f', diff, tol);
   success = 0;
   return;
end

%%
mpc2.gencost(1:n, 6) = -2*mpc2.gen(:, 2);
mpc2.gencost(1:n, 7) = mpc2.gen(:, 2).^2;
mpc2.gencost((n+1):2*n, 6) = -2*mpc2.gen(:, 3);
mpc2.gencost((n+1):2*n, 7) = mpc2.gen(:, 3).^2;
mpc = mpc2;

%%
% Let's do something with the voltage magnitude constraints here
% Force the generators to be within 1% of their usual voltage
%buffer = .01;
%gens = mpc.bus(:, 2) > 1;
%v_gens = mpc.bus(gens, 8);
%mpc.bus(gens, 12) = (1+buffer)*v_gens;
%mpc.bus(gens, 13) = (1-buffer)*v_gens;

%%
% As an alternative to the above, what if we made these equality
% constraints?
%gens = mpc.bus(:, 2) > 1;
%v_gens = mpc.bus(gens, 8);
%mpc.bus(gens, 12) = v_gens;
%mpc.bus(gens, 13) = v_gens;