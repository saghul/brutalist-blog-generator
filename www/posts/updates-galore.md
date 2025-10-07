---
date: "2025-10-07T14:49:29Z"
slug: "updates-galore"
---

# Updates galore!

It's been a while since the last project update. I've spent a bit of time working on a few new things, and I'm
really happy with the result, so allow me to share!

## More semantic CSS

One of my goals with the project was to make the CSS as minimal as possible while still looking great.
While the first version was quite _spartan_, which is what I intended, I knew there was room for improvement.

I somewhat randomly ran into [PicoCSS] and I was tempted. I briefly considered switching to it, it's so small and nice!
The problem is, it's over 60 times the size of the CSS I worte, and it has a lot of unnecessary stuff for this project.
I can, however, learn from it! A cool thing I learned is the existence of the [hgroup] element. It can be used like so:

```
<hgroup>
  <h1>Heading</h1>
  <p>Paragraph</p>
</hgroup>
```

It provides the semantics of a "subtitle" to the heading, but most importantly it allows for more semantic HTML and thus
for a cleaner CSS without the need for a specific class or ID for styling purposes. Here is all the CSS we now need to make it
look the same as before:

```css
hgroup > :not(:first-child):last-child {
    font-size: 1rem;
    color: var(--bbg-secondary-text);
}
```

Only now, there is no "sticky" class needed! Yes, this might be obvious to many, but I'm not that great at CSS :-)

## Updated dependencies and switching to Mustache

Dependencies have moved forward since my last post in April, so it was a good time for an update. There was one notable exception
though: [Stencil], the templating library.

While powerful, it's currently unmaintained, and while there is a [community fork], it just got started.

Since the web server I'm using is [Hummingbird] I thought I'd check what they use or recommend, which is [Mustache]. I had discarded it before, because it seemed so simple, but it turns out, it provides everything this project needs! It's very minimalistic, which matches the vibe of the project.

## New navbar

One of the things I didn't like was the "navbar". It didn't seem very polished, and the page links were not available on every post or page. With some CSS tweaks it now looks much better (in my opinion of course!) and it's more functional, as it's available on every page.

## Theming and dark mode

This was something I wanted to do from the beginning, but hadn't gotten to yet. All theming related options are now configurable in `config.yml` like so:

```yaml
# Theme configuration
theme:
  light:
    background: "#FAFAFA"
    text: "#24292f"
    link: "#0969da"
    codeBg: "#f6f8fa"
    border: "#d0d7de"
    codeBorderLeft: "#2b2b2b"
    secondaryText: "#57606a"
  dark:
    background: "#0d1117"
    text: "#e6edf3"
    link: "#58a6ff"
    codeBg: "#161b22"
    border: "#30363d"
    codeBorderLeft: "#6e7681"
    secondaryText: "#8b949e"
# Default theme: "light", "dark", or "auto" (respects system preference)
defaultTheme: "auto"
```

So, _some_ customization is possible, while remaining very minimalistic. I may continue tweaking the colors until I find the _right_ tones, but you get the idea.

Dark / light mode, was obviously necessary. This feature requires a very small amount of JavaScript, but hey I'll switch to something else if / when widely available.

## "new" CLI command

This was just a little quality of life improvement I wanted to have, a simple way to create new posts. It's a very small command, but it's a nice addition to the CLI. Here is how it works:

```bash
$ bbg new
Enter post title: Test post
Enter post date (YYYY-MM-DD) [2025-10-07]:
Enter slug [test-post]:
Created: www/posts/test-post.md
Open in editor? [Y/n]: n
```

---

So that's it, see you on the next post!

[PicoCSS]: https://picocss.com/
[hgroup]: https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/hgroup
[community fork]: https://github.com/swiftstencil/swiftpm-stencil
[Hummingbird]: https://github.com/hummingbird-project/hummingbird
[Mustache]: https://github.com/hummingbird-project/swift-mustache
