function gamma = random_attack(n_lines, gamma_max, K)
    gamma = inf;
    while (sum(gamma) > gamma_max*K),
        gamma = gamma_max*rand(1, n_lines);
    end
end