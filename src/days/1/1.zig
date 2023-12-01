const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const print = std.debug.print;
const part = 2;

const nums = [_][]const u8{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

pub fn solve() !void {
    const buf = @embedFile("input");

    var lines = std.mem.split(u8, buf, "\n");

    var total: u32 = 0;

    while (lines.next()) |line| {
        var digits = std.ArrayList(u32).init(allocator);
        var i: u32 = 0;
        while (i < line.len) : (i += 1) {
            const ch = line[i];
            if (std.ascii.isDigit(ch)) {
                try digits.append(try std.fmt.charToDigit(ch, 10));
            } else if (part == 2) {
                for (nums, 0..) |num, j| {
                    if (num.len + i <= line.len) {
                        if (std.mem.eql(u8, line[i .. num.len + i], num)) {
                            try digits.append(@truncate(j + 1));
                            i += @truncate(num.len - 2);
                        }
                    }
                }
            }
        }

        total += digits.items[0] * 10 + digits.getLast();
    }
    print("result: {}\n", .{total});
}

pub fn main() !void {
    try solve();
}
