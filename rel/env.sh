!/bin/sh

# # Sets and enables heart (recommended only in daemon mode)
# case $RELEASE_COMMAND in
#   daemon*)
#     HEART_COMMAND="$RELEASE_ROOT/bin/$RELEASE_NAME $RELEASE_COMMAND"
#     export HEART_COMMAND
#     export ELIXIR_ERL_OPTIONS="-heart"
#     ;;
#   *)
#     ;;
# esac

# # Set the release to load code on demand (interactive) instead of preloading (embedded).
# export RELEASE_MODE=interactive

# # Set the release to work across nodes.
# # RELEASE_DISTRIBUTION must be "sname" (local), "name" (distributed) or "none".
# export RELEASE_DISTRIBUTION=name
# export RELEASE_NODE=<%= @release.name %>

export SECRET_KEY_BASE=HGF1ekWu4VWXZDLby40lUOJFN2dufDptrfr3C1NwwvZFeWmFYxSvUIFTc9/A/Gt/
export DATABASE_URL=ecto://postgres:postgres@10.0.9.100/docker_rel_dev
 _build/prod/rel/docker_rel/bin/migrate
_build/prod/rel/docker_rel/bin/docker_rel start_iex