# firefly-iii-upgrade
Bash script to automatically upgrade Firefly III when running it on a Pi

# Assumptions
This assumes you are running Firefly III on something like a Raspberry PI (I've not tested it on other platforms), using apache2 (LAMP stack).

# Setup
Please configure the FIREFLY_DIR so that points to the locaiton of your local installation. If you are using apache2, the default is mostly correct.

# How it works
1 - Checks you are running as SUDO (required to create directories)
2 - Checks if a previous backup exists and prompts to delete it if it does
3 - Ask which version you want to install
4 - Downloads and sets up the requested version in a new directory
5 - runs all updates and datbase migrations
6 - Copies the existing installation to a backup directory call "firefly-iii-old"
7 - Copies the new install into the FIREFLY_DIR
8 - Restarts apache2 to make everything work ok

# TODO

1) Make it check the version entered is one that exists before continuing (ideas welcome as I'm not sure how to do this)
2) Add a backup script (I have a forked version of another script I'm currently using to backup to my NAS, but want a single point for everything you need here)
3) Add "undo" in case things break
