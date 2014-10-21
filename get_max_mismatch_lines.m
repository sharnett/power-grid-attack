function [attacked_lines, success] = get_max_mismatch_lines(mpc, K)

attacked_lines = [];
success = 1;

[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, VA, ...
    BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
    TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;
[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
    QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;

tree_branches = mst(mpc);
tree = mpc;
tree.branch = mpc.branch(tree_branches, :);

n_lines = size(tree.branch, 1);
fileID = fopen('temp.csv','w');
fprintf(fileID, 'fbus,tbus,p\n');
for i = 1:n_lines,
    x = num2cell(tree.branch(i, [F_BUS, T_BUS, PF, PT]));
    [f_bus, t_bus, pf, pt] = x{:};
    if pf < 0,
        temp = f_bus;
        f_bus = t_bus;
        t_bus = temp;
        p = abs(pf);
    else
        p = abs(pt);
    end
    fprintf(fileID, '%d,%d,%f\n', f_bus, t_bus, p);
end
fclose(fileID);

[status, cmdout] = system(sprintf('python max_mismatch_heuristic.py %d', K));
if status ~= 0,
    success = 0;
    disp('Gurobi failed to converge');
end

% the python script sometimes swaps fbus and tbus, so let's recover the
% original order, then return the appropriate index of mpc.branch rather
% the buses for each line
attacked_lines_mat = cell2mat(textscan(cmdout, '%d %d'));
for i=1:n_lines,
    for j = 1:size(attacked_lines_mat, 1),
        fbus1 = mpc.branch(i, F_BUS);
        tbus1 = mpc.branch(i, T_BUS);
        fbus2 = attacked_lines_mat(j, 1);
        tbus2 = attacked_lines_mat(j, 2);
        if (fbus1==fbus2 && tbus1==tbus2) || (fbus1==tbus2 && tbus1==fbus2),
            attacked_lines = [attacked_lines, i];
        end
    end
end