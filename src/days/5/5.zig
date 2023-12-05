const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const print = std.debug.print;
const part = 1;

const MapEntry = struct {
    dest_start: i64,
    source_start: i64,
    range: i64
};

const Range = struct {
    from: i64,
    to: i64
};

pub fn main() !void {
    const buf = @embedFile("input");

    var lines = std.mem.split(u8, buf, "\n");

    var seeds_it = std.mem.split(u8, lines.next().?, ": ");
    _ = seeds_it.next();

    var seeds = std.mem.split(u8, seeds_it.next().?, " ");
    
    var inputs = std.ArrayList(i64).init(allocator);

    var seeds_range = std.ArrayList(Range).init(allocator);

    var maps = std.ArrayList(std.ArrayList(MapEntry)).init(allocator);

    if (part == 1) {
        while (seeds.next()) |seed|
            try inputs.append(try std.fmt.parseInt(i64, seed, 10));   
    } else {
        while (seeds.next()) |seed| {
            const from = try std.fmt.parseInt(i64, seed, 10);
            const range = try std.fmt.parseInt(i64, seeds.next().?, 10);
            try seeds_range.append(Range {.to=from+range, .from=from});
        }      
    }

    while (lines.next()) |line| {
        if (std.mem.endsWith(u8, line, ":")) {

            var map = std.ArrayList(MapEntry).init(allocator);

            while (lines.next()) |map_line| {            
                var ranges_it = std.mem.split(u8, map_line, " ");
                const dest_start = std.fmt.parseInt(i64, ranges_it.next().?, 10) catch break;
                const source_start = try std.fmt.parseInt(i64, ranges_it.next().?, 10); 
                const range = try std.fmt.parseInt(i64, ranges_it.next().?, 10);

                const entry = if (part == 2) MapEntry {
                    .dest_start = source_start,
                    .source_start = dest_start,
                    .range = range,
                } else 
                MapEntry {
                    .dest_start = dest_start,
                    .source_start = source_start,
                    .range = range,
                };

                try map.append(entry);
            }
            try maps.append(map);
        }
    }
    
    if (part == 1) {
        for (inputs.items, 0..) |*input, i| { 
            for (maps.items) |map| {
                var visited_inputs: u32 = 0;
                for (map.items) |entry| {
                    if (entry.source_start + entry.range >= input.* and entry.source_start <= input.* and (visited_inputs & std.math.shl(u32, 1, i)) == 0) {
                        input.* = (entry.dest_start - entry.source_start) + input.*;
                        visited_inputs ^= std.math.shl(u32, 1, i);
                    }
                }

            }
        }

        var min_num: ?i64 = null;
        for (inputs.items) |output| {
            if (min_num == null or min_num.? > output) min_num = output;
        }
        print("{}\n", .{min_num.?});
    } else { // part 2
        var input: i64 = 0;
        var i: i64 = 0;
        std.mem.reverse(std.ArrayList(MapEntry), maps.items);
        const result = outer: while (true) : (i += 1) {
            input = i;
            for (maps.items) |map| {
                for (map.items) |entry| {
                    if (entry.source_start + entry.range >= input and entry.source_start <= input) {
                        
                        input = (entry.dest_start - entry.source_start) + input;
                        break;
                    }
                }
            }

            for (seeds_range.items) |range| {
                if (input >= range.from and input <= range.to) {
                    
                    break :outer i;
                }
            }
        };
        print("{}\n", .{result});
    }

}
