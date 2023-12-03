const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const print = std.debug.print;

pub fn main() !void {
    const buf = @embedFile("input");

    var split_it = std.mem.split(u8, buf, "\n");
    var lines = std.ArrayList([]const u8).init(allocator);
    var gears = std.AutoHashMap(usize, u32).init(allocator);
    var gear_counts = std.ArrayList(usize).init(allocator);
    
    var sum: u32 = 0;

    while (split_it.next()) |line| {
        try lines.append(line);
    }
    var num_str = std.ArrayList(u8).init(allocator);
    var valid_num: bool = false;
    var gear_xy: ?usize = null;
    for (lines.items, 0..) |line, y| {

        for (line, 0..) |c, x| {

            if (std.ascii.isDigit(c)) {
                try num_str.append(c);
                if (valid_num == false) {
                    var j: u32 = 0;
                    outer: while (j < 3) : (j += 1) {
                        var i: u32 = 0;
                        while (i < 3) : (i += 1) {
                            if (y+j < 1 or x+i < 1) continue;
                            if (y+j > lines.items.len or x+i > line.len) continue;
                            const item = lines.items[y+j-1][x+i-1];

                            if (!std.ascii.isDigit(item) and item != '.') {
                                if (item == '*') gear_xy = (x+i-1)+(y+j-1)*line.len;
                                
                                valid_num = true;
                                break :outer;
                            }
                        }
                    }
                }

            } else {
                if (valid_num == true) {
                    const num = try std.fmt.parseInt(u32, num_str.items, 10);

                    if (gear_xy != null) {
                        const result = try gears.getOrPut(gear_xy.?);
                        const counts = for (gear_counts.items) |xy| {
                            if (xy == gear_xy.?) break xy;
                        } else null;

                        if (counts == null) {
                            if (result.found_existing) {
                                try gears.put(gear_xy.?, result.value_ptr.* * num);
                                try gear_counts.append(gear_xy.?);
                            } else {
                                try gears.put(gear_xy.?, num);
                            }
                        }
                        gear_xy = null;
                    }

                    sum += num;
                    valid_num = false;
                }
                num_str.clearAndFree();
            }
        }
    }
    var map_it = gears.iterator();
    var part2: u32 = 0;
    while (map_it.next()) |entry| {
        const counts = for (gear_counts.items) |xy| {
                                if (xy == entry.key_ptr.*) break xy;
                            } else null;
        if (counts != null) {
            part2 += entry.value_ptr.*;
        }
    }
    print("part 1: {}\npart 2: {}\n", .{sum, part2});
}