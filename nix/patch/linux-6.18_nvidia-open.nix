# removal blocker: https://github.com/NixOS/nixpkgs/issues/467145
{
  config,
  pkgs,
  ...
}:
{
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable // {
    open = config.boot.kernelPackages.nvidiaPackages.stable.open.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [
        (pkgs.fetchpatch {
          name = "get_dev_pagemap.patch";
          url = "https://github.com/NVIDIA/open-gpu-kernel-modules/commit/3e230516034d29e84ca023fe95e284af5cd5a065.patch";
          hash = "sha256-BhL4mtuY5W+eLofwhHVnZnVf0msDj7XBxskZi8e6/k8=";
        })
      ];
    });
  };
}
