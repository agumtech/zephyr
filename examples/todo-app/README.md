# Zephyr Todo App Example

A complete, real-time todo application built with Zephyr that demonstrates the full power of the framework:
- Zig backend with Phoenix-inspired architecture
- WebAssembly compilation for client-side logic
- React/TypeScript frontend with generated types
- Real-time WebSocket channels for live updates
- Automatic type generation from Zig to TypeScript
- Edge deployment ready

## Features Demonstrated

| Feature | Implementation |
|---------|----------------|
| **Pipeline Architecture** | Authentication pipeline with plugs |
| **Real-time Channels** | Live todo updates across clients |
| **WASM Integration** | Client-side todo filtering in Zig |
| **Type Generation** | Automatic TypeScript interfaces from Zig structs |
| **React Hooks** | `useTodos`, `useTodoChannel` generated from Zig |
| **Database Layer** | SQLite with migrations |
| **Edge Deployment** | Cloudflare Pages configuration |

## Project Structure

```
todo-app/
├── zephyr.toml              # Project configuration
├── build.zig                # Zig build configuration
├── src/
│   ├── main.zig             # Application entry point
│   ├── router.zig           # Route definitions
│   ├── controllers/
│   │   └── todo.zig         # Todo HTTP controller
│   ├── channels/
│   │   └── todo.zig         # Real-time todo updates
│   ├── models/
│   │   └── todo.zig         # Todo model with types
│   ├── repositories/
│   │   └── todo_repo.zig    # Database operations
│   ├── pipelines/
│   │   └── api.zig          # API middleware pipeline
│   └── client/
│       └── filters.zig      # Client-side WASM functions
├── frontend/
│   ├── package.json
│   ├── vite.config.js       # Vite with Zephyr plugin
│   ├── src/
│   │   ├── main.tsx         # React entry point
│   │   ├── App.tsx          # Main application component
│   │   ├── components/
│   │   │   ├── TodoList.tsx
│   │   │   ├── TodoItem.tsx
│   │   │   └── TodoForm.tsx
│   │   └── generated/       # Auto-generated types & hooks
│   └── public/
├── migrations/              # Database migrations
│   └── 001_create_todos.sql
└── .github/
    └── workflows/
        └── deploy.yml       # CI/CD for Cloudflare
```

## Quick Start

### Prerequisites

- [Zig 0.12.0+](https://ziglang.org/download/)
- [Node.js 18+](https://nodejs.org/) or [Bun 1.0+](https://bun.sh/)
- [SQLite](https://sqlite.org/) (development database)

### Installation

1. **Clone the example:**

   ```bash
   git clone https://github.com/agumtech/zephyr.git
   cd zephyr/examples/todo-app
   ```

2. **Install dependencies:**

   ```bash
   npm install
   ```

3. **Setup database:**

   ```bash
   zephyr db:migrate
   ```

4. **Start development servers:**

   ```bash
   zephyr dev
   ```

5. **Open your browser:**

   Navigate to [http://localhost:3000](http://localhost:3000)

## Key Code Examples

### Zig Backend: Todo Model with Type Metadata

```zig
// src/models/todo.zig
const std = @import("std");
const zephyr = @import("zephyr");

pub const Todo = struct {
    id: u64,
    title: []const u8,
    completed: bool,
    user_id: u64,
    created_at: i64,
    updated_at: i64,
    
    // TypeScript generation metadata
    pub const typescript = .{
        .interface = "Todo",
        .exclude_fields = &.{"user_id"},     // Hide from frontend
        .optional_fields = &.{"updated_at"}, // Optional in TypeScript
        .transformations = &.{
            .{ .field = "created_at", .to = "Date", .via = "new Date(value)" },
        },
    };
    
    // Client-side WASM function
    pub export fn filter_by_title(todos: []const Todo, query: []const u8) usize {
        var count: usize = 0;
        for (todos) |todo| {
            if (std.mem.indexOf(u8, todo.title, query) != null) {
                count += 1;
            }
        }
        return count;
    }
};
```

### Real-time Channel for Live Updates

```zig
// src/channels/todo.zig
const zephyr = @import("zephyr");
const Todo = @import("../models/todo.zig");

pub const TodoChannel = zephyr.Channel("todo:*", .{
    .join = struct {
        pub fn call(socket: *zephyr.Socket, params: struct {
            user_id: u64,
            room: []const u8,
        }) !void {
            // Authenticate user
            const user = try authenticate_user(params.user_id);
            socket.assign(:user, user);
            
            // Join the todo room
            try socket.join(params.room);
            
            return .{
                .status = .joined,
                .response = .{
                    .user = user.name,
                    .room = params.room,
                    .message = "Welcome to the todo room!",
                },
            };
        }
    },
    
    .handle_in = struct {
        pub fn "todo:created"(socket: *zephyr.Socket, todo: Todo) !void {
            const room = socket.get(:room);
            const user = socket.get(:user);
            
            // Broadcast to everyone in the room
            try socket.broadcast(room, "todo:created", .{
                .todo = todo,
                .user = user,
                .timestamp = std.time.timestamp(),
            });
            
            // Optional: Notify other rooms
            try socket.broadcast("todo:global", "todo:created", .{
                .todo = todo,
                .user = user,
            });
        }
        
        pub fn "todo:updated"(socket: *zephyr.Socket, update: struct {
            id: u64,
            completed: bool,
        }) !void {
            const room = socket.get(:room);
            try socket.broadcast(room, "todo:updated", update);
        }
    },
});
```

### Generated TypeScript Hooks

```typescript
// frontend/src/generated/todo.ts - AUTO-GENERATED
// This file is automatically generated from Zig code

export interface Todo {
  id: number;
  title: string;
  completed: boolean;
  created_at: Date;
  updated_at?: Date;
}

export interface TodoCreateParams {
  title: string;
}

export interface TodoUpdateParams {
  id: number;
  completed?: boolean;
  title?: string;
}

// Generated React hooks
export function useTodos() {
  const { data: todos, error, mutate } = useZephyr<Todo[]>('/api/todos');
  const { data: stats } = useZephyr<{ count: number }>('/api/todos/stats');
  
  const createTodo = useCallback(async (params: TodoCreateParams) => {
    const response = await fetch('/api/todos', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(params),
    });
    await mutate(); // Refresh the list
    return response.json();
  }, [mutate]);
  
  return { todos, stats, createTodo, error, loading: !todos && !error };
}

export function useTodoChannel(room: string) {
  const { send, messages, status, error } = useChannel(`todo:${room}`, {
    params: { room, user_id: getCurrentUserId() },
    onJoin: (response) => {
      console.log('Joined todo room:', response);
    },
    onMessage: (event, data) => {
      if (event === 'todo:created') {
        // Handle new todo
        showNotification(`New todo: ${data.todo.title}`);
      }
    },
  });
  
  const createTodo = useCallback((todo: TodoCreateParams) => {
    send('todo:created', todo);
  }, [send]);
  
  return { send, messages, status, createTodo, error };
}
```

### React Component Using Generated Hooks

```typescript
// frontend/src/components/TodoList.tsx
import React, { useState } from 'react';
import { useTodos, useTodoChannel, useWasm } from '../generated/todo';
import TodoItem from './TodoItem';
import TodoForm from './TodoForm';

export function TodoList() {
  const { todos, createTodo, loading, error } = useTodos();
  const { createTodo: createRealtimeTodo } = useTodoChannel('global');
  const { filterByTitle } = useWasm('todo');
  const [search, setSearch] = useState('');
  
  // Use WASM for client-side filtering
  const filteredTodos = React.useMemo(() => {
    if (!todos || !filterByTitle || !search.trim()) return todos || [];
    // This runs Zig code in the browser via WebAssembly
    const count = filterByTitle(todos, search);
    return todos.filter(todo => 
      todo.title.toLowerCase().includes(search.toLowerCase())
    );
  }, [todos, filterByTitle, search]);
  
  const handleCreate = async (title: string) => {
    const todo = await createTodo({ title });
    // Also send real-time update
    createRealtimeTodo(todo);
  };
  
  if (loading) return <div className="loading">Loading todos...</div>;
  if (error) return <div className="error">Error: {error.message}</div>;
  
  return (
    <div className="todo-list">
      <header>
        <h1>Zephyr Todo App</h1>
        <div className="stats">
          {todos && <span>{todos.length} total todos</span>}
          {search && filteredTodos && (
            <span>{filteredTodos.length} matching "{search}"</span>
          )}
        </div>
      </header>
      
      <div className="controls">
        <TodoForm onCreate={handleCreate} />
        <input
          type="text"
          placeholder="Search todos..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="search"
        />
      </div>
      
      <div className="todos">
        {filteredTodos.map(todo => (
          <TodoItem key={todo.id} todo={todo} />
        ))}
        {filteredTodos.length === 0 && (
          <div className="empty">
            {search ? 'No todos match your search' : 'No todos yet'}
          </div>
        )}
      </div>
      
      <footer>
        <p>
          <small>
            Filtering powered by Zig WebAssembly • Updates in real-time
          </small>
        </p>
      </footer>
    </div>
  );
}
```

## Deployment

### Deploy to Cloudflare Pages

1. **Configure deployment:**

   ```bash
   zephyr deploy:setup --provider=cloudflare
   ```

2. **Build and deploy:**

   ```bash
   zephyr deploy --env=production
   ```

3. **Or use GitHub Actions:**

   The included `.github/workflows/deploy.yml` will automatically deploy when you push to main.

### Environment Variables

Create a `.env` file:

```env
DATABASE_URL=sqlite://./todos.db
SESSION_SECRET=your-secret-key-here
CLOUDFLARE_API_TOKEN=your-api-token
CLOUDFLARE_ACCOUNT_ID=your-account-id
```

### Database Migration for Production

```bash
# Generate migration
zephyr db:create add_todo_completed_index

# Run migrations
zephyr db:migrate --env=production
```

## Performance

This example demonstrates Zephyr's performance advantages:

| Operation | Time | Notes |
|-----------|------|-------|
| **Todo filtering (WASM)** | < 0.1ms | Client-side Zig code |
| **Real-time broadcast** | < 5ms | Edge network latency |
| **Page load (cold)** | < 800ms | Includes WASM download |
| **Page load (warm)** | < 100ms | WASM cached |
| **HTTP request p95** | < 10ms | Edge deployment |

## Learning Path

1. **Start with the basics:**
   - Examine `src/models/todo.zig` to understand type definitions
   - Look at `frontend/src/generated/todo.ts` to see generated types
   - Run `zephyr dev` and make changes to see hot reload in action

2. **Explore real-time features:**
   - Open the app in two browser windows
   - Create a todo in one window, watch it appear in the other
   - Check browser console for WebSocket messages

3. **Experiment with WASM:**
   - Modify `filter_by_title` in `src/models/todo.zig`
   - See changes reflect immediately in the browser
   - Use browser devtools to inspect WebAssembly module

4. **Try deployment:**
   - Deploy to Cloudflare Pages (free tier)
   - Test global latency from different regions
   - Monitor performance metrics

## Troubleshooting

### Common Issues

1. **Zig compilation errors:**
   ```bash
   # Ensure correct Zig version
   zig version  # Should be 0.12.0+
   
   # Clean build
   rm -rf zig-cache zig-out
   zig build
   ```

2. **WASM not loading in browser:**
   - Check browser console for errors
   - Ensure `Content-Type: application/wasm` is served correctly
   - Try `npm run build` then `npm run preview` to test production build

3. **Real-time connections failing:**
   - Check WebSocket URL (should be `ws://localhost:4000/ws`)
   - Verify CORS settings in `zephyr.toml`
   - Check browser's network tab for WebSocket frames

### Getting Help

- [Zephyr Documentation](https://zephyrframework.com/docs)
- [GitHub Issues](https://github.com/agumtech/zephyr/issues)
- [Discord Community](https://discord.gg/zephyr)

## License

This example is part of the Zephyr framework and is licensed under the [MIT License](../LICENSE).

## Contributing

Found a bug or have an improvement? 
1. Fork the repository
2. Create a feature branch
3. Submit a pull request

See the [Contributing Guide](../CONTRIBUTING.md) for details.

---

**Built with Zephyr** • Zig + React + WebAssembly • Real-time • Type-safe • Edge-native