const std = @import("std");

pub const Lexer = struct {
    source: []const u8,
    current: usize,
    last: usize,
    curr_loc: Loc,
    state: State,

    pub const state_fn = ?*const fn (*Lexer) state_fn;

    pub const Loc = struct { line: usize, column: usize };

    pub const Type = enum {
        eof,
    };

    pub const State = enum {
        start,

        simple_string,
        integer,
        float,

        fn get_state_fn(self: State) state_fn {
            return switch (self) {
                .start => state_start,
            };
        }
    };

    pub const Token = struct {
        tk_lexeme: []const u8,
        tk_type: Type,
        tk_loc: Loc,
    };

    pub fn emit_token(self: *Lexer, tk_type: Type) Token {
        defer self.last = self.current;

        return Token{
            .tk_lexeme = self.source[self.last..self.current],
            .tk_type = tk_type,
            .tk_loc = self.curr_loc,
        };
    }

    pub fn next(self: *Lexer) void {
        switch (self.state) {
            .start => self.state.get_state_fn(self),
            else => @panic("bruh\n"),
        }
    }

    fn state_start(_: *Lexer) state_fn {
        std.debug.print("{}\n", "yooo");
        return null;
    }
};

test "Test get_state_fn()" {
    var l = Lexer{
        .curr_loc = .{
            .line = 0,
            .column = 0,
        },
        .current = 0,
        .last = 0,
        .source = "aaaa",
        .state = .start,
    };

    l.next();
}
