# micro-misc

Some miscellaneous utils that I use in micro editor, but might not be generic enough for a separate plugin.

To use this, you need to add the `bin` folder within the plugin to your `PATH`.

## llm-review

Proofread a Markdown document with an LLM (typos, spelling, grammar,
paraphrasing). Works standalone — see `llm-review --help` — and plugs into
micro:

```sh
llm-review draft.md            # anywhere: review a file
cat draft.md | llm-review      # or pipe it
```

Setup (once):

```sh
llm-review --init   # writes ~/.llm-review.json
# edit it: set base_url, api_key, model
```

Example `~/.llm-review.json` (GLM via Zhipu's Anthropic-compatible endpoint):

```json
{
  "base_url": "https://open.bigmodel.cn/api/anthropic",
  "api_key":  "your-api-key",
  "model":    "glm-5.3"
}
```

Any Anthropic-compatible Messages API works (`base_url` is the base, and
`/v1/messages` is appended unless it already ends in `/messages`). You can also
set `LLM_REVIEW_BASE_URL`, `LLM_REVIEW_API_KEY`, and `LLM_REVIEW_MODEL` in the
environment instead of the file. Use whatever exact model id your provider
exposes for GLM (e.g. `glm-5.3`).

Findings are grouped into three sections (the model is asked to tag every
finding; the script prints a header when the category changes):

```
── Typos & grammar ──
<path>:2:9:11: "teh" — suggestion: "the"

── Paraphrasing ──
<path>:8:1:17: "We did a thing" — suggestion: "We performed an action"

── Other suggestions ──
<path>:14: inconsistent terminology — suggestion: ...
```

The column range (`line:col:cole`, 1-based inclusive) is computed locally by
locating the quoted text on the stated line (LLMs cannot count columns), so
it is only included when the text is actually found — the line jump always
works. With the acme plugin's right-click, `file:line:col` places the cursor
and `file:line:col:cole` selects the exact text.

Usage inside micro (with the micro-acme plugin):

- `e llm-review` — reviews the file at the buffer's path (`$samfile`), just
  like `e rg`. Blocking: results appear in a right pane when done.
- `ee llm-review` — streaming variant (generic `ee <binary>` command from
  the micro-acme plugin). Opens the right pane immediately and findings
  arrive live as the model generates them. While the model is quiet, the
  script prints `[llm-review] still waiting (Ns)...` placeholders. The
  heartbeat interval is tunable via `LLM_REVIEW_HEARTBEAT` (seconds,
  default 15, `0` disables).

Both use the SSE streaming API when the endpoint supports it, and fall back
to a regular request otherwise.

Right-click navigation is provided by the acme plugin's `MouseRight` binding
(`lua:acme.search`); click on the `file:line:` (or `file:line:col:`) part of
a finding to jump there. `acme.search` understands an optional column
component.
