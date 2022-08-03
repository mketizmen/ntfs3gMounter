#! /bin/bash
FSTYPE="Windows_NTFS"
# FSTYPE="APFS Volume"
PARTITIONS=(`diskutil list |grep "$FSTYPE" |sed "s/ \{2,\}/\t/g"|sed "s/ /_/g"|sed "s/\t/ /g"|awk '{print $4}'|cut -d' ' -f1`)
function remount(){
    DEVICE="/dev/$1"
    FILESYSTEM=$(diskutil info $DEVICE | grep "File System Personality:"| awk '{print $4}')
    if [[ "$FILESYSTEM" = "NTFS" ]]; then
        VOLUMENAME=$(diskutil info $DEVICE | grep "Volume Name:"| awk '{print $3}')
        READONLY=$(diskutil info $DEVICE | grep "Volume Read-Only:"| awk '{print $3}')
        # $(mkdir -p /Volumes/$VOLUMENAME)
        echo $VOLUMENAME " volume found. If mounted it will remount with write support."
        if [[ "$READONLY" = "Yes" ]]; then
            STATUS=$(diskutil unmount "$DEVICE" | awk '{print $5}')
            if [[ "$STATUS" = "unmounted" ]]; then 
            echo "mounting " $VOLUMENAME
                (`/usr/local/bin/ntfs-3g "$DEVICE" /Volumes/"$VOLUMENAME" -olocal -oallow_other -o auto_xattr -ovolname="$VOLUMENAME"`)
            fi
        fi
    fi
}
for i in "${PARTITIONS[@]}"
do
	remount "$i"
done