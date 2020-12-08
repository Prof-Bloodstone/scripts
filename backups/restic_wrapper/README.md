# Resticly

A simple wrapper around restic backup tool.
Copy the executable into somewhere on your path and then run `resticly --help`.
If you just need it for your user,
there's a good chance that `~/.local/bin` is in PATH.

All commands you run, appart from `--help`,
are passed into `restic` after loading additional variables from your config file.

Alternatively, instead of using `restic`, it'll run your `wrapper` with all the arguments.

This lets you setup pre/post backup actions easily.

## Usage

If you create your config called `example`,
create directory `~/.config/resticly/example`.

Then, create file called `env` in that directory
and put your restic configuration variables in it.

```sh
# vim: ft=bash
# shellcheck disable=SC2039,SC2034
declare -gxr RESTIC_PASSWORD='pass1234'
declare -gxr RESTIC_REPOSITORY='rclone:example:mybackups/'
declare -gxr RCLONE_CONFIG_EXAMPLE_TYPE=ftp
declare -gxr RCLONE_CONFIG_EXAMPLE_HOST='192.168.0.50'
declare -gxr RCLONE_CONFIG_EXAMPLE_USER=myuser
declare -gxr RCLONE_CONFIG_EXAMPLE_PASS='cOhEvF46sGkbwu_Nlk1KrcDpkNxrkPKSTFXp_H6HHEc' # Obscured, see rclone obscure

declare -gr backup_args=(
  "${HOME}"
  --exclude "${HOME}/Downloads/"
)
declare -gr forget_args=(
  --keep-hourly 8
  --keep-daily 16
  --keep-weekly 10
  --keep-monthly 12
  --keep-yearly 3
)
```

NOTE: The file is loaded from within a function,
and so if you'll use `declare`,
you need to explicitely pass `-g` flag to make the variables global.
This is not an issue when using simple `export`s :)

## Automatic usage

There's sample systemd services and timers provided.
For installation as your current user, copy them to `~/.config/systemd/user/`.

Then, to start the backup timer,
run `systemctl --user enable --now resticly-backup@example.timer`.
This will use your `example` configuration and run backup and check using it.

## Wrapper

If `~/.config/resticly/example/wrapper` exists and is an executable file,
then it'll be passed the arguments to run instead of restic.

This way, you can check what action is to be executed by checking first argument.
