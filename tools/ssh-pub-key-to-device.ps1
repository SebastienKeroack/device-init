# Ask SSH Hostname (artifal@artifal.ddns.net):
$SSH_DEST = Read-Host -Prompt "SSH Hostname"
$SSH_PORT = Read-Host -Prompt "SSH port"

# Export the public key to the destination
Get-Content "$env:USERPROFILE\.ssh\id_ed25519.pub" | ssh -p ${SSH_PORT} ${SSH_DEST} "cat >> .ssh/authorized_keys"