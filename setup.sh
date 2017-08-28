#!/bin/sh

# DO THE FOLLOWING BEFORE RUNNING THIS SCRIPT
# RUN THIS SCRIPT ONLY ONCE
  
  # IN CLOUD9, CREATE A NEW WORKSPACE, CHOOSE A TEMPLATE - RUBY
  
  # PLACE THIS FILE IN A DIRECTORY ON ~ PATH
    # OPEN A TERMINAL AND TYPE THE FOLLOWING
    # $ cd
    # $ mkdir scripts
    # $ cd scripts
    # $ touch setup.sh
    # $ c9 setup.sh
  # COPY AND PASTE THE CONTENTS OF THIS FILE IN NEWLY CREATED setup.sh FILE, SAVE
  
  # REMOVE THE CONTENTS OF YOUR NEWLY CREATED RUBY ENVIRONMENT
    # OPEN A TERMINAL AND TYPE THE FOLLOWING
    # $ cd
    # $ rm -r workspace/
  
  # LINK THIS MACHINE'S SSH KEY TO YOUR GITHUB ACCOUNT
    # OPEN A TERMINAL AND TYPE THE FOLLOWING
    # $ cd
    # $ cd workspace/
    # $ cat ~/.ssh/id_rsa.pub
  # COPY AND PASTE THE OUTPUT TO YOUR GITHUB ACCOUNT SSH KEY SETTINGS
  # CALL IT SOMETHING LIKE "Cloud9"

# RUN THIS FILE
# OPEN A TERMINAL AND TYPE THE FOLLOWING
# $ cd
# $ cd scripts/
# $ bash setup.sh

# TLDR
  # cd
  # verify workspace/ is empty
  # cd workspace/
  # configure git
  # log into heroku
  # add key to heroku

# TODO
  # check git and heroku are installed
  # incrementing exit numbers

# Get flag arguments
# https://stackoverflow.com/questions/7069682/how-to-get-arguments-with-flags-in-bash-script
force=false
while getopts 'f' flag; do
  echo $flag
  case "${flag}" in
    f) force=true ;;
    *) error "Unexpected option ${flag}" ;;
  esac
done

# Change to ~ directory
cd
echo "$ cd $PWD"

# Change to workspace directory
cd workspace/
echo "$ cd $PWD"

# Verify contents of workspace is empty
ls=$(ls)
if [[ $ls != "" ]] && ! $force; then
  echo "workspace/ has contents, expected empty directory"
  echo "Please read the setup directions carefully before running script, exiting script"
  exit 1
fi

# Git setup

echo
echo "Git setup"
echo

# Get information
echo -n "First name: "
read fname
echo -n " Last name: "
read lname
echo -n "     Email: "
read email

echo "$ git config --global user.name \"$fname $lname\""
git config --global user.name "$fname $lname"
echo "$ git config --global user.email $email"
git config --global user.email $email


# Heroku setup

echo
echo "Heroku setup"
echo

# Log into Heroku
echo "$ heroku login"
heroku login

# Add key to heroku
echo "$ heroku keys:add"
heroku keys:add

echo "Finished"

# Successful script
exit 0
