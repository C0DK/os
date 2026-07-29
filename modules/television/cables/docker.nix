{ user, ... }:
{
  home-manager.users.${user}.xdg.configFile = {
    "television/cable/docker-containers.toml" = {
      force = true;
      text = ''
        [metadata]
        name = "docker-containers"
        description = "List and manage Docker containers"
        requirements = ["docker", "jq"]

        [source]
        command = ["docker ps --format '{{.Names}}\t{{.Image}}\t{{.Status}}'", "docker ps -a --format '{{.Names}}\t{{.Image}}\t{{.Status}}'"]
        shell = "bash"
        display = "{split:\t:0} ({split:\t:2})"
        output = "{split:\t:0}"

        [preview]
        command = "docker inspect '{split:\t:0}' | jq -C '.[0] | {Name, State, Config: {Image: .Config.Image, Cmd: .Config.Cmd}, NetworkSettings: {IPAddress: .NetworkSettings.IPAddress}}'"

        [ui]
        layout = "portrait"

        [keybindings]
        ctrl-s = "actions:start"
        f2 = "actions:stop"
        ctrl-r = "actions:restart"
        ctrl-l = "actions:logs"
        ctrl-e = "actions:exec"
        ctrl-d = "actions:remove"

        [actions.start]
        description = "Start the selected container"
        command = "docker start '{split:\t:0}'"
        mode = "fork"

        [actions.stop]
        description = "Stop the selected container"
        command = "docker stop '{split:\t:0}'"
        mode = "fork"

        [actions.restart]
        description = "Restart the selected container"
        command = "docker restart '{split:\t:0}'"
        mode = "fork"

        [actions.logs]
        description = "Follow logs of the selected container"
        command = "docker logs -f '{split:\t:0}'"
        mode = "execute"

        [actions.exec]
        description = "Execute shell in the selected container"
        command = "docker exec -it '{split:\t:0}' /bin/sh"
        mode = "execute"

        [actions.remove]
        description = "Remove the selected container"
        command = "docker rm '{split:\t:0}'"
        mode = "execute"
      '';
    };

    "television/cable/docker-compose.toml" = {
      force = true;
      text = ''
        [metadata]
        name = "docker-compose"
        description = "Manage Docker Compose services"
        requirements = ["docker"]

        [source]
        command = "docker compose ps --format '{{.Name}}\t{{.Service}}\t{{.Status}}'"
        shell = "bash"
        display = "{split:\t:1} ({split:\t:2})"
        output = "{split:\t:1}"

        [preview]
        command = "docker compose logs --tail=30 --no-log-prefix '{split:\t:1}'"

        [actions.up]
        description = "Start the selected service"
        command = "docker compose up -d '{split:\t:1}'"
        mode = "fork"

        [actions.down]
        description = "Stop and remove the selected service"
        command = "docker compose down '{split:\t:1}'"
        mode = "fork"

        [actions.restart]
        description = "Restart the selected service"
        command = "docker compose restart '{split:\t:1}'"
        mode = "fork"

        [actions.logs]
        description = "Follow logs of the selected service"
        command = "docker compose logs -f '{split:\t:1}'"
        mode = "execute"
      '';
    };
  };
}
