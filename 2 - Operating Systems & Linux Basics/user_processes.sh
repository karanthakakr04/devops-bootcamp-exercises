#!/bin/bash

# Get the current user name
user=$(whoami)

# Get the option to sort by memory or CPU
echo "Do you want to sort by memory or CPU? (m/c)"
read option

# Check the option and set the sort field accordingly
if [[ "$option" = "m" ]]; then
  sort_field="%mem"
elif [[ "$option" = "c" ]]; then
  sort_field="%cpu"
else
  echo "Invalid option. Please enter m or c."
  exit 1
fi

# Get the number of processes to display
echo "How many processes do you want to see? (Enter a number)"
read num

# Define the regular expression for positive integers
re='^[0-9]+$'

# Check if the number is valid or not
if ! [[ $num =~ $re ]]; then
  echo "Invalid number. Please enter a positive whole number."
  exit 1
fi

# Get the processes of the current user and sort by the chosen field
ps -u $user -o pid,user,%mem,%cpu,cmd --sort=-$sort_field > /tmp/processes.txt

# Print the processes
cat /tmp/processes.txt | head -n $(($num + 1))

