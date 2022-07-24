const std = @import("std");
const ArrayList = std.ArrayList;
const parseInt = std.fmt.parseInt;

fn isOperator(c: u8) bool {
    return c == '+' or c == '-' or c == '*' or c == '/';
}

fn getOperatorPrecedence(operator: u8) u32 {
    return switch (operator) {
        '+', '-' => 50,
        '*', '/' => 100,
        else => {
            std.debug.print("Unsupported operator `{}`\n", .{operator});
            return 0;
        },
    };
}

fn calculate(operator: u8, left: i32, right: i32) i32 {
    return switch (operator) {
        '+' => left + right,
        '-' => left - right,
        '*' => left * right,
        '/' => @divFloor(left, right),
        else => unreachable,
    };
}

pub fn main() !void {
    const expression = "8 * 3 - 2 * 11";
    var token_iterator = std.mem.tokenize(u8, expression, " ");

    var operators = ArrayList(u8).init(std.heap.page_allocator);
    var operands = ArrayList(i32).init(std.heap.page_allocator);
    defer operators.deinit();
    defer operands.deinit();

    var token = token_iterator.next();
    while (token != null) {
        var t = token.?;
        if (t.len == 1 and isOperator(t[0])) {
            const current_precedence = getOperatorPrecedence(t[0]);

            const size = operators.items.len;
            if (size > 0 and getOperatorPrecedence(operators.items[size - 1]) >= current_precedence) {
                const right = operands.pop();
                const left = operands.pop();

                const value = calculate(operators.pop(), left, right);
                try operands.append(value);
            }

            try operators.append(t[0]);
        } else {
            try operands.append(try parseInt(i32, t, 10));
        }

        token = token_iterator.next();
    }

    while (operators.items.len > 0) {
        const right = operands.pop();
        const left = operands.pop();

        const value = calculate(operators.pop(), left, right);
        try operands.append(value);
    }

    std.debug.print("Result: {}\n", .{operands.pop()});
}
