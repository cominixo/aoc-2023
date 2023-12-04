const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const print = std.debug.print;

pub fn main() !void {
    const buf = @embedFile("input");

    var lines = std.mem.splitBackwards(u8, buf, "\n");
    var points: u32 = 0;

    var card_values = std.ArrayList(u32).init(allocator);
    var id: u32 = 0;
    while (lines.next()) |line| : (id += 1) {
        var it = std.mem.split(u8, line, ": ");
        _ = it.next();
        const cards = it.next().?;

        var cards_split = std.mem.split(u8, cards, " | ");
        var winning_it = std.mem.split(u8, cards_split.next().?, " ");
        var card_it = std.mem.split(u8, cards_split.next().?, " ");

        var nums = std.ArrayList([]const u8).init(allocator);

        var wins: u32 = 0;

        while (card_it.next()) |num| {
            try nums.append(num);
        }

        while (winning_it.next()) |winning_num| {
            for (nums.items) |n| {
                _ = std.fmt.parseInt(u32, n, 10) catch continue;
                if (std.mem.eql(u8, winning_num, n)) {
                    wins += 1;
                    break;
                }
            }
        }

        if (wins > 0)
            points += std.math.pow(u32, 2, wins - 1);

        // part 2
        var new_cards: u32 = 0;
        for (id - wins..id) |i| {
            new_cards += card_values.items[i];
        }

        try card_values.append(1 + new_cards);
    }

    var part2: u32 = 0;
    for (card_values.items) |card| {
        part2 += card;
    }

    print("part 1: {}\npart 2: {}\n", .{ points, part2 });
}
