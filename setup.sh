# mv all files that start with .git to .git_distro

# Get absolute path to this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

mv $SCRIPT_DIR/.git $SCRIPT_DIR/.git_distro
mv $SCRIPT_DIR/.github $SCRIPT_DIR/.github_distro
mv $SCRIPT_DIR/.gitignore $SCRIPT_DIR/.gitignore_distro

git clone https://github.com/comfyanonymous/ComfyUI $SCRIPT_DIR/ComfyUI
mv $SCRIPT_DIR/ComfyUI/* $SCRIPT_DIR/
rm -rf $SCRIPT_DIR/ComfyUI

rm -rf $SCRIPT_DIR/.git*

mv $SCRIPT_DIR/.git_distro $SCRIPT_DIR/.git
mv $SCRIPT_DIR/.github_distro $SCRIPT_DIR/.github
mv $SCRIPT_DIR/.gitignore_distro $SCRIPT_DIR/.gitignore

target_dir="$SCRIPT_DIR/custom_nodes"
while IFS= read -r repo_url; do
    if [ ! -z "$repo_url" ]; then
        repo_name=$(basename "$repo_url" .git)
        repo_target_dir="$target_dir/$repo_name"
        echo "Cloning $repo_url into $repo_target_dir"
        git clone "$repo_url" "$repo_target_dir" --recursive
    fi
done < "$SCRIPT_DIR/custom_node_repo_urls.txt"

pip install -r $SCRIPT_DIR/requirements.txt

# Replace line "import manager_core as core" in custom_nodes/ComfyUI-Manager/glob/manager_server.py with "from . import manager_core as core"
sed -i 's/^import manager_core as core/from . import manager_core as core/' $SCRIPT_DIR/custom_nodes/ComfyUI-Manager/glob/manager_server.py

# After the line if __name__ == "__main__": in main.py, add the following lines:
# import os
# os.system("python install_models.py")

sed -i '/if __name__ == "__main__":/a import os\nos.system("python install_models.py")' $SCRIPT_DIR/main.py