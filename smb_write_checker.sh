#!/bin/bash

# _____0-0-0-0-______0-0-0-0-______0-0-0-0-________________0-0-_______________
# __0-0-____0-0-__0-0-____0-0-__0-0-____0-0-__0-0-0-______0-0-______0-0-0-___
# ___0-0-0-0-____0-0-____0-0-____0-0-0-0-________0-0-____0-0-____0-0-X-0-0-_
# 0-0-____0-0-__0-0-____0-0-__0-0-____0-0-__0-0-0-0-____0-0-____0-0-_______
# _0-0-0-0-______0-0-0-0-______0-0-0-0-____0-0-X-0-0-__0-0-0-____0-0-0-0-_

# ------------------------------------------------------------------------------
# Name: smb_write_checker.sh
# Author: 808ale
#
# Description:
#   Checks for writable directories within an SMB share by attempting to upload
#   a test file to each directory found. Writable directories are highlighted
#   in green for readability.
#
# Usage:
#   ./smb_write_checker.sh -t <target> -s <share> -u <username> -p <password>
#
# Example:
#   ./smb_write_checker.sh -t sizzle.htb.local -s "Department Shares" -u guest -p ""
#
# ------------------------------------------------------------------------------

# parse arguments
while getopts "t:s:u:p:" opt; do
  case $opt in
    t) TARGET="$OPTARG" ;;
    s) SHARE="$OPTARG" ;;
    u) USERNAME="$OPTARG" ;;
    p) PASSWORD="$OPTARG" ;;
    *)
      echo "Usage: $0 -t target -s share -u username -p password"
      exit 1
      ;;
  esac
done

# check if all arguments were provided
if [ -z "$TARGET" ] || [ -z "$SHARE" ] || [ -z "$USERNAME" ]; then
  echo "Missing one or more required arguments."
  echo "Usage: $0 -t target -s share -u username -p password"
  exit 1
fi

# create dummy file
touch test

# recursively list all directories
echo "[*] Now running: smbclient //$TARGET/$SHARE -U \"$USERNAME%$PASSWORD\" -c \"recurse; dir\" | grep \"\\\\\\\\\" > dirs.txt\""

smbclient "//$TARGET/$SHARE" -U "$USERNAME%$PASSWORD" -c "recurse; dir" | grep "\\\\" > dirs.txt

# substitute backslashes for forward slashes
sed -i 's/\\/\//g' dirs.txt

# try uploading a test file to each directory
for dir in $(cat dirs.txt); do
    echo "[*] Testing write access in: $dir"
    smbclient "//$TARGET/$SHARE" -U "$USERNAME%$PASSWORD" -c "cd $dir; put test" && echo -e "\e[32m[+] Writable: $dir\e[0m"
done

rm test dirs.txt