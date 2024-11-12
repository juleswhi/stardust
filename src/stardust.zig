const std = @import("std");

pub const sd_log_level = enum(u8) {
    info = 0,
    debug = 1,
    err = 2,
    fatal = 3,

    pub fn to_string(self: *const sd_log_level) []const u8 {
        return switch (self.*) {
            .info => "INF",
            .debug => "DEB",
            .err => "ERR",
            .fatal => "FAT",
        };
    }

    pub fn colour(self: *const sd_log_level) []const u8 {
        return switch (self.*) {
            .info => "\x1b[38;5;2m",
            .debug => "\x1b[38;5;12m",
            .err => "\x1b[38;5;3m",
            .fatal => "\x1b[38;5;1m",
        };
    }
};

// Global config of Stardust
var SD_CONFIG = _sd_global_config{
    .alloc = null,
    .level = .info,
    .stdout = null,
};

const _sd_global_config = struct {
    alloc: ?std.mem.Allocator,
    level: sd_log_level,
    stdout: ?std.io.AnyWriter,
};

// Setup Stardust allocator and other configuration
pub fn sd_setup(args: struct {
    alloc: std.mem.Allocator,
    level: ?sd_log_level,
}) void {
    if (args.level) |l| {
        SD_CONFIG.level = l;
    }

    SD_CONFIG.alloc = args.alloc;
    SD_CONFIG.stdout = null;
}

pub fn log(args: anytype) void {
    if (SD_CONFIG.alloc == null) {
        std.debug.print("Stardust has not been initialised. Please call sd_setup()", .{});
    }

    var string = std.ArrayList(u8).init(SD_CONFIG.alloc.?);
    defer string.deinit();

    const args_type = @TypeOf(args);

    var description = std.ArrayList([]const u8).init(SD_CONFIG.alloc.?);
    defer description.deinit();

    var level: sd_log_level = .debug;
    var source: ?std.builtin.SourceLocation = null;

    inline for (@typeInfo(args_type).Struct.fields) |field| {
        const field_value = @field(args, field.name);
        const field_type = @TypeOf(field_value);
        if (isZigString(field_type)) {
            if (std.mem.containsAtLeast(u8, field_value, 1, "|>")) {
                description.append(field_value) catch |e| {
                    std.debug.panic("Could not append slice: {}", .{e});
                };
            } else {
                string.appendSlice(field_value) catch |e| {
                    std.debug.panic("Could not append slice: {}", .{e});
                };
                string.appendSlice(" ") catch |e| {
                    std.debug.panic("Could not append slice: {}", .{e});
                };
            }
        } else if (isZigInt(field_type)) {
            var buf: [64]u8 = undefined;
            _ = std.fmt.bufPrint(&buf, "{}", .{field_value}) catch "";
            string.appendSlice(&buf) catch {};
            string.appendSlice(" ") catch {};
        } else if (field_type == std.builtin.SourceLocation) {
            source = field_value;
        } else if (field_type == sd_log_level) {
            level = field_value;
        } else {
            level = switch (field_value) {
                .info => .info,
                .debug => .debug,
                .err => .err,
                .fatal => .fatal,
                else => {},
            };
        }
    }

    if (string.items.len == 0) {
        string.appendSlice("!") catch std.debug.print("[[stardust]] could not log err", .{});
    }

    const final_string = string.toOwnedSlice() catch "";
    var desc: ?[][]const u8  = description.toOwnedSlice() catch null;
    if(desc.?.len == 0) {
        desc = null;
    }

    if (@intFromEnum(level) >= @intFromEnum(SD_CONFIG.level)) {
        _sd_print(log_message{
            .time = "00:00",
            .level = level,
            .message = final_string,
            .source = source,
            .description = desc,
        });
    }
}

// HH:MM DEBU msg
// --> File fn :: Line Column
// | More
// | Information
// | Goes
// | Here

const log_message = struct {
    time: []const u8,
    level: sd_log_level,
    message: []const u8,
    source: ?std.builtin.SourceLocation,
    description: ?[][]const u8,
};

const _SD_COL_LIGHT_PINK = "\x1b[38;5;13m";
const _SD_COL_WHITE = "\x1b[38;5;255m";
const _SD_COL_GOLD = "\x1b[33m";
const _SD_COL_BLUE = "\x1b[38;5;63m";
const _SD_EFF_ITALICS = "\x1b[3m";
const _SD_EFF_NO_ITALICS = "\x1b[0m";
const _SD_EFF_ENBOLDEN = "\x1b[1m";
const _SD_EFF_NO_ENBOLDEN = "\x1b[22m";

fn _sd_print(msg: log_message) void {
    var desc: ?[]const u8 = "";

    if (msg.description) |d| {
        for (d) |line| {
            desc = std.mem.concat(SD_CONFIG.alloc.?, u8, &[4][]const u8{ desc.?, "\n", "  ", line }) catch "";
        }
    } else {
        desc = null;
    }

    if (msg.source) |s| {
        std.io.getStdOut().writer().print("{s}{s}{s}{s}{s} {s}\n  --> {s}{s}{s} {s}{s}{s} {}:{}{s}\n", .{
            _SD_EFF_ENBOLDEN,
            msg.level.colour(),
            msg.level.to_string(),
            _SD_COL_WHITE,
            _SD_EFF_NO_ENBOLDEN,
            msg.message,
            _SD_EFF_ITALICS,
            s.file,
            _SD_EFF_NO_ITALICS,
            _SD_EFF_ENBOLDEN,
            s.fn_name,
            _SD_EFF_NO_ENBOLDEN,
            s.line,
            s.column,
            desc orelse "",
        }) catch |e| {
            std.debug.print("[[stardust]] has encountered a stdout err, {any}", .{e});
        };
        return;
    }

    std.io.getStdOut().writer().print("{s}{s}{s}{s}{s} {s}{s}\n", .{
        _SD_EFF_ENBOLDEN,
        msg.level.colour(),
        msg.level.to_string(),
        _SD_COL_WHITE,
        _SD_EFF_NO_ENBOLDEN,
        msg.message,
        desc orelse "",
    }) catch |e| {
        std.debug.print("[[stardust]] has encountered a stdout err, {any}", .{e});
    };
}

inline fn isZigInt(comptime T: type) bool {
    return comptime blk: {
        const info = @typeInfo(T);
        if (info == .Int or info == .Float) {
            break :blk true;
        }
        break :blk false;
    };
}

inline fn isZigString(comptime T: type) bool {
    return comptime blk: {
        // Only pointer types can be strings, no optionals
        const info = @typeInfo(T);
        if (info != .Pointer) break :blk false;

        const ptr = &info.Pointer;
        if (ptr.is_volatile or ptr.is_allowzero) break :blk false;

        if (ptr.size == .Slice) {
            break :blk ptr.child == u8;
        }

        if (ptr.size == .One) {
            const child = @typeInfo(ptr.child);
            if (child == .Array) {
                const arr = &child.Array;
                break :blk arr.child == u8;
            }
        }

        break :blk false;
    };
}
