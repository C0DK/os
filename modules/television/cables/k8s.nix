{ user, ... }:
{
  home-manager.users.${user}.xdg.configFile = {
    "television/cable/k8s-pods.toml" = {
      force = true;
      text = ''
        [metadata]
        name = "k8s-pods"
        description = "List and preview Pods in a Kubernetes Cluster"
        requirements = ["kubectl"]

        [source]
        command = [
          "kubectl get pods --no-headers -o custom-columns='NS:.metadata.namespace,NAME:.metadata.name' 2>/dev/null",
          "kubectl get pods --all-namespaces --no-headers -o custom-columns='NS:.metadata.namespace,NAME:.metadata.name' 2>/dev/null",
        ]
        shell = "bash"
        output = "{1}"

        [preview]
        command = "kubectl describe -n {0} pods/{1}"

        [ui.preview_panel]
        size = 60

        [keybindings]
        ctrl-d = "actions:delete"
        ctrl-e = "actions:exec"
        ctrl-l = "actions:logs"

        [actions.exec]
        description = "Execute shell inside the selected Pod"
        command = "kubectl exec -i -t -n {0} pods/{1} -- /bin/sh"
        mode = "execute"

        [actions.delete]
        description = "Delete the selected Pod"
        command = "kubectl delete -n {0} pods/{1}"
        mode = "execute"

        [actions.logs]
        description = "Follow logs of the selected Pod"
        command = "kubectl logs -f -n {0} pods/{1}"
        mode = "execute"
      '';
    };

    "television/cable/k8s-services.toml" = {
      force = true;
      text = ''
        [metadata]
        name = "k8s-services"
        description = "List and preview Services in a Kubernetes Cluster"
        requirements = ["kubectl"]

        [source]
        command = [
          "kubectl get services --no-headers -o custom-columns='NS:.metadata.namespace,NAME:.metadata.name' 2>/dev/null",
          "kubectl get services --all-namespaces --no-headers -o custom-columns='NS:.metadata.namespace,NAME:.metadata.name' 2>/dev/null",
        ]
        shell = "bash"
        output = "{1}"

        [preview]
        command = "kubectl describe -n {0} services/{1}"

        [ui.preview_panel]
        size = 60

        [keybindings]
        ctrl-d = "actions:delete"

        [actions.delete]
        description = "Delete the selected Service"
        command = "kubectl delete -n {0} services/{1}"
        mode = "execute"
      '';
    };

    "television/cable/k8s-deployments.toml" = {
      force = true;
      text = ''
        [metadata]
        name = "k8s-deployments"
        description = "List and preview Deployments in a Kubernetes Cluster"
        requirements = ["kubectl"]

        [source]
        command = [
          "kubectl get deployments --no-headers -o custom-columns='NS:.metadata.namespace,NAME:.metadata.name' 2>/dev/null",
          "kubectl get deployments --all-namespaces --no-headers -o custom-columns='NS:.metadata.namespace,NAME:.metadata.name' 2>/dev/null",
        ]
        shell = "bash"
        output = "{1}"

        [preview]
        command = "kubectl describe -n {0} deployments/{1}"

        [ui.preview_panel]
        size = 60

        [keybindings]
        ctrl-d = "actions:delete"

        [actions.delete]
        description = "Delete the selected Deployment"
        command = "kubectl delete -n {0} deployments/{1}"
        mode = "execute"
      '';
    };
  };
}
