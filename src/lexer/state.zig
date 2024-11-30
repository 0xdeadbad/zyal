const std = @import("std");
@import("./lexer.zig");

pub const state_fn = ?*const fn (lexer.Lexer) state_fn;
