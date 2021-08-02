#   ██                      ██      ██               ██
#  ░██              ██   ██░██     ░░               ░██
#  ░██  ██  █████  ░░██ ██ ░██      ██ ███████      ░██  ██████
#  ░██ ██  ██░░░██  ░░███  ░██████ ░██░░██░░░██  ██████ ██░░░░
#  ░████  ░███████   ░██   ░██░░░██░██ ░██  ░██ ██░░░██░░█████
#  ░██░██ ░██░░░░    ██    ░██  ░██░██ ░██  ░██░██  ░██ ░░░░░██
#  ░██░░██░░██████  ██     ░██████ ░██ ███  ░██░░██████ ██████
#  ░░  ░░  ░░░░░░  ░░      ░░░░░   ░░ ░░░   ░░  ░░░░░░ ░░░░░░
#

# ctrl + l → ls
bindkey -s '^l' 'exa -Flam --git --color-scale --icons'

# ctrl + s → g status
bindkey -s '^s' 'git status^M'

# crtl + a → git commit
bindkey -s '^a' 'git commit -m "'