# mv all files that start with .git to .git_distro

mv .git .git_distro
mv .github .github_distro
mv .gitignore .gitignore_distro

git clone https://github.com/comfyanonymous/ComfyUI
mv ComfyUI/* .
rm -rf ComfyUI

rm -rf .git*

mv .git_distro .git
mv .github_distro .github
mv .gitignore_distro .gitignore

target_dir="custom_nodes"
while IFS= read -r repo_url; do
    if [ ! -z "$repo_url" ]; then
        repo_name=$(basename "$repo_url" .git)
        repo_target_dir="$target_dir/$repo_name"
        echo "Cloning $repo_url into $repo_target_dir"
        git clone "$repo_url" "$repo_target_dir" --recursive
    fi
done < "custom_node_repo_urls.txt"

pip install -r requirements.txt

# Replace line "import manager_core as core" in custom_nodes/ComfyUI-Manager/glob/manager_server.py with "from . import manager_core as core"
sed -i 's/^import manager_core as core/from . import manager_core as core/' custom_nodes/ComfyUI-Manager/glob/manager_server.py

python install_models.py