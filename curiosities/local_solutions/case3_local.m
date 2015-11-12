function mpc = case3_local
mpc.version = '2';

mpc.baseMVA = 100;

%% bus data
%	bus_i	type	Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax	Vmin
mpc.bus = [
	1	3	110	  40	0	0	1	.9     0	1	1	1.1 0.9;
	2	2	110	  40	0	0	1	.9   32	1	1	1.1	0.9;
	3	1	95	  50	0	0	1	.9  -132	1	1	1.1	0.9;
];

%% generator data
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin	Pc1	Pc2	Qc1min	Qc1max	Qc2min	Qc2max	ramp_agc	ramp_10	ramp_30	ramp_q	apf
mpc.gen = [
	1	181	-17	500	-500	.95	1	1	500	-500	0	0	0	0	0	0	0	0	0	0	0;
	2	194	5	500	-500	.95	1	1	500	-500	0	0	0	0	0	0	0	0	0	0	0;
];

%% branch data
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax
mpc.branch = [
	1	2	0.042	.9	.3	2500	2500	2500	0	0	1	-360	360;
	1	3	0.065	.62	.7	2500	2500	2500	0	0	1	-360	360;
	2	3	0.025	.75	.45	186	186	186	0	0	1	-360	360;
];


%%-----  OPF Data  -----%%
%% generator cost data
%	1	startup	shutdown	n	x1	y1	...	xn	yn
%	2	startup	shutdown	n	c(n-1)	...	c0
mpc.gencost = [
	2	0	0	3	.11     5	0;
	2	0	0	3	.085	1.2	0;
    2	0	0	3	0 0	0;
	2	0	0	3	0 0	0;
];