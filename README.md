<div align="center">

# Stardust 🌠

Beautiful Zig Logging Library

</div>

## Install

To add **Stardust** to your `build.zig.zon`

```zig
zig fetch --save git+https://github.com/juleswhi/stardust.git#main
```

Then add these lines to your `build.zig`

```zig
const stardust = b.dependency("stardust", .{
    .target = target,
    .optimize = optimize,
});

exe.root_module.addImport("stardust", stardust.module("stardust"));
```

## Usage

Include **Stardust** in your project like this:

```zig
const sd = @import("stardust");
```

Initiate the logging system

```zig
try stardust.sd_init_log(null, null);
```

__It's recommended to import the log function itself__

```zig
const log = @import("stardust").sdlog;
```

To log some data, do the following:

This will log all values, separated by a space.

`.debug` signifies the level, this can one of, `info`, `debug`, `err`, `fatal`

```zig
stardust.sdlog(@src(), .{"Hello, World!", 69, .debug});
```
