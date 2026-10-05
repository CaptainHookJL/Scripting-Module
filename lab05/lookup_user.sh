#!/bin/bash

#!/bin/bash

read -p "Enter a username to look up: " TARGET_USER
read -p "Enter a department: " TARGET_DEPT

echo "Searching for $TARGET_USER in $TARGET_DEPT"
grep "$TARGET_USER" intel/users.csv | grep "$TARGET_DEPT"

