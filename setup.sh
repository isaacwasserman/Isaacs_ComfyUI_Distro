#!/bin/bash

# Save the original directory
original_dir=$(pwd)

# Change to the directory containing this script
script_dir=$(dirname "$(realpath "$0")")
cd "$script_dir" || exit

# Backup existing directories and files
# mv .git .git_distro
# mv .github .github_distro
# mv .gitignore .gitignore_distro

# Clone the repository and move its contents
git clone https://github.com/comfyanonymous/ComfyUI
find ComfyUI -type f -exec bash -c '
  for file; do
    dest="./$(basename "$file")"
    if [ -e "$dest" ]; then
      echo "File $dest already exists. Skipping."
    else
      mv "$file" "$dest"
    fi
  done
' bash {} +
rm -rf ComfyUI

# Clean up old git files
rm -rf .git*

# Restore original directories and files
# mv .git_distro .git
# mv .github_distro .github
# mv .gitignore_distro .gitignore

# Clone repositories listed in custom_node_repo_urls.txt
target_dir="custom_nodes"
while IFS= read -r repo_url; do
    if [ ! -z "$repo_url" ]; then
        repo_name=$(basename "$repo_url" .git)
        repo_target_dir="$target_dir/$repo_name"
        echo "Cloning $repo_url into $repo_target_dir"
        git clone "$repo_url" "$repo_target_dir" --recursive
    fi
done < "custom_node_repo_urls.txt"

# Install requirements
pip install -r requirements.txt

# Modify the import statement in manager_server.py
sed -i 's/^import manager_core as core/from . import manager_core as core/' custom_nodes/ComfyUI-Manager/glob/manager_server.py

# Add lines after if __name__ == "__main__": in main.py
sed -i '/if __name__ == "__main__":/a\n     import os\n    os.system("python install_models.py")' main.py

# Return to the original directory
cd "$original_dir" || exit
