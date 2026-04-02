# NLM for Learning — API Alignment Reference

> Complete reference of NotebookLM MCP tool signatures used by this skill.
> Maps to `notebooklm-mcp` server tools. Updated for NLM MCP v0.6+.

---

## 1. Notebook Lifecycle

### `notebook_create(title)`
Create a new NotebookLM notebook.

| Param | Type | Required | Default | Notes |
|-------|------|----------|---------|-------|
| `title` | string | No | `""` | Display title |

**Returns**: `{ notebook_id, url, title }`

### `notebook_get(notebook_id)`
Get full notebook details including sources.

| Param | Type | Required |
|-------|------|----------|
| `notebook_id` | string | Yes |

**Returns**: `{ notebook_id, title, sources[], ... }`

### `notebook_rename(notebook_id, new_title)`
Rename an existing notebook.

| Param | Type | Required |
|-------|------|----------|
| `notebook_id` | string | Yes |
| `new_title` | string | Yes |

### `notebook_list(max_results?)`
List all notebooks with metadata.

| Param | Type | Required | Default |
|-------|------|----------|---------|
| `max_results` | integer | No | `100` |

---

## 2. Research

### `research_start(query, notebook_id?, source, mode)`
Launch web or Drive research to discover new sources.

| Param | Type | Required | Default | Notes |
|-------|------|----------|---------|-------|
| `query` | string | Yes | — | Search query |
| `notebook_id` | string | No | — | Existing notebook (creates new if omitted) |
| `source` | string | No | `"web"` | `"web"` or `"drive"` |
| `mode` | string | No | `"fast"` | `"fast"` (~30s, ~10 sources) or `"deep"` (~5min, ~40 sources) |
| `title` | string | No | — | Title for auto-created notebook |

**Returns**: `{ task_id, notebook_id }`

### `research_status(notebook_id, task_id?, poll_interval, max_wait, compact, query?)`
Poll research progress. Can block or return immediately.

| Param | Type | Required | Default | Notes |
|-------|------|----------|---------|-------|
| `notebook_id` | string | Yes | — | |
| `task_id` | string | No | — | Specific task to poll |
| `poll_interval` | integer | No | `30` | Seconds between polls (ignored when max_wait=0) |
| `max_wait` | integer | No | `300` | **Use 0 for non-blocking** in round-robin loops |
| `compact` | boolean | No | `true` | Reduce token usage |
| `query` | string | No | — | Fallback matching when task_id changes (deep research) |

**Returns**: `{ status, sources_found, report?, task_id }`

### `research_import(notebook_id, task_id, source_indices?, timeout)`
Import discovered sources into the notebook.

| Param | Type | Required | Default | Notes |
|-------|------|----------|---------|-------|
| `notebook_id` | string | Yes | — | |
| `task_id` | string | Yes | — | From research_status response |
| `source_indices` | integer[] | No | all | Specific sources to import |
| `timeout` | number | No | `300` | Seconds to wait for import |

**Returns**: `{ imported_count }`

---

## 3. Sources

### `source_add(notebook_id, source_type, ...)`
Add a source to a notebook. Supports multiple source types.

| Param | Type | Required | Default | Notes |
|-------|------|----------|---------|-------|
| `notebook_id` | string | Yes | — | |
| `source_type` | string | Yes | — | `"url"`, `"text"`, `"drive"`, `"file"` |
| `url` | string | No | — | For `source_type="url"` (single URL) |
| `urls` | string[] | No | — | For `source_type="url"` (bulk add) |
| `text` | string | No | — | For `source_type="text"` |
| `title` | string | No | — | Display title (text sources) |
| `file_path` | string | No | — | For `source_type="file"` |
| `document_id` | string | No | — | For `source_type="drive"` |
| `doc_type` | string | No | `"doc"` | Drive: `"doc"`, `"slides"`, `"sheets"`, `"pdf"` |
| `wait` | boolean | No | `false` | Block until source is indexed |
| `wait_timeout` | number | No | `120` | Max seconds if wait=true |

**Returns**: `{ source_id }`

### `source_rename(notebook_id, source_id, new_title)`
Rename a source within a notebook.

| Param | Type | Required |
|-------|------|----------|
| `notebook_id` | string | Yes |
| `source_id` | string | Yes |
| `new_title` | string | Yes |

### `source_describe(source_id)`
Get AI-generated source summary with keyword chips.

| Param | Type | Required |
|-------|------|----------|
| `source_id` | string | Yes |

**Returns**: `{ summary, keywords[] }`

### `source_get_content(source_id)`
Get raw text content of a source (no AI processing).

| Param | Type | Required |
|-------|------|----------|
| `source_id` | string | Yes |

**Returns**: `{ content, title, source_type, char_count }`

---

## 4. Chat

### `chat_configure(notebook_id, goal, custom_prompt, response_length)`
Configure chat behavior for a notebook (tutor persona setup).

| Param | Type | Required | Default | Notes |
|-------|------|----------|---------|-------|
| `notebook_id` | string | Yes | — | |
| `goal` | string | No | `"default"` | `"default"`, `"learning_guide"`, `"custom"` |
| `custom_prompt` | string | No | — | Required when goal=`"custom"` (max 10000 chars) |
| `response_length` | string | No | `"default"` | `"default"`, `"longer"`, `"shorter"` |

---

## 5. Studio

### `studio_create(notebook_id, artifact_type, confirm, ...)`
Create any studio artifact. Type-specific params vary.

**Common params:**

| Param | Type | Required | Default | Notes |
|-------|------|----------|---------|-------|
| `notebook_id` | string | Yes | — | |
| `artifact_type` | string | Yes | — | See types below |
| `confirm` | boolean | Yes | — | **MUST be `true`** |
| `source_ids` | string[] | No | all | Subset of sources |
| `language` | string | No | `"en"` | BCP-47 code |
| `focus_prompt` | string | No | — | Custom focus text |

**Type-specific params:**

| Type | Param | Values | Default |
|------|-------|--------|---------|
| `audio` | `audio_format` | `deep_dive`, `brief`, `critique`, `debate` | `deep_dive` |
| `audio` | `audio_length` | `short`, `default`, `long` | `default` |
| `video` | `video_format` | `explainer`, `brief`, `cinematic` | `explainer` |
| `video` | `visual_style` | `auto_select`, `classic`, `whiteboard`, `kawaii`, `anime`, `watercolor`, `retro_print`, `heritage`, `paper_craft` | `auto_select` |
| `quiz` | `difficulty` | `easy`, `medium`, `hard` | `medium` |
| `quiz` | `question_count` | integer | `2` |
| `flashcards` | `difficulty` | `easy`, `medium`, `hard` | `medium` |
| `mind_map` | `title` | string | `"Mind Map"` |
| `report` | `report_format` | `Briefing Doc`, `Study Guide`, `Blog Post`, `Create Your Own` | `Briefing Doc` |
| `report` | `custom_prompt` | string | — | Required for `Create Your Own` |
| `infographic` | `orientation` | `landscape`, `portrait`, `square` | `landscape` |
| `infographic` | `detail_level` | `concise`, `standard`, `detailed` | `standard` |
| `slide_deck` | `slide_format` | `detailed_deck`, `presenter_slides` | `detailed_deck` |
| `slide_deck` | `slide_length` | `short`, `default` | `default` |
| `data_table` | `description` | string (required) | — | Description of table to generate |

### `studio_status(notebook_id)`
Check artifact generation status and get download URLs.

| Param | Type | Required |
|-------|------|----------|
| `notebook_id` | string | Yes |

**Returns**: `{ artifacts: [{ artifact_id, title, type, status, url }], summary }`

Status values: `completed`, `in_progress`, `failed`

---

## 6. Notes

### `note(notebook_id, action, ...)`
Unified note management tool.

| Param | Type | Required | Default | Notes |
|-------|------|----------|---------|-------|
| `notebook_id` | string | Yes | — | |
| `action` | string | Yes | — | `"create"`, `"list"`, `"update"`, `"delete"` |
| `note_id` | string | For update/delete | — | Note UUID |
| `content` | string | For create | — | Note body text |
| `title` | string | No | — | Note title |
| `confirm` | boolean | For delete | — | Must be `true` |

**Returns (create)**: `{ note_id }`
**Returns (list)**: `{ notes: [{ note_id, title, content }] }`

---

## 7. Tags

### `tag(action, ...)`
Manage notebook tags for smart selection.

| Param | Type | Required | Notes |
|-------|------|----------|-------|
| `action` | string | Yes | `"add"`, `"remove"`, `"list"`, `"select"` |
| `notebook_id` | string | For add/remove | |
| `tags` | string | For add/remove | Comma-separated |
| `notebook_title` | string | No | Display name (for add) |
| `query` | string | For select | Tag match query |

---

## Known Gotchas

### 1. `confirm=true` REQUIRED
All `studio_create` and delete calls (`notebook_delete`, `source_delete`, `studio_delete`) require `confirm=true`. Omitting it silently does nothing.

### 2. `max_wait=0` for non-blocking polls
Default `max_wait=300` blocks for up to 5 minutes. In round-robin loops polling multiple dimensions, **always set `max_wait=0`** to return immediately with current status.

### 3. Deep research `task_id` can CHANGE
When using `mode="deep"`, the task_id returned by `research_start` may change during execution. Always use the `task_id` from the **latest** `research_status` response, not the original. Pass `query` param as fallback matching.

### 4. 300 source per notebook limit
NotebookLM enforces a maximum of 300 sources per notebook. Plan dimension research budgets accordingly (7 dimensions x ~40 sources each = ~280 total spread across 7 notebooks, well within limit per notebook).

### 5. Studio artifacts generate asynchronously
After `studio_create`, the artifact is not immediately ready. Poll `studio_status` until `status == "completed"`. Generation times vary: audio ~2-5min, video ~5-10min, quiz/flashcards ~30s-2min.

### 6. Auth expires periodically
NotebookLM MCP auth tokens expire. If you get auth errors, run `nlm login` via bash to re-authenticate. The `save_auth_tokens` tool is a fallback if CLI auth fails.

### 7. `source_add` with `urls` array
You can add multiple URLs in a single call using the `urls` parameter (array of strings) instead of `url` (single string). More efficient for batch operations.

### 8. `source_add` with `wait=true`
Setting `wait=true` blocks until the source is fully indexed. Useful when you need to query the source immediately after adding it. Default `wait_timeout` is 120 seconds.

### 9. `notebook_query` vs `research_start`
- `notebook_query`: Ask questions about **existing** sources already in the notebook
- `research_start`: **Find new** sources via web/Drive search

Do not confuse them. Use `notebook_query` for synthesis, `research_start` for discovery.

### 10. Rate limits
Rapid successive MCP calls may hit rate limits. Space research launches with brief pauses. Round-robin polling with `max_wait=0` naturally creates spacing.
