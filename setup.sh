#!/bin/bash

echo "⚙️  Installing development tools for Mac"
echo "----------------------------------------"

# Executing configs
echo "🍺 Install Homebrew? [Y/n] "
read yn
if [ "$yn" != "n" ]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "📦 Install NVM? [Y/n] "
read yn
if [ "$yn" != "n" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
fi

echo "🟢 Install the latest Node.js version with NVM? [Y/n] "
read yn
if [ "$yn" != "n" ]; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  nvm install --lts
  echo "✅ Node.js installed: $(node -v)"
fi

echo "🐙 Install GitHub CLI (gh)? [Y/n] "
read yn
if [ "$yn" != "n" ]; then
  brew install gh
  echo "✅ GitHub CLI installed: $(gh --version | head -n 1)"
fi

echo "🔑 Log in with GitHub CLI now? [Y/n] "
read yn
if [ "$yn" != "n" ]; then
  gh auth login
fi

echo "🔧 Install jq (JSON processor)? [Y/n] "
read yn
if [ "$yn" != "n" ]; then
  brew install jq
  echo "✅ jq installed: $(jq --version)"
fi

echo "📝 Configure ~/.gitconfig? [Y/n] "
read yn
if [ "$yn" != "n" ]; then
  echo "👤 Enter your name for Git: "
  read git_user
  echo "📧 Enter your email for Git: "
  read git_email

  echo ""
  echo "➡️  Git will be configured with:"
  echo "   Name:  $git_user"
  echo "   Email: $git_email"
  echo ""

  echo "Continue? [Y/n]: "
  read confirm
  if [ "$confirm" = "n" ] || [ "$confirm" = "N" ]; then
    echo "❌ Cancelled by user."
    exit 1
  fi

cat << EOF > ~/.gitconfig
[user]
  name = $git_user
  email = $git_email
[core]
  editor = code -w
[alias]
  co = checkout
  br = branch
  ci = commit
  st = status
  squash = !git fetch origin && git rebase -i origin/main
  pushf = !git push --set-upstream --force-with-lease origin \$(git rev-parse --abbrev-ref HEAD)
  logmain = log origin/main..HEAD --oneline
  pob = !git push origin \$(git rev-parse --abbrev-ref HEAD)
[url "ssh://git@github.com/"]
  insteadOf = https://github.com/
EOF

  echo "✅ ~/.gitconfig file generated successfully."

  echo "🔑 Do you want to generate a new SSH key for GitHub? [Y/n] "
  read genkey
  if [ "$genkey" != "n" ] && [ "$genkey" != "N" ]; then
    ssh-keygen -t ed25519 -C "$git_email" -f "$HOME/.ssh/id_ed25519" -N ""
    echo "✅ SSH key generated at $HOME/.ssh/id_ed25519."
    if command -v gh > /dev/null; then
      echo "🔗 Uploading SSH key to GitHub via gh CLI..."
      gh ssh-key add "$HOME/.ssh/id_ed25519.pub" --title "$(hostname)"
      echo "✅ SSH key uploaded to GitHub."
    else
      echo "⚠️  gh CLI not found. Please upload your SSH key manually."
    fi
  fi
fi

echo "Do you want to set your Git GLOBAL email? (Y/n)"
echo "→ This email will be used as your identity in ALL repositories unless a local email is set."
read set_global

if [[ "$set_global" == "y" ||  "$set_global" == "Y" ]]; then
  echo "Enter the GLOBAL email address you want to use:"
  read global_email_input
  if [[ -z "$global_email_input" ]]; then
    echo "Email cannot be empty. Skipping global config."
  else
    git config --global user.email "$global_email_input"
    echo "✓ Global Git email has been set to: $global_email_input"
  fi
else
  echo "Skipping global Git email configuration."
fi

echo ""
echo "Do you want to set your Git LOCAL email for this repository? (Y/n)"
echo "→ This email will only apply to the Git repository you're currently in: $(pwd)"
read set_local

if [[ "$set_local" == "y" || "$set_local" == "Y" ]]; then
  echo "Enter the LOCAL email address you want to use:"
  read local_email_input
  if [[ -z "$local_email_input" ]]; then
    echo "Email cannot be empty. Skipping local config."
  else
    git config user.email "$local_email_input"
    echo "✓ Local Git email has been set to: $local_email_input"
  fi
else
  echo "Skipping local Git email configuration."
fi

# Fetch current configuration
global_email=$(git config --global user.email 2>/dev/null)
local_email=$(git config --local user.email 2>/dev/null)

echo ""
echo "==================== Git Email Configuration Summary ===================="
echo "Global email: ${global_email:-<not set>}"
echo "  → Used by default in all repositories unless overridden locally."

echo "Local email: ${local_email:-<not set>}"
echo "  → Used only in this repository: $(pwd)"
echo "=========================================================================== "

echo "📂 Show hidden files in Finder? [Y/n] "
read yn
if [ "$yn" != "n" ]; then
  defaults write com.apple.finder AppleShowAllFiles true
  killall Finder
  echo "✅ Hidden files enabled in Finder."
fi

echo "📝 Configuring VS Code to disable enablePreview? [Y/n] "
read yn
if [[ $yn != "n" ]]; then
  VSCODE_SETTINGS="$HOME/Library/Application Support/Code/User/settings.json"
  mkdir -p "$(dirname \"$VSCODE_SETTINGS\")"
  if [ ! -f "$VSCODE_SETTINGS" ]; then
    echo '{
      "workbench.editor.enablePreview": false
    }' > "$VSCODE_SETTINGS"
    echo "✅ VS Code settings.json created with enablePreview disabled."
  else
    if grep -q '"workbench.editor.enablePreview"' "$VSCODE_SETTINGS"; then
      sed -i '' 's/"workbench.editor.enablePreview"[ ]*:[ ]*true/"workbench.editor.enablePreview": false/' "$VSCODE_SETTINGS"
      echo "✅ VS Code enablePreview updated to false."
    else
      TMPFILE=$(mktemp)
      awk 'BEGIN{found=0} /}/ && !found {print "  ,\"workbench.editor.enablePreview\": false"; found=1} {print}' "$VSCODE_SETTINGS" > "$TMPFILE" && mv "$TMPFILE" "$VSCODE_SETTINGS"
      echo "✅ VS Code enablePreview added to settings.json."
    fi
  fi
fi

echo "💻 Install Oh My Zsh? [Y/n] "
read yn
if [[ $yn != "n" ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

echo "📝 Configuring ~/.zshrc? [Y/n]"
read yn
if [[ $yn != "n" ]]; then
cat << 'EOF' >> "$HOME/.zshrc"
export NVM_DIR="$HOME/.nvm"

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"
  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")
    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

alias gitconfig="code ~/.gitconfig"
alias zshconfig="code ~/.zshrc"
setgitemail() {
  bash <(curl -fsSL https://raw.githubusercontent.com/silvanatrabalon/mysetup/main/gitemail.sh)
}

EOF

echo "✔️ Configuration added. To apply the changes, open a new terminal or run 'source ~/.zshrc' in zsh."
fi

# Finish
echo ""
echo "----------------------------------------"
echo "✅ Installation complete."
echo "🙌 Development environment ready!"