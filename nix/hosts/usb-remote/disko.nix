{
  lib,
  ...
}:
let
  btrfsMountOptions = [
    "compress=zstd:1"
    "noatime"
  ];
in
{
  disko.devices = {
    nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [
          "size=1G"
          "mode=755"
        ];
      };
    };
    disk = {
      main = {
        device = lib.mkDefault "/dev/disk/by-id/usb-Generic_Flash_Disk_0916027A-0:0";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "fmask=0077"
                  "dmask=0077"
                ];
              };
            };
            root = {
              priority = 2;
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [
                  "-m"
                  "single"
                  "-L"
                  "usb-remote"
                ];
                subvolumes = {
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = btrfsMountOptions;
                  };
                  "@persist" = {
                    mountpoint = "/persist";
                    mountOptions = btrfsMountOptions;
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  fileSystems."/nix".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;
}
