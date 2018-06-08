# Getting up and running

Step 0: Read the docs

VVV2 [Adding a New Site](https://varyingvagrantvagrants.org/docs/en-US/adding-a-new-site/)

Step 1: Add your site to  `vvv-custom.yml`

Add a site block into `vvv-custom.yml`, like this:

``` yml
  name-your-site-here: 
    repo: https://github.com/Automattic/vvv-vip-go.git
    branch: master
    hosts: 
     - name-your-site-here.test
    custom:
      vip-repo: git@github.com:wpcomvip/demo.git
      vip-branch: master
```

* Subsitute `name-your-site-here` with the name of your site, this will be used for the directory and will be the basis of the database name
* Add the HTTP hosts (domains) you need into the `hosts` array
* You always want to leave the `repo` and `branch` values as they are above, because this is the provisioning script for VVV VIP Go
* Add your VIP Go client repo into `custom > vip-repo`
* Add the branch you want to use in your VIP Go client repo into `custom > vip-branch`

For comparison, you'll end up with something like this:

``` yml
  vip-go-demo: 
    repo: https://github.com/Automattic/vvv-vip-go.git
    branch: master
    hosts: 
     - vip-go-demo.test
    custom:
      vip-repo: git@github.com:wpcomvip/demo.git
      vip-branch: master
```

Save your `vvv-custom.yml`

Step 2: Re-Provision your VVVV

``` bash
vagrant provision
```

or, on a fresh install

``` bash
vagrant up --provision
```

When finished, your VIP site will appear on the dashboard at http://vvv.test and at the hosts specified
