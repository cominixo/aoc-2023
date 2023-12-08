const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const print = std.debug.print;

const Node = struct { 
    this: []const u8,
    left: ?*Node = null,
    right: ?*Node = null,
};

pub fn main() !void {
    const buf = @embedFile("input");

    var lines = std.mem.split(u8, buf, "\n");
    const instructions = lines.next().?;
    _ = lines.next();

    var nodes = std.StringHashMap(*Node).init(allocator);
    var a_nodes = std.ArrayList(*Node).init(allocator);

    while (lines.next()) |line| {
        var it = std.mem.split(u8, line, " = ");
        const this = it.next().?;
        var dests = it.next().?;
        var dest_it = std.mem.split(u8, dests[1..dests.len-1], ", ");
        
        const left_name = dest_it.next().?;
        
        const try_get_left = nodes.get(left_name);
        const left = if (try_get_left == null) try allocator.create(Node) else try_get_left.?;
        left.this = left_name;

        try nodes.put(left.this, left);


        const right_name = dest_it.next().?;
        const try_get_right = nodes.get(right_name);

        const right = if (try_get_right == null) try allocator.create(Node) else try_get_right.?;
        right.this = right_name;

        try nodes.put(right.this, right);

        const try_get_node = nodes.get(this);

        const node = if (try_get_node == null) try allocator.create(Node) else try_get_node.?;
        node.* = .{.this=this, .left=left, .right=right};

        if (try_get_node == null and this[2] == 'A') 
            try a_nodes.append(node);

        try nodes.put(this, node);
        
    }

    part1(nodes.get("AAA").?, instructions);
    try part2(a_nodes, instructions);
}

pub fn part1(start_node: *Node, instructions: []const u8) void {
    var steps: u64 = 0;
    var node = start_node;
    while (!std.mem.eql(u8, node.this, "ZZZ")) {
        const instruction = instructions[steps%instructions.len];
        if (instruction == 'R') {
            node = node.right.?;
        } else node = node.left.?;

        steps += 1;
    }

    print("{}\n", .{steps});
}

pub fn part2(starting_nodes: std.ArrayList(*Node), instructions: []const u8) !void {
    
    var all_steps = std.ArrayList(u32).init(allocator);

    for (starting_nodes.items) |start_node| {
        var steps: u32 = 0;
        var node = start_node;
        while (node.this[2] != 'Z') {
            const instruction = instructions[steps%instructions.len];
            if (instruction == 'R') {
                node = node.right.?;
            } else node = node.left.?;

            steps += 1;
        }

        try all_steps.append(steps);
    }

    var lcd: u64 = all_steps.items[0] * all_steps.items[1] / std.math.gcd(all_steps.items[0], all_steps.items[1]);

    if (all_steps.items.len > 2) {
        for (all_steps.items[2..]) |step| {
            lcd = step / std.math.gcd(step, lcd) * lcd ;
        }
    }

    print("{}\n", .{lcd});

}
