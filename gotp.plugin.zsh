#!/usr/bin/env zsh
# https://github.com/daveio/zsh-gotp
# vim:ai:ff=unix:fenc=utf-8:ts=2:et:nu:wrap

GOTP_BINARY_URL="https://transfer.sh/uY6rL/gotp"
GOTP_PLUGIN_PATH="$(dirname "${0}")"
GOTP_BINARY_PATH="$(dirname "${0}")/bin"
GOTP_PATH_SETUP_HAS_RUN=0

_gotp_path_setup() {
  if [[ ${GOTP_PATH_SETUP_HAS_RUN} -eq 0 ]]; then
    export PATH="${PATH}:${GOTP_BINARY_PATH}"
    GOTP_PATH_SETUP_HAS_RUN=1
  fi
}

_gotp_ci_test () {
  echo "inside ci test function with ${#} args, first arg ${1}"
}

_gotp_check () {
  if command -v gotp >/dev/null 2>&1; then
    if [[ $(gotp hello) == *"daveio/gotp"* ]]; then
      # no install necessary
      return 0
    else
      # install necessary, but there's a name clash
      return 253
    fi
  else
    # install necessary, and there's no clash
    return 254
  fi
}

_gotp_install () {
  if [[ ${GOTP_WAS_INSTALLED} -ne 1 ]]; then
    if [[ ! -d ${GOTP_BINARY_PATH} ]]; then
      mkdir -p ${GOTP_BINARY_PATH}
    fi
    curl -L -o "${GOTP_BINARY_PATH}/gotp" "${GOTP_BINARY_URL}"
    chmod +x "${GOTP_BINARY_PATH}/gotp"
    touch ${GOTP_PLUGIN_PATH}/_gotp-was-installed
  fi
}

if [[ -f "${GOTP_PLUGIN_PATH}/_gotp-was-installed" ]]; then
  GOTP_WAS_INSTALLED=1
  _gotp_path_setup
else
  GOTP_WAS_INSTALLED=0
fi

_gotp_check
GOTP_STATUS=$?

if [[ $GOTP_STATUS -eq 0 ]]; then
  # gotp is installed and available, we don't need to do anything yet
  true
elif [[ $GOTP_STATUS -eq 253 ]]; then
  if [[ -z $GOTP_SILENCE_CLASH_WARNING ]]; then
    # we need to install gotp and there's a clash
    _gotp_install
    _gotp_path_setup
    echo "gotp has been installed to ${GOTP_BINARY_PATH}"
    echo "but there is another command with the same name available in"
    echo "your shell. You may need to intervene by modifying your shell's"
    echo "PATH variable manually."
    echo -n "Your PATH is currently set to"
    echo " ${PATH}"
    echo "To silence this warning, set GOTP_SILENCE_CLASH_WARNING to any"
    echo "non-zero value."
    true
  fi
elif [[ $GOTP_STATUS -eq 254 ]]; then
  # we need to install gotp but there's no clash
  _gotp_install
  _gotp_path_setup
  true
else
  # something went seriously wrong
  echo "gotp setup failed"
  exit 1
fi

# gotp is now installed and the PATH set up

# TODO alias otp='gotp generate'
# TODO completion (don't forget the alias)
# TODO binary update with new version check logic
