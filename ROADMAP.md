# Zephyr Framework Public Roadmap

**Last updated:** March 4, 2026  
**View PRD:** [Complete Product Requirements Document](PRD.md)

## 🧭 Our Vision

Zephyr aims to become the most productive and performant full‑stack web framework, combining Phoenix‑like developer experience with Zig's performance and safety, while delivering seamless React/TypeScript integration and edge‑native deployment.

This roadmap outlines how we plan to get there, and how you can help.

## 🧱 Guiding Principles

1. **Developer Experience First:** Every feature must make developers more productive.
2. **Performance by Default:** No hidden allocations, minimal runtime overhead.
3. **Type Safety Across Stack:** Write types once in Zig, use them everywhere.
4. **Edge‑Native Architecture:** Build for global distribution from day one.
5. **Open & Collaborative:** Community‑driven design and implementation.

## 🗓 Development Phases

### Phase 1: Foundation (Q2‑Q3 2026)
**Goal:** Working prototype with core HTTP server and basic WASM compilation.

| Milestone | Status | Description |
|-----------|--------|-------------|
| M1: HTTP server with Phoenix‑like routing | Planned | Minimal router with pipeline/plug system |
| M2: Basic WASM compilation from Zig | Planned | Compile Zig functions to WebAssembly |
| M3: Hello World example end‑to‑end | Planned | Complete working example |
| M4: Initial CLI tool (`zephyr new`, `zephyr dev`) | Planned | Developer onboarding experience |

**Deliverables:**
- Core Zephyr library (Zig package)
- Simple CLI tool
- Basic React integration proof‑of‑concept
- Documentation website skeleton

### Phase 2: Real‑time & Types (Q4 2026 – Q1 2027)
**Goal:** Complete real‑time system and automatic type generation.

| Milestone | Status | Description |
|-----------|--------|-------------|
| M5: WebSocket server with channel system | Planned | Phoenix‑inspired channels |
| M6: Automatic TypeScript type generation | Planned | Generate `.d.ts` from Zig structs |
| M7: React hooks (`useWasm`, `useChannel`) | Planned | Type‑safe React integration |
| M8: Todo example app with real‑time updates | Planned | Comprehensive example |

**Deliverables:**
- Channel system implementation
- Type generator tool
- React integration library (`@zephyr/react`)
- Comprehensive documentation

### Phase 3: Tooling & Polish (Q2‑Q3 2027)
**Goal:** Production‑ready tooling and excellent developer experience.

| Milestone | Status | Description |
|-----------|--------|-------------|
| M9: Vite plugin with hot reload | Planned | Seamless development workflow |
| M10: Database layer (SQLite/PostgreSQL) | Planned | ORM‑like interface with migrations |
| M11: Edge deployment automation | Planned | One‑command deploy to Cloudflare/Vercel |
| M12: Performance optimization | Planned | Benchmarking and optimization suite |

**Deliverables:**
- Vite/Rollup plugins
- Database adapter interface
- Deployment CLI commands
- Performance benchmarking suite

### Phase 4: Ecosystem (Q4 2027 – Q1 2028)
**Goal:** Community growth and ecosystem development.

| Milestone | Status | Description |
|-----------|--------|-------------|
| M13: Authentication/authorization system | Planned | JWT, OAuth, permission system |
| M14: Package registry and common libraries | Planned | `zephyr‑packages` registry |
| M15: VS Code/Neovim extensions | Planned | IDE support for Zig/TypeScript sync |
| M16: Production case studies | Planned | Real‑world adoption examples |

**Deliverables:**
- Auth package (JWT, OAuth)
- Zephyr package registry
- IDE tooling
- Migration guides from Phoenix/Next.js

### Phase 5: Expansion (2028+)
**Goal:** Enterprise features and scaling.

| Milestone | Status | Description |
|-----------|--------|-------------|
| Y2 Q1: Monitoring and observability | Future | Distributed tracing, metrics |
| Y2 Q2: Multi‑tenant support | Future | Built‑in tenant isolation |
| Y2 Q3: GraphQL integration | Future | Automatic GraphQL schema generation |
| Y2 Q4: Zephyr Cloud (optional) | Future | Managed deployment platform |

## 🚀 How We Prioritize

We use a simple framework to decide what to build next:

1. **Impact:** How many developers will this benefit?
2. **Feasibility:** Can we build it with current resources?
3. **Alignment:** Does it move us toward our vision?
4. **Community Demand:** How many requests have we received?

## 🤝 How to Contribute

### For Developers
- **Good first issues:** Look for `good first issue` labels on GitHub.
- **Documentation:** Improve tutorials, API docs, or examples.
- **Bug fixes:** Tackle issues labeled `bug` and `difficulty: easy`.
- **Feature implementation:** Comment on issues you'd like to work on.

### For Non‑Developers
- **Testing:** Try Zephyr and report bugs or usability issues.
- **Design:** Help with UI/UX for tools and documentation.
- **Community:** Answer questions, write blog posts, create tutorials.
- **Sponsorship:** Support development through GitHub Sponsors.

See our [Contributing Guide](CONTRIBUTING.md) for details.

## 📈 Success Metrics

| Metric | Current | Phase 1 Target | Phase 2 Target |
|--------|---------|----------------|----------------|
| **GitHub Stars** | 0 | 500 | 2,000 |
| **Weekly Downloads** | 0 | 100 | 500 |
| **Active Contributors** | 0 | 10 | 30 |
| **Production Users** | 0 | 5 | 50 |
| **Documentation Coverage** | 0% | 80% | 100% |

## 🔄 How This Roadmap Evolves

This is a living document. We update it based on:

1. **Community feedback** from GitHub Discussions and Discord.
2. **Technology changes** in Zig, WebAssembly, and React ecosystems.
3. **Real‑world usage patterns** from early adopters.
4. **Contributor availability** and bandwidth.

Major changes will be announced in:
- GitHub Releases
- Discord announcements channel
- Twitter ([@zephyrframework](https://twitter.com/zephyrframework))

## ❓ Frequently Asked Questions

### When will Zephyr be production‑ready?
We expect Phase 3 (Q2‑Q3 2027) to deliver a production‑ready framework. Early adopters can start using it in Phase 2.

### How stable is the API?
Until version 1.0.0, we may make breaking changes, but we'll follow semantic versioning and provide migration guides.

### Can I use Zephyr today?
Yes! The code will be available from Phase 1, but expect rapid changes and some missing features.

### How does this compare to Phoenix?
Zephyr shares Phoenix's architecture (pipelines, channels) but uses Zig instead of Elixir, compiles to WebAssembly, and has built‑in React/TypeScript integration.

### What about other Zig web frameworks?
Zephyr is unique in its focus on full‑stack type safety, React integration, and edge‑native deployment. Other frameworks may focus on different niches.

## 📞 Stay Updated

- **GitHub:** [agumtech/zephyr](https://github.com/agumtech/zephyr)
- **Discord:** [Join our community](https://discord.gg/zephyr)
- **Twitter:** [@zephyrframework](https://twitter.com/zephyrframework)
- **Email:** [newsletter@zephyrframework.com](mailto:newsletter@zephyrframework.com)

## 🙏 Acknowledgments

Thank you to everyone who contributes ideas, code, documentation, or feedback. This roadmap is a collective vision, and we're excited to build it together.

---

*This roadmap is inspired by the work of Phoenix Framework, Next.js, and the Zig community. Special thanks to early contributors and advisors.*