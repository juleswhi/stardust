<div align="center">

# Stardust 🌠

Beautiful Zig Logging Library

</div>

## Install

To add **Stardust** to your `build.zig.zon`

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

```zig
stardust.log(.{ "This is a debug", "!example description", "!another description", .debug });
```

```sh
DEB This is a debug
  --> src/main.zig main 10:88
  |> example description
  |> another description
```
