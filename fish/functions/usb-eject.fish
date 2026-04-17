# `umount` / "Démonter" dans Nemo ne flushent que les buffers kernel ; le cache
# d'écriture interne du contrôleur de la clé USB, lui, n'est vidé qu'au
# STOP UNIT SCSI envoyé par `power-off`. Sans ça un sha256sum peut différer
# après débranchement/rebranchement. `udisksctl power-off` refuse de tourner
# tant qu'une partition est montée, d'où le démontage préalable de chacune.
function usb-eject --description 'Unmount all partitions of a USB disk and power it off (flush controller cache)'
    if test (count $argv) -ne 1
        echo "Usage: usb-eject /dev/sdX"
        return 1
    end

    set -l disk $argv[1]
    if not test -b $disk
        echo "Not a block device: $disk"
        return 1
    end

    for part in (lsblk -lnp -o NAME $disk | tail -n +2)
        udisksctl unmount -b $part 2>/dev/null
    end
    udisksctl power-off -b $disk
end
