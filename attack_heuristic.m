function [z, last_repeated, objectives, success] = ...
    attack_heuristic(method, mpc, K, attack_level, max_iter, tol)

[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, VA, ...
    BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
    TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;
[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
    QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;

if nargin < 6, tol = 1e-4; end
if nargin < 5, max_iter = 50; end

mpc = loadcase(mpc);
mpc = dedupe_lines(mpc);
mpc = dedupe_gens(mpc);
mpc = transform_case(mpc);

n_lines = size(mpc.branch, 1);
z = ones(max_iter+1, n_lines);
objectives = zeros(max_iter+1, 3);
last_repeated = 1;
success = 1;

[mpc, setup_success] = set_up_opf(mpc);
if ~setup_success,
    success = 0;
    return;
end

function converged = check_convergence(z, i, tol)
    converged = 0;
    for j = i-1:-1:1,
        if norm(z(i, :) - z(j, :), inf) < tol,
            converged = j;
            break;
        end
    end
end

for i = 1:max_iter,
    fprintf('.');
    result = attack(mpc, z(i, :)');
    if (result.success < 1),
        success = 0;
        break;
    end
    ang_diffs = get_branch_angle_diffs(result);
    objectives(i, 1) = norm(ang_diffs, 1);
    objectives(i, 2) = norm(ang_diffs, 2);
    objectives(i, 3) = norm(ang_diffs, inf);
    if strcmp(method, 'top_k')
        top_k_lines = get_top_k_mst_lines(result, K);
    elseif strcmp(method, 'max_mismatch')
        [top_k_lines, success] = get_max_mismatch_lines(result, K);
        if ~success,
            disp('get_max_mismatch_lines failed');
            return;
        end
    else
        error('method must be one of top_k or max_mismatch');
    end
    w = ones(n_lines, 1);
    w(top_k_lines) = attack_level;
    z(i+1, :) = .5*(w+z(i, :)');
    last_repeated = check_convergence(z, i+1, tol);
    if last_repeated,
        break;
    end
end
fprintf('\n');
if i >= max_iter,
    success = 0;
end
z = z(1:i+1, :);

end