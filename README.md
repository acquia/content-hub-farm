# content-hub-farm
Builds a Content Hub Docker Farm of multiple Drupal sites (publishers and subscribers) for development purposes using the same 
codebase.
It allows you to debug on any of the sites without having to switch your IDE code scope. See your code changes 
automatically on every site in the farm by modifying code in a single location. 

It creates a network of Drupal Muti-sites, each one of them on a different container, all connected together to the same Content Hub Subscription.

If you need more sites, just run the setup command, alter the number of sites and re-run the farm. That's pretty much all you 
need to do.
You can make your sites persist next time you restart the farm. 

The purpose of this project is to be able to develop Content Hub without having to spend time on building sites or 
doing any site configuration.

## Building steps

- Download and install [Docker Desktop](https://www.docker.com/products/docker-desktop).

- Download and install [Ngrok](https://ngrok.com). You will need a paid version if you want to use multiple domains.

- Download and install [Composer](https://getcomposer.org/).

- Clone this repository.

        $git clone git@github.com:abarriosr/content-hub-farm.git
        $cd content-hub-farm 
        
- Execute the "go" command:

        $./chf go
        
  That's pretty much it. This command will ask you some questions about your Configuration:
  
   - If you want to enable **NFS mounts**. We recommend you do. You would normally always want to do do this because 
     there are a lot of performance gains when accessing an NFS mounted volume instead of using the native docker mount.     
   - Your Acquia Content Hub Credentials,
   - Go to your [Ngrok dashboard page](https://dashboard.ngrok.com/auth) and obtain your **ngrok token**. You will need 
     to provide that information throughout the questions. Make sure the domains (hostnames) you are adding for your 
     publishers/subscribers are available Ngrok sub-domains. 
   - For your publishers or subscribers, you don't need to insert anything in the Environment Variables for PHP Debug,
     The script will make best guesses about those. You can always change them later.
   - If you want to build Acquia Content Hub from public repositories, you can choose that option, otherwise you can
     choose private and provide a branch name from Acquia's private repository. 
   - If you have created a custom "build profile" in **"bin/profiles"**, you can select that one from the list.  
       
   It will create a **docker-compose.yml** and **~/ngrok2/ngrok.yml** files, taking backup copies of existing
   files, if there were any and do the whole building and installation for you.
         
## Using the Content Hub Farm Control Script

  Use the Content Hub Farm Control Script for anything you do to control your farm of sites: 
 
        $./bin/chf <COMMAND> <COMMAND-ARGUMENTS>  ; General format 
        
        $./chf build       ; Build or rebuild service containers.
        $./chf build_code  ; Build or rebuild Site's source code. 
        $./chf setup       ; Sets up the environment and creates docker-compose.yml and ngrok.yml files.
        $./chf up          ; Create and start containers.
        $./chf start       ; Start services.
        $./chf stop        ; Stop services.
        $./chf restart     ; Restart services.
        $./chf pause       ; Pause services.
        $./chf sh          ; Opens a bash terminal inside the container.
        $./chf logs        ; View output logs from containers
        $./chf down        ; Stop and remove containers and networks.
        $./chf down -v     ; Stop and remove all above plus volumes. If used, It invalidates the persistent feature in sites.

  You can also execute operations on the containers:
 
        $./chf <CONTAINER> <COMMAND> <COMMAND-ARGUMENTS> ; General format.
        
        $./chf <container> enable_xdebug ; Enables Xdebug in container.
        $./chf <container> drush status  ; Executes 'drush status' on site installed in this container. You can execute any drush command.
                        
  Use this command every time you need to interact with the farm.
  For more instructions on how to use it, you can list all commands. 
 
         $./chf list-commands   ; Lists all available commands.
         
  Executing the control script without any arguments presents a list of containers, or you can also do:
  
         $./chf images          ; Lists all available containers.
  
  Use this script to enable/disable Xdebug, execute drush commands, etc.    
 
  Access your sites: 
            
         $./chf <container> url                     ; Opens the site URL in a browser.
         $./chf <container> sh                      ; Opens a bash terminal to the container.
         $./chf <container> exec <command>          ; Execute any command inside the container.

  Import/Export Site's Database:  
            
         $./chf <container> import-db database.gz     ; Imports a compressed database SQL file into the container. 
         $./chf <container> export-db database.sql.gz ; Exports database from container into an gzip compressed SQL file. 
            
  Run tests inside the containers:
  
         $./chf <container> test html/web/modules/contrib/acquia_contenthub/tests/src/Kernel/ClientFactoryTest.php       ; Runs this test using PHPUnit.                         
        
## Reinstall a particular site

You have two options, either manually modify the **docker-compose.yml** file and change the value of this property in 
all the sites you need to re-install to **false**.

          - PERSISTENT=false
          
Then just restart the services:

        $./chf restart     ; Restart services.

Alternatively, instead of doing that, because it uses Drupal multi-sites configuration, you could just delete the 
site directory in **./html/web/sites/\<YOUR NGROK DOMAIN\>** and restart the services and this will have the same effect.

Remember that if you keep your configuration with **PERSISTENT=false** it will reinstall the site every time you start 
the services.   
        
## PHP Debugging

You can debug any site in the farm from the same codebase. To do that, you need to enable Xdebug in the container. 
Notice that you IDE code will remain the same because all of them have the same code, you are just activating which 
site will be creating the debug session. 
You can disable Xdebug later when you dont need it:

        $./chf <container> enable_xdebug  ; Enables Xdebug in container.
        $./chf <container> disable_xdebug ; Disables Xdebug in container.

The following are the important PHP Environment variables you need to adjust if you want to debug from the Command Line.
The default values provided by the "setup" command should be enough but you can change them if your local configuration
is different (Ex: Port 9000 is taken and you need to use another one). 

    - PHP_IDE_CONFIG
    - XDEBUG_CONFIG

You can modify them straight in the *docker-composer.yml* file or in the file **./setup_options.sh** (which stores 
answers to all the questions provided during the normal setup process). If you modify the last file, you can do:

    $./chf setup --fast      ; Creates the docker-compose.yml and ngrok.yml files.
    $./chf restart           ; Restart services.
    
The **--fast** option avoids asking you again and just reads from the stored answers in that file, using that 
information to create the configuration files. Depending on what changes you made you might need to recheck your 
ngrok setup too. 
    
It is good to keep xdebug disabled (default option) if you are not actively debugging because that speeds up PHP processing times.     

If you feel like you need more guidance into how to configure your environment for PHP Debugging, use this guide: 
https://thecodingmachine.io/configuring-xdebug-phpstorm-docker. When you are following the guide, make sure you create a 
server name with your docker instance's name so it can map it correctly.

Also, if you need to make changes to the Xdebug configuration stored in the containers, you can modify the file 
**./config/00_xdebug.conf**. Notice that after customizing this file, you need to push it inside the containers, which 
means you have to rebuild them. Don't worry, if your sites are persistent (All of them are by default) they will not be
affected by this set of commands:

        $./chf build       ; Build or rebuild service containers.
        $./chf up          ; Create and start containers.

## Adding more publishers/subscribers:

The easiest way to do this is by executing the **go** command again and reconfigure your system, adding
more publishers/subscribers. Alternatively you can also do:

        $./chf setup       ; Sets up the environment and creates docker-compose.yml and ngrok.yml files.
        $./chf build       ; Build or rebuild service containers.
        $./chf up          ; Create and start containers.
        
Those set of commands will reconfigure your system, build the containers and run them without changing the source
code. 
  
If you feel like you want to modify the docker-compose.yml by hand, this is what you need to do to add more sites.
Just add entries to the **docker-compose.yml** and **ngrok.yml** files. 
Those entries have to be paired together. Then run the Content Hub Farm as explained above without the **setup** command.

- Add entries into the docker-compose.yml file. For example, a second subscriber could be done by adding the following 
lines:

    ```  
      subscriber3:
        # The hostname has to match the declaration in **ngrok.yml** 
        hostname: subscriber3.ngrok.io
        build:
          context: .
        depends_on:
          - database 
        environment:
          # There are two sites roles: 'publisher' or 'subscriber'.
          - SITE_ROLE=subscriber
          # If persistent, the site will persist through `./chf up`
          # Otherwise, the site will be re-installed.
          - PERSISTENT=true
          # The Drupal profile you wish to install (defaults to "standard")  
          - DRUPAL_PROFILE=standard   
          # Content Hub Client Name (Has to be provided to connect to Acquia Content Hub).
          - ACH_CLIENT_NAME=subscriber2-docker
          # These are your Acquia Content Hub Credentials (override what is defined in database)  
          - ACH_API_KEY=00000000000000000000
          - ACH_SECRET_KEY=1111111111111111111111111111111111111111
          - ACH_HOSTNAME=https://plexus-dev.content-hub.acquia.com
          # These are your Xdebug parameters.
          - PHP_IDE_CONFIG=serverName=content-hub-farm_subscriber1_2
          - XDEBUG_CONFIG=remote_port=9000 remote_autostart=1
        volumes:
          - html:/var/www/html
        ports:
          # The port has to match the declaration in **ngrok.yml**
          - 8083:80
        networks:
          ch_farm:
            ipv4_address: 192.168.1.12
    ```
- Add more entries into the ngrok.yml file, for example for the second subscriber above, you could do:

    ```     
       subscriber3:
          proto: "http"
          addr: "8083"
          hostname: subscriber3.ngrok.io
          host_header: subscriber3.ngrok.io
    ```
  
## Build Profiles:

The Code build process can be customized with build profiles. By creating a new profile, you can customize the list of 
composer packages and hence Drupal core version and modules you will have available in your codebase. 
You can build your codebase by executing this command:

      $./bin/chf build_code <source> <Content Hub version> <Drupal Core version> <Build Profile> ; Build or rebuild Site's source code.

      Where:
        - source: "public" (Using Drupal.org repository), or "private" (Using Acquia's private repository). 
        - Content Hub version: If using "public" then something like "^2", if using "private" use the branch name like "LCH-XXXX".
        - Drupal Core version: Examples: "^8" or "9.0.0-beta2".
        - Build Profile: If not given it uses the "default" profile, located in "bin/profiles/default.sh"  

To customize a "build profile", copy the file "bin/profiles/default.sh" and customize it:

      $cp bin/profiles/default.sh bin/profiles/custom.sh  
      
You can modify the **./bin/profiles/custom.sh**. Edit the contents and add/modify your own list of 
  composer packages in this part of the file:

        # You can modify the list of packages defined in this block.
        # -------------------------------------------------------------
        COMPOSER_MEMORY_LIMIT=-1 composer require drupal/entity_browser \
          && COMPOSER_MEMORY_LIMIT=-1 composer require drupal/features \
          && COMPOSER_MEMORY_LIMIT=-1 composer require drupal/paragraphs

        if ! ${DRUPAL_9} ; then
          # Only install these packages if it is not Drupal 9.x
          COMPOSER_MEMORY_LIMIT=-1 composer require drupal/view_mode_selector
        fi
        # -------------------------------------------------------------
              

If executing the `./chf go` command, it will ask you which build profile you want to use. You can select **"custom"** from 
the list. Just make sure to keep the input parameters the same when doing your customizations.  

If you don't want to execute the whole installation and just want to build your code base, you can do the following:

- Stop all running containers. 

- Build the new codebase by executing your custom build profile:

        $./chf build_code private <ACH-BRANCH> ^8 custom
  

## Modifications to the docker container:

- If you don't want to modify the code but would like to customize the docker container then you can edit the file 
  **"Dockerfile"** and rebuild the containers with the following command:

        $./chf build 
        