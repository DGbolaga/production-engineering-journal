#!/usr/bin/env bash
set -euo pipefail

OBSIDIAN_DIR="$HOME/Documents/300 Day SYS ENG in Rust Obsidian Vault/100 Day Challenge (Production Engineering)"
JOURNAL_DIR="$HOME/production-engineering-journal"
ASSETS_DIR="$JOURNAL_DIR/assets"

mkdir -p "$ASSETS_DIR"

# Process a single markdown file: copy images to assets/, rewrite ![[...]] syntax
process_file() {
    local src="$1"
    local dest="$2"
    local assets_rel="$3"  # relative path from dest file to assets/ dir

    local content
    content=$(cat "$src")

    # Find all ![[filename]] references and process them
    while IFS= read -r image_name; do
        # Search for the image in vault root and Images/ subdirectory
        local found=""
        local search_paths=(
            "$HOME/Documents/300 Day SYS ENG in Rust Obsidian Vault/$image_name"
            "$HOME/Documents/300 Day SYS ENG in Rust Obsidian Vault/Images/$image_name"
            "$OBSIDIAN_DIR/$image_name"
        )
        for path in "${search_paths[@]}"; do
            if [[ -f "$path" ]]; then
                found="$path"
                break
            fi
        done

        if [[ -n "$found" ]]; then
            cp "$found" "$ASSETS_DIR/$image_name"
            # Replace ![[image_name]] with standard markdown image syntax
            # Escape special characters in image_name for sed
            local escaped_name
            escaped_name=$(printf '%s\n' "$image_name" | sed 's/[[\.*^$()+?{|]/\\&/g')
            content=$(printf '%s' "$content" | sed "s|!\[\[$escaped_name\]\]|![$image_name]($assets_rel/$image_name)|g")
        else
            echo "  WARNING: image not found: $image_name"
        fi
    done < <(printf '%s' "$content" | grep -oP '(?<=!\[\[)[^\]]+(?=\]\])' || true)

    mkdir -p "$(dirname "$dest")"
    printf '%s' "$content" > "$dest"
}

echo "Syncing daily logs..."
while IFS= read -r -d '' src; do
    filename=$(basename "$src")
    # Extract day number from "Day N - YYYY-MM-DD.md"
    if [[ "$filename" =~ ^Day[[:space:]]([0-9]+)[[:space:]]-[[:space:]].*\.md$ ]]; then
        day_num="${BASH_REMATCH[1]}"
        dest="$JOURNAL_DIR/logs/day-$day_num.md"
        echo "  $filename -> logs/day-$day_num.md"
        process_file "$src" "$dest" "../assets"
    fi
done < <(find "$OBSIDIAN_DIR" -maxdepth 1 -name "Day *.md" -print0)

echo "Syncing phase notes..."
while IFS= read -r -d '' src; do
    # Strip the Obsidian base path and "Phases/" prefix to get the relative path
    rel="${src#"$OBSIDIAN_DIR/Phases/"}"
    # Convert to lowercase for the destination (phase-1/notes/...)
    dest_rel=$(echo "$rel" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')
    dest="$JOURNAL_DIR/$dest_rel"

    # Compute depth of the destination file to find the right relative path to assets/
    # e.g. phase-1/notes/file.md is depth 2, so assets_rel = ../../assets
    depth=$(echo "$dest_rel" | tr -cd '/' | wc -c)
    assets_rel=""
    for ((i=0; i<depth; i++)); do
        assets_rel="../$assets_rel"
    done
    assets_rel="${assets_rel}assets"

    echo "  $rel -> $dest_rel"
    process_file "$src" "$dest" "$assets_rel"
done < <(find "$OBSIDIAN_DIR/Phases" -name "*.md" -print0)

echo ""
cd "$JOURNAL_DIR"
git add -A

if git diff --cached --quiet; then
    echo "Nothing new to commit."
    exit 0
fi

echo "--- Staged changes ---"
git diff --cached --stat
echo ""
git diff --cached
echo ""
read -rp "Commit and push? [y/N]: " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    today=$(date +%Y-%m-%d)
    git commit -m "Sync from Obsidian - $today"
    git push
    echo "Done — pushed to GitHub."
else
    echo "Aborted. Changes are staged but not committed. Run 'git reset HEAD' to unstage."
fi
