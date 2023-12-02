const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const print = std.debug.print;

const colors = [_][]const u8{ "red", "green", "blue" };
const limits = [_]u32{ 12, 13, 14 };

pub fn main() !void {
    const buf = @embedFile("input");

    var lines = std.mem.split(u8, buf, "\n");
    var id: u32 = 1;

    var power_sum: u32 = 0;
    var games_sum: u32 = 0;

    while (lines.next()) |line| : (id += 1) {
        var it = std.mem.split(u8, line, ": ");
        _ = it.next();
        const game = it.next().?;

        var it2 = std.mem.split(u8, game, " ");

        var max_cubes = [_]u32{ 0, 0, 0 };
        var valid_game: bool = true;

        while (it2.next()) |elem| {
            const num = std.fmt.parseInt(u32, elem, 10) catch continue;
            var color_str = it2.next().?;
            if (color_str[color_str.len - 1] == ',' or color_str[color_str.len - 1] == ';')
                color_str = color_str[0 .. color_str.len - 1];

            var i: u32 = 0;
            for (colors) |color| {
                if (std.mem.eql(u8, color, color_str)) {
                    break;
                }
                i += 1;
            }

            if (num > limits[i]) {
                valid_game = false;
            }

            if (num > max_cubes[i]) {
                max_cubes[i] = num;
            }
        }
        power_sum += max_cubes[0] * max_cubes[1] * max_cubes[2];
        if (valid_game)
            games_sum += id;
    }

    print("part 1: {}\npart 2: {}\n", .{ games_sum, power_sum });
}
