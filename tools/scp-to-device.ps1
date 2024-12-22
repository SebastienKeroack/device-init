# Ask SSH hostname (artifal@artifal.ddns.net):
$SSH_DEST = Read-Host -Prompt "SSH dest"
$SSH_PORT = Read-Host -Prompt "SSH port"

# Upload the repository to the destination
ssh -p ${SSH_PORT} ${SSH_DEST} "mkdir -p device-init"
scp -P ${SSH_PORT} "device-init/.gitignore" "${SSH_DEST}:device-init/.gitignore"
scp -P ${SSH_PORT} "device-init/LICENSE" "${SSH_DEST}:device-init/LICENSE"
scp -P ${SSH_PORT} -r "device-init/tools" "${SSH_DEST}:device-init/tools"
scp -P ${SSH_PORT} -r "device-init/ubuntu" "${SSH_DEST}:device-init/ubuntu"