# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
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
    cloud-init euca2ools
    # Server
    samba4Full
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "without-password";
  services.openssh.challengeResponseAuthentication = false;

  # Enable cloud-init
  # TODO: fix config file install
  # services.cloud-init.enable = true;


  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    #read-only exports to users:
    /export/aristotle/apps 128.84.8.0/22(insecure,ro,async,no_subtree_check,nohide)
    #/export/aristotle/apps 128.84.9.0/24(insecure,ro,async,no_subtree_check,nohide)
    #read-write exports to elastic ips
    /export/aristotle/apps 128.84.8.65(insecure,rw,no_root_squash,sync,no_subtree_check,nohide)
    /export/aristotle/apps 128.84.8.85(insecure,rw,no_root_squash,sync,no_subtree_check,nohide)
  '';

  services.samba = {
    enable = true;
    syncPasswordsByPam = true;
    shares = {
      apps =
        { path = "/mnt/aristotle/apps";
          "read only" = "yes";
          browseable = "yes";
          "guest ok" = "yes";
          "write list" = "nixos";
	  "read list"  = "smbguest";
        };
    };
    extraConfig = ''
      guest account = smbguest
      map to guest = bad user
      acl allow execute always = True
    '';
  };
  # create the smbguest user, otherwise connections will fail
  users.users.smbguest = {
    name = "smbguest";
    uid  = config.ids.uids.smbguest;
    description = "smb guest user";
  };
  


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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.extraUsers.guest = {
  #   isNormalUser = true;
  #   uid = 1000;
  # };

  fileSystems."/mnt/aristotle/apps" = {
    device = "/dev/disk/by-uuid/e996be09-4d05-4ae5-aeae-0ced4bd50498";
    fsType = "ext4";
  };
  fileSystems."/export/aristotle/apps" = { 
    device = "/mnt/aristotle/apps";
    options = "bind";
  };


  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "15.09";

}
