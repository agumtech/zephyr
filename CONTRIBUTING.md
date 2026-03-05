# Contributing to Zephyr

Thank you for your interest in contributing to Zephyr! This document provides guidelines and instructions for contributing to the project. By participating in this project, you agree to abide by its terms.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Contribution Workflow](#contribution-workflow)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Documentation](#documentation)
- [Issue Reporting](#issue-reporting)
- [Pull Request Process](#pull-request-process)
- [Review Process](#review-process)
- [Community](#community)

## Code of Conduct

We are committed to providing a friendly, safe, and welcoming environment for all contributors. Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md).

## Getting Started

### Prerequisites

- [Zig 0.12.0](https://ziglang.org/download/) or later
- [Node.js 18+](https://nodejs.org/) or [Bun 1.0+](https://bun.sh/)
- Git

### First-time Contributors

If you're new to the project, we recommend starting with:
- **Good first issues**: Issues labeled `good first issue` are carefully selected for newcomers.
- **Documentation**: Improving documentation is always valuable and helps you learn the codebase.
- **Bug fixes**: Issues labeled `bug` with `difficulty: easy` are good starting points.

## Development Setup

### 1. Fork and Clone

```bash
# Fork the repository on GitHub
# Clone your fork
git clone https://github.com/YOUR_USERNAME/zephyr.git
cd zephyr

# Add upstream remote
git remote add upstream https://github.com/agumtech/zephyr.git
```

### 2. Build the Project

```bash
# Install dependencies
npm install

# Build Zig code
zig build

# Build TypeScript/React components
npm run build

# Run tests
npm test
```

### 3. Development Server

```bash
# Start development servers (Zig backend + React frontend)
npm run dev

# This will start:
# - Zig backend on http://localhost:4000
# - React frontend on http://localhost:3000
# - Hot reload for both Zig and TypeScript
```

## Contribution Workflow

### 1. Branch Strategy

- `main`: Stable, production-ready code
- `develop`: Integration branch for features
- Feature branches: `feature/description`
- Bug fix branches: `fix/description`
- Documentation branches: `docs/description`

### 2. Creating a Branch

```bash
# Sync with upstream
git checkout main
git pull upstream main

# Create a new branch
git checkout -b feature/your-feature-name
```

### 3. Making Changes

- Keep changes focused and atomic
- Write descriptive commit messages (see below)
- Add tests for new functionality
- Update documentation as needed

### 4. Commit Message Format

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or fixing tests
- `chore`: Maintenance tasks

Example:
```
feat(router): add wildcard route matching

Add support for * wildcard in route patterns to match
any path segment.

Closes #123
```

## Coding Standards

### Zig Code

1. **Formatting**: Use `zig fmt` before committing
2. **Naming**:
   - Types: `PascalCase` (`struct User`, `const UserController`)
   - Functions and variables: `snake_case`
   - Constants: `SCREAMING_SNAKE_CASE` for module-level constants
3. **Error Handling**: Use Zig's error sets and `try`/`catch`
4. **Memory**: Be explicit about allocators, no hidden allocations
5. **Documentation**: Use `///` for public API documentation

Example:
```zig
/// User controller for handling user-related HTTP requests.
pub const UserController = struct {
    /// Retrieves a user by ID.
    pub fn show(conn: *zephyr.Conn) !void {
        const id = try conn.param(u64, "id");
        const user = try UserRepo.find(id) orelse return error.NotFound;
        return conn.json(user);
    }
};
```

### TypeScript/React Code

1. **Formatting**: Use Prettier (configured in project)
2. **Type Safety**: Always use TypeScript types, avoid `any`
3. **Hooks**: Follow React hooks rules, use custom hooks for logic
4. **Imports**: Group imports (external, internal, relative)
5. **Naming**: Use PascalCase for components, camelCase for functions/variables

Example:
```typescript
import React from 'react';
import { useWasm } from '@zephyr/react';

interface TodoListProps {
  todos: Todo[];
  onUpdate: (id: number, completed: boolean) => Promise<void>;
}

export function TodoList({ todos, onUpdate }: TodoListProps) {
  const { filterTodos } = useWasm('todo');
  
  // Component logic...
}
```

### WebAssembly Considerations

1. **Size Matters**: Keep WASM modules small (< 50KB gzipped)
2. **No Syscalls**: Browser WASM can't make system calls
3. **Memory Management**: Explicitly manage WebAssembly.Memory
4. **Type Safety**: Ensure Zig and TypeScript types match

## Testing

### Zig Tests

```bash
# Run all Zig tests
zig build test

# Run specific test suite
zig build test --test-filter "router"
```

Write tests in the same file or in `*_test.zig` files:

```zig
const std = @import("std");
const testing = std.testing;
const router = @import("router");

test "router matches simple path" {
    const r = router.Router.init(.{
        .routes = &.{.{ .method = .GET, .path = "/api/users", .to = UserController }},
    });
    
    const match = try r.match(.GET, "/api/users");
    try testing.expect(match != null);
}
```

### TypeScript/React Tests

```bash
# Run all frontend tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:coverage
```

Use Jest and React Testing Library:

```typescript
import { render, screen } from '@testing-library/react';
import { TodoList } from './TodoList';

describe('TodoList', () => {
  it('renders empty state when no todos', () => {
    render(<TodoList todos={[]} onUpdate={jest.fn()} />);
    expect(screen.getByText('No todos yet')).toBeInTheDocument();
  });
});
```

### Integration Tests

```bash
# Run full integration tests
npm run test:integration

# This tests:
# 1. Zig backend server
# 2. WebSocket connections
# 3. React frontend integration
# 4. WASM module loading
```

## Documentation

### Types of Documentation

1. **API Documentation**: Generated from Zig doc comments
2. **Tutorials**: Step-by-step guides for common tasks
3. **Examples**: Complete example applications
4. **Architecture**: High-level design documents
5. **Migration Guides**: From other frameworks

### Writing Documentation

- Use clear, concise language
- Include code examples
- Keep examples up-to-date
- Use diagrams for complex concepts
- Document edge cases and limitations

### Building Documentation

```bash
# Generate API documentation
npm run docs

# Serve documentation locally
npm run docs:serve

# Documentation will be available at http://localhost:8080
```

## Issue Reporting

### Before Submitting an Issue

1. Search existing issues to avoid duplicates
2. Check if the issue has been fixed in the latest version
3. Reproduce the issue in a minimal example

### Issue Template

When creating an issue, please use the template and include:

```
**Description**
Clear description of the issue.

**Steps to Reproduce**
1. ...
2. ...
3. ...

**Expected Behavior**
What you expected to happen.

**Actual Behavior**
What actually happened.

**Environment**
- Zig version:
- Node.js version:
- OS:
- Browser (if applicable):

**Additional Context**
Screenshots, logs, or additional information.
```

### Issue Labels

- `bug`: Something isn't working
- `feature`: New functionality request
- `enhancement`: Improvement to existing feature
- `documentation`: Documentation issue
- `good first issue`: Good for newcomers
- `help wanted`: Extra attention needed
- `question`: Further information is requested

## Pull Request Process

### 1. Before Submitting a PR

- [ ] Code follows coding standards
- [ ] Tests pass (`npm test && zig build test`)
- [ ] Documentation is updated
- [ ] Changes are focused and atomic
- [ ] Commit messages follow convention
- [ ] Branch is up-to-date with `main`

### 2. Creating a Pull Request

1. Push your branch to your fork
2. Open a PR against the `main` branch
3. Fill out the PR template completely
4. Reference any related issues

### 3. PR Template

```
## Description
Brief description of the changes.

## Related Issues
Closes #123, Fixes #456

## Changes
- Change 1
- Change 2

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manual testing performed

## Documentation
- [ ] API documentation updated
- [ ] Examples updated if applicable
- [ ] README updated if applicable

## Checklist
- [ ] Code follows project standards
- [ ] Self-review completed
- [ ] All tests pass
- [ ] No new warnings
```

### 4. Continuous Integration

All PRs must pass CI checks:
- Zig compilation and tests
- TypeScript compilation and tests
- Linting (Zig fmt, ESLint)
- Integration tests
- Documentation generation

## Review Process

### What Reviewers Look For

1. **Correctness**: Does the code work as intended?
2. **Performance**: Are there any performance regressions?
3. **Security**: Any potential security issues?
4. **Maintainability**: Is the code clean and well-documented?
5. **Testing**: Are there adequate tests?
6. **Documentation**: Is documentation updated?

### Review Etiquette

- Be respectful and constructive
- Focus on the code, not the person
- Explain the "why" behind suggestions
- Recognize that everyone has different experience levels
- Thank contributors for their work

### Addressing Feedback

1. Respond to all review comments
2. Make requested changes or explain why not
3. Push updates to the same branch
4. Request re-review when ready

## Community

### Getting Help

- [GitHub Discussions](https://github.com/agumtech/zephyr/discussions): Q&A and ideas
- [Discord](https://discord.gg/zephyr): Real-time chat
- [Twitter](https://twitter.com/zephyrframework): Updates and announcements

### Recognition

Contributors are recognized in:
- GitHub contributors list
- Release notes
- Project documentation
- Community announcements

### Becoming a Maintainer

After significant contributions, you may be invited to become a maintainer. Maintainers have:
- Commit access to the repository
- Responsibility for code review
- Involvement in project direction
- Mentoring opportunities

## License

By contributing to Zephyr, you agree that your contributions will be licensed under the project's [MIT License](LICENSE).

---

Thank you for contributing to Zephyr! Your work helps build better web applications for everyone.