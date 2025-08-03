{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forEachSupportedSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import nixpkgs {
              inherit system;
            };
          }
        );
    in
    {

      packages = forEachSupportedSystem (
        { pkgs }:
        rec {
          debug-container = pkgs.dockerTools.buildImage {
            name = "debug-container";
            tag = "latest";
            contents = with pkgs; [
              python3
              python3Packages.pip
              iputils
              mtr
              nettools
              htop
              vim
              git
              bind
              iproute2
              wget
              curl
              tcpdump
              sysstat
              numactl
              hping
              dnsperf
              jq
              speedtest-cli
              iperf3
              procps
              nmap
              ethtool
              coreutils-full
            ];
            config = {
              Cmd = [ "${pkgs.lib.getExe pkgs.bash}" ];
              WorkingDir = "/root";
            };
          };

          default = debug-container;
        }
      );

      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {
            buildInputs = [
              pkgs.skopeo
            ];
          };
        }
      );
    };
}
