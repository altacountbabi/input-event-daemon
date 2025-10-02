{
  description = "A Nix flake for input-event-daemon";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      systems = nixpkgs.lib.platforms.linux;
    in
    rec {
      packages = nixpkgs.lib.genAttrs systems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.python3Packages.buildPythonPackage {
            pname = "input-event-daemon";
            version = "0.1";

            src = ./.;

            pyproject = true;
            propagatedBuildInputs = with pkgs.python3Packages; [
              evdev
              pyudev
              setuptools
            ];

            doCheck = false;

            meta = with pkgs.lib; {
              description = "A daemon to monitor key inputs and trigger user-defined commands";
              license = licenses.bsd3;
              platforms = platforms.linux;
            };
          };
        }
      );

      nixosModules.systemd-service =
        { config, ... }:
        {
          options = { };
          config = {
            systemd.services."input-event-daemon" = {
              description = "Input event daemon";
              wantedBy = [ "multi-user.target" ];

              serviceConfig = {
                Type = "simple";
                ExecStart = "${
                  packages.${config.system}.default
                }/bin/input-event-daemon --config=/etc/input-event-daemon.conf";
              };
            };
          };
        };

    };
}
