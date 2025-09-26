# Declarative-Flatpak Upgrade Notes

## Version Update: v3.1.0 → v4.0.1

This upgrade resolves issue #42 by updating declarative-flatpak from v3.1.0 to v4.0.1, which now includes native support for device overrides.

### Changes Made

1. **Updated Dependency**: 
   - `flake.nix`: Changed version from `v3.1.0` to `v4.0.1`
   - `flake.lock`: Updated commit SHA to match v4.0.1

2. **Native Device Override Support**:
   - **BEFORE**: Manual workaround using `preSwitchCommand`
   ```nix
   preSwitchCommand = ''
     flatpak override --user --device=input org.vinegarhq.Sober
   '';
   ```
   
   - **AFTER**: Native support using `Context.devices`
   ```nix
   overrides = {
     "org.vinegarhq.Sober" = {
       Context.devices = [ "input" ];
     };
   };
   ```

3. **Updated Override Syntax**:
   - Changed `filesystems` to `Context.filesystems` to match v4.0.1 format
   - All overrides now use the proper Context sections

### Benefits

- ✅ **Native Device Support**: No more manual workarounds
- ✅ **Cleaner Configuration**: Consistent with upstream format
- ✅ **Better Maintainability**: Follows official API patterns
- ✅ **Issue Resolution**: Addresses github.com/in-a-dil-emma/declarative-flatpak/issues/42

### Verification

After applying these changes, you should:

1. Run `sudo nixos-rebuild switch` to apply the new configuration
2. Verify that Sober has input device access: `flatpak override --show org.vinegarhq.Sober`
3. Confirm the application works as expected

### Troubleshooting

If you encounter any issues:
- Check that your NixOS version is compatible with declarative-flatpak v4.0.1
- Verify the override syntax matches the examples in this repository
- Consult the [declarative-flatpak documentation](https://github.com/in-a-dil-emma/declarative-flatpak) for additional configuration options