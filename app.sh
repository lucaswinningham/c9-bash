#!/bin/sh

# DO THE FOLLOWING BEFORE RUNNING THIS SCRIPT FOR THE FIRST TIME
  # VERIFY YOU HAVE RUN ~/scripts/setup.sh FOR YOUR WORKSPACE
  
  # PLACE THIS FILE IN THE ~/scripts DIRECTORY
    # OPEN A TERMINAL AND TYPE THE FOLLOWING
    # $ cd
    # $ cd scripts
    # $ touch app.sh
    # $ c9 app.sh
  # COPY AND PASTE THE CONTENTS OF THIS FILE IN NEWLY CREATED app.sh FILE, SAVE

# DO THE FOLLOWING BEFORE RUNNING THIS SCRIPT
  
  # CREATE A NEW GITHUB REPOSITORY AND COPY THE LINK
  # THE LINK WILL BE USED AS AN ARGUMENT FOR THE COMMAND

# RUN THIS FILE
# OPEN A TERMINAL AND TYPE THE FOLLOWING
# $ cd
# $ cd scripts/
# $ bash app.sh newappname https://github.com/your_git_username/newappname.git

# TLDR
  # TODO

# TODO
  # TLDR
  # argument checking
    # skip functions otherwise
  # check git installed and configured from setup.sh
    # skip git functions otherwise
  # check heroku installed and configured from setup.sh
    # skip heroku functions otherwise
  # incrementing exit numbers

# Change to ~ directory
cd
echo "$ cd $PWD"

# Change to workspace directory
cd workspace
echo "$ cd $PWD"

# Get app name and github repository
app=$1
git=$2

# Get arguments if they were not passed
if [[ $app == "" ]]; then
  echo
  echo -n "         App name: "
  read app
  echo -n "Github repository: "
  read git
elif [[ $git == "" ]]; then
  echo
  echo -n "Github repository: "
  read git
fi

# TODO: Argument checking such as app name non empty, starts with character etc.

# RVM setup
echo
echo "RVM setup"
echo

# Load rvm into shell session as a function
# https://rvm.io/workflow/scripting
echo "Loading rvm into shell session as a function"
if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
  # First try to load from a user install
  source "$HOME/.rvm/scripts/rvm"
elif [[ -s "/usr/local/rvm/scripts/rvm" ]] ; then
  # Then try to load from a root install
  source "/usr/local/rvm/scripts/rvm"
else
  echo "ERROR: An rvm installation was not found.\n"
  exit 2
fi
echo "rvm loaded"

# Install latest stable ruby version
echo "$ rvm install ruby --latest"
rvm install ruby --latest

# Get ruby version
# http://tldp.org/LDP/abs/html/x17129.html
# http://tldp.org/LDP/abs/html/string-manipulation.html
# https://unix.stackexchange.com/questions/63690/extracting-a-string-according-to-a-pattern-in-a-bash-script
echo "$ ruby -v"
ruby_v=$(ruby -v)
echo $ruby_v
ruby_v=$([[ $ruby_v =~ [0-9]+\.[0-9]+\.[0-9]+ ]] && echo $BASH_REMATCH)

# Make app gemset

echo
echo "Making $app gemset"
echo

# Check name collision with default gemsets
# Delete gemset on non default name collision
gemsets=$(rvm gemset list)
if [[ $app == "default" ]]; then
  echo "Cannot use app name 'default', exiting script"
  exit 5
elif [[ $app == "global" ]]; then
  echo "Cannot use app name 'global', exiting script"
  exit 6
elif [[ $app == "rails5" ]]; then
  echo "Cannot use app name 'rails5', exiting script"
  exit 7
elif [[ $gemsets == *"$app"* ]]; then
  echo "A gemset with name $app already exists:"
  echo "Script must delete gemset $app to continue."
  echo "Do you wish to delete the gemset whose name collides with $app?"
  echo -n "(anything other than 'yes' will cancel) > "
  read delete_gemset
  if [[ $delete_gemset == "yes" ]]; then
    echo "$ rvm gemset delete $app"
    rvm --force gemset delete $app
    gemsets=$(rvm gemset list)
    if [[ $gemsets == *"$app"* ]]; then
      echo "Unable to delete gemset $app, exiting script"
      exit 9
    fi
  else
    echo "$app gemset was not deleted, exiting script"
    exit 10
  fi
fi

# Create app gemset
echo "$ rvm gemset create $app"
rvm gemset create $app
gemsets=$(rvm gemset list)
if [[ $gemsets != *"$app"* ]]; then
  echo "Unable to create $app gemset, exiting script"
  echo $gemsets
  exit 5
fi

# Set new app gemset as default
echo "$ rvm --default use ruby-$ruby_v@$app"
rvm --default use ruby-$ruby_v@$app
gemsets=$(rvm gemset list)
if [[ $gemsets != *"=> $app"* ]]; then
  echo "Unable to set $app as default gemset, exiting script"
  exit 6
fi

# Show gemsets
echo "$ rvm gemset list"
echo $gemsets

# Rails installation

echo
echo "Installing rails"
echo

# Update bundler
echo "$ gem install bundler"
gem install bundler

# Run install
echo "$ gem install rails --no-ri --no-rdoc"
gem install rails --no-ri --no-rdoc

rails_v=$(rails -v)

# Catch bundle install message
if [[ $rails_v == *"bundle install"* ]]; then
  echo "$ bundle install"
  bundle install
  rails_v=$(rails -v)
fi

# Reset app gemset as default
echo "$ rvm --default use ruby-$ruby_v@$app"
rvm --default use ruby-$ruby_v@$app
gemsets=$(rvm gemset list)
if [[ $gemsets != *"=> $app"* ]]; then
  echo "Unable to reset $app as default gemset, exiting script"
  exit 7
fi

# Show gemsets
echo "$ rvm gemset list"
echo $gemsets

# App creation

echo
echo "Making new app $app"
echo

# Remove app directory if it exists
if [ -d "$app/" ]; then
  echo "$app/ already exists:"
  echo "Script must remove $app/ to continue."
  echo "Do you wish to remove the directory whose name collides with $app?"
  echo -n "(anything other than 'yes' will cancel) > "
  read remove_directory
  if [[ $remove_directory == "yes" ]]; then
    echo "$ rmdir -r $app"
    rm -r $app
  else
    echo "$app/ was not removed, exiting script"
    exit 13
  fi
fi

# Create app
echo "$ rails new $app --database=postgresql"
rails new $app --database=postgresql

# Delete .rvmrc if it exists
if [ -f "$app/.rvmrc" ]; then
  echo "$app/.rvmrc already exists, deleting"
  echo "$ rm $app/.rvmrc"
  rm $app/.rvmrc
fi

# Change to app directory
echo "$ cd $app/"
cd $app/

# TODO: Figure out why this does not work on fresh workspace
# Ignore rvmrc warnings
echo "$ rvm rvmrc warning ignore $PWD/.rvmrc"
rvm rvmrc warning ignore $PWD/.rvmrc

# Populate .rvmrc
echo "$ echo rvm use $ruby_v@$app > .rvmrc"
echo rvm use $ruby_v@$app > .rvmrc

# Do rvmrc conversion to .ruby-gemset and .ruby-version
echo "$ rvm rvmrc to .ruby-version"
rvm rvmrc to .ruby-version

# Bundle install
echo "$ bundle install"
bundle install

# Initial commit

echo
echo "Initial commit"
echo

# Initialize git
echo "$ git init"
git init
echo "$ git add ."
git add .
echo "$ git commit -m \"Initial commit\""
git commit -m "Initial commit"

# Add repository
echo "$ git remote add origin $git"
origin=$(git remote add origin $git)
echo $origin
if [[ $origin == *"fatal"* ]]; then
  echo "error adding git origin, exiting script"
  exit 14
fi

# Correct repository URL if necessary
echo "$ git ls-remote --get-url"
url=$(git ls-remote --get-url)
echo $url
if [[ $url != *"git+ssh:"* ]]; then
  if [[ $url == *"https:"* ]]; then
    link=${url/"https:"/"git+ssh:"}
    echo "$ git remote set-url origin $link"
    git remote set-url origin $link
  else
    echo "repository name has neither git+ssh nor https to replace with, exiting script"
    exit 15
  fi
fi

# Push initial commit
echo "$ git push origin master"
git push origin master

# Create welcome page

echo
echo "Creating welcome page"
echo

# Generate pages controller
echo "rails generate controller pages"
rails generate controller pages

# Create welcome view
welcome="app/views/pages/welcome.html.erb"
echo "$ touch $welcome"
touch $welcome

# Populate welcome view
hello_world="<h2>Hello World</h2>"
time_now="<p>The time is now: <%= Time.now %></p>"
echo "$ echo $hello_world > $welcome"
echo "$ echo $time_now >> $welcome"
echo $hello_world > $welcome
echo $time_now >> $welcome

# Overwrite Rails.application.routes.draw
routes="config/routes.rb"
routes_method="Rails.application.routes.draw"
root_path="root 'pages#welcome'"
echo "$ echo \"$routes_method do\" > $routes"
echo "$ echo \"  $root_path\" >> $routes"
echo "$ echo \"end\" >> $routes"
echo "$routes_method do" > $routes
echo "  $root_path" >> $routes
echo "end" >> $routes

# Welcome page commit

echo
echo "Welcome page commit"
echo

# Add, commit and push
echo "$ git add ."
git add .
echo "$ git commit -m \"Create welcome page\""
git commit -m "Create welcome page"
echo "$ git push origin master"
git push origin master

# Create heroku app

echo
echo "Creating heroku app"
echo

# Create on heroku
echo "$ heroku create"
heroku_create=$(heroku create)
echo $heroku_create

# Verify heroku create
if [[ $heroku_create == *"fatal"* ]]; then
  echo "Unable to create heroku app, exiting script"
  exit 16
fi

# Verify heroku app list
echo "$ git config --list | grep heroku"
heroku_list=$(git config --list | grep heroku)
echo $heroku_list
if [[ $heroku_list == *"fatal"* ]]; then
  echo "Unable to create heroku app, exiting script"
  exit 17
fi

# Push to heroku
echo "$ git push heroku master"
git push heroku master

# Run server

echo
echo "Running server"
echo

echo "$ rails s -b \$IP -p \$PORT"
rails s -b $IP -p $PORT

# Successful script
exit 0
