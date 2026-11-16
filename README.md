# Desktop Beomgyu

A fan-made photo-based desktop companion and an HTML/CSS interface study.

- **Website:** https://il2527.github.io/desktop-beomgyu/
- **Complete Mac download:** https://github.com/il2527/desktop-beomgyu/raw/refs/heads/main/Desktop-Beomgyu.zip
- **Existing public preview:** https://little-companion-studio.cheerylarch3.chatgpt.site/

## Assignment document

- [Google Doc submission](https://docs.google.com/document/d/13zM873IIdiwIZpgM0oOi5QJCpAN7KU4IgHLpf5234_Q/edit)
- [Readable document copy](Assignment.html)
- [Plain text document copy](Assignment.txt)

## Use the desktop character

Download the complete ZIP using the link above, unzip it, and open **Beomgyu Desktop.app**. Right-click him for walking, running, celebration, **Need a hug?**, size, focus, and confirmed Trash actions with Undo. All images are bundled inside the app; no separate asset installation is needed.

The downloadable prototype requires an Apple silicon Mac and macOS 26 or later. It is ad-hoc signed and not notarized.

## Website structure

- `index.html`: semantic interface, preview, controls, and single download button.
- `styles.css`: CSS Grid, Flexbox, responsive layouts, colors, typography, and motion preferences.
- `companion.js`: movement, step timing, mode changes, and animated hug playback.
- `process.html`: design decisions, AI collaboration, and iteration history.
- PNG files and `frames.json`: photo assets and original hug-frame timing.

The browser preview does not delete or move visitors' files. The native Mac app handles confirmed Trash operations.

## Build the Mac app

Requires Xcode Command Line Tools. Run `zsh build.sh` from this directory. The output is `build/Beomgyu Desktop.app`. `main.swift` contains the AppKit companion. All resources live beside the source so the website and desktop build can share them.

## AI process and attribution

The concept, reference photos, and direction came from the student. Codex assisted with implementation and media preparation. Student feedback corrected sideways walking, changed movement and size, rejected a generated hug that altered the face, moved Hug into the main preview, and simplified downloads.

The approved hug uses 20 original GIF frames with background masks; the face was not regenerated. Other character assets include AI-assisted photo edits. Reference media belong to their respective owners. This is an unofficial fan project.

Original hug reference: https://media1.tenor.com/m/5-2hUKXUZUwAAAAd/beomgyu-hug-beomgyu-sweet.gif

- [Download the assignment document](Assignment.docx)

## Opening on macOS

This prototype is ad-hoc signed and has not been notarized by Apple. If macOS blocks it, only if you trust this project copy: click Done, open System Settings → Privacy & Security, find the blocked Beomgyu Desktop message, click Open Anyway, and confirm. Keep macOS security protections enabled. Apple instructions: https://support.apple.com/en-us/102445

## Designing for feeling: in-progress interaction

Choose an action using the radio buttons, then combine it with the independent Quiet comfort checkbox. Walk and Run slow down; Hug uses longer original-frame timings; Celebrate has a smaller bounce. The response card describes the combined state, and Reset returns to Stay with Quiet comfort off and the default size. These new combined inputs are in the website preview; the Mac download retains its existing controls.

## Walking and running motion

The website now uses SVG clips of the existing photographs with separate arm and leg pivots. Opposite arms and legs alternate with distance traveled, while the original head pixels remain unchanged. Continuous random steering replaces target arrival pauses and fixed loops. Stay, Hug, Celebrate, and reduced-motion preferences still stop wandering. This update applies to the web preview; the downloadable native build is unchanged.

The shoulder repair uses photo-textured triangular strips with shared vertices and a fixed attachment edge. Upper arms and forearms use separate joint transforms; torso clips exclude moving sleeves. The four quarter-stride poses were inspected for both gaits before publication.
