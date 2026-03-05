# Zephyr Framework Architecture

## Overview

Zephyr is a full‑stack web framework built in Zig that combines Phoenix‑inspired architecture with WebAssembly compilation and React/TypeScript integration. The framework is designed from the ground up for edge deployment, real‑time communication, and full‑stack type safety.

## Design Principles

1. **Zero‑Cost Abstractions**: All framework features compile to minimal, efficient machine code or WebAssembly.
2. **Comptime‑Driven Development**: Leverage Zig's comptime for code generation, type checking, and optimization.
3. **Edge‑First Architecture**: Applications deploy globally by default, not as an afterthought.
4. **Type Safety Across Stack**: Write types once in Zig, use them automatically in TypeScript.
5. **Progressive Disclosure**: Simple defaults with escape hatches to lower‑level APIs when needed.
6. **Batteries‑Included, But Removable**: Comprehensive built‑in features that can be replaced piecemeal.

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Zephyr Application                             │
├──────────────────┬──────────────────┬───────────────-───┬───────────────────┤
│    Zig Core      │  WASM Runtime    │ React Integration │   Build System    │
│   (Backend)      │   (Browser)      │    (Frontend)     │    & Tooling      │
├──────────────────┼──────────────────┼──────────────-────┼───────────────────┤
│ • HTTP Server    │ • Zig→WASM       │ • Generated Hooks │ • Vite Plugin     │
│ • Router         │   Compiler       │ • Type Bindings   │ • CLI             │
│ • Pipelines      │ • WASM Loader    │ • Dev Server      │ • Code Generator  │
│ • Channels       │ • Bridge         │ • Hot Reload      │ • Type Sync       │
│ • Database       │                  │                   │                   │
│ • Templates      │                  │                   │                   │
└──────────────────┴──────────────────┴─────────────-─────┴───────────────────┘
                            │                │                │
                            ▼                ▼                ▼
┌──────────────────┬──────────────────┬──────────────────┬───────────────────┐
│  Edge Runtime    │    CDN           │   Browser        │  Package Registry │
│  (Deployment)    │  (Assets)        │   Runtime        │   (Ecosystem)     │
├──────────────────┼──────────────────┼──────────────────┼───────────────────┤
│ • Cloudflare     │ • Static Files   │ • React App      │ • Zephyr Packages │
│   Workers        │ • WASM Modules   │ • WASM Execution │ • Common Libs     │
│ • Traditional    │ • Auto‑deploy    │ • WebSockets     │ • Templates       │
│   Servers        │                  │ • Channels       │                   │
└──────────────────┴──────────────────┴──────────────────┴───────────────────┘
```

## Core Components

### 1. HTTP Layer (`zephyr.Conn`, `zephyr.Router`)

**Purpose**: Handle HTTP requests and responses with Phoenix‑inspired routing.

**Key Design Decisions**:
- **Connection‑Oriented**: Each request creates a `Conn` struct that flows through the pipeline
- **Router as Comptime Data**: Routes are defined at comptime for maximum performance
- **Pattern Matching**: Route patterns support Phoenix‑style syntax (`/users/:id`, `/*path`)

**Implementation**:
```zig
// Example route definition (comptime)
const routes = &.{
    .{ .method = .GET,  .path = "/api/users",     .to = UserController, .action = .index },
    .{ .method = .POST, .path = "/api/users",     .to = UserController, .action = .create },
    .{ .method = .GET,  .path = "/api/users/:id", .to = UserController, .action = .show },
};

// Router matches at comptime when possible
pub fn match(comptime method: http.Method, comptime path: []const u8) ?RouteMatch {
    // Comptime route matching for compile‑time verification
}
```

### 2. Pipeline System (`zephyr.Pipeline`, `zephyr.plugs`)

**Purpose**: Middleware system inspired by Phoenix Plugs for request processing.

**Key Design Decisions**:
- **Type‑Safe Plugs**: Each plug declares its input/output types at comptime
- **Pipeline Composition**: Pipelines can be nested and composed
- **Connection Transformation**: Plugs transform the `Conn` struct as it flows through

**Data Flow**:
```
HTTP Request → Router → Pipeline[Plug₁ → Plug₂ → ... → Plugₙ] → Controller → Response
```

**Implementation**:
```zig
// Plug definition
pub const AuthPlug = struct {
    pub fn call(conn: *Conn, opts: anytype) !void {
        // Authentication logic
        conn.assign(:current_user, user);
    }
    
    // Comptime metadata for pipeline validation
    pub const requires = &.{:session};
    pub const provides = &.{:current_user};
};
```

### 3. Channel System (`zephyr.Channel`, `zephyr.Socket`)

**Purpose**: Real‑time WebSocket communication with pub/sub patterns.

**Key Design Decisions**:
- **Topic‑Based Addressing**: Channels are addressed as `topic:subtopic` (e.g., `chat:lobby`)
- **Socket State Management**: Each WebSocket connection maintains typed state
- **Broadcast Optimization**: Efficient message routing with room‑based subscriptions

**Architecture**:
```
Browser Client ──WebSocket──→ Channel Server ──Pub/Sub──→ Other Clients
       │                              │
       └──Message──→ Topic Router ────┘
```

**Implementation**:
```zig
// Channel definition with typed handlers
pub const ChatChannel = zephyr.Channel("chat:*", .{
    .join = struct {
        pub fn call(socket: *Socket, params: JoinParams) !JoinResponse {
            // Authentication and room joining
        }
    },
    
    .handle_in = struct {
        pub fn "new:msg"(socket: *Socket, msg: Message) !void {
            // Broadcast to room
            try socket.broadcast(room, "new:msg", .{.msg = msg});
        }
    },
});
```

### 4. WebAssembly Compilation Pipeline

**Purpose**: Compile Zig code to WebAssembly for browser execution.

**Key Design Decisions**:
- **Dual Compilation**: Zig code compiles to both native (backend) and WASM (frontend)
- **Automatic Binding Generation**: Export annotations generate TypeScript bindings
- **Size Optimization**: Aggressive dead code elimination and optimization

**Compilation Pipeline**:
```
Zig Source → Comptime Analysis → Dependency Graph → WASM Compilation
     │              │                  │                  │
     ▼              ▼                  ▼                  ▼
  Zig AST       Type Info         Module Graph       .wasm Binary
                                                   (with debug info)
     │                                                  │
     └───────────────Type Extraction────────────────────┘
                                 │
                                 ▼
                         TypeScript .d.ts
                         React Hooks (.tsx)
```

**Implementation**:
```zig
// Zig function marked for WASM export
pub export fn process_data(input: []const u8, output: []u8) usize {
    // Runs in browser as WebAssembly
    return processed_len;
}

// Generated TypeScript:
// export function process_data(input: string, output: Uint8Array): number;
```

### 5. Type Generation System

**Purpose**: Generate TypeScript types and React hooks from Zig definitions.

**Key Design Decisions**:
- **Comptime Reflection**: Use Zig's comptime to inspect type definitions
- **Bidirectional Mapping**: Zig types → TypeScript interfaces with transformations
- **Hook Generation**: Automatically generate React hooks for Zig functions and channels

**Type Mapping**:
| Zig Type | TypeScript Type | Notes |
|----------|-----------------|-------|
| `u8`, `u16`, `u32`, `u64` | `number` | Range validation in dev mode |
| `i8`, `i16`, `i32`, `i64` | `number` | Range validation in dev mode |
| `f32`, `f64` | `number` | |
| `bool` | `boolean` | |
| `[]const u8` | `string` | UTF‑8 validation |
| `[]u8` | `Uint8Array` | Binary data |
| `struct` | `interface` | With optional/readonly modifiers |
| `enum` | `enum` | String‑based in TypeScript |
| `union` | `discriminated union` | With tag field |

**Implementation**:
```zig
// Zig struct with TypeScript metadata
pub const User = struct {
    id: u64,
    name: []const u8,
    email: []const u8,
    created_at: i64,
    
    pub const typescript = .{
        .interface = "User",
        .optional_fields = &.{"email"},
        .transformations = &.{
            .{ .field = "created_at", .to = "Date", .via = "new Date(value * 1000)" },
        },
        .exclude_fields = &.{"internal_field"}, // Not exposed to TypeScript
    };
};
```

### 6. React Integration Layer

**Purpose**: Provide seamless integration between Zig backend and React frontend.

**Key Design Decisions**:
- **Generated Hooks**: `useWasm()`, `useChannel()`, `useZephyr()` auto‑generated from Zig
- **Type‑Safe Communication**: All hooks are fully typed based on Zig definitions
- **Development Proxy**: Dev server proxies between React dev server and Zig backend

**Hook Architecture**:
```
React Component → Generated Hook → TypeScript Interface → WASM/HTTP/WebSocket
       │                  │                  │                    │
       └──Type Safety─────┴──────────────────┴──────Runtime───────┘
```

**Implementation**:
```typescript
// Generated hook example
export function useTodos() {
  const { data: todos, mutate } = useZephyr<Todo[]>('/api/todos');
  const { filterTodos } = useWasm('todo');
  
  // Fully typed based on Zig definitions
  const createTodo = async (params: TodoCreateParams) => {
    const response = await fetch('/api/todos', {
      method: 'POST',
      body: JSON.stringify(params),
    });
    mutate();
    return response.json() as Promise<Todo>;
  };
  
  return { todos, createTodo, filterTodos };
}
```

## Data Flow Patterns

### 1. HTTP Request/Response Flow

```
1. HTTP Request arrives
2. Router matches request to route
3. Pipeline executes plugs in sequence:
   a. Logger plug (logs request)
   b. CSRF plug (validates token)
   c. Auth plug (authenticates user)
   d. LoadUser plug (loads user from DB)
4. Controller handles request
5. Response flows back through pipeline (reverse order)
6. HTTP Response sent
```

### 2. Real‑Time Message Flow

```
1. WebSocket connection established
2. Client joins channel with parameters
3. Channel validates and authorizes join
4. Socket subscribes to topic(s)
5. Messages flow:
   a. Client → `socket.send("event", data)`
   b. Channel → `handle_in."event"(socket, data)`
   c. Channel → `socket.broadcast(topic, "event", data)`
   d. Other clients receive via WebSocket
```

### 3. Type Generation Flow

```
1. Developer changes Zig file
2. File watcher detects change
3. Comptime analyzer extracts type information
4. TypeScript generator creates/updates .d.ts files
5. React hook generator creates/updates hook files
6. Vite plugin triggers hot module replacement
7. Browser updates without full refresh
```

## Build System Architecture

### 1. Zig Build System Integration

Zephyr uses Zig's native build system with custom build steps:

```zig
// build.zig.zon dependencies
.dependencies = .{
    .zephyr = .{
        .url = "https://github.com/agumtech/zephyr/archive/main.tar.gz",
        .hash = "...",
    },
    .zephyr_wasm = .{
        .url = "...",
        .hash = "...",
    },
},
```

### 2. Multi‑Target Compilation

```
Same Zig Source → Different Build Configurations
        │
        ├───▶ x86_64‑linux (Backend Server)
        ├───▶ wasm32‑wasi  (Browser WASM)
        ├───▶ aarch64‑macos (Development)
        └───▶ x86_64‑windows (Cross‑compilation)
```

### 3. Development Build vs Production Build

| Aspect | Development | Production |
|--------|-------------|------------|
| **Optimization** | Debug | ReleaseSafe/ReleaseSmall |
| **WASM Size** | Includes debug info | Stripped, optimized |
| **Hot Reload** | Enabled | Disabled |
| **Type Checking** | Lazy, incremental | Full, strict |
| **Error Messages** | Detailed with context | Minimal, secure |

## Deployment Architecture

### 1. Edge Deployment (Primary)

```
Static Assets (CDN)              Edge Functions (Workers)
├── index.html                   ├── /api/* → Zig WASM
├── assets/                      ├── /ws/* → WebSocket
│   ├── app‑*.js                 └── /rpc/* → RPC endpoint
│   ├── app‑*.css
│   └── *.wasm
└── *.woff2
```

**Cloudflare Workers Integration**:
- Zig compiles to WASM with WASI preview2
- Workers run Zig code directly
- Global distribution with < 5ms latency

### 2. Traditional Server Deployment

```
Docker Container / Bare Metal
├── Zig HTTP Server (port 4000)
├── PostgreSQL / SQLite
├── Redis (for pub/sub scaling)
└── Nginx (optional reverse proxy)
```

### 3. Hybrid Deployment

```
Static Site (CDN)          Edge Functions         Origin Server
    │                           │                       │
    └───▶ Initial Load ────────┼───────────────────────┘
    └───▶ API Calls ───────────▶ Zig WASM
    └───▶ WebSocket ───────────▶ Zig Channel Server
    └───▶ Static Assets ◀───────┘
```

## Extension Points

### 1. Custom Plugs

```zig
pub const CustomPlug = struct {
    pub fn call(conn: *Conn, opts: anytype) !void {
        // Custom middleware logic
    }
    
    // Optional: Comptime metadata
    pub const provides = &.{:custom_data};
    pub const requires = &.{:some_dependency};
};
```

### 2. Database Adapters

```zig
pub const DatabaseAdapter = struct {
    connect: fn (allocator: Allocator, config: anytype) anyerror!*Connection,
    query: fn (conn: *Connection, sql: []const u8, params: anytype) anyerror!QueryResult,
    // ... other required methods
};

// Implement for SQLite, PostgreSQL, MySQL, etc.
```

### 3. Template Engines

```zig
pub const TemplateEngine = struct {
    render: fn (allocator: Allocator, template: []const u8, data: anytype) anyerror![]const u8,
    compile: fn (comptime template: []const u8) type, // Returns a render function type
};
```

### 4. Authentication Strategies

```zig
pub const AuthStrategy = struct {
    authenticate: fn (conn: *Conn, credentials: anytype) anyerror!User,
    authorize: fn (user: User, resource: anytype, action: []const u8) anyerror!void,
};
```

## Performance Characteristics

### 1. Runtime Performance

| Operation | Target Performance | Comparison |
|-----------|-------------------|------------|
| HTTP Request (p95) | < 5ms | 4× faster than Phoenix |
| WebSocket Broadcast | < 2ms | 10× faster than Node.js |
| WASM Function Call | < 0.1ms | Native‑like speed |
| Memory per Connection | < 64KB | 10× less than BEAM |

### 2. Bundle Sizes

| Component | Target Size (gzipped) | Notes |
|-----------|----------------------|-------|
| Core WASM Library | < 50KB | Includes router, basic plugs |
| Channel WASM | < 30KB | Real‑time communication |
| TypeScript Runtime | < 20KB | Hook utilities, WebSocket client |
| Total Initial Load | < 100KB | Faster than equivalent JavaScript |

### 3. Compilation Performance

| Build Type | Target Time | Optimization |
|------------|-------------|--------------|
| Development (incremental) | < 3s | With caching |
| Production (full) | < 30s | Parallel compilation |
| Type Generation | < 1s | Incremental updates |

## Security Architecture

### 1. Defense in Depth

```
Request → Router → Pipeline → Controller → Response
    │         │         │         │         │
    ├─CORS────┼─────────┼─────────┼─────────┤
    ├─CSRF────┼─────────┼─────────┼─────────┤
    ├─Rate Limit───────┼─────────┼─────────┤
    ├─Authentication───┼─────────┼─────────┤
    ├─Authorization────┼─────────┼─────────┤
    └─Input Validation───────────┼─────────┘
```

### 2. WebAssembly Security

- **Memory Isolation**: Each WASM module gets its own linear memory
- **System Call Restrictions**: Browser sandboxing enforced
- **Size Limits**: Maximum memory allocation configurable
- **Import/Export Validation**: Strict validation of WASM imports

### 3. Real‑Time Security

- **Channel Authentication**: Must authenticate before joining
- **Topic Authorization**: Fine‑grained permission checks
- **Message Validation**: All messages validated against schemas
- **Rate Limiting**: Per‑connection and per‑topic limits

## Monitoring and Observability

### 1. Built‑in Metrics

```zig
// Metrics collected automatically
const metrics = struct {
    http_requests_total: Counter,
    http_request_duration_seconds: Histogram,
    websocket_connections: Gauge,
    channel_messages_total: Counter,
    wasm_function_calls: Counter,
};
```

### 2. Distributed Tracing

- **Request‑ID Propagation**: Across HTTP, WebSocket, and background jobs
- **Span Creation**: Automatic for pipelines, controllers, channels
- **Export Support**: OpenTelemetry, Jaeger, Zipkin

### 3. Health Checks

```
GET /healthz → Application health
GET /readyz  → Readiness for traffic
GET /livez   → Liveness check
GET /metrics → Prometheus metrics
```

## Future Architecture Directions

### 1. WebAssembly Component Model

Future integration with WASM Component Model for:
- Language‑agnostic component composition
- Better interface definitions
- Improved performance isolation

### 2. Distributed Channels

Planned support for:
- Redis‑backed pub/sub for horizontal scaling
- Multi‑region channel replication
- Consistent hashing for channel distribution

### 3. Edge Database Integration

Exploring:
- SQLite compiled to WASM for edge databases
- Replication from central database to edge
- Conflict‑free replicated data types (CRDTs)

---

*This architecture document will evolve as Zephyr develops. See [ROADMAP.md](ROADMAP.md) for implementation timeline and [PRD.md](PRD.md) for product requirements.*
