# Disk partitioning information
part pv.110 --fstype="lvmpv" --ondisk=sda --size=237354
part /boot --fstype="ext4" --ondisk=sda --size=512
volgroup xcatvg --pesize=4096 pv.110
logvol swap --fstype="swap" --size=64374 --name=swap --vgname=xcatvg
logvol / --fstype="ext4" --grow --size=1 --name=root --vgname=xcatvg
