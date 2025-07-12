#!/bin/zsh

echo "Do you want to set your Git GLOBAL email? (yes/no)"
echo "→ This email will be used as your identity in ALL repositories unless a local email is set."
read set_global

if [[ "$set_global" == "yes" ]]; then
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
echo "Do you want to set your Git LOCAL email for this repository? (yes/no)"
echo "→ This email will only apply to the Git repository you're currently in: $(pwd)"
read set_local

if [[ "$set_local" == "yes" ]]; then
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
