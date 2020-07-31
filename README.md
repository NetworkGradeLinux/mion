Mion: mini infrastructure operating system for networks

TODO

Fill in a bunch of stuff here but for now, see QUICKSTART.md


Quickstart

git clone --recursive git@github.com:APS-Networks/mion.git
cd mion
# Apply out of tree patches not yet upstreamed
./patches/apply.sh


To Build host filesystem with ONLPv1 Guest
./scripts/build.py -M stordis-bf2556x-1t -T guest:mion-guest-onlpv1 -T mion-native-onie-new:mion-host-prod

To Build host filesystem with ONLPv2 Guest
./scripts/build.py -M stordis-bf2556x-1t -T guest:mion-guest-onlpv2 -T mion-native-onie-new:mion-host-prod

To Build ONIE installer for ONLPv1
./scripts/build.py -M stordis-bf2556x-1t -T guest:mion-guest-onlpv1 -T mion-native-onie:mion-host-onie-onlpv1

To Build ONIE installer for ONLPv2
./scripts/build.py -M stordis-bf2556x-1t -T guest:mion-guest-onlpv2 -T mion-native-onie:mion-host-onie-onlpv2


TODO

Document:

# The System Profiles
# The Application Profiles
# The Platform Profiles
# The ONIE Profile
