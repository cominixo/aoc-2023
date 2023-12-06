const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const print = std.debug.print;


fn calc_number_wins(time: u64, distance: u64) u64 {
    const sqr = @sqrt(@as(f64,@floatFromInt(std.math.pow(u64, time, 2) - 4*distance)));

    const upper = @floor((@as(f64,@floatFromInt(time)) + sqr)/2);
    const lower = @ceil((@as(f64,@floatFromInt(time)) - sqr)/2);

    return @intFromFloat(upper-lower+1);
}

pub fn main() !void {
    const buf = @embedFile("input");

    var lines = std.mem.split(u8, buf, "\n");

    var time_it = std.mem.split(u8, lines.next().?," ");
    var distance_it = std.mem.split(u8, lines.next().?," ");

    var times_str = std.ArrayList(u8).init(allocator);
    var distances_str = std.ArrayList(u8).init(allocator);

    var times = std.ArrayList(u64).init(allocator);
    var distances = std.ArrayList(u64).init(allocator);

    var result: u64 = 1;

    while (time_it.next()) |time| {
        try times.append(std.fmt.parseInt(u64, time, 10) catch continue);
        try times_str.appendSlice(time);
    }
    while (distance_it.next()) |distance| {
        try distances.append(std.fmt.parseInt(u64, distance, 10) catch continue);
        try distances_str.appendSlice(distance);
    }

    const p2_time = try std.fmt.parseInt(u64, times_str.items, 10);
    const p2_distance = try std.fmt.parseInt(u64, distances_str.items, 10);

    for (times.items, distances.items) |time, distance| {
        result *= calc_number_wins(time, distance);
    }

    print("part 1: {}\n", .{result});
    print("part 2: {}\n", .{calc_number_wins(p2_time, p2_distance)});
}
