function mpc = dedupe_gens(mpc)
mpc = loadcase(mpc);
gen = mpc.gen;
y = gen(1, :);
while ~isempty(gen),
    bus = gen(1, 1);
    i = find(gen(:, 1) == bus);
    new_row = gen(1, :);
    
    p = mpc.gen(i, 2);
    q = mpc.gen(i, 3);
    newrow(1, 2) = sum(p);
    newrow(1, 3) = sum(q);
    
    y = [y; new_row];
    gen(i, :) = [];
end
y(1, :) = [];
y = sortrows(y, 1);
mpc.gen = y;