# Disk partitioning information
part /boot --fstype="ext4" --ondisk=sda --size=512
part pv.110 --fstype="lvmpv" --ondisk=sda --size=1 --grow
volgroup xcatvg --pesize=4096 pv.110
logvol swap --fstype="swap" --size=16384 --name=swap --vgname=xcatvg
logvol / --fstype="ext4" --size=1 --grow --name=root --vgname=xcatvg
