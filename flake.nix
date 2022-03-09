{
  description = "lounge.rocks VPN config";

  inputs = {

    flake-utils.url = "github:numtide/flake-utils";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
  with inputs; rec {

    nixosModules.lounge-vpn-client = { config, pkgs, lib, ... }:
    with lib;
    let cfg = config.lounge-rocks.vpn-client;
    in {

      options.lounge-rocks.vpn-client = {
        enable = mkEnableOption "wireguard client configuration";

        keyfile = mkOption {
          type = types.str;
          example = "/var/src/secrets/lounge-rocks-secretskey";
          description = ''
                Path to the file containing the secret key
          '';
        };

        client-ip = mkOption {
          type = types.str;
          default = "0.0.0.0";
          example = "192.168.7.1/24";
          description = ''
                IP address of the host.
                Make sure to also set the peer entry for the server accordingly.
          '';
        };
      };

      config = mkIf cfg.enable {

        networking.wireguard.interfaces = {
          lounge-rocks-wg = {
            ips = [ "${cfg.client-ip}/24" ];
            privateKeyFile = cfg.keyfile;
            peers = [{
              publicKey =
                "TODO"; # Public key of the server (not a file path).
                  # TODO Don't forward all the traffic via VPN, only particular subnets
                  # allowedIPs = [ "192.168.7.0/24" ];
                  endpoint = "vpn.lounge.rocks:51820";
                  persistentKeepalive = 25;
                }];
              };
            };
          };
        };

        nixosModules.lounge-vpn-server = { config, pkgs, lib, ... }:


        with lib;
        let cfg = config.lounge-rocks.vpn-client;
        in {

          options.lounge-rocks.vpn-server = {
            enable = mkEnableOption "wireguard server configuration";

            keyfile = mkOption {
              type = types.str;
              example = "/var/src/secrets/lounge-rocks-secretskey";
              description = ''
                Path to the file containing the secret key
              '';
            };
          };

          config = mkIf cfg.enable {

            networking.wireguard.interfaces = {

              lounge-rocks-wg = {

            # Determines the IP address and subnet of the client's end of the
            # tunnel interface.
            # TODO ips = [ "192.168.7.1/24" ];
            listenPort = 51820;
            privateKeyFile = cfg.keyfile;
            peers = import ./peers.nix;
        };
      };

    };
  };
}
