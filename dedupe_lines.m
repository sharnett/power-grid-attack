function mpc = dedupe_lines(mpc)
mpc = loadcase(mpc);
branch = mpc.branch;
y = branch(1, :);
while ~isempty(branch),
    fbus = branch(1, 1);
    tbus = branch(1, 2);
    i = find(branch(:, 1) == fbus & branch(:, 2) == tbus);
    new_row = branch(1, :);
    
    r = mpc.branch(i, 3);
    x = mpc.branch(i, 4);
    g = r./(r.^2+x.^2);
    b = -x./(r.^2+x.^2);
    gsum = sum(g);
    bsum = sum(b);
    newrow(1, 3) = gsum/(gsum^2+bsum^2);
    newrow(1, 4) = -bsum/(gsum^2+bsum^2);
    
    y = [y; new_row];
    branch(i, :) = [];
end
y(1, :) = [];
mpc.branch = y;