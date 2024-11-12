<div align="center">

# Stardust 🌠

Beautiful Zig Logging Library

</div>

## Install

To use **Stardust**, run the following command to add it to your `build.zig.zon`

```sh
zig fetch --save git+https://github.com/juleswhi/stardust.git#main
```

Then add these lines to your `build.zig`

```zig
const stardust = b.dependency("stardust", .{
    .target = target,
    .optimize = optimize,
});

exe.root_module.addImport("sd", stardust.module("stardust"));
```

## Usage

Include **Stardust** in your project like this:

```zig
const sd = @import("sd");
```

Initiate the logging system

```zig
try sd.sd_setup(some_alloc, default_log_level);
```

To log some data, do the following:

- Strings will be output a concatonated line
- Strings beginning with a `&` will be a 'description'
- To add trace details include `@src()`
- Finally, choose the log level with a one of the following:
    - .info
    - .debug
    - .err
    - .fatal

```zig
sd.log(.{ "This is a debug", "&example description", "&another description", @src(), .debug });
```

```sh
DEB This is a debug
  --> src/main.zig main 10:88
  |> example description
  |> another description
```

If you want a simple log, you only need some strings

```zig
sd.log(.{ "Making Tea.." });
```

This will use the global log level

```sh
INF Making Tea..
```