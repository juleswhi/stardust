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

To log some data, do the following:

```zig
stardust.sdlog(@src(), .{"Hello, World!", 69, .debug});
// Hello, World! 69
```
