# Sub-Agent Dispatch Standard

> `[evol:protocol]` — Standardized sub-agent prompt template with PUA injection, output contract, and result assembly.

## When to Dispatch

Use an `Agent` sub-agent when:
- A sub-task belongs to a parallel group (no inter-dependencies)
- A sub-task requires a different tool or capability profile
- A sub-task is purely mechanical (search, extract, read) and can run independently
- Complexity score of the sub-task ≥5 (moderate or complex)

## Prompt Template

```yaml
Agent:
  model: "sonnet"
  description: "{short sub-task name, ≤50 chars}"
  prompt: |
    ## Background

    This is sub-task {N} of {total} for: "{parent_task_summary}".
    Context: {why this sub-task exists, how it fits in the parent task}

    ## Task Specification

    ### WHAT
    {concrete deliverable — what to produce or modify}

    ### WHERE
    {file domain — exact paths or directories}

    ### DONE
    {verification criterion — how to confirm completion}

    ### DON'T
    {forbidden actions — what NOT to do, files NOT to touch}

    ## Execution Protocol

    Plan before you start. Verify after you finish. No skipped steps.

    ## Output Contract

    Return your result in this format:

    ```markdown
    ## Sub-Task {N} Result

    status: {success|partial|failure}
    files_modified: [file1, file2, ...]
    verification_evidence: {specific evidence meeting DONE criterion}

    ### Key Decisions
    - {decision 1}

    ### Issues
    - {issue} → {resolution}
    ```
```

## Parallel Execution

- **Max 3 simultaneous sub-agents** (context window budget)
- Independent sub-tasks within the same dependency group → dispatch in parallel
- Dependent sub-tasks → wait for prerequisites to complete
- If >3 independent in one group → dispatch 3, wait for first completion, dispatch next

## Result Assembly

After each group completes:

1. Collect each sub-task's result block (`## Sub-Task N Result`)
2. For each `failure`: diagnose root cause. If retryable → re-dispatch with additional context.
3. For each `success`: verify `verification_evidence` matches the DONE criterion.
4. Once all groups complete → generate consolidated summary for the user.

## Retry Logic

| Attempt | Action |
|---------|--------|
| 1st failure | Add context about what went wrong, re-dispatch |
| 2nd failure | Decompose the sub-task further, dispatch sub-sub-tasks |
| 3rd failure | Abort this sub-task. Mark parent task as `partial`. Log detailed failure. |
