@echo off
"C:\Program Files\qemu\qemu-system-x86_64.exe" ^
 -m 2048 ^
 -smp 2 ^
 -drive file="your\path\fedora-coreos-41.20250315.3.0-qemu.x86_64.qcow2",format=qcow2,if=virtio ^
 -fw_cfg name=opt/com.coreos/config,file="your\path\config.ign" ^
 -netdev user,id=net0,hostfwd=tcp::2222-:22 ^
 -device virtio-net-pci,netdev=net0 ^
 -nographic