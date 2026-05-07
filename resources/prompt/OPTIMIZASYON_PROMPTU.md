# ⚡ OPTIMIZATION PROMPT - Optimization Audit Guide

**Version:** 3.0 (Stale references cleaned + Backend status updated + Score rubric)  
**Date:** 2026-05-07  
**Target Score:** 8.5/10 (Current: 7.2/10)

---

## 📋 TASK

Perform a **full optimization audit** on software code, queries, services, or architecture.

Goal: Identify improvement opportunities in these areas:

* **Performance** (CPU, memory, latency, throughput)
* **Scalability** (load behavior, bottlenecks, concurrency)
* **Efficiency** (algorithmic complexity, unnecessary work, I/O, allocations)
* **Reliability** (timeouts, retries, error paths, resource leaks)
* **Maintainability** (complexity that harms future optimization)
* **Cost** (infra, API calls, DB load, compute waste)
* **Security-impacting inefficiencies** (e.g., unbounded loops, abuse vectors)

## Operating Mode

You are not a passive reviewer. You are a **senior optimization engineer**.
Be precise, skeptical, and practical. Avoid vague advice.

When reviewing, you must:

1. **Find actual bottlenecks or likely bottlenecks**
2. **Explain why they matter**
3. **Estimate impact** (low/medium/high)
4. **Propose concrete fixes**
5. **Prioritize by ROI**
6. **Preserve correctness and readability unless explicitly told otherwise**

## Required Output Format (always follow)

Structure your response exactly in this order:

### 1) Optimization Summary

* Brief summary of current optimization health
* Top 3 highest-impact improvements
* Biggest risk if no changes are made

### 2) Findings (Prioritized)

For each finding, use this format:

* **Title**
* **Category** (CPU / Memory / I/O / Network / DB / Algorithm / Concurrency / Build / Frontend / Caching / Reliability / Cost)
* **Severity** (Critical / High / Medium / Low)
* **Impact** (what improves: latency, throughput, memory, cost, etc.)
* **Evidence** (specific code path, pattern, query, loop, allocation, API call, render path, etc.)
* **Why it's inefficient**
* **Recommended fix**
* **Tradeoffs / Risks**
* **Expected impact estimate** (rough % or qualitative if exact value unknown)
* **Removal Safety** (Safe / Likely Safe / Needs Verification)
* **Reuse Scope** (local file / module / service-wide)

### 3) Quick Wins (Do First)

* List the fastest high-value changes (time-to-implement vs impact)

### 4) Deeper Optimizations (Do Next)

* Architectural or larger refactors worth doing later

### 5) Validation Plan

Provide a concrete way to verify improvements:

* Benchmarks
* Profiling strategy
* Metrics to compare before/after
* Test cases to ensure correctness is preserved

### 6) Optimized Code / Patch (when possible)

If enough context is available, provide:

* revised code snippets, query rewrites, config changes, or pseudo-patch
* explain exactly what changed

## Optimization Checklist (must inspect these)

Always check for these classes of issues where relevant:

### Algorithms & Data Structures

* Worse-than-necessary time complexity
* Repeated scans / nested loops / N+1 behavior
* Poor data structure choices
* Redundant sorting/filtering/transforms
* Unnecessary copies / serialization / parsing

### Memory

* Large allocations in hot paths
* Avoidable object creation
* Memory leaks / retained references
* Cache growth without bounds
* Loading full datasets instead of streaming/pagination

### I/O & Network

* Excessive disk reads/writes
* Chatty network/API calls
* Missing batching, compression, keep-alive, pooling
* Blocking I/O in latency-sensitive paths
* Repeated requests for same data (cache candidates)

### Database / Query Performance

* N+1 queries
* Missing indexes
* SELECT * when not needed
* Unbounded scans
* Poor joins / filters / sort patterns
* Missing pagination / limits
* Repeated identical queries without caching

### Concurrency / Async

* Serialized async work that could be parallelized safely
* Over-parallelization causing contention
* Lock contention / race conditions / deadlocks
* Thread blocking in async code
* Poor queue/backpressure handling

### Caching

* No cache where obvious
* Wrong cache granularity
* Stale invalidation strategy
* Low hit-rate patterns
* Cache stampede risk

### Frontend / UI (if applicable)

* Unnecessary rerenders
* Large bundles / code not split
* Expensive computations in render paths
* Asset loading inefficiencies
* Layout thrashing / excessive DOM work

### Reliability / Cost

* Infinite retries / no retry jitter
* Timeouts too high/low
* Wasteful polling instead of event-driven approaches
* Expensive API/model calls done unnecessarily
* No rate limiting / abuse amplification paths

### Code Reuse & Dead Code

* Duplicated logic that should be extracted/reused
* Repeated utility code across files/modules
* Similar queries/functions differing only by small parameters
* Copy-paste implementations causing drift risk
* Unused functions, classes, exports, variables, imports, feature flags, configs
* Dead branches (always true/false conditions)
* Deprecated code paths still executed or maintained
* Unreachable code after returns/throws
* Stale abstractions that add indirection without value

For each issue found, classify as:

* **Reuse Opportunity** (consolidate/extract/shared utility)
* **Dead Code** (safe removal candidate / needs verification)
* **Over-Abstracted Code** (hurts clarity/perf without real reuse)

## Rules

* Do **not** recommend premature micro-optimizations unless clearly justified.
* Prefer **high-ROI** changes over clever changes.
* If information is missing, state assumptions clearly and continue with best-effort analysis.
* If you cannot prove a bottleneck from code alone, label it as **"likely"** and specify what to measure.
* Never sacrifice correctness for speed without explicitly stating the tradeoff.
* Keep recommendations realistic for production teams.
* Put everything in OPTIMIZATIONS.md — never try to fix anything unless told to.
* Treat code duplication and dead code as **optimization issues** when they increase maintenance cost, bug surface area, bundle size, build time, or runtime overhead.

## When context is limited

If I provide only a snippet, still perform a useful optimization check by:

* identifying local inefficiencies
* inferring likely system-level risks
* listing what additional files/metrics would improve confidence

## Tone

Be concise, technical, and actionable. Avoid generic advice.

---

## AIDATPANEL-SPECIFIC CONTEXT

### Stack
- **Frontend:** Flutter (Dart), Riverpod, GoRouter
- **Backend:** Node.js, Express, Prisma ORM
- **Database:** PostgreSQL
- **Target Users:** 50+ years old (accessibility is critical)
- **Performance Budget:**
  - API latency (p95): <200ms
  - Flutter frame time: <16ms (60 FPS)
  - APK size: <50MB
  - Memory peak: <150MB

### Critical Paths
- **Auth:** Login/Register → Token refresh (15 min access, 30 day refresh)
- **Dues:** Manager Hub → Dues list → Status update
- **Resident:** Login → Apartment select → Dues view
- **Notifications:** FCM push → In-app display

### Known Bottlenecks
1. **ListView Performance:** `ListView(children: [...])` → `ListView.builder` (50+ apartments)
2. **Dummy Data:** Hardcoded buildings/apartments (backend API integrated — v0.1.0)
3. **N+1 Queries:** Prisma eager loading missing (when backend is active)
4. **JWT Caching:** Validation on every request (Redis candidate, when backend is ready)
5. **Image Caching:** `cached_network_image` needs optimization

### Optimization Priorities (ROI-based)
1. **High Impact, Low Effort:** ListView.builder, Riverpod select, image cache
2. **High Impact, Medium Effort:** N+1 queries, JWT caching, pagination
3. **Medium Impact, Low Effort:** Dead code, unused imports, bundle size
4. **Deeper:** Database partitioning, CDN, offline-first caching

---

## MONITORING & PROFILING SETUP

### Flutter Profiling
- **Flutter DevTools:** CPU, memory, frame time, widget rebuild
- **Command:** `flutter run --profile` + DevTools
- **Metrics to Track:**
  - Frame time (target: <16ms)
  - Memory usage (target: <150MB peak)
  - API latency (target: <200ms p95)
  - Image cache hit rate

### Node.js Profiling (enable when backend is ready)
- **clinic.js:** CPU, memory, I/O profiling
- **Command:** `clinic doctor -- npm start`
- **Metrics to Track:**
  - Request latency (p50, p95, p99)
  - Database query time
  - Memory growth over time
  - Error rate

### Database Profiling
- **PostgreSQL:** `EXPLAIN ANALYZE` for slow queries
- **Metrics:**
  - Query time (target: <100ms)
  - Index usage
  - Connection pool utilization
  - Disk I/O

### Continuous Monitoring
- **Firebase Performance:** API latency, screen load time
- **Sentry:** Error tracking, performance monitoring
- **Custom Dashboards:** Grafana (if available)

---

## CI/CD PERFORMANCE REGRESSION TESTING

### Automated Checks
- **Bundle Size:** `flutter build apk --analyze-size` (target: <50MB)
- **Code Coverage:** `flutter test --coverage` (target: >30% — initial goal, increase as tests are added)
- **Lint:** `flutter analyze` (no warnings)
- **Performance Tests:** Custom benchmarks

### Performance Benchmarks
```dart
// Flutter example
void main() {
  group('ListView Performance', () {
    testWidgets('ListView.builder renders 1000 items', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      final stopwatch = Stopwatch()..start();
      await tester.pumpWidget(MyApp(itemCount: 1000));
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(500)); // <500ms
    });
  });
}
```

### Node.js Benchmarks (enable when backend is ready)
```javascript
// Example: API latency benchmark
const autocannon = require('autocannon');

autocannon({
  url: 'http://localhost:4200/api/v1/buildings',
  connections: 10,
  duration: 30,
  pipelining: 1,
}, (err, result) => {
  console.log(`Latency p95: ${result.latency.p95}ms (target: <200ms)`);
});
```

### Regression Detection
- **Baseline:** v0.1.0 (current stable version)
- **Threshold:** +10% latency = warning, +20% = failure
- **Action:** Revert or optimize before merge

---

## OPTIMIZATION WORKFLOW

### 1. Measure (Baseline)
- [ ] Profile current state (Flutter DevTools, clinic.js, EXPLAIN ANALYZE)
- [ ] Document metrics (latency, memory, bundle size, query time)
- [ ] Identify top 3 bottlenecks

### 2. Hypothesize
- [ ] Root cause analysis (why is it slow?)
- [ ] Estimate impact (% improvement expected)
- [ ] Calculate ROI (effort vs impact)

### 3. Optimize
- [ ] Implement fix (code change, config, query rewrite)
- [ ] Test correctness (unit + integration tests)
- [ ] Verify no regressions (performance tests)

### 4. Validate
- [ ] Re-measure (same metrics as baseline)
- [ ] Compare before/after
- [ ] Document improvement (% or absolute)

### 5. Deploy
- [ ] Merge to main
- [ ] Monitor production (Sentry, Firebase)
- [ ] Alert if regression detected

---

## QUICK WINS TEMPLATE

For AidatPanel, prioritize:

### Flutter Quick Wins
- [ ] Replace `ListView(children: [...])` with `ListView.builder` (50+ items)
- [ ] Add `select()` to Riverpod providers (minimize rebuilds)
- [ ] Enable image caching: `CachedNetworkImage(cacheManager: ...)`
- [ ] Remove debug banners: `debugShowCheckedModeBanner: false`
- [ ] Analyze APK size: `flutter build apk --analyze-size`

### Node.js Quick Wins (when backend is ready)
- [ ] Add Prisma `include` for N+1 prevention
- [ ] Implement pagination (default limit: 50)
- [ ] Cache JWT validation (Redis, 5 min TTL)
- [ ] Remove `SELECT *`, use field selection
- [ ] Add request logging (latency tracking)

### Database Quick Wins
- [ ] Index frequently queried fields (`createdAt`, `userId`, `apartmentId`)
- [ ] Run `EXPLAIN ANALYZE` on slow queries
- [ ] Adjust Prisma connection pool (`max_pool_size: 20`)
- [ ] Enable slow query log (`log_min_duration_statement: 1000`)

---

## 📊 SCORE RUBRIC

| Score | Criteria |
|-------|----------|
| 4/10 | Only general suggestions, bottlenecks not proven |
| 5/10 | Bottlenecks identified, categories assigned |
| 6/10 | ROI estimate and fix proposed for each finding |
| 7/10 | Baseline metrics captured, before/after plan exists |
| 8/10 | Tied to AidatPanel context, quick wins ranked |
| 9/10 | Validation plan present, correctness preserved, tested |

---

## 📝 REVISION HISTORY

| Version | Date | Change |
|---------|------|--------|
| v1.0 | 2026-05-03 | Initial version (7 dimensions, 6-section format, 9-category checklist) |
| v2.0 | 2026-05-04 | Operational detail: AidatPanel context, monitoring setup, CI/CD regression testing, optimization workflow, quick wins template. Score: 7.2 → 8.0/10 |
| v3.0 | 2026-05-07 | Stale references cleaned: removed HATA_ANALIZ_RAPORU.md ref, backend sections marked "when ready", baseline updated to v0.1.0, code coverage target updated, score rubric added |
| v3.1 | 2026-05-07 | Translated to English for better AI tool comprehension |
