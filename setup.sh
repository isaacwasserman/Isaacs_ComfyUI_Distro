#!/bin/bash

# Save the original directory
original_dir=$(pwd)

# Change to the directory containing this script
script_dir=$(dirname "$(realpath "$0")")
cd "$script_dir" || exit

# Backup existing directories and files
mkdir distro_git
mv .git distro_git/.git
mv .github distro_git/.github
mv .gitignore distro_git/.gitignore

# Clone the repository and move its contents
git clone https://github.com/comfyanonymous/ComfyUI
mv ComfyUI/* .
rm -rf ComfyUI

# Clean up old git files
rm -rf .git*

# Restore original directories and files
mv distro_git/.git .
mv distro_git/.github .
mv distro_git/.gitignore .
rm -rf distro_git

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
sed -i.bak '/^import manager_core as core$/s|^import manager_core as core|from . import manager_core as core|' custom_nodes/ComfyUI-Manager/glob/manager_server.py

# Check in main.py contains the string "install_models.py", if not, append it
if grep -q "# install_models.py" main.py; then
    # If the comment is found, do nothing
    echo "Comment found. No action needed."
else
    # If the comment is not found, prepend install_models.py to main.py
    # Create a temporary file
    temp_file=$(mktemp)

    # Concatenate install_models.py and main.py into the temporary file
    cat install_models.py main.py > "$temp_file"

    # Move the temporary file to replace the original main.py
    mv "$temp_file" main.py

    echo "install_models.py has been prepended to main.py."
fi

# Return to the original directory
cd "$original_dir" || exit
