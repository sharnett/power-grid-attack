function obj = objective(result, type, Lnorm)

if (strcmp(type, 'magnitude')),
    diffs = result.bus(:, 8) - 1;
elseif (strcmp(type, 'angle')),
    diffs = get_branch_angle_diffs(result);
else
    error('type must be one of "magnitude" or "angle"');
end
obj = norm(diffs, Lnorm);