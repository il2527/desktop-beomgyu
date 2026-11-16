# Desktop Beomgyu

## My project and why I made it

I am developing Desktop Beomgyu, an unofficial, photo-based companion inspired by Beomgyu from TXT and Desktop Goose. I wanted a tiny character who could keep someone company, wander, run, celebrate, and offer a comforting hug. My intention is to make an ordinary computer interaction feel more personal and playful.

I began with the character idea and reference photos rather than code. As the project developed, I needed a visible interface for my coursework. I wanted visitors to understand what they could try and immediately see the result. This version focuses on a website preview and on the module theme of designing for feeling through combined inputs.

## The four files I am sharing

I organized this version into exactly four files:

| File | What I use it for |
| --- | --- |
| `index.html` | My page structure, character preview, labeled form controls, Trash-helper explanation, and download link. |
| `styles.css` | My colors, typography, spacing, responsive layout, selected-control states, focus outlines, and motion preferences. |
| `script.js` | My action changes, continuous wandering, opposite arm-leg timing, photo-textured arm joints, speed input, comfort response, and original hug-frame playback. I combined the two original JavaScript modules here. |
| `README.md` | My intentions, interaction logic, UI choices, AI collaboration, revisions, testing, and remaining questions. |

To avoid a separate asset folder, I embedded the PNG images as data URLs inside the HTML, CSS, and JavaScript. That makes these files larger and puts long encoded image strings in the source. These strings are image data, not additional code or an API key. The original photo pixels are still used by the animation. I have not redrawn the face for this package.

## How I open this version

I keep all four files together in one folder and open `index.html` in a modern browser. I do not need to install packages, run a build, or provide an API key. The embedded images and main preview can work without the internet. Links to the published design-process page, GitHub source, and Mac app download require internet access.

My published website: https://il2527.github.io/desktop-beomgyu/

My design process: https://github.com/il2527/desktop-beomgyu#how-i-used-ai

My original project repository: https://github.com/il2527/desktop-beomgyu

## What I want the interaction to feel like

I want visitors to choose between energetic company and a quieter presence. I am exploring feeling through pace, gesture, timing, and reassuring words. I do not want emotion to be represented only by a background color.

I can choose Run at a higher pace for an energetic response, then turn on Quiet comfort to soften that same choice. I can also choose Hug and use Quiet comfort to slow the gesture. I am still experimenting with how strong these differences should be before they become distracting.

## The inputs I combine

I use action radio buttons for Stay, Walk, Run, Celebrate, and Hug because only one action should be selected at a time. Stay keeps the character still. Walk and Run wander continuously within the preview. Celebrate uses the chosen celebration photo. Hug plays the original transparent animation and displays the comforting message.

I added a Movement speed slider from 50% to 180%, with 100% as the default. I chose a slider because I wanted gradual adjustment rather than only a fast/slow switch. The visible percentage updates while I move it. I can also focus it with the keyboard and use the arrow keys, Home, or End. It affects only Walk and Run.

I use Quiet comfort as a checkbox because it can combine with any action. For Walk and Run, it reduces my selected pace further. For Hug, it lengthens the frame timing. For Celebrate, it reduces the bounce. Stay remains still.

I use Tiny, Small, and Large radio buttons for character size. I added Reset to Stay so visitors have an obvious way to return to the starting state: Stay, Small, Quiet comfort off, and 100% pace.

## My event and state logic

I use `change` listeners for the action, comfort, and size choices, an `input` listener for the slider, and a `reset` listener for the reset button. I use `requestAnimationFrame` to advance movement and keep limb motion connected to distance traveled. I use timed original frames for Hug.

```text
Action change -> select one behavior and update the response text
Slider input -> update the percentage and movement speed
Comfort change -> apply a calmer response to the selected action
Reset -> restore the initial action, comfort, size, and pace

If the action is Walk or Run:
    speed = action base speed * (slider percentage / 100)
    if Quiet comfort is on:
        speed = speed * 0.55

If reduced motion is preferred:
    do not wander
```

I use base speeds of 48 pixels per second for Walk and 110 for Run. At Run + 150%, the target pace is 165 pixels per second. With Quiet comfort added, it becomes 90.75. Acceleration and edge steering mean the measured speed may vary briefly. I keep footsteps tied to movement distance, so a slower pace also produces a slower stride.

I use continuous random steering rather than a fixed repeated route. I steer inward near the preview edges. I keep the browser character inside this preview; this page does not let him travel across the actual operating-system desktop.

## My layout and aesthetic decisions

I chose soft green, warm white cards, and a large serif title to make the page feel calm and personal. I use a system sans-serif font for the controls to keep them readable. I place the character preview beside the settings on a wide screen so visitors can connect a choice with its response.

After feedback that the interface was difficult to read or manipulate, I requested larger labels, numbered groups, clearer instructions, and a response card. The response card explains the action and comfort state; the slider separately shows the chosen percentage.

Adding the slider made the controls column taller. I noticed a large empty area below the preview and asked for the layout to be adjusted. I kept tighter desktop spacing and a sticky preview that remains visible beside the lower controls while scrolling. I use a stacked layout at tablet and mobile widths so the columns do not become too narrow.

I learned that HTML structures my content while CSS controls layout and style. In this project, semantic elements such as `main`, `section`, `aside`, `fieldset`, `legend`, and `label` organize the interface. CSS Grid places the main regions, and Flexbox aligns smaller control groups. Focus outlines make keyboard position visible.

## How I used AI

I used ChatGPT/Codex as a creative and technical partner. I supplied the initial concept, reference photos, the hug GIF, and detailed feedback. AI helped generate and revise HTML, CSS, JavaScript, image preparation, and documentation. I did not write all of the implementation myself, and I did not accept every result.

My contribution was to decide what I wanted the experience to communicate, inspect the visible results, and describe what was wrong when the output did not match my intention. The most useful exchanges were often corrections rather than the first generated answer.

### How I developed the character

I asked for a real-photo companion rather than an illustrated character. I supplied images and selected a specific celebration pose. An early walk looked like a crab because front-facing legs moved sideways. I rejected it and asked for the lower body to face the travel direction.

I also requested smaller character sizes, faster movement, random directions, and running during Trash delivery in the native prototype. These requests came from the experience I wanted, not from automatically accepting a generated feature list.

### Why I insisted on the original face

I rejected a generated hug because the face did not look like Beomgyu. I repeatedly asked for the face to remain unchanged, the background to be removed, and the hug to remain animated. I kept the approach using all 20 original GIF frames with background masks rather than a newly generated face. This showed me that a polished image is not necessarily the correct image for my intention.

### What I revised in walking and running

I noticed that the original running images had similar leg positions, so switching between them looked like sliding. I asked for both legs and arms to alternate. I also pointed out that the character stayed in the same area for a while and requested continuous wandering.

The first articulated attempts created disconnected shoulders and elbows. I supplied screenshots and challenged the attempted fixes because the problem was still visible. AI then rebuilt the arm connections with photo-textured triangular strips that share joint edges. The shoulder attachment stays fixed while the upper arm and forearm move.

I had to clarify that arm motion and arm layering are different problems. I did not want an arm to jump from behind the torso to in front of it during the stride. For running, I explicitly requested that the existing arm layers be reversed, and I approved that change. I then separately requested opposite arm-leg timing for walking and running: one leg advances with the opposite arm. I kept those timing changes and the approved fixed layer order.

These revisions taught me that code can run correctly while the motion still looks unnatural. I needed to describe the specific joint, depth, or timing issue rather than only saying that the animation looked wrong.

### What I added for this module

I asked for an additional input element from the assignment list. AI implemented the Movement speed slider, and I kept it because it connects directly to the existing character behavior. It gives me a clear multi-input system: action + pace + comfort.

I also asked for the blank layout area to be reduced and for the documentation to reflect the latest controls. I requested first-person explanations so the reflection describes my intentions and decisions, while still acknowledging AI’s implementation work.

## What was checked and what I still need to explore

With AI assistance, I checked the speed slider at 50% and 180%, its combination with Quiet comfort, and Reset returning it to 100%. The controls were also checked with keyboard input. Several stride phases were inspected for joint connections and arm depth, and the desktop layout was checked while scrolling.

These checks do not mean every frame or device is perfect. I am still refining a photo-based animation, and some deformation can remain visible. I want feedback on whether the combined inputs feel meaningfully different and whether first-time visitors understand what to try.

A useful comparison is Run at 150% with Quiet comfort off, then on. I would ask classmates whether the difference feels energetic versus calming, or simply faster versus slower.

## Website preview and the Mac app

I keep these roles separate. This four-file version is the website preview. It never reads, moves, or deletes visitors’ files. The Trash-helper section is an explanatory storyboard.

My separate Mac prototype can appear on the actual desktop and handle confirmed Trash actions with Undo. Its download includes the app, character assets, and a quick-start guide in one ZIP. It requires Apple silicon and macOS 26 or later and is not notarized by Apple. The newest website slider, combined-input logic, and animation revisions have not yet been added to that native build.

I have considered connecting the companion with ChatGPT, but that integration is not implemented. This website does not make AI API requests or require an account.

## Media and attribution

I made this as an unofficial fan project. I acknowledge that the reference photos and GIF belong to their respective owners. Some standing, walking, running, and celebration assets include AI-assisted photo edits. The approved hug uses the original GIF frames with background masks. The arm animation transforms existing photo pixels and does not regenerate the face during playback.

My original hug reference: https://media1.tenor.com/m/5-2hUKXUZUwAAAAd/beomgyu-hug-beomgyu-sweet.gif

## Sharing my process

I am sharing a work in progress, including the mistakes and revisions. A conversation share link documents my exchanges with AI; it does not replace opening the HTML file or trying the live website. This package is the clean four-file version for reviewing the code and my detailed reflection.

## My public repository and archive

I organized the main branch to show only `index.html`, `styles.css`, `script.js`, and `README.md`. I embedded the photo assets in the source so this website does not need extra image files. I preserved my earlier documents, separate assets, and native Mac app on the `codex/archive-before-four-file` branch. This keeps the current code review focused without losing my earlier work.

My archived Mac app download: https://github.com/il2527/desktop-beomgyu/raw/refs/heads/codex/archive-before-four-file/Desktop-Beomgyu.zip

My earlier files: https://github.com/il2527/desktop-beomgyu/tree/codex/archive-before-four-file
