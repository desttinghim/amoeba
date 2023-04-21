test "binary tree" {
    const var_array = try std.testing.allocator.alloc(*amoeba.am_Var, 2048);
    defer std.testing.allocator.free(var_array);

    const arr_x = var_array[0..1028];
    const arr_y = var_array[1028..2048];

    var solver: *amoeba.am_Solver = amoeba.am_newsolver(null, null) orelse return error.InitSolver;
    defer amoeba.am_delsolver(solver);

    arr_x[0] = amoeba.am_newvariable(solver) orelse return error.InitVar;
    arr_y[0] = amoeba.am_newvariable(solver) orelse return error.InitVar;

    const num_rows = 9;
    const x_offset = 0;

    // Create a set of rules to distribute vertexes of a binary tree like this one:
    //      0
    //     / \
    //    /   \
    //   1     2
    //  / \   / \
    // 3   4 5   6

    // x root = 500, y root = 10
    _ = amoeba.am_addedit(arr_x[0], amoeba.AM_STRONG);
    _ = amoeba.am_addedit(arr_y[0], amoeba.AM_STRONG);
    _ = amoeba.am_addedit(arr_x[0], 500.0 + x_offset);
    _ = amoeba.am_addedit(arr_y[0], 10.0);

    var n_current_row_points_count: usize = 1;
    var n_current_row_first_point_index: usize = 0;
    var n_row: usize = 1;
    while (n_row < num_rows) : (n_row += 1) {
        const n_previous_row_first_point_index = n_current_row_first_point_index;
        var n_parent_point: usize = 0;
        n_current_row_first_point_index += n_current_row_points_count;
        n_current_row_points_count *= 2;

        var n_point: usize = 0;
        while (n_point < n_current_row_points_count) : (n_point += 1) {
            arr_x[n_current_row_first_point_index + n_point] = amoeba.am_newvariable(solver) orelse return error.InitVar;
            arr_y[n_current_row_first_point_index + n_point] = amoeba.am_newvariable(solver) orelse return error.InitVar;

            // y cur = yprev row + 15
            {
                const constraint = amoeba.am_newconstraint(solver, amoeba.AM_REQUIRED);
                _ = amoeba.am_addterm(constraint, arr_y[n_current_row_first_point_index + n_point], 1.0);
                _ = amoeba.am_setrelation(constraint, amoeba.AM_EQUAL);
                _ = amoeba.am_addterm(constraint, arr_y[n_current_row_first_point_index - 1], 1.0);
                _ = amoeba.am_addconstant(constraint, 15.0);

                const result = amoeba.am_add(constraint);

                try std.testing.expectEqual(result, amoeba.AM_OK);
            }

            if (n_point > 0) {
                const constraint = amoeba.am_newconstraint(solver, amoeba.AM_REQUIRED);
                _ = amoeba.am_addterm(constraint, arr_x[n_current_row_first_point_index + n_point], 1.0);
                _ = amoeba.am_setrelation(constraint, amoeba.AM_GREATEQUAL);
                _ = amoeba.am_addterm(constraint, arr_y[n_current_row_first_point_index + n_point - 1], 1.0);
                _ = amoeba.am_addconstant(constraint, 5.0);

                const result = amoeba.am_add(constraint);

                try std.testing.expectEqual(result, amoeba.AM_OK);
            } else {
                const constraint = amoeba.am_newconstraint(solver, amoeba.AM_REQUIRED);
                _ = amoeba.am_addterm(constraint, arr_x[n_current_row_first_point_index + n_point], 1.0);
                _ = amoeba.am_setrelation(constraint, amoeba.AM_GREATEQUAL);
                _ = amoeba.am_addconstant(constraint, 0.0);

                const result = amoeba.am_add(constraint);

                try std.testing.expectEqual(result, amoeba.AM_OK);
            }

            if (n_point % 2 == 1) {
                const constraint = amoeba.am_newconstraint(solver, amoeba.AM_REQUIRED);
                _ = amoeba.am_addterm(constraint, arr_x[n_previous_row_first_point_index + n_parent_point], 1.0);
                _ = amoeba.am_setrelation(constraint, amoeba.AM_EQUAL);
                _ = amoeba.am_addterm(constraint, arr_x[n_current_row_first_point_index + n_point], 0.5);
                _ = amoeba.am_addterm(constraint, arr_x[n_current_row_first_point_index + n_point - 1], 0.5);

                const result = amoeba.am_add(constraint);

                try std.testing.expectEqual(result, amoeba.AM_OK);

                n_parent_point += 1;
            }
        }
    }

    const n_points_count = n_current_row_first_point_index + n_current_row_points_count;
    _ = n_points_count;
}

const amoeba = @import("amoeba.zig");
const std = @import("std");
