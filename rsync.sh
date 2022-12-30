#!/bin/sh
PS3="Select an option: "
select opt in local remote schedule info quit; do

    case $opt in
      # Local transfers
      local)
      read -p "Enter the path you would like to backup: " dir1
      read -p "Enter the path you would like to backup to: " dir2
      rsync -avucP '$dir1' '$dir2'
      echo Backup complete!
      break
      ;;
      # Remote transfers (Needs work)
      remote)
      read -p "Enter the local path you would like to backup: " dir1
      read -p "Enter the remote path (Ex. username@remote_host:/home/username/dir1): " dir2
      rsync -avuczP '$dir1' '$dir2'
      echo Backup complete!
      break
      ;;
      # Schedules cron job for rsync
      schedule)
      echo 
      echo "READ THIS FIRST. Before you run this script you need to have an existing crontab or it will error."
      echo "To create a crontab type 'crontab -e' and add a comment '#a' to initialize it"
      echo "I havent figured out a way around this yet, but I am working on it! :)"
      echo 
      read -p "Enter the path you would like to backup: " dir1
      read -p "Enter the path you would like to backup to: " dir2
      echo "How often would you like to backup?"
      select time in day week month; do
        case $time in
         day)
         read -p "What time of day (hour only) would you like to backup on? (24 hour format, 0 - 23): " hour
         # cron expression "0 $hour * * *"
         (crontab -l; echo "0 $hour * * * rsync -avu '$dir1' '$dir2'") | sort -u | crontab -
         break
         ;;
         week)
         read -p "What day of the week would you like to backup? (0 - 6): " dow
         read -p "What time of day (hour only) would you like to backup on? (24 hour format, 0 - 23): " hour
         # cron expression "0 $hour * * $dow"
         (crontab -l; echo "0 $hour * * $dow rsync -avu '$dir1' '$dir2'") | sort -u | crontab -
         break
         ;;
         month)
         read -p "What day of the month would you like to backup on? (1 - 31): " dom
         read -p "What time of day (hour only) would you like to backup on? (24 hour format, 0 - 23): " hour
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
