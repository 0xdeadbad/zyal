const std = @import("std");

const Allocator = std.mem.Allocator;

pub fn LinkedList(comptime T: type) type {
    const ListCell = struct {
        value: T,
        index: usize,
        next: ?*@This(),

        pub fn new(allocator: Allocator, value: T, index: usize) !*@This() {
            var c = try allocator.create(@This());

            c.value = value;
            c.index = index;
            c.next = null;

            return c;
        }

        pub fn destroy(self: *@This(), allocator: Allocator) void {
            allocator.destroy(self);
        }
    };

    return struct {
        allocator: Allocator,
        length: usize,
        head: ?*ListCell,

        pub fn init(allocator: Allocator) !*@This() {
            var ll = try allocator.create(@This());

            ll.allocator = allocator;
            ll.head = null;
            ll.length = 0;

            return ll;
        }

        pub fn deinit(self: *@This()) void {
            var curr_ptr = self.head;
            var prev_ptr: ?*ListCell = null;

            while (curr_ptr) |ptr| {
                prev_ptr = ptr;
                curr_ptr = ptr.next;
                prev_ptr.?.destroy(self.allocator);
            }

            self.allocator.destroy(self);
        }

        pub fn append(self: *@This(), value: T) !void {
            var lc_ptr = self.head;
            var prev_ptr: ?*ListCell = null;

            if (lc_ptr == null) {
                self.head = try ListCell.new(self.allocator, value, 0);
                return;
            }

            var i: usize = 0;
            while (lc_ptr) |ptr| : (i += 1) {
                prev_ptr = ptr;
                lc_ptr = ptr.next;
            }

            prev_ptr.?.next = try ListCell.new(self.allocator, value, i);
        }

        pub fn index(self: *@This(), findex: usize) ?*ListCell {
            var lc_ptr = self.head;
            var prev_ptr: ?*ListCell = null;

            while (lc_ptr) |ptr| {
                if (ptr.index == findex) {
                    return ptr;
                }
                prev_ptr = ptr;
                lc_ptr = ptr.next;
            }
            return null;
        }

        pub fn search_first(self: *@This(), value: T) ?*ListCell {
            var lc_ptr = self.head;
            var prev_ptr: ?*ListCell = null;

            while (lc_ptr) |ptr| {
                if (ptr.value == value) {
                    return ptr;
                }
                prev_ptr = ptr;
                lc_ptr = ptr.next;
            }
            return null;
        }
    };
}

test "LinkedList - Create and append one value, retrive it by its index (0), compare it and destroy the list" {
    const allocator = std.testing.allocator;

    const ll = try LinkedList(u32).init(allocator);
    defer ll.deinit();

    try ll.append(42);

    try std.testing.expectEqual(@as(u32, 42), ll.index(0).?.value);
}

test "LinkedList - Test method search_first()" {
    const allocator = std.testing.allocator;

    const ll = try LinkedList(u32).init(allocator);
    defer ll.deinit();

    try ll.append(42);
    try ll.append(10);
    try ll.append(11);
    try ll.append(88);
    try ll.append(11);
    try ll.append(9);

    const v = ll.search_first(11).?;

    try std.testing.expectEqual(@as(u32, 11), v.value);
    try std.testing.expectEqual(@as(u32, 88), v.next.?.value);
}
