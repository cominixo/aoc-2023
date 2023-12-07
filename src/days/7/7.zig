const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const print = std.debug.print;
const part = 2;

const HandType = enum {
    HIGH, ONE_PAIR, TWO_PAIR, THREE, FULL_HOUSE, FOUR, FIVE
};

const Hand = struct {
    cards: u32,
    bid: u32
};

pub fn hand_asc() fn (void, Hand, Hand) bool {
    return struct {
        pub fn inner(_: void, a: Hand, b: Hand) bool {
            return a.cards < b.cards;
        }
    }.inner;
}

pub fn solve() !void {
    const buf = @embedFile("input");

    var lines = std.mem.split(u8, buf, "\n");
    var hands = std.AutoHashMap(HandType, std.ArrayList(Hand)).init(allocator);

    while (lines.next()) |line| {
        var it = std.mem.split(u8, line, " ");
        const cards = it.next().?;
        const bid = try std.fmt.parseInt(u32, it.next().?, 10);

        var cards_value: u32 = 0;

        var repeat_count = std.mem.zeroes([16]u32);

        var joker_count: u32 = 0;

        for (cards, 0..) |card, i| {
            
            const card_hex = switch (card) {
                'A' => 0xE,
                'K' => 0xD,
                'Q' => 0xC,
                'J' => if (part == 1) 0xB else 1,
                'T' => 0xA,
                else => card - '0',
            };
            if (card_hex != 1) {
                repeat_count[card_hex] += 1;
            } else joker_count += 1;
            cards_value += std.math.shl(u32, card_hex, ((cards.len - i - 1) * 4));
        }

        var hand_type: HandType = .HIGH;

        var has_three: bool = false;
        var has_joker_pair: bool = false;
        var number_real_pairs: u32 = 0;

        for (repeat_count) |count| {
            switch (count + joker_count) {
                5 => {
                    hand_type = .FIVE;
                    break;
                },
                4 => hand_type = .FOUR,
                3 => has_three = true,
                2 => has_joker_pair = true,
                else => {}
            }
            if (count == 2) number_real_pairs += 1;
        }

        if (number_real_pairs == 2 and joker_count == 1) {
            hand_type = .FULL_HOUSE;
        } else if (hand_type == .HIGH) {
            if (has_three and number_real_pairs == 1 and joker_count == 0) {
                hand_type = .FULL_HOUSE;
            } else if (has_three) {
                hand_type = .THREE;
            } else if (number_real_pairs == 2) {
                hand_type = .TWO_PAIR;
            } else if (number_real_pairs == 1 or has_joker_pair) hand_type = .ONE_PAIR;
        }

        const found = try hands.getOrPut(hand_type);
        if (!found.found_existing) {
            found.value_ptr.* = std.ArrayList(Hand).init(allocator);
        }

        try found.value_ptr.*.append(Hand{.cards = cards_value, .bid = bid});
    }

    var cur_rank: u32 = 1;
    var result: u32 = 0;

    for (0..7) |i| {
        const hand_type: HandType = @enumFromInt(i);
        const hand =  hands.get(hand_type);
        if (hand == null) continue;
        std.sort.pdq(Hand, hand.?.items, {}, hand_asc());
        
        for (hand.?.items) |h| {
            //print("{} {x}\n", .{hand_type, h.cards});
            result += h.bid * cur_rank;
            cur_rank += 1;
        }
        
    }
    print("{}\n", .{result});
}

pub fn main() !void {
    try solve();
}
