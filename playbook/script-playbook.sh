
ansible -m copy -a "src=./ansible.txt dest=~/.gitignore" localhost

ansible -m apt -a "name=docker.io state=latest" localhost

ansible -m homebrew -a "name=jq state=latest" localhost
