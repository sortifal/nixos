# Daily "unlocked time" tracking.
#
# A user service samples every `interval` seconds and credits the elapsed time
# to today's file when no hyprlock is running. Sleeping or powered-off time is
# never counted: after a suspend the next sample sees a gap much larger than
# the interval and drops it instead of crediting the whole night.
#
# Samples are kept as one file of seconds per day in
# ~/.local/share/worktime/YYYY-MM-DD; `worktime` reads them back.
{ pkgs, lib, ... }:

let
  interval = 30;

  tracker = pkgs.writeShellApplication {
    name = "worktime-tracker";
    runtimeInputs = [ pkgs.coreutils pkgs.procps ];
    text = ''
      dir="$HOME/.local/share/worktime"
      mkdir -p "$dir"
      last=$(date +%s)
      while sleep ${toString interval}; do
        now=$(date +%s)
        delta=$((now - last))
        last=$now
        # A gap this far over the interval means the machine was suspended.
        if [ "$delta" -gt ${toString (interval * 3)} ]; then continue; fi
        if pidof hyprlock >/dev/null; then continue; fi
        f="$dir/$(date +%F)"
        total=$(cat "$f" 2>/dev/null || echo 0)
        echo $((total + delta)) > "$f"
      done
    '';
  };

  summary = pkgs.writeShellApplication {
    name = "worktime";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      dir="$HOME/.local/share/worktime"

      fmt() { printf '%dh %02dm' $(($1 / 3600)) $(($1 % 3600 / 60)); }

      # One line per recorded day from $1 (YYYY-MM-DD) onwards, then a total.
      report() {
        since=$1
        sum=0
        for f in "$dir"/*; do
          [ -e "$f" ] || continue
          day=$(basename "$f")
          [[ "$day" < "$since" ]] && continue
          secs=$(cat "$f")
          sum=$((sum + secs))
          printf '%s  %s\n' "$day" "$(fmt "$secs")"
        done
        echo "total       $(fmt "$sum")"
      }

      case "''${1:-today}" in
        today) report "$(date +%F)" ;;
        week)  report "$(date -d '6 days ago' +%F)" ;;
        month) report "$(date +%Y-%m-01)" ;;
        all)   report 0000-00-00 ;;
        *)     echo "usage: worktime [today|week|month|all]"; exit 1 ;;
      esac
    '';
  };
in
{
  home.packages = [ summary ];

  systemd.user.services.worktime = {
    Unit = {
      Description = "Track daily unlocked time";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = lib.getExe tracker;
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
