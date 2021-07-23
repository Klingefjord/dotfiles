#   ██ ██         ██        ██
#  ░██░░   █████ ░██       ░██
#  ░██ ██ ██░░░██░██      ██████  ██████
#  ░██░██░██  ░██░██████ ░░░██░  ██░░░░
#  ░██░██░░██████░██░░░██  ░██  ░░█████
#  ░██░██ ░░░░░██░██  ░██  ░██   ░░░░░██
#  ███░██  █████ ░██  ░██  ░░██  ██████
# ░░░ ░░  ░░░░░  ░░   ░░    ░░  ░░░░░░
#

PARBS_LIGHTS_OFFICE=4,8
PARBS_LIGHTS_BED=5,7
PARBS_LIGHTS_LIVING=1,2,6

# Wrapper for hue lights with no output.
function lights() {
	hue lights $@ &>/dev/null;
}

# Control office lights.
function office() {
	lights ${PARBS_LIGHTS_OFFICE} $@;
}

# Control bedroom lights.
function bed() {
	lights ${PARBS_LIGHTS_BED} $@;
}

# Control living room lights.
function living() {
	lights ${PARBS_LIGHTS_LIVING} $@;
}

# Flash an alert in the office.
function oalert() {
	office on;
	office ${1:-red};
	sleep 1;
	office white;
}