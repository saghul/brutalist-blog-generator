---
date: "2025-03-21T00:00:00Z"
---

# Hello world!

If you are reading this it means I have published **BBG: the Brutalist Blog Generator.**
This project is a simple static site generator that I built using Swift so I can finally learn the
language. I have been wanting to learn Swift for a while now and I thought this would be a fun way to do it.

While I have written [some Swift code before], I have never quite gotten deep enough to feel comfortable with it.
I kept track of Swift over the years and when [Swift 6 was announced], including full static binaries support for Linux,
I knew I would eventually give it a try.

## Why a static site generator?

While I have never used one myself, it's a well understood concept and there are many mature implementations out
there such as Hugo or Pelican which I could use as a refrerence.

I started writing down ideas and it all started to make sense. I remembered the one and only [Motherfucking website].
There is also [a better one]. Oh and there is [the best one]. Ok, I won't lie: I can't write CSS to save my life, so
the "brutalist" style was a cop out.

## Getting started

Since I knew what I was building, but I wanted to master the tool I thought I'd give AI a try. The idea was simple,
break it all down in steps so I could iterate over them with the help of the AI. I didn't want it to write the whole
thing, but rather to help me iterate.

You can actually see how it all started by checking out the [commit history], I didn't skip anything :-)

## Small steps

Here was my rough idea for the steps I would take:

- Create the Swift project using the Swift Package Manager
- Use the `--tool` option so I'd get the basic structure for a CLI app
- Start by implementing a dummy `build` operation that just parsed a markdown file
- A quick search revealed that [swift-markdown] was a good candidate for the job since it also had the ability to [render the markdown to HTML]
- Look into parsing metadata located at the top of the markdown files (I learned this is called "front matter")
- YAML seemed like the popular choice so I went with that, [Yams] was the library I picked
- ...

## The templating engine

Choosing the templating engine was a bit harder. I wanted something akin to [Jinja], which I'm familiar with.
First I found a [Swift implementation of Jinja] but it barely had any docs. Another option was [Leaf] but being
somewhat tied to the Vapor app framework didn't quite convince me. I ended up going with [Stencil] which has great
docs, supports everything I need, but it seems to be not very actively maintained. I truested my gut.

## Publishing

I wanted to publish the project as soon as possible, so I could publish its progress in this very blog, built with it.
Obviously. Given it's a blog, I wanted to add RSS support first... So I did, and here we are.

## Onward!

There is _a lot_ more to do such as some adding the ability to create pages which are not posts, a builtin dev server,
and more. You can check the progress on [GitHub]. Stay tuned!

[some Swift code before]: https://github.com/jitsi/jitsi-meet/pull/15741
[Swift 6 was announced]: https://www.swift.org/blog/announcing-swift-6/
[Motherfucking website]: https://motherfuckingwebsite.com/
[a better one]: http://bettermotherfuckingwebsite.com/
[the best one]: https://thebestmotherfucking.website/
[commit history]: https://github.com/saghul/brutalist-blog-generator/commits/master/
[swift-markdown]: https://github.com/swiftlang/swift-markdown
[render the markdown to HTML]: https://github.com/swiftlang/swift-markdown/pull/106
[Yams]: https://github.com/jpsim/Yams
[Jinja]: https://jinja.palletsprojects.com/
[Swift implementation of Jinja]: https://github.com/johnmai-dev/Jinja
[Leaf]: https://docs.vapor.codes/leaf/getting-started/
[Stencil]: https://stencil.fuller.li/en/latest/
[GitHub]: https://github.com/saghul/brutalist-blog-generator
