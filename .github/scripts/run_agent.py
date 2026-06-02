import os
import sys
import glob
import argparse
import anthropic
import requests
 
def load_agent(agent_dir=".github/agents"):
    """Reads all .md files in the agents folder and combines them."""
    agent_files = glob.glob(f"{agent_dir}/**/*.md", recursive=True)
    if not agent_files:
        print(f"No agent files found in {agent_dir}")
        sys.exit(1)
 
    instructions = []
    for path in agent_files:
        with open(path) as f:
            content = f.read()
            # Strip Claude agent frontmatter (--- name: ... ---)
            if content.startswith("---"):
                parts = content.split("---", 2)
                content = parts[2].strip() if len(parts) >= 3 else content
            instructions.append(content)
        print(f"Loaded agent: {path}")
 
    return "\n\n---\n\n".join(instructions)
 
def get_files(args):
    """Returns list of .cls files to process."""
    if args.all:
        with open("all_files.txt") as f:
            return [line.strip() for line in f if line.strip()]
    else:
        changed = os.environ.get("CHANGED_FILES", "")
        return [f.strip() for f in changed.split() if f.strip().endswith(".cls")]
 
def run_agent(instructions, class_content, filename):
    client = anthropic.Anthropic(api_key=os.environ["ANTHROPIC_API_KEY"])
    response = client.messages.create(
        model="claude-sonnet-4-20250514",
        max_tokens=4096,
        messages=[
            {
                "role": "user",
                "content": (
                    f"{instructions}\n\n"
                    f"Here is the Apex class (`{filename}`):\n\n"
                    f"```apex\n{class_content}\n```"
                )
            }
        ]
    )
    return response.content[0].text
 
def post_pr_comment(repo, pr_number, body):
    url = f"https://api.github.com/repos/{repo}/issues/{pr_number}/comments"
    headers = {
        "Authorization": f"Bearer {os.environ['GH_TOKEN']}",
        "Accept": "application/vnd.github+json"
    }
    r = requests.post(url, json={"body": body}, headers=headers)
    r.raise_for_status()
 
def write_summary(filename, docs):
    """Falls back to writing a file when there's no PR (manual run)."""
    out_path = filename.replace(".cls", "_docs.md")
    with open(out_path, "w") as f:
        f.write(f"# Docs: {filename}\n\n{docs}")
    print(f"Written to {out_path}")
 
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--all", action="store_true",
                        help="Process all .cls files instead of changed only")
    args = parser.parse_args()
 
    instructions = load_agent()
    files = get_files(args)
    pr_number = os.environ.get("PR_NUMBER", "").strip()
    repo = os.environ.get("REPO", "")
 
    if not files:
        print("No .cls files to process.")
        return
 
    for filepath in files:
        if not os.path.exists(filepath):
            print(f"Skipping missing file: {filepath}")
            continue
 
        print(f"Processing: {filepath}")
        with open(filepath) as f:
            class_content = f.read()
 
        docs = run_agent(instructions, class_content, filepath)
        comment = f"## 📄 Apex Docs — `{filepath}`\n\n{docs}"
 
        if pr_number:
            post_pr_comment(repo, pr_number, comment)
            print(f"Posted PR comment for {filepath}")
        else:
            write_summary(filepath, docs)
 
if __name__ == "__main__":
    main()
