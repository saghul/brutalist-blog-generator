---
date: "2025-04-26T00:00:00Z"
---

# Progress: file watching and local server

We've got progress! The first thing I wanted to tackle after making `bbg` public was to add file watching and local server functionality. This allowed me to see changes in real-time and test my code locally without having to constantly
run `bbg build`.

## File watching

First I tried to see if there was something simple which would work out of the box, but I'm either bad at searching
or didn't quite find what I was looking for. I did find [FileMonitor] but for some reason it would enter some infinite
loop when I ran it. I was probably Using It Wrong (TM). Since one of the goals of this project was to learn Swift, I thought I'd implement it myself (with some AI assistance).

The plan is:

- Monitor the directory where the posts are located to detect if any new files are added / removed
- For each file there, monitor if they change
- If either of these happens, rebuild the site

We are going to use [DispatchSource]() which works on both macOS and Linux, though this is not obvious from the
documentation, which I found confusing.

On macOS we can use [makeFileSystemObjectSource] directly to monitor the directory and each file, but on Linux
we'll need to use the `Glibc` or `Musl` libraries to use the `inotify` API and then use the [makeReadSource] and
manually read the inotify event.

In the end it turned out ok and thus now you can do `bbg build --watch` which will build the site and rebuild it when
any changes occur.

## Local server

The next obvious step is to have a local server which will serve the site. This will allow us to see the site in a browser quickly while writing a post, for example.

The candidates for such a task were [Vapor] and [Hummingbird]. I had already looked at the former a bit, since it has
a templating library I was interested in and ended up not using, but it felt very heavy for the little task I needed,
so I went with Hummingbird. It also has a great name!

Hummingbird was a breeze to integrate, this is all it took to serve the static files off the build directory:

```swift
let router = Router()
router.add(middleware: FileMiddleware(builder.config.outputDir, searchForIndexHtml: true))

let app = Application(
    router: router,
    configuration: .init(address: .hostname(hostname, port: port))
)

try await app.runService()
```

You can see how the web server and file watching interact in the [ServeCommand.swift] file. With that we now have
`bbg serve` which does exactly what you expect! 🎉


[FileMonitor]: https://github.com/aus-der-Technik/FileMonitor
[DispatchSource]: https://developer.apple.com/documentation/dispatch/dispatchsource
[makeFileSystemObjectSource]: https://developer.apple.com/documentation/dispatch/dispatchsource/makefilesystemobjectsource(filedescriptor:eventmask:queue:)
[makeReadSource]: https://developer.apple.com/documentation/dispatch/dispatchsource/makereadsource(filedescriptor:queue:)
[Vapor]: https://vapor.codes
[Hummingbird]: https://hummingbird.codes
[ServeCommand.swift]: https://github.com/saghul/brutalist-blog-generator/blob/master/Sources/Commands/ServeCommand.swift
