function [f, f_opf] = ps_fun(x, mpc, m)
    n_lines = size(mpc.branch, 1);

    gamma = zeros(n_lines, 1);
    for i = 1:length(m.subset),
        gamma(m.subset(i)) = x(i);
    end

    result = attack(mpc, ones(n_lines, 1)+gamma);
    f = objective(result, m.obj_type, m.Lnorm);
    f = -f;