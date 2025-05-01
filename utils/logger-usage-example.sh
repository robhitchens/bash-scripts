# NOTE: using alias within a bash script doesn't seem to work as I would think
# alias log='bash ~/projects/bash-scripts/utils/logger.sh'

#function log { bash ~/projects/bash-scripts/utils/logger.sh "$@"; }
source ~/projects/bash-scripts/utils/logger.sh

log info "some info"
log warn "some warning"
log error "some error"
log debug "some debug"
log trace "some trace"

# Set logLevel globally
setLogLevel trace

log info "some info again"
log warn "some warning again"
log error "some error again"
log debug "some debug again"
log trace "some trace again"

# FIXME: need to figure out way to encapsulate variables in bash.
echo "$_loggingLevel"
echo "$_logLevels"
