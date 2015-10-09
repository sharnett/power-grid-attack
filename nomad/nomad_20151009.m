%%
clear m;
m.mpc = 'case9.m';
m.subset = [1 4 7 8];
m.subset = 1:9;

m.mpc = 'case14.m';
m.subset = 1:20;

m.mpc = 'case30.m';
m.subset = 1:41;

m.gamma_max = 2.5;
m.K = 3;
m.Lnorm = 1;
m.obj_type = 'angle';

clear opts;
opts.max_iter = 50;
%m.initial_guess = random_attack(length(m.subset), m.gamma_max, m.K);

disp(datestr(now, 'yyyymmdd_HHMMSS'));
disp(m);

%%
m.initial_guess = random_attack2(length(m.subset), m.gamma_max, m.K);
%m.initial_guess = [2.5; 1.625; 2.5; .875];
tic;
[gamma_opt, val] = fw_attack_20150427(m, opts);
val
toc

%% nomad

%addpath('/Applications/nomad.3.7.2/examples/interfaces/Matlab_MEX');

n = length(m.subset);
mpc = loadcase3(m.mpc);
fun = @(x) [ps_fun(x, mpc, m) sum(x)-m.K*m.gamma_max];

%fun = @(x) [x(5) sum((x-1).^2)-25 25-sum((x+1).^2)];
x0 = zeros(n, 1);
%x0 = [2.5; 0; 2.5; 2.5];
lb = zeros(n, 1);
ub = m.gamma_max*ones(n, 1);
opts = nomadset('bb_output_type', 'OBJ PB', ...
				'display_degree', 2);
			%	'max_time', 36000, ...
			%	'max_bb_eval', 100000, ...
tic;
[x,fval,exitflag,iter,nfval] = nomad(fun,x0,lb,ub,opts)
toc


% 	 13596	-47.6182340788
% 	 13597	-47.6182340788
% 
% } end of run (max time)
% 
% blackbox evaluations                     : 13597
% best infeasible solution (min. violation): ( 0.0219619 0.407516 0.639336 0.0292826 0.556369 0.527086 0.034163 0.0390434 0.0195217 0.0390434 0.0463641 0.0463641 0.0195217 0.034163 0.0219619 2.45608 0.0658858 0.0976086 0.161054 0.0390434 0.0439239 0.183016 0.0780869 0.0195217 0.068326 0.0317228 0.0439239 0.0219619 0.0244022 0.0219619 0.068326 0.0756467 0.0512445 0.0195217 0.0244022 0.0512445 0.480722 0.688141 0.143973 0.0195217 0.0390434 ) h=5.95465e-07 f=-46.6347
% best feasible solution                   : ( 0 0.464132 0.96412 0.00259273 0.15475 0.624999 0 0.0559724 0 0.0201631 0 0.0805167 0 0.0181014 0.00114385 2.5 0.00289776 0 0.139169 0 0.0158995 0.31981 0.0170434 0 0.00823573 0 0.00163952 0.000762567 0.00575738 0.0051378 0.00549048 0.0117435 0.00171578 0 0.0227912 0.00045754 0.795155 0.957616 0.279598 0.0102756 0.0117817 ) h=0 f=-47.6182
% ------------------------------------------------------------------
% fval = -47.618
% exitflag = 0
% iter = 454
% nfval = 13597
% 
% Elapsed time is 5440.883092 seconds.

