{
  description = "k9s with pre-configured plugins and settings";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        k9sConfig = pkgs.writeTextDir "config/config.yaml" ''
          k9s:
            # UI settings
            ui:
              enableMouse: true
              headless: false
              logoless: false
              crumbsless: false
              reactive: false
              noIcons: false
              maxColWidth: 50
              defaultsToFullScreen: false
            
            # Logger settings
            logger:
              tail: 100
              buffer: 5000
              sinceSeconds: -1
              textWrap: false
              showTime: false
            
            # Skin theme
            skin: dracula
            
            # Refresh rate (2 seconds)
            refreshRate: 2
            
            # Max logs lines
            maxLogsBuffer: 5000
            
            # Read-only mode
            readOnly: false
            
            # No exit confirmation
            noExitOnCtrlC: false
            
            # Skip version check
            skipLatestRevCheck: false
        '';
        
        k9sPlugins = pkgs.writeTextDir "config/plugins.yaml" ''
          plugins:
            # Debug pod with dive
            dive:
              shortCut: Shift-D
              confirm: true
              description: "Dive image"
              scopes:
                - containers
              command: dive
              background: false
              args:
                - $COL-IMAGE
            
            # Get all resources with get-all plugin
            get-all:
              shortCut: g
              confirm: false
              description: "Get all resources"
              scopes:
                - all
              command: sh
              background: false
              args:
                - -c
                - kubectl get-all -n $NAMESPACE --context $CONTEXT | less
            
            # View logs with stern
            stern:
              shortCut: Ctrl-L
              confirm: false
              description: "Logs <Stern>"
              scopes:
                - pods
              command: stern
              background: false
              args:
                - --tail
                - "50"
                - $NAME
                - -n
                - $NAMESPACE
            
            # Port forward with confirmation
            pf:
              shortCut: Shift-F
              confirm: true
              description: "Port forward"
              scopes:
                - pods
                - services
              command: kubectl
              background: true
              args:
                - port-forward
                - $NAME
                - 8080:$COL-PORT
                - -n
                - $NAMESPACE
            
            # Edit resource
            edit:
              shortCut: e
              confirm: false
              description: "Edit resource"
              scopes:
                - all
              command: kubectl
              background: false
              args:
                - edit
                - $RESOURCE_NAME
                - $NAME
                - -n
                - $NAMESPACE
            
            # Get resource in JSON
            json:
              shortCut: j
              confirm: false
              description: "Get resource as JSON"
              scopes:
                - all
              command: kubectl
              background: false
              args:
                - get
                - $RESOURCE_NAME
                - $NAME
                - -o
                - json
                - -n
                - $NAMESPACE
            
            # Decode secrets
            decode-secret:
              shortCut: x
              confirm: false
              description: "Decode secret"
              scopes:
                - secrets
              command: kubectl
              background: false
              args:
                - get
                - secret
                - $NAME
                - -o
                - go-template='{{range $k,$v := .data}}{{printf "%s: " $k}}{{if not $v}}{{$v}}{{else}}{{$v | base64decode}}{{end}}{{"\n"}}{{end}}'
                - -n
                - $NAMESPACE
            
            # Raw logs follow (from k9s official plugins)
            raw-logs-follow:
              shortCut: Ctrl-G
              confirm: false
              description: "Follow logs"
              scopes:
                - pods
              command: kubectl
              background: false
              args:
                - logs
                - -f
                - $NAME
                - -n
                - $NAMESPACE
                - --context
                - $CONTEXT
            
            # Log with less viewer
            log-less:
              shortCut: Shift-K
              confirm: false
              description: "Logs <Less>"
              scopes:
                - pods
              command: sh
              background: false
              args:
                - -c
                - kubectl logs $NAME -n $NAMESPACE --context $CONTEXT | less
            
            # Log container with less
            log-less-container:
              shortCut: Shift-L
              confirm: false
              description: "Container Logs <Less>"
              scopes:
                - containers
              command: sh
              background: false
              args:
                - -c
                - kubectl logs $POD -c $NAME -n $NAMESPACE --context $CONTEXT | less
            
            # Remove finalizers (DANGEROUS - use with caution!)
            remove-finalizers:
              shortCut: Ctrl-F
              confirm: true
              description: "Remove Finalizers (DANGEROUS!)"
              scopes:
                - all
              command: kubectl
              background: false
              args:
                - patch
                - $RESOURCE_NAME
                - $NAME
                - -n
                - $NAMESPACE
                - --context
                - $CONTEXT
                - -p
                - '{"metadata":{"finalizers":null}}'
                - --type
                - merge
        '';
        
        k9sAliases = pkgs.writeTextDir "config/aliases.yaml" ''
          aliases:
            # Resource aliases
            dp: deployments
            sts: statefulsets
            ds: daemonsets
            svc: services
            ing: ingresses
            cm: configmaps
            sec: secrets
            pv: persistentvolumes
            pvc: persistentvolumeclaims
            ns: namespaces
            no: nodes
            po: pods
            rs: replicasets
            rc: replicationcontrollers
            netpol: networkpolicies
            psp: podsecuritypolicies
            rb: rolebindings
            crb: clusterrolebindings
            sa: serviceaccounts
            
            # CRD aliases
            vs: virtualservices
            dr: destinationrules
            gw: gateways
            se: serviceentries
            we: workloadentries
            
            # Cert-manager
            cert: certificates
            issuer: issuers
            cissuer: clusterissuers
            
            # Monitoring
            sm: servicemonitors
            pm: podmonitors
            pr: prometheusrules
        '';
        
        k9sHotkeys = pkgs.writeTextDir "config/hotkeys.yaml" ''
          hotkeys:
            # Global hotkeys
            ':':
              shortCut: ':'
              description: "Command mode"
            
            # Navigation hotkeys  
            '?':
              shortCut: '?'
              description: "Help"
            
            'q':
              shortCut: 'q'
              description: "Quit"
            
            # View hotkeys
            'v':
              shortCut: 'v'
              description: "View YAML"
            
            'd':
              shortCut: 'd'
              description: "Describe"
            
            'l':
              shortCut: 'l'
              description: "Logs"
            
            # Action hotkeys
            'ctrl-d':
              shortCut: 'Ctrl-D'
              description: "Delete"
            
            'y':
              shortCut: 'y'
              description: "YAML"
              
            # Namespace switching
            'ctrl-n':
              shortCut: 'Ctrl-N'
              description: "Next namespace"
            
            'ctrl-p':
              shortCut: 'Ctrl-P'
              description: "Previous namespace"
        '';
        
        k9sConfigPackage = pkgs.runCommand "k9s-config" {} ''
          mkdir -p $out/config
          cp ${k9sConfig}/config/config.yaml $out/config/
          cp ${k9sPlugins}/config/plugins.yaml $out/config/
          cp ${k9sAliases}/config/aliases.yaml $out/config/
          cp ${k9sHotkeys}/config/hotkeys.yaml $out/config/
        '';
        
      in
      {
        packages = {
          default = k9sConfigPackage;
          k9s-configured = pkgs.writeShellScriptBin "k9s-configured" ''
            # Create writable config directory in user's home
            K9S_USER_CONFIG="$HOME/.config/k9s"
            mkdir -p "$K9S_USER_CONFIG"/{skins,clusters,screen-dumps,benchmarks}
            
            # Copy config files if they don't exist
            for config_file in config.yaml plugins.yaml aliases.yaml hotkeys.yaml; do
              if [[ ! -f "$K9S_USER_CONFIG/$config_file" ]]; then
                cp "${k9sConfigPackage}/config/$config_file" "$K9S_USER_CONFIG/"
              fi
            done
            
            # Set config directory and run k9s
            export K9S_CONFIG_DIR="$K9S_USER_CONFIG"
            echo "🚀 Using k9s config: $K9S_CONFIG_DIR"
            exec ${pkgs.k9s}/bin/k9s "$@"
          '';
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            k9s
            kubectl
            stern
            dive
            kubernetes-helm
          ];
          
          shellHook = ''
            echo "🚀 k9s development environment loaded!"
            echo ""
            echo "Available tools:"
            echo "  - k9s: Kubernetes TUI"
            echo "  - kubectl: Kubernetes CLI"
            echo "  - stern: Multi-pod log tailing"
            echo "  - dive: Docker image explorer"
            echo "  - helm: Kubernetes package manager"
            echo ""
            echo "🎯 Quick start:"
            echo "  nix run .#k9s-configured"
            echo ""
            echo "📁 Config will be copied to: ~/.config/k9s/"
            echo "  - Modify configs in ~/.config/k9s/ to customize"
            echo "  - Original templates: ${k9sConfigPackage}/config/"
            echo ""
            echo "🔧 Manual setup:"
            echo "  cp -r ${k9sConfigPackage}/config/* ~/.config/k9s/"
            echo "  export K9S_CONFIG_DIR=~/.config/k9s"
            echo "  k9s"
          '';
        };

        apps = {
          default = {
            type = "app";
            program = "${self.packages.${system}.k9s-configured}/bin/k9s-configured";
          };
        };
      });
}