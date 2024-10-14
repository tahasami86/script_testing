#!/usr/bin/bash
num_vf=$((2))    # change this number

start_vf=$((2))  # dont touch this number

device_name="enp4s0f0np0"
start_pci_address="0000:04:00.0"
pci_for_unbinding="0000:04:00"

echo $num_vf > /sys/class/net/$device_name/device/sriov_numvfs || { echo "Error: Unable to set number of VFs"; exit 1; }

# Iterate through the range of VFs
for ((vf=start_vf; vf<=start_vf+num_vf-1; vf++)); do
    # Construct the PCI address
    pci_address="$pci_for_unbinding.$vf"

    # Unbind the mlx5_core driver
    echo "$pci_address" > /sys/bus/pci/drivers/mlx5_core/unbind || { echo "Error: Unable to unbind mlx5_core driver for $pci_address"; exit 1; }

    # Output confirmation
    echo "Unbind successful for $pci_address"
done

devlink dev eswitch set pci/$start_pci_address mode switchdev  || { echo "Error: Unable to set switchdev mode"; exit 1; }

echo "changed device $device_name from legacy to switchdev"
# Rebind the mlx5_core driver for each VF
for ((vf=start_vf; vf<=start_vf+num_vf-1; vf++)); do
    # Construct the PCI address
    pci_address="$pci_for_unbinding.$vf"

    # Rebind the mlx5_core driver
    echo "$pci_address" > /sys/bus/pci/drivers/mlx5_core/bind || { echo "Error: Unable to rebind mlx5_core driver for $pci_address"; exit 1; }

    # Output confirmation
    echo "Rebind successful for $pci_address"
done

