# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, ... }:

let
  cloudInitConfig =
    ''
       system_info:
         distro: nixos
         default_user:
           name: nixos
       users:
         - default
       disable_root: true
       preserve_hostname: false
       cloud_init_modules:
         - migrator
         - seed_random
         - bootcmd
         - write-files
         - growpart
         - resizefs
         - update_etc_hosts
         - ca-certs
         - rsyslog
         - users-groups
	 - ssh
       cloud_config_modules:
         - disk_setup
         - mounts
         - ssh-import-id
         - set-passwords
         - timezone
         - disable-ec2-metadata
         - runcmd
         - ssh-import-id
       cloud_final_modules:
         - rightscale_userdata
         - scripts-vendor
         - scripts-per-once
         - scripts-per-boot
         - scripts-per-instance
         - scripts-user
         - ssh-authkey-fingerprints
         - keys-to-console
         - phone-home
         - final-message
         - power-state-change
    '';
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/vda";

  networking.networkmanager.enable = false;
  networking.hostName = ""; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  #
  # Disable firewall in Cloud images by default; should be
  # handled by cloud manager config instead.
  #
  networking.firewall.enable = false;

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    # General
    wget 
    # Editors
    emacs vim nano
    # Desktop
    icewm
    # Development
    git tmux
    # Cloud
    cloud-init
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "without-password";
  services.openssh.challengeResponseAuthentication = false;

  # Enable cloud-init
  # TODO: fix config file install: https://github.com/NixOS/nixpkgs/issues/50366
  services.cloud-init.enable = true;
  services.cloud-init.config = cloudInitConfig;

  # services.nfs.server.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  services.xserver.windowManager.icewm.enable = true;
  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.kdm.enable = true;
  # services.xserver.desktopManager.kde4.enable = true;

  # Define a user account. Don't forget to set a password with 'passwd'.
  # users.extraUsers.guest = {
  #   isNormalUser = true;
  #   uid = 1000;
  # };

  virtualisation.docker.enable = true;
  
  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.03";

}
