# Automatic NixOS upgrades (modules/server/system.nix) requires updating
# flake.lock in the repository periodically. This repository is hosted on
# Gitea, which doesn't have good support for CI. Instead, this Containerfile
# is run on a server. This requires a Gitea access token[1] with repository
# read/write permissions. Note that we must use an account-wide access token to
# be able to clone through HTTPS (and utilise certificates rather than blindly
# trusting SSH keys), as repository deploy keys can only be used through
# SSH. The token should be passed as the GIT_PASSWORD environment variable.
# [1] https://git.caspervk.net/user/settings/applications

FROM nixos/nix:latest

CMD git clone https://caspervk:$GIT_PASSWORD@git.caspervk.net/caspervk/nixos.git && \
    cd nixos/ && \
    git config user.email "snowflake@caspervk.net" && \
    git config user.name "snowflake" && \
    # store in /dev/shm tmpfs to avoid an ever-growing nix store in the container
    nix --extra-experimental-features nix-command --extra-experimental-features flakes flake update --commit-lock-file --store /dev/shm && \
    git push && \
    cd .. && \
    rm -rf nixos/ && \
    sleep 7d  # Run again in a week. Requires `restart: unless-stopped`
