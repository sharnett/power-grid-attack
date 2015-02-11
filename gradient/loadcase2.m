function mpc = loadcase2(mpc)

mpc = loadcase(mpc);
mpc = dedupe_lines(mpc);
mpc = dedupe_gens(mpc);
mpc = transform_case(mpc);
[mpc, setup_success] = set_up_opf(mpc);
if ~setup_success,
    error('failed to set up the problem');
end