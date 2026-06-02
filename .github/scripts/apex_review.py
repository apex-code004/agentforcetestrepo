"""
Amadeus Hospitality – Apex Code Review Agent
=============================================
Uses GitHub Models API (https://models.github.ai/inference)
Authenticated via the built-in GITHUB_TOKEN — NO external API key needed.
Requires a GitHub Copilot licence on the organisation/user.

Triggered by GitHub Actions when:
  - Label "apex-review" is added to a PR
  - Comment "/apex-review" is posted on a PR
"""

import os
import sys
import json
import fnmatch
import requests
from pathlib import Path
from openai import OpenAI   # openai SDK works with GitHub Models endpoint

# ──────────────────────────────────────────────────────────────────────────────
# CONFIGURATION
# ──────────────────────────────────────────────────────────────────────────────
GITHUB_TOKEN      = os.environ["GITHUB_TOKEN"]   # Built-in Actions token — always present
PR_NUMBER         = int(os.environ["PR_NUMBER"])
REPO              = os.environ["REPO"]            # e.g. "MyOrg/my-salesforce-repo"
GITHUB_RUN_ID     = os.environ.get("GITHUB_RUN_ID", "")
GITHUB_SERVER_URL = os.environ.get("GITHUB_SERVER_URL", "https://github.com")

# GitHub Models endpoint — uses GITHUB_TOKEN, no external API key required
GITHUB_MODELS_ENDPOINT = "https://models.github.ai/inference"
# Model to use — gpt-4o gives the best code review quality
AI_MODEL = "openai/gpt-4o"

GITHUB_API = "https://api.github.com"
HEADERS = {
    "Authorization":        f"Bearer {GITHUB_TOKEN}",
    "Accept":               "application/vnd.github.v3+json",
    "X-GitHub-Api-Version": "2022-11-28",
}

# Salesforce Apex file extensions to review
APEX_EXTENSIONS = (".cls", ".trigger", ".apex")

SEVERITY_EMOJI = {
    "error":      "🔴",
    "warning":    "🟡",
    "suggestion": "🔵",
}


# ──────────────────────────────────────────────────────────────────────────────
# GITHUB API HELPERS
# ──────────────────────────────────────────────────────────────────────────────

def get_pr_info():
    url = f"{GITHUB_API}/repos/{REPO}/pulls/{PR_NUMBER}"
    r = requests.get(url, headers=HEADERS)
    r.raise_for_status()
    return r.json()


def get_pr_files():
    files, page = [], 1
    while True:
        url = f"{GITHUB_API}/repos/{REPO}/pulls/{PR_NUMBER}/files?per_page=100&page={page}"
        r = requests.get(url, headers=HEADERS)
        r.raise_for_status()
        batch = r.json()
        if not batch:
            break
        files.extend(batch)
        page += 1
    return files


def get_file_content(raw_url):
    if not raw_url:
        return ""
    r = requests.get(raw_url, headers=HEADERS)
    return r.text if r.status_code == 200 else ""


def post_pr_comment(body):
    url = f"{GITHUB_API}/repos/{REPO}/issues/{PR_NUMBER}/comments"
    r = requests.post(url, headers=HEADERS, json={"body": body})
    r.raise_for_status()


def post_pr_review(review_body, inline_comments):
    """Post a formal PR review. Falls back gracefully if inline lines miss the diff."""
    url = f"{GITHUB_API}/repos/{REPO}/pulls/{PR_NUMBER}/reviews"

    formatted = []
    for c in inline_comments:
        entry = {
            "path": c["path"],
            "body": _format_inline_body(c),
            "side": "RIGHT",
        }
        if c.get("line"):
            entry["line"] = c["line"]
        formatted.append(entry)

    payload = {
        "body":     review_body,
        "event":    "COMMENT",
        "comments": formatted,
    }

    r = requests.post(url, headers=HEADERS, json=payload)

    if r.status_code == 422:
        # Line numbers not in diff — post without inline comments
        print("⚠️  Some inline lines not in diff — posting summary only.")
        payload["comments"] = []
        r = requests.post(url, headers=HEADERS, json=payload)

    r.raise_for_status()


def _format_inline_body(c):
    emoji    = SEVERITY_EMOJI.get(c.get("severity", "suggestion"), "🔵")
    severity = c.get("severity", "suggestion").upper()
    rule     = c.get("rule", "Standard")
    message  = c.get("message", "")
    fix      = c.get("fix", "")
    body     = f"{emoji} **[{severity}] {rule}**\n\n{message}"
    if fix:
        body += f"\n\n**Suggested fix:**\n```apex\n{fix}\n```"
    return body


# ──────────────────────────────────────────────────────────────────────────────
# INSTRUCTION FILE LOADER
# ──────────────────────────────────────────────────────────────────────────────

def load_instructions():
    """
    Load coding standards from:
      .github/copilot-instructions.md         → applies to all files
      .github/instructions/*.instructions.md  → path-scoped
    """
    instructions = []

    global_file = Path(".github/copilot-instructions.md")
    if global_file.exists():
        instructions.append({
            "name":    "copilot-instructions.md",
            "content": global_file.read_text(encoding="utf-8"),
            "applyTo": None,
        })

    inst_dir = Path(".github/instructions")
    if inst_dir.exists():
        for f in sorted(inst_dir.glob("*.instructions.md")):
            content  = f.read_text(encoding="utf-8")
            apply_to = _parse_apply_to(content)
            instructions.append({
                "name":    f.name,
                "content": content,
                "applyTo": apply_to,
            })

    return instructions


def _parse_apply_to(content):
    if not content.startswith("---"):
        return None
    for line in content.split("\n")[1:]:
        if line.strip() == "---":
            break
        if line.startswith("applyTo:"):
            return line.replace("applyTo:", "").strip().strip('"').strip("'")
    return None


def get_applicable_instructions(filename, instructions):
    applicable = []
    for inst in instructions:
        if inst["applyTo"] is None:
            applicable.append(inst["content"])
            continue
        for pattern in [p.strip() for p in inst["applyTo"].split(",")]:
            if fnmatch.fnmatch(filename, pattern) or fnmatch.fnmatch(Path(filename).name, pattern):
                applicable.append(inst["content"])
                break
    return applicable


# ──────────────────────────────────────────────────────────────────────────────
# GITHUB MODELS AI REVIEW
# ──────────────────────────────────────────────────────────────────────────────

def review_file_with_github_models(filename, file_content, patch, instructions_list):
    """
    Calls GitHub Models API using the built-in GITHUB_TOKEN.
    No external API key required — works with GitHub Copilot licence.
    """
    # GitHub Models uses the OpenAI-compatible SDK with a custom endpoint
    client = OpenAI(
        base_url=GITHUB_MODELS_ENDPOINT,
        api_key=GITHUB_TOKEN,    # ← GITHUB_TOKEN, not an Anthropic or OpenAI key
    )

    standards = "\n\n---\n\n".join(instructions_list) if instructions_list else "Apply general Salesforce Apex best practices."

    prompt = f"""You are the Amadeus Hospitality Apex Code Review Agent.

Review the Salesforce Apex code below STRICTLY against these Amadeus Hospitality coding standards:

==========================================================
AMADEUS HOSPITALITY APEX CODING STANDARDS
==========================================================
{standards}

==========================================================
FILE: {filename}
==========================================================

GIT DIFF (what changed in this PR):
{patch or "No patch — reviewing full file."}

FULL FILE CONTENT:
{file_content or "Content unavailable."}

==========================================================
YOUR TASK
==========================================================
1. Check EVERY rule: naming conventions, description headers,
   bypass switches, trigger structure, no ternary operators,
   curly brackets on all if statements, error logging classes,
   test class rules (NI_TestClassData, @testSetup, assertions).
2. Report EVERY violation found, even minor ones.
3. Provide the exact line number in the file for each violation.
4. If NO violations exist, return an empty array: []

Return ONLY a valid JSON array — no markdown fences, no explanation:
[
  {{
    "line": <integer or null>,
    "severity": "error" | "warning" | "suggestion",
    "rule": "<short rule name>",
    "message": "<what is wrong and why>",
    "fix": "<corrected code snippet, or empty string>"
  }}
]"""

    response = client.chat.completions.create(
        model=AI_MODEL,
        messages=[
            {
                "role": "system",
                "content": (
                    "You are a strict Salesforce Apex code reviewer for Amadeus Hospitality. "
                    "You enforce coding standards precisely and return only valid JSON arrays."
                ),
            },
            {"role": "user", "content": prompt},
        ],
        temperature=0.1,   # Low temperature = consistent, deterministic reviews
        max_tokens=4096,
    )

    raw = response.choices[0].message.content.strip()

    # Strip accidental markdown fences
    if raw.startswith("```"):
        parts = raw.split("```")
        raw = parts[1] if len(parts) > 1 else raw
        if raw.startswith("json"):
            raw = raw[4:].strip()

    try:
        result = json.loads(raw)
        return result if isinstance(result, list) else []
    except json.JSONDecodeError as e:
        print(f"⚠️  JSON parse error for {filename}: {e}")
        return []


# ──────────────────────────────────────────────────────────────────────────────
# DIFF LINE PARSER
# ──────────────────────────────────────────────────────────────────────────────

def get_diff_lines(patch):
    """Return the set of new-file line numbers present in this diff patch."""
    diff_lines, current_line = set(), 0
    if not patch:
        return diff_lines
    for line in patch.split("\n"):
        if line.startswith("@@"):
            try:
                new_info     = line.split("+")[1].split("@@")[0].strip()
                current_line = int(new_info.split(",")[0])
            except Exception:
                pass
        elif line.startswith("+") and not line.startswith("+++"):
            diff_lines.add(current_line)
            current_line += 1
        elif not line.startswith("-"):
            current_line += 1
    return diff_lines


# ──────────────────────────────────────────────────────────────────────────────
# REVIEW SUMMARY BUILDER
# ──────────────────────────────────────────────────────────────────────────────

def build_review_summary(apex_files, all_violations):
    total       = len(all_violations)
    errors      = sum(1 for v in all_violations if v.get("severity") == "error")
    warnings    = sum(1 for v in all_violations if v.get("severity") == "warning")
    suggestions = sum(1 for v in all_violations if v.get("severity") == "suggestion")

    if total == 0:
        status = "✅ **All files comply with Amadeus Hospitality Apex Development Standards!**"
        verdict = "PASSED ✅"
    elif errors > 0:
        status  = f"❌ **{errors} error(s) must be fixed before merging.**"
        verdict = "FAILED ❌"
    else:
        status  = f"⚠️ **{warnings} warning(s) found — please review before merging.**"
        verdict = "WARNINGS ⚠️"

    rows = ""
    for filename, violations in apex_files.items():
        err  = sum(1 for v in violations if v.get("severity") == "error")
        warn = sum(1 for v in violations if v.get("severity") == "warning")
        sugg = sum(1 for v in violations if v.get("severity") == "suggestion")
        icon = "✅" if not violations else ("🔴" if err else "🟡")
        rows += f"| {icon} `{Path(filename).name}` | {err} | {warn} | {sugg} |\n"

    run_url = f"{GITHUB_SERVER_URL}/{REPO}/actions/runs/{GITHUB_RUN_ID}"

    return f"""## 🔍 Amadeus Apex Code Review — {verdict}

{status}

### 📊 Summary

| Files Reviewed | 🔴 Errors | 🟡 Warnings | 🔵 Suggestions | Total |
|---|---|---|---|---|
| {len(apex_files)} | {errors} | {warnings} | {suggestions} | {total} |

### 📁 File Breakdown

| File | 🔴 Errors | 🟡 Warnings | 🔵 Suggestions |
|---|---|---|---|
{rows}
### 📋 Standards Applied
- Naming Conventions (`AH_`, `INTGR_`, `_TriggerHandler`, `_Test`, `_Batch`, `_Schedule`)
- Description Header Block on every class & trigger
- Trigger Structure (one event per trigger, handler-only pattern)
- Bypass Switch (`NI_TriggerBypassSwitches__c`)
- Code Style (no ternary operators, always curly brackets, nested else)
- Error Logging (`NI_Error_Logger`, `DTS_Integration_Logger`)
- Test Class Rules (`@testSetup`, `NI_TestClassData`, 80%+ coverage)

---
*🤖 Amadeus Apex Review Agent · Powered by [GitHub Models]({GITHUB_MODELS_ENDPOINT}) · [View Run]({run_url})*
*🔑 Uses built-in `GITHUB_TOKEN` — no external API key required*
"""


# ──────────────────────────────────────────────────────────────────────────────
# MAIN
# ──────────────────────────────────────────────────────────────────────────────

def main():
    print(f"🚀 Amadeus Apex Review Agent — PR #{PR_NUMBER} | {REPO}")
    print(f"🤖 AI Model : {AI_MODEL} via GitHub Models")
    print(f"🔑 Auth     : GITHUB_TOKEN (built-in — no external key needed)")
    print("=" * 60)

    # 1. Load coding standards
    instructions = load_instructions()
    print(f"\n📚 Loaded {len(instructions)} instruction file(s):")
    for i in instructions:
        print(f"   - {i['name']}  →  applyTo: {i['applyTo'] or 'all files'}")

    # 2. Get changed files
    pr_files = get_pr_files()
    apex_files_list = [
        f for f in pr_files
        if f["filename"].endswith(APEX_EXTENSIONS)
        and f.get("status") != "removed"
    ]
    print(f"\n📂 Total changed files : {len(pr_files)}")
    print(f"⚡ Apex files to review: {len(apex_files_list)}")

    if not apex_files_list:
        post_pr_comment(
            "## 🔍 Amadeus Apex Code Review\n\n"
            "✅ No Salesforce Apex files (`.cls`, `.trigger`) found in this PR — nothing to review.\n\n"
            "> *Amadeus Apex Code Review Agent · GitHub Models*"
        )
        print("No Apex files found — exiting.")
        return

    # 3. Review each file
    all_violations   = []
    per_file_results = {}

    for file_info in apex_files_list:
        filename     = file_info["filename"]
        patch        = file_info.get("patch", "")
        raw_url      = file_info.get("raw_url", "")

        print(f"\n🔎 Reviewing: {filename}")

        applicable   = get_applicable_instructions(filename, instructions)
        file_content = get_file_content(raw_url)
        diff_lines   = get_diff_lines(patch)

        violations = review_file_with_github_models(filename, file_content, patch, applicable)
        print(f"   Issues found: {len(violations)}")

        for v in violations:
            v["path"] = filename
            # Only post inline if the line is in the diff range
            if v.get("line") and v["line"] not in diff_lines:
                v["line"] = None
            all_violations.append(v)

        per_file_results[filename] = violations

    # 4. Post the review
    print(f"\n📝 Posting review — {len(all_violations)} total issue(s)")
    summary         = build_review_summary(per_file_results, all_violations)
    inline_comments = [v for v in all_violations if v.get("line")]

    post_pr_review(summary, inline_comments)
    print("✅ Review posted successfully!")
    print("=" * 60)


if __name__ == "__main__":
    main()
