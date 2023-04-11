#!/bin/bash

#####
#
# Mass postfixadmin mailboxes creation by @ClessAlvein
#
#####


# VARS

mailboxesListFile="./USERS_lada-tambovavtocity.ru.txt"
mailboxQuota="2048"
pfCli="/usr/share/nginx/html/postfixadmin/scripts/postfixadmin-cli"
dateTimeCurrent=`date +%Y-%m-%d_%H-%M-%S`


# SCRIPT START

# declare array with mailbox data in the each line
declare -A arrayMailboxes;

# getting each line from the file with each user's data
while IFS= read -r line || [[ "$line" ]];
do
  # getting user, pass, name from the line and put it to the assoc array key=value
  while IFS="|" read "mailboxUserFromFile" "mailboxPassFromFile" "mailboxNameFromFile";
  do
    # makeup
    echo "";

    # debug
    #echo "${mailboxUser}, ${mailboxPass}, ${mailboxName}";

    # declare assoc array with each key as a bit mailbox's data
    declare -A arrayMailbox;

    # each key is a bit of the mailbox's data
    arrayMailbox[arrayMailboxUser]=${mailboxUserFromFile};
    arrayMailbox[arrayMailboxPass]=${mailboxPassFromFile};
    arrayMailbox[arrayMailboxName]=${mailboxNameFromFile};

    # for each bit of mailbox's data create var (user,pass,name)
    for key in "${!arrayMailbox[@]}";
    do
      case $key in
      arrayMailboxUser)
        mailboxUser=${arrayMailbox[${key}]};;
      arrayMailboxPass)
        mailboxPass=${arrayMailbox[${key}]};;
      arrayMailboxName)
        mailboxName=${arrayMailbox[${key}]};;
      esac
    done
  done < <( echo ${line} )

  # if ${mailboxName} is empty
  if [ -z "${mailboxName}" ]; then
    mailboxName=${mailboxUser}
  fi

  # debug
  echo "mailboxUser: ${mailboxUser}";
  echo "mailboxPass: ${mailboxPass}";
  echo "mailboxName: ${mailboxName}";

  # create each mailbox
  ${pfCli} mailbox add ${mailboxUser} \
    --password "${mailboxPass}" \
    --password2 "${mailboxPass}" \
    --name "${mailboxName}" \
    --quota "${mailboxQuota}" \
    --active --welcome-mail \
    | tee -a ./log_${dateTimeCurrent}

done < ${mailboxesListFile}
