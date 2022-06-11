

if [[ "$#" -eq 1 ]]; then
    tput setaf 1; echo "ERROR: To execute script, use VSCODE Tasks: [CTRL+SHIFT+P -> Tasks: Run Tasks -> $1]."
    read -p "Press <Enter> to close this window"
    exit 1
fi
