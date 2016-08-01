# How to use this example bootstrap

## Basic setup

1. Run a search and replace for `site-name.dev` to whatever the subdomain for your development site will be
2. Run a search and replace for `site_name` to whatever the database name for your development site will be
3. Run a search and replace for `Site Name` to whatever the human readable name for your development site will be
3. Git clone a copy of your client site repo so it is in this directory and named `wp-content`; example command: `git clone --recursive https://github.com/wpcomvip/your-repo.git` (you will need to replace `https://github.com/wpcomvip/your-repo.git` with the URL for your repo: On GitHub, navigate to the main page of the repository, then under your repository name, click "Clone or download") 

If you want to package these instructions for other developers in your team:

1. Remove these initial instructions, leaving the "Development environment bootstrap" heading and everything below it
2. Amend the "Development environment bootstrap" heading and paragraph below so it reflects your purpose for the particular development environment
3. Test everything works as expected in a [VVV](https://github.com/Varying-Vagrant-Vagrants/VVV/) context
4. Copy or `git push` to a new repo or new branch in an existing repo
5. Point people towards the `readme.md` in the repo you pushed to, so they can get going

# Development environment bootstrap

This site bootstrap is designed to be used with [Varying Vagrants Vagrant](https://github.com/Varying-Vagrant-Vagrants/VVV/) and a WordPress single site, the code for which is stored as a monolithic (or submoduled, probably) Git(Hub) repo.

To get started:

1. If you don't already have it, clone the [Vagrant repo](https://github.com/Varying-Vagrant-Vagrants/VVV/) (perhaps into your `~/Vagrants/` directory, you may need to create it if it doesn't already exist)
2. Install the Vagrant hosts updater: `vagrant plugin install vagrant-hostsupdater` [1]
3. Clone this repo into the `www` directory of your Vagrant as `www/site-name`
4. If your Vagrant is running, from the Vagrant directory run `vagrant halt`
5. Followed by `vagrant up --provision`.  Perhaps a cup of tea now? The initial provisioning may take a while.
6. If you want the user uploaded files, you'll need to download these separately

Then you can visit: [http://site-name.dev/](http://site-name.dev/)

[1] If you do not install the Vagrant hosts updater, you will need to manually alter your `/etc/hosts` file yourself

This script is free software, and is released under the terms of the <abbr title="GNU General Public License">GPL</abbr> version 2 or (at your option) any later version. See license.txt.
