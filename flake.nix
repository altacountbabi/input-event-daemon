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
    {
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
    };
}
