# OpenSpace Domain Context

## Chat Domain

### Terminology

- **Conversation** — A persistent thread of messages between the user and one or more AI models. A conversation has a lifecycle: created, active, archived.
- **Message** — A single turn in a conversation. Each message has a `role` (user, assistant, system, tool) and `content` (text, thinking, tool calls, attachments).
- **Provider** — A remote AI inference service accessed via HTTP API (OpenAI, Anthropic, xAI, Gemini, etc.). Each provider speaks its own schema but exposes the same capability surface: streaming, thinking, tool calling.
- **Streaming** — Consumption of an AI response as incremental deltas via Server-Sent Events (SSE), not as a single complete response. Enables live UI updates (typing indicator, thinking bubbles).
- **Thinking** — Model-generated intermediate reasoning tokens exposed during streaming. Provider-specific: OpenAI calls it `reasoning_content`, Anthropic calls it `thinking` blocks. Not all models expose thinking.
- **Tool Use** — When the model emits structured function/tool calls that the client executes locally, then returns results back to the model. All major providers support streaming tool_call deltas.
- **Subagent** — An application-level abstraction, NOT a protocol feature. A subagent is a child conversation spawned to handle a delegated task, whose result is injected back into the parent conversation. Requires orchestration logic in the client.

### Capabilities Matrix

| Capability | Native in HTTP API | Notes |
|---|---|---|
| Streaming (SSE) | Yes | Universal across providers |
| Thinking tokens | Model-dependent | o1/o3 (OpenAI), Claude 3.7 Sonnet (Anthropic) |
| Tool calling | Yes | Format varies per provider |
| Subagents | No | Application-layer orchestration only |

### Thread Hierarchy

- **Parent Thread** — The primary conversation visible in the main chat UI. The user interacts directly with the parent thread.
- **Child Thread** — An independent conversation spawned by the parent to handle a delegated task. Runs in parallel with other children. Linked to the parent via a `Thread Link`.
- **Thread Link** — A directional relationship from parent to child. The parent stores a reference (id, name, role) to each child it spawned.
- **Turn** — One request-response cycle. A turn may span multiple streaming events (text, thinking, tool calls) before completion.
- **Streaming Event** — An incremental delta delivered via SSE (text fragment, thinking fragment, tool_call invocation, tool_call result).

### Subagent Visibility Rules

- The parent thread displays a **summary card** for each child thread (name, role, status: running/done/failed).
- The user taps the summary card to **push to a new page** showing the child's full streaming log.
- The child page is a **live mirror**: events stream in real-time while the child is active; historical events are replayed from storage if the child has finished.
- Child threads are **first-class navigable destinations**, not inline expandable sections.

### Thread Nesting Policy

| Stage | Max Depth | Behavior |
|---|---|---|
| Early stage (default) | 1 | Parent may spawn children. Children **cannot** spawn grandchildren. |
| Stage 2 (configurable) | 2 | One-level nesting with guardrails: parent → child → grandchild. |
| Stage 3 (configurable) | unlimited | Arbitrary nesting. User selects max depth per conversation. |

- **Depth counter** is stored per thread. When a child reaches `maxDepth`, any delegation request from the model is handled as a `tool_use` to a search/execute tool, not as a spawn.
- The depth policy is a **conversation-level setting** (`maxNestingDepth`), defaulting to `1`.

### Tool Categories (iOS-First)

OpenSpace runs on iOS (iPhone/iPad) via direct cloud API. Tools are organized into three categories:

- **Client-local tools** — Execute on the device within iOS App Sandbox. Examples: read/write app documents, access Photo Library, read Clipboard, fetch Location, access Contacts/Calendar with user permission.
- **App-internal tools** — Interact with OpenSpace's own features. Examples: `navigateToScreen`, `toggleTheme`, `createReminder`, `toggleSpacerPet`.
- **Model-native tools** — Built-in tools offered by the AI provider itself (server-side). Examples: OpenAI `web_search_preview`, `code_interpreter`, `file_search`; Anthropic `computer_use`.

Excluded: shell execution, subprocess spawning, arbitrary filesystem access, and macOS-only capabilities.

### Tool Strategy

| Stage | Provider-native tools | Custom function tools |
|---|---|---|
| Early stage | Use if available (web_search_preview, code_interpreter where supported) | Client-local + app-internal only |
| Next stage | Full hybrid with auto-detection | Add network tools (web search via Brave/SerpAPI, fetch URL), complex orchestration |

- In early stage, behavior may differ per provider. The UI surfaces which provider-native tools are active for the current model.
- Custom function tools require explicit schema registration per provider (OpenAI `functions`, Anthropic `tools`).

### Tool Access Control

| Access Level | Behavior | Default For |
|---|---|---|
| **Auto** | Execute immediately without user approval | App-internal tools |
| **On-Request** | Show approval UI card with tool name + parameters; user taps Approve/Reject before execution | Client-local tools, Model-native tools |
| **Never** | Tool is disabled; model receives error if it attempts to call | Dangerous operations (delete, modify system settings) |

- **Global per-category toggle**: User can set an entire category to `auto` or `on_request` (e.g., "Allow all app-internal tools without approval").
- **Per-tool override**: Individual tools can be pinned to a stricter level than their category default (e.g., `readPhotoLibrary` set to `on_request` even if Client-local category is `auto`).
- **Approval UI**: When a tool call arrives, the chat UI pauses streaming and renders an inline card showing: tool name, arguments, and Approve/Reject buttons. The model waits until user acts.
- **Rejection handling**: If user rejects, a `tool_result` with `approved: false` and `reason: "user_denied"` is sent back to the model.
- **Timeout**: On-request approval has a configurable timeout (default 5 minutes). If user does not act, the call is rejected automatically.

### Persistence

- **Storage backend**: SwiftData with `ModelContainer` and iCloud sync capability for automatic sync across user's devices.
- **Sync scope**: Conversation history, message content, thread hierarchy, and tool access settings sync via iCloud. Provider API keys and user credentials are stored in Keychain (not synced).
- **Conflict resolution**: Last-write-wins per record with manual merge UI for rare conflicts.
- **Offline support**: Full read/write offline. Sync happens when connectivity returns.
- **Migration**: Schema versioning via SwiftData model container configuration.

### TCA Architecture (Feature-Based)

`HomeContainer` is a **root orchestrator reducer** that composes child feature reducers. Each child owns its own state and action domain. Navigation is driven by state, not by NavigationStack path-based routing.

| Feature | Responsibility | State |
|---|---|---|
| `ChatConversationList` | List of threads, search, archive, delete | `conversations: [ChatConversation]` |
| `MainChat` | Single conversation execution: message streaming, tool calling, subagent spawning | `messages: [ChatMessage]`, `selectedConversation: ChatConversation?` |
| `InputComposer` | Text input, model selection, attachment picker, context mentions | `draftMessage: String`, `selectedModel: ComposerModelOption`, `attachments: [Attachment]` |
| `ToolExecutor` | Receives tool_call from model, resolves access level, executes, returns result | `pendingCalls: [ToolCall]`, `approvalQueue: [ToolCall]` |
| `SubagentOrchestrator` | Spawns child threads, tracks status, merges results back to parent | `children: [ChildThreadState]` |
| `ChatSettings` | Provider config, API keys, tool access control | `providers: [ProviderConfig]`, `toolAccess: ToolAccessConfig` |

- `MainChat` is **reused** for both parent threads and child thread detail pages. The same reducer, initialized with different `ChatConversation` state.
- Child reducers communicate with the parent via **Actions**, not direct mutation. `SubagentOrchestrator` dispatches `MainChat.Action` to child stores.
- `HomeContainer` uses `Scope` and `Reduce` to delegate actions to the correct child feature.

### Message Model (Discriminated Union)

`ChatMessage` is an enum with associated values:

```swift
enum ChatMessage: Equatable, Identifiable, Sendable {
    case text(ChatTextMessage)
    case thinking(ChatThinkingMessage)
    case toolCall(ChatToolCallMessage)
    case toolResult(ChatToolResultMessage)
    case subagentLink(ChatSubagentLinkMessage)
    case attachment(ChatAttachmentMessage)
    case system(ChatSystemMessage)
}
```

| Case | Content | Render |
|---|---|---|
| `.text` | `content: String`, `isComplete: Bool` | Bubble chat biasa |
| `.thinking` | `content: String`, `isComplete: Bool` | Collapsible bubble dengan styling berbeda (italic, muted color) |
| `.toolCall` | `calls: [ToolCall]`, `status: .pending/.approved/.executed` | Inline approval card atau summary card |
| `.toolResult` | `callId: String`, `result: String`, `approved: Bool` | Compact expandable card (default collapsed) |
| `.subagentLink` | `link: ThreadLink`, `status: .running/.done/.failed` | Summary card tap-able, navigasi ke detail |
| `.attachment` | `type: .image/.audio/.file`, `url: URL` | Inline preview sesuai tipe |
| `.system` | `content: String` | Hidden atau subtle indicator, tidak masuk ke context window saat kirim ke model |

- Thinking messages **stream independently** dari text messages. Model bisa mengeluarkan `.thinking` delta lalu `.text` delta bergantian.
- UI renders thinking **collapsible** dengan default state `collapsed` setelah turn selesai, `expanded` saat streaming.
- Tool calls dan tool results **muncul sebagai satu pasangan** dalam message list (call diikuti result), meskipun secara teknis dikirim sebagai event terpisah.

### Provider Abstraction (API Layer)

- `APIClient` is a **protocol/interface** with a single entry point: `stream(request: ChatRequest) -> AsyncStream<StreamingEvent>`.
- Concrete implementations exist per provider: `OpenAIClient`, `AnthropicClient`, `xAIClient`, `GeminiClient`.
- Each implementation handles its own SSE parsing, format translation, and error mapping, converting raw provider deltas into the universal `StreamingEvent` domain type.
- `ThreadEngine` is **provider-agnostic**. It only knows `APIClient` and `StreamingEvent`.
- **Model selection** is per-conversation. Once a conversation starts with a model, all messages in that conversation use the same provider/model. Switching models requires starting a new conversation.

### Persistence Schema (SwiftData)

`ChatMessageRecord` is a SwiftData `@Model` with normalized fields and a JSON payload:

| Field | Type | Purpose | Queryable |
|---|---|---|---|
| `messageID` | UUID | Primary key | Yes |
| `conversationID` | UUID | Foreign key to conversation | Yes |
| `timestamp` | Date | Waktu pembuatan | Yes |
| `role` | String | `user` / `assistant` / `system` | Yes |
| `messageKind` | String | Discriminator: `text`, `thinking`, `toolCall`, `toolResult`, `subagentLink`, `attachment`, `system` | Yes |
| `status` | String | `.streaming` / `.complete` / `.failed` | Yes |
| `payloadData` | Data | JSON-encoded associated value dari `ChatMessage` enum | No |

- `ChatConversationRecord` is a separate `@Model` for conversation metadata (title, modelID, timestamps).
- `ChatPersistenceMapper` handles domain model <-> record conversion.
- `ChatMessagePayloadCoder` encodes/decodes enum payloads as JSON with full-precision date round-tripping.
- Query untuk filter, sort, dan fetch conversation history menggunakan normalized fields. Payload JSON hanya dibaca saat rendering atau reconstructing `ChatMessage` enum.
- `ThreadLink` (subagent reference) disimpan sebagai normalized relationship via `conversationID` fields untuk navigasi efisien.

### Provider Key Management (BYOK + Proxy Hybrid)

| Mode | Tagline | Behavior |
|---|---|---|
| **Bring Your Own Key (BYOK)** | "Bring Your Own Key" | User provides their own API key per provider. Stored in Keychain (not synced). Direct API call from device to provider. No backend needed. |
| **OpenSpace Proxy** | "Zero-config AI" | User subscribes via in-app purchase. OpenSpace backend handles provider billing, key rotation, and rate limiting. Device calls OpenSpace API, backend forwards to provider. |
| **Hybrid** | "BYOK, or let us handle it" | Default to BYOK. User can switch to Proxy anytime. Proxy mode hides API keys entirely. BYOK mode shows key management UI. |

- **Key validation**: Saat user input API key, a lightweight `GET /models` test call is made to validate the key. Invalid key = inline error, tidak disimpan.
- **Key security**: API keys stored in **Keychain** with `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` (tidak backup ke iCloud, tidak sync antar device).
- **Fallback**: Saat BYOK key invalid atau expired, UI menawarkan switch ke Proxy mode dengan one-tap.
- **Proxy pricing**: Metered by token usage or flat subscription. TBD in next stage.

### Error Handling & Resilience

| Error Type | Strategy | User Visibility |
|---|---|---|
| **Network disconnect** | Automatic retry with exponential backoff (max 3 retries) | Inline "Reconnecting..." indicator. No user action required. |
| **Rate limit (429)** | Automatic retry with `Retry-After` header respect + jitter | Inline "Rate limited, retrying in Ns..." indicator. |
| **Context window exceeded** | Automatic summarization: summarize oldest 50% of conversation into a system summary, then retry | Inline "Summarizing conversation..." indicator. |
| **Invalid API key** | No retry. Show inline error card with "Update Key" or "Switch to Proxy" button | Inline error card. |
| **Model refusal** | No retry. Render refusal as `.text` message with refusal styling | Inline refusal message. |

- **Summarization**: When context window is exceeded, `ThreadEngine` pauses streaming, triggers a background summarization call to the same model (with a truncated prompt), stores the summary as a `.system` message, and retries the original request with the summarized context.
- **Max retries**: 3 for network/rate limit. After 3 failures, show inline error card with manual retry button.
- **State preservation**: During retry/summarization, the partial streamed message is preserved. User sees the message grow after recovery, not a fresh restart.
