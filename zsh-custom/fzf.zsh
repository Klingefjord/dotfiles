#    ████          ████
#   ░██░          ░██░
#  ██████ ██████ ██████
# ░░░██░ ░░░░██ ░░░██░
#   ░██     ██    ░██
#   ░██    ██     ░██
#   ░██   ██████  ░██
#   ░░   ░░░░░░   ░░
#

#########################################
# Checkout local branch                 #
#########################################
function co() {
	if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then return; fi

	local branches=$(git branch --color | grep -v HEAD | sed 's#.* ##' | sed 's#remotes/##')
	local target=$(fzf +s +m +e --ansi --preview-window 'right:60%' --preview 'git log --pretty=lo --no-merges --color --oneline --date=human {1} -- | head -200' <<< "$branches")

	git checkout "$@" "$(awk '{print $1}' <<< "$target")"
}

#########################################
# Tag new version                       #
#########################################
function gtag() {
	if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then return; fi

	local current=$(git describe --tags --abbrev=0 | sed 's#v##')
	local new=$(echo "$current" | awk -F '.' '{FS="."; OFS="."; $3++; print $0; $2++; $3=0; print $0; $1++; $2=0; print $0}' | fzf --height=5 --color=16 --border=none --info=hidden --header="Current Version: $current" --prompt="> " --print-query)

	print -z git tag -a "$new" -m \"Version "$new"\"
}


#########################################
# Composer run scripts                  #
#########################################
function comp() {
	if [ ! -f composer.json ]; then return; fi;

	composer run-script -l --no-ansi 2> /dev/null | cut -d' ' -f3- | sort | fzf --query="$1" --select-1 --height=20 --layout=reverse --cycle --prompt='' | cut -d' ' -f1 | xargs composer run-script
}

#########################################
# NPM run script     			        #
#########################################
function npmr() {
	if [ ! -f package.json ]; then return; fi;

	npm run-script --porcelain | sort | fzf --delimiter=" " --with-nth=1,2 | cut -d' ' -f1 | xargs npm run
}

#########################################
# SSH 								    #
#########################################
function ffh() {
	local host=$(history | rg --pcre2 '^(?= [\d]+  ssh )(.)+' | cut -d' ' -f5- | sort | uniq | fzf --query="$1" --select-1 --height=20 --layout=reverse --cycle --prompt='')

	if [ -n "$host" ]; then
		ssh "$host"
	fi
}

#########################################
# Bin 								    #
#########################################
function bin() {
	print -z $(command ls "$DOTFILES_PATH/bin" | fzf --query="$1" --select-1 --cycle --preview-window=top --preview 'bat --color=always --style=numbers "$DOTFILES_PATH/bin/"{}')" "
}

#########################################
# Bookmarks			       			    #
#########################################
function bookmarks() {
	# https://github.com/junegunn/fzf/wiki/Examples#bookmarks
	local bookmarks_path=~/Library/Application\ Support/Google/Chrome/Default/Bookmarks

	local jq_script='
		def ancestors: while(. | length >= 2; del(.[-1,-2]));
		. as $in | paths(.url?) as $key | $in | getpath($key) | {name,url, path: [$key[0:-2] | ancestors as $a | $in | getpath($a) | .name?] | reverse | join(" / ") } | .path + " / " + .name + "\t" + .url'

	jq -r "$jq_script" < "$bookmarks_path" | \
		sed -E $'s/(.*)\t(.*)/\\1\t\x1b[36m\\2\x1b[m/g' | \
		sed 's#Bookmarks Bar /##' | \
		fzf --ansi | \
		cut -d$'\t' -f2 | \
		xargs open
}

#########################################
# Launch app 						    #
#########################################
function app() {
	print -l /System/Applications/*.app /Applications/*.app | fzf \
	--query="$1" --select-1 --delimiter="Applications/" --with-nth=-1 --multi \
	--no-info --prompt='' --pointer=" →" --reverse --border=none --black --margin=2,20%,2,10% \
	--preview-window=right --preview='catimg -H "$FZF_PREVIEW_COLUMNS" "$(make-tmp-app-icon-preview {+})"' \
	--color="gutter:black,bg:black,pointer:cyan,fg+:cyan,fg+:bold,border:black" | xargs open
}

#########################################
# Run an alias                          #
#########################################
function falias() {
	local alias=$(alias | fzf \
	--query="$1" --select-1 --prompt="   alias: " \
	--color=dark --color='gutter:black,bg+:black,prompt:gray,info:black' \
	--preview-window=top:5,border-none \
	--preview 'alias=$(echo {1} | cut -d "=" -f1); command=$( echo {1} | cut -d "=" -f2 | cut -c 2-); alias="  $alias  ";command="  $command  ";space=$(( $FZF_PREVIEW_COLUMNS/9 ));
	printf "\e[90;100m%-${space}s\e[0m   \e[90;100m%-${space}s\e[0m\n\e[7;106;90m%-${space}s\e[0m \e[2m→ \e[0m\e[7;102;90m%-${space}s\e[0m\n\e[90;100m%-${space}s\e[0m   \e[90;100m%-${space}s\e[0m" $alias $command $alias $command $alias $command' | cut -d "=" -f1 )

	local command=$(which "$alias" | cut -d':' -f2 | cut -d ' ' -f4-)
	local cmdwidth=${#command}

	echo -e "\e[7;102;90m"
	printf "  %-${cmdwidth}s  \n" " "
	printf "  %-${cmdwidth}s  \n" $command
	printf "  %-${cmdwidth}s  \n" " "
	echo -e "\e[0m"

	print -z "$alias "
}

#########################################
# Pick an icon 						    #
#########################################
function icon-picker() {
	local current_dir=$(pwd)

	cd $HOME/Dropbox/Photos/Icons || return

 	icon=$(fd --type file --extension svg --extension png | \
	fzf --query="$1" -e --no-multi --border=none --filepath-word --pointer=" →" --prompt="    " \
	--color=16 --color="preview-bg:white,gutter:-1,border:-1,preview-fg:-1" \
	--preview-window left,26,border-rounded \
	--preview='echo -e "\n\n\n";catimg -w 50 $(make-tmp-image-preview {})')

	if [ -z "$icon" ]; then
		cd "$current_dir"
		return
	fi

	cp "$icon" "$HOME/Desktop/$(basename "$icon")"
	echo "$icon" | pbcopy
	echo "Copied path to clipboard. Copied image to desktop."

	cd "$current_dir"
}