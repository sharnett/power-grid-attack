%%
attack_level = 3.0;
K = 2;

mpc = 'case9.m';

%%
mpc = loadcase(mpc);
mpc = dedupe_lines(mpc);
mpc = dedupe_gens(mpc);
mpc = transform_case(mpc);
[mpc, setup_success] = set_up_opf(mpc);
if ~setup_success,
    error('failed to set up the problem');
end

i = 1;

n_lines = size(mpc.branch, 1);
objectives = zeros(1, 6);

%% enumerate and attack all pairs, print out the objectives

result = mpc;
ang_diffs = get_branch_angle_diffs(result);
bus_mag_diffs = result.bus(:, 8) - 1;
objectives(i, 1) = norm(ang_diffs, 1);
objectives(i, 2) = norm(ang_diffs, 2);
objectives(i, 3) = norm(ang_diffs, inf);
objectives(i, 4) = norm(bus_mag_diffs, 1);
objectives(i, 5) = norm(bus_mag_diffs, 2);
objectives(i, 6) = norm(bus_mag_diffs, inf);
fprintf('- - %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f\n', objectives)

for line1 = 1:9,
    for line2 = (line1+1):9,
        z = ones(1, n_lines);
        z(line1) = attack_level;
        z(line2) = attack_level;
        result = attack(mpc, z(i, :)');

        ang_diffs = get_branch_angle_diffs(result);
        bus_mag_diffs = result.bus(:, 8) - 1;
        objectives(i, 1) = norm(ang_diffs, 1);
        objectives(i, 2) = norm(ang_diffs, 2);
        objectives(i, 3) = norm(ang_diffs, inf);
        objectives(i, 4) = norm(bus_mag_diffs, 1);
        objectives(i, 5) = norm(bus_mag_diffs, 2);
        objectives(i, 6) = norm(bus_mag_diffs, inf);
        fprintf('%d %d %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f\n', ...
                [line1, line2, objectives])
    end
end

%% lines 3 and 8, i.e. 5->6 and 8->9, make a good candidate
line1 = 3;
line2 = 8;

for attack_level = [1.1, 2, 3, 4, 5, 8, 15, 20, 25, 30, 100, 1000],
    z = ones(1, n_lines);
    z(line1) = attack_level;
    z(line2) = attack_level;
    result = attack(mpc, z(i, :)');

    ang_diffs = get_branch_angle_diffs(result);
    bus_mag_diffs = result.bus(:, 8) - 1;
    objectives(i, 1) = norm(ang_diffs, 1);
    objectives(i, 2) = norm(ang_diffs, 2);
    objectives(i, 3) = norm(ang_diffs, inf);
    objectives(i, 4) = norm(bus_mag_diffs, 1);
    objectives(i, 5) = norm(bus_mag_diffs, 2);
    objectives(i, 6) = norm(bus_mag_diffs, inf);
    fprintf('%8.1f %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f\n', ...
            [attack_level, objectives])
end