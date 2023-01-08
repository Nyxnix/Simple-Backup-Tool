#!/bin/sh
PS3="Select an option: "
select opt in local schedule clear info quit; do

    case $opt in
      # Local transfers
      local)
      read -p "Enter the path you would like to backup: " dir1
      read -p "Enter the path you would like to backup to: " dir2
      rsync -avucP '$dir1' '$dir2'
      echo Backup complete!
      break
      ;;
      # Schedules cron job for rsync
      schedule)
      read -p "Enter the path you would like to backup: " dir1
      read -p "Enter the path you would like to backup to: " dir2
      # Initialize crontab by adding a comment if not present
      crontab -l | grep -q '#a' && echo "crontab exists" || (crontab -l; echo "#a") | sort -u | crontab -
      echo "How often would you like to backup?"
      select time in day week month; do
        case $time in
         day)
         read -p "What time of day (hour only) would you like to backup on? (24 hour format, 0 - 23): " hour
         # Check if the input is an integer
         if ! [[ "$hour" =~ ^[0-9]+$ ]] || ! [[ "$hour" -ge 0 && "$hour" -le 23 ]]; then
           echo "Error: Hour must be an integer between 0 and 23"
           exit 1
         fi
         # cron expression "0 $hour * * *"
         (crontab -l; echo "0 $hour * * * rsync -avu '$dir1' '$dir2'") | sort -u | crontab -
         break
         ;;
         week)
         read -p "What day of the week would you like to backup? (0 - 6): " dow
         read -p "What time of day (hour only) would you like to backup on? (24 hour format, 0 - 23): " hour
         # Check if the input is an integer
         if ! [[ "$hour" =~ ^[0-9]+$ ]] || ! [[ "$hour" -ge 0 && "$hour" -le 23 ]] || ! [[ "$dow" =~ ^[0-9]+$ ]] || ! [[ "$dow" -ge 0 && "$dow" -le 6 ]]; then
           echo "Error: Hour must be an integer between 0 and 23 and day of week must be an integer between 0 and 6"
           exit 1
         fi
         # cron expression "0 $hour * * $dow"
         (crontab -l; echo "0 $hour * * $dow rsync -avu '$dir1' '$dir2'") | sort -u | crontab -
         break
         ;;
         month)
         read -p "What day of the month would you like to backup on? (1 - 31): " dom
         read -p "What time of day (hour only) would you like to backup on? (24 hour format, 0 - 23): " hour
         if ! [[ "$dom" =~ ^[0-9]+$ ]] || ! [[ "$dom" -ge 1 && "$dom" -le 31 ]] || ! [[ "$hour" =~ ^[0-9]+$ ]] || ! [[ "$hour" -ge 0 && "$hour" -le 23 ]]; then
           echo "Error: Day of month must be an integer between 1 and 31 and hour must be an integer between 0 and 23"
           exit 1
         fi
         # cron expression "0 $hour $dom * *"
         (crontab -l; echo "0 $hour $dom * * rsync -avu '$dir1' '$dir2'") | sort -u | crontab -
         break
         ;;
         *)
         echo "Invalid option $REPLY"
         ;;
        esac
    done
      echo "Schedule is set! If you would like to remove an entry type 'crontab -e' in your terminal and remove it."
      break
      ;;
      # About page
      info)
      echo 
      echo Simple Backup Tool
      echo By: Nyxnix
      echo  
      break
      ;;
      clear)
      read -p "Are you sure you want to continue? (y/n) " response
      if [[ "$response" =~ ^[Yy]$ ]]; then
      (crontab -r) # This completely deletes the crontab, I plan on making a better implementation eventually.
      fi
      break
      ;;
      # Quit
      quit)
      break
      ;;
      # Else
      *)
      echo "Invalid option $REPLY"
      ;;
    esac
done
