const std = @import("std");
const ctime = @cImport({
    @cInclude("time.h");
});

var ALLOCATOR: ?std.mem.Allocator = null;
var LEVEL: LogLevel = .debug;

const _SD_COL_LIGHT_PINK = "\x1b[38;5;13m";
const _SD_COL_WHITE = "\x1b[38;5;255m";
const _SD_COL_GOLD = "\x1b[33m";
const _SD_COL_BLUE = "\x1b[38;5;63m";
const _SD_EFF_ITALICS = "\x1b[3m";
const _SD_EFF_NO_ITALICS = "\x1b[0m";
const _SD_EFF_ENBOLDEN = "\x1b[1m";
const _SD_EFF_NO_ENBOLDEN = "\x1b[22m";

pub const LogLevel = enum {
    debug,
    info,
    err,
    fatal,

    pub fn toString(self: *const LogLevel) []const u8 {
        return switch (self.*) {
            .info => "INF",
            .debug => "DEB",
            .err => "ERR",
            .fatal => "FAT",
        };
    }

    pub fn colour(self: *const LogLevel) []const u8 {
        return switch (self.*) {
            .info => "\x1b[38;5;2m",
            .debug => "\x1b[38;5;12m",
            .err => "\x1b[38;5;3m",
            .fatal => "\x1b[38;5;1m",
        };
    }
};

pub fn setup(alloc: std.mem.Allocator, level: LogLevel) void {
    ALLOCATOR = alloc;
    LEVEL = level;
}

pub fn log(
    comptime level: LogLevel,
    comptime fmt: []const u8,
    args: anytype,
) void {
    const stdout = std.io.getStdOut().writer();
    const stderr = std.io.getStdErr().writer();

    var now: ctime.time_t = undefined;
    _ = ctime.time(&now);
    const timeinfo = ctime.localtime(&now);

    const hours = timeinfo.*.tm_hour;
    const minutes = timeinfo.*.tm_min;

    stdout.print("{}:{d:0>2} {s}{s}{s}{s}{s} ", .{
        @as(u8, @intCast(hours)),
        @as(u8, @intCast(minutes)),
        _SD_EFF_ENBOLDEN,
        level.colour(),
        level.toString(),
        _SD_COL_WHITE,
        _SD_EFF_NO_ENBOLDEN,
    }) catch |e| {
        stderr.print("Stardust Error: {}\n", .{e}) catch return;
    };

    stdout.print(fmt, args) catch return;
    stdout.writeAll("\n") catch {};
}

pub fn debug(comptime fmt: []const u8, args: anytype) void {
    log(.debug, fmt, args);
}

pub fn info(comptime fmt: []const u8, args: anytype) void {
    log(.info, fmt, args);
}

pub fn warn(comptime fmt: []const u8, args: anytype) void {
    log(.warn, fmt, args);
}

pub fn err(comptime fmt: []const u8, args: anytype) void {
    log(.err, fmt, args);
}

pub fn fatal(comptime fmt: []const u8, args: anytype) void {
    log(.fatal, fmt, args);
}

fn cIntToUsize(x: anytype) i32 {
    return @intCast(x);
}
