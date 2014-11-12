%%
attack_level = 2.0;
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

for attack_level = [1.1, 2, 2.5, 2.7, 3],
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

%% it hits a voltage constraint with attack of 2.7

attack_level = 8;
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

branch_ang_diffs = [get_branch_angle_diffs(mpc) get_branch_angle_diffs(result)]
bus_voltages = [mpc.bus(:, 8) result.bus(:, 8)]
Pgen = [mpc.gen(:, 2) result.gen(:, 2)]
Qgen = [mpc.gen(:, 3) result.gen(:, 3)]
sum_of_squared_diffs = result.f

%% do just one line at a time, print out the objectives

attack_level = 3.0;

result = mpc;
ang_diffs = get_branch_angle_diffs(result);
bus_mag_diffs = result.bus(:, 8) - 1;
objectives(i, 1) = norm(ang_diffs, 1);
objectives(i, 2) = norm(ang_diffs, 2);
objectives(i, 3) = norm(ang_diffs, inf);
objectives(i, 4) = norm(bus_mag_diffs, 1);
objectives(i, 5) = norm(bus_mag_diffs, 2);
objectives(i, 6) = norm(bus_mag_diffs, inf);
fprintf('- %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f\n', objectives)

for line1 = 1:9,
    z = ones(1, n_lines);
    z(line1) = attack_level;
    result = attack(mpc, z(i, :)');

    ang_diffs = get_branch_angle_diffs(result);
    bus_mag_diffs = result.bus(:, 8) - 1;
    objectives(i, 1) = norm(ang_diffs, 1);
    objectives(i, 2) = norm(ang_diffs, 2);
    objectives(i, 3) = norm(ang_diffs, inf);
    objectives(i, 4) = norm(bus_mag_diffs, 1);
    objectives(i, 5) = norm(bus_mag_diffs, 2);
    objectives(i, 6) = norm(bus_mag_diffs, inf);
    fprintf('%d %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f\n', ...
            [line1, objectives])
end

%% lines 7 and 8, i.e. 8->2 and 8->9, look good
% consider them individually
line1 = 4;

for attack_level = [1.1, 2, 2.5, 2.7, 2.9, 3, 5, 5.9],
    z = ones(1, n_lines);
    z(line1) = attack_level;
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

%% line 7 hits a voltage constraint with attack of 2.9

attack_level = 20;
z = ones(1, n_lines);
z(line1) = attack_level;
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

branch_ang_diffs = [get_branch_angle_diffs(mpc) get_branch_angle_diffs(result)]
bus_voltages = [mpc.bus(:, 8) result.bus(:, 8)]
Pgen = [mpc.gen(:, 2) result.gen(:, 2)]
Qgen = [mpc.gen(:, 3) result.gen(:, 3)]
sum_of_squared_diffs = result.f