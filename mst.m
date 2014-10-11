function t = mst(mpc),
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
    TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;

    opt = mpoption('OUT_ALL', 0, 'VERBOSE', 0);
    mpc_tree = mpc;
    r = runpf(mpc_tree, opt);
    if r.success ~= 1,
        t = [];
        display('runpf failed');
        return;
    end
    r = ext2int(r);
    n = size(r.bus, 1);
    m = size(r.branch, 1);
    branchmap = sparse(n, n);
    DG = sparse(n, n); % directed graph
    %values = -sqrt(sum(r.branch(:,[16 17]).^2,2));
    % |P_km| + |P_mk| for real power flows P over edges {k, m}
    values = -sum(abs(r.branch(:, [PF PT])), 2);
    values = values - 1e-16; % annoying zero flow lines
    for line=1:m,
        i = r.branch(line,1);
        j = r.branch(line,2);
        value = values(line);
        prev = branchmap(i,j);
        % if multiple lines connect same two buses, take minimum
        if ~prev || value < values(prev), 
            branchmap(i,j) = line;
            branchmap(j,i) = line;
            DG(i, j) = value;
        end
    end
    UG = tril(DG + DG'); % undirected graph, MST function needs this
    t2 = graphminspantree(UG, 'Method', 'Kruskal');
    [i,j] = find(t2);
    t = full(branchmap(sub2ind([n n],i,j)));
    %sort(t)'
    %t = r.order.branch.i2e(t); # TODO: crap, do I need to worry about this?
end
