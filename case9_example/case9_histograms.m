function [mpc, weak_result, med_result, strong_result] = case9_histograms()
mpc = 'case9.m';
subset = 1:9;

%%
clear m;
m.mpc = mpc;
m.subset = subset;
m.gamma_max = 2.5;
m.K = 3;
m.Lnorm = 1;
m.obj_type = 'angle';
m.opf_obj_mult = 0;

%%
%fw_attack_20150211(m);

%%
mpc = loadcase3(m.mpc);
n = length(m.subset);
o = ones(n, 1);

attacks = nchoosek(1:9, 3);
n_attacks = size(attacks, 1);
attacks = [zeros(n_attacks, 3) attacks];

%%
function result = do_attack(a)
    g = zeros(n, 1);
    g(a) = m.gamma_max;    
    result = attack(mpc, o+g);
end

%%
for i=1:n_attacks,
    result = do_attack(attacks(i, 4:end));
    
    h = result.f;
    f = objective(result, 'angle', m.Lnorm);
    f2 = objective(result, 'magnitude', m.Lnorm);
    attacks(i, [1 2 3]) = [f f2 h];
end

%%
sorted = sortrows(attacks, 1);

null = [objective(mpc, 'angle', m.Lnorm)
        objective(mpc, 'magnitude', m.Lnorm)
        0]'
weak = sorted(1, :)
med = sorted(ceil((n_attacks+1)/2), :)
strong = sorted(end, :)

weak_result = do_attack(weak(4:end));
med_result = do_attack(med(4:end));
strong_result = do_attack(strong(4:end));

%%
null_gen = mpc.gen(:, [2 3])
weak_gen = weak_result.gen(:, [2 3])
med_gen = med_result.gen(:, [2 3])
strong_gen = strong_result.gen(:, [2 3])

%%
function my_savefig(fig, name),
    %fig.PaperUnits = 'inches';
    %fig.PaperPosition = [0 0 6 3];
    %fig.PaperPositionMode = 'manual';
    %print(name,'-dpdf','-r0');
    saveas(fig, name, 'pdf');
end

%% phase angle difference histograms

null_angles = get_branch_angle_diffs(mpc);
weak_angles = get_branch_angle_diffs(weak_result);
med_angles = get_branch_angle_diffs(med_result);
strong_angles = get_branch_angle_diffs(strong_result);

edges = linspace(0, 30, 7);
ymax = 8;
fig = figure(1);

subplot(1, 4, 1);
histogram(null_angles, edges); ylim([0 ymax]); title('null');
xlabel('phase angle difference (degrees)'); ylabel('count');
subplot(1, 4, 2);
histogram(weak_angles, edges); ylim([0 ymax]); title('weak');
subplot(1, 4, 3);
histogram(med_angles, edges); ylim([0 ymax]); title('median');
subplot(1, 4, 4);
histogram(strong_angles, edges); ylim([0 ymax]); title('strong');

my_savefig(fig, 'case9_phase');

%% voltage magnitude histograms
null_magnitudes = mpc.bus(:, 8);
weak_magnitudes = weak_result.bus(:, 8);
med_magnitudes = med_result.bus(:, 8);
strong_magnitudes = strong_result.bus(:, 8);

edges = linspace(.8, 1.05, 6);
fig = figure(2);

subplot(1, 4, 1);
histogram(null_magnitudes, edges); ylim([0 ymax]); title('null');
xlabel('bus voltage magnitude (p.u.)'); ylabel('count');
subplot(1, 4, 2);
histogram(weak_magnitudes, edges); ylim([0 ymax]); title('weak');
subplot(1, 4, 3);
histogram(med_magnitudes, edges); ylim([0 ymax]); title('median');
subplot(1, 4, 4);
histogram(strong_magnitudes, edges); ylim([0 ymax]); title('strong');

my_savefig(fig, 'case9_mag');

%% flow histograms
null_flows = compute_s(mpc.branch);
weak_flows = compute_s(weak_result.branch);
med_flows = compute_s(med_result.branch);
strong_flows = compute_s(strong_result.branch);

% max([null_flows weak_flows med_flows strong_flows])
% 163.33

edges = linspace(0, 175, 8);
fig = figure(3);

subplot(1, 4, 1);
histogram(null_flows, edges); ylim([0 ymax]); title('null');
xlabel('branch apparent power (MVA)'); ylabel('count');
subplot(1, 4, 2);
histogram(weak_flows, edges); ylim([0 ymax]); title('weak');
subplot(1, 4, 3);
histogram(med_flows, edges); ylim([0 ymax]); title('median');
subplot(1, 4, 4);
histogram(strong_flows, edges); ylim([0 ymax]); title('strong');

my_savefig(fig, 'case9_flow');

%% real power loss
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
    TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;

null_loss = sum(mpc.branch(:, [PF PT]), 2);
weak_loss = sum(weak_result.branch(:, [PF PT]), 2);
med_loss = sum(med_result.branch(:, [PF PT]), 2);
strong_loss = sum(strong_result.branch(:, [PF PT]), 2);

% max([null_loss; weak_loss; med_loss; strong_loss])
% 6.8793

edges = linspace(0, 8, 8);
fig = figure(4);

subplot(1, 4, 1);
histogram(null_loss, edges); ylim([0 ymax]); title('null');
xlabel('branch real power loss (MW)'); ylabel('count');
subplot(1, 4, 2);
histogram(weak_loss, edges); ylim([0 ymax]); title('weak');
subplot(1, 4, 3);
histogram(med_loss, edges); ylim([0 ymax]); title('median');
subplot(1, 4, 4);
histogram(strong_loss, edges); ylim([0 ymax]); title('strong');

my_savefig(fig, 'case9_loss');

end
