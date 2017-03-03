Welcome to the RisingSeas Source!
========================

This is the main source code repository for the RisingSeas project. It contains all the necessary assets and source necessary for the project to be opened and run with the Stingray game engine. 

# Latest changes

Updated the project to the latest version of Stingray, v 1.7

# Quick start for new users

The following steps are a shorthand guide to getting started, aimed at someone familiar with using Stingray. It will help you get started and create an additional location in the context of the RisingSeas project.

Please note that some assets, including 3d models, textures and audio files are missing from the project because they cannot be distributed under the Creative Common license. In most cases, the source of the missing asset is indicated, or, in the case or audio, the triggers are simply left empty.

## Step 1. Install prerequisites

-   Autodesk Stingray v1.6
    -   Product Overview: http://www.autodesk.com/products/stingray/overview
    -   Trial Download: http://www.autodesk.com/products/stingray/free-trial
-   Git client: <https://git-scm.com/>
    -   Git LFS 1.1.1 or greater: <https://git-lfs.github.com/> 

## Step 2. Get a local copy of the source

You will need to clone a local copy of this repository, using:

```
git clone https://github.com/humanimpactlab/Rising-Seas
```

And you should have everything you need to get started!

## Step 3. Opening the Stingray Project

-   Launch Stingray
-   In the Stingray ProjectManager, under the "My Projects" tab, click on "Add Existing" and browse you the "RisingSeas" folder where you cloned the git repository. Select the rising_seas.stingray_project file and click Open.
-   The project will open. Wait for it to compile (this can take several minutes).
-   On the left side of the Level Viewport, click on "Run Game".


# Adding a new Location

There are various mechanisms put in place in the RisingSeas project to facilitate the addition of a new location. This section will run through the Steps to follow to add a new location and provide explanations of the behind-the-scenes mechanisms that take place.
In this exmaple, we will use "ExampleCity" as out new location.

1. Create a new level called "ExampleCity.level" in the content/levels/ExampleCity folder. It is important for the new level name and new folder name to match. 
2. Open cities.ini, and add an entry for the ExampleCity:

--------------
    ExampleCity = {
        label = "MyCity"
         location = [90, 90]
         scripts = {
             example_class = "content/levels/ExampleCity/scripts/example"
             flow_callbacks = "content/levels/ExampleCity/scripts/flow_callbacks"
         }
    }
--------------
The location represents the Earth coordinates of the city, in longitude and latitude. In this case, the city will be located at the North pole. The option "label" entry will be the label associated to the city in the World level.
Here you define which scripts will be included when the level is loaded. If the script contains a class as defined by the example_class.lua. If a script does not implement a class, it will smply be "required" and available to be used, like in the case of custom flow nodes associated to a level.

3. You are done!

Your new location should now appear in the World level, as a new pin! From here, you are free to leverage the entire power of Stingray to customize your level, its content and behavior, using the other levels as examples! It is recommended that you follow the established file structure to keep things clean and organised.


# An overview of the project Structure

As with all Stingray projects, the root of the project is where the settings.ini file is located. The settings.ini file for this project is unmodified, in the default state from Stingray. The same can be said of the boot.package file, that indicates what resources to load when launching the project. The " * = ["*"] " line in boot.package indicates that everything will be loaded when the project is launched.

The project file Structure is as follows:
- Root
    -   components: Where new project-specific compnents should be located. These are common to the entire project.
    -   content: Contains all the content for the entire project, including assets, models, geometry, etc. 
         -   audio: Contains all common Audio assets
         -   levels: Contains every level of the project, each in a seperate folder. 
             -   World: Contains the initial level, World.level, and all the assets associated to that level. This is the level that is loaded when the project is launched
             -   Other Folders: Every other folder here contains a separate location, and all their associated assets, accessible from the World level. 
         -   Other folders: These contain shared assets, such as the water, that can be used accross multiple levels
    -   core: A copy of the Stingray "core" folder, with few modifications. This was only modified to implement "fading" between levels and should be removed in later versions.
    -   script: This folder contains all the common scripts for the projects, as well as custom flow nodes. More details in a later section. 
    -   ui: Contains the Scaleform project for the RisingSeas User Interface (ui)

    -   boot.package: The initial package to be loaded at runtime
    -   settings.ini: The default settings for the project
    -   global.physics_properties: The default physics layers and interactions or the project
    -   cities.ini: This is where you will define new locations to be added to the World. More in the "Adding a new location" section

The Basics: Flow Interactions

Most interactions in the RisingSeas project has been implemented using the Flow visual programming language. We recommend using Flow for user interactions (or "Gameplay") wherever possible to keep the project in a consistent state and to make behavior modifications accessible.
Each Location, or city, in the RisingSeas project is represented by a level in Stingray.
Behaviors are implemented in the Level Flow, to allow different locations to behave differently. For example, the San Francisco location can share the Story of different characters in the scene, while the New York location could potentially provide a fly-through of the city. Because all of the behaviors and interactions are implement in the level itself, there are no dependencies between each level.

About the "Levels" folder

Every new location in RisingSeas should be added to a new folder here. A new location folder shuld be named after the new location and contain all the assets needed for the entire level to work (except for common assets). These include 3D models, textures, custom flwo nodes and scripts, following the ExampleCity file structure.

About the "scripts" folder

The "scripts" folder contains all the shared scripts throught the projects, as well as any shared custom flow node definitions. The project.lua script is the entry-point 
The common scripts in the RisingSeas project are mostly there to provide utilities and glue the different levels together.
The following scripts are included in this folder:
    - projec.lua: The Entry-point for the RisingSeas project. Il will handle loading shared script into the Project.components table, which will then automatically get started, updated and shutdown at the appropiate time. 
    - flow_callbacks.lua: Implementation of common custom flow nodes
    - input.lua: An abstraction layer to handle different inputs
    - lua_utility.lua: Various utility functions
    - math.lua: An extension of math functions
    - city_loader.lua: A class that handles the loading of scripts and assets associated to a level, after it is selected. See "Adding a new location"
    - appkit_utility.lua: Provides various utility functions for interacting with the AppKit
    - effects.lua: Provides various utility functions to add visual effects
    - package_loader.lua: resolves the loading of packages in the project
    - schedueler.lua: A class that provides an interface to different schedueling tasks such as Coroutines and Timers
    - scipt_loader.lua: A class that handles loading all scripts associated to a level.
    - ui_manager.lua: A class that handles interactions with the UIScaleform project.
    - example_class.lua: A template to create new classes that will be conveiniently handled by the project. A class implemented in this fashion will automatically have its init(), start(), update() render(), exit() and shutdown() functions called.

About the "ui" folder

This folder contains the Scaleform project used to create all the User Interface used in the RisingSeas Project. Each Location is representated by a Scene in the Scaleform project. This should eventually be depricated and moved to the new Stingray UI solution.

## How you can contribute

There are many improvements that can be made to the RisingSeas experience. Contributions can be separated into two categories:

-   Code Contributions: Improvements and additions to the overarching project structure and capibilities. Current needs under this category include
    -   Better memory management and dynamic loading
    -   Updates to latest Stingray versions
    -   Improved interactions
    -   Bug fixes
    -   Migration to the new Stingray Entity/Component system
    -   Removing the "core" folder and using the new Stingray system to implement "fading" between levels.
    -   Support for more platforms (iOS, Android, WebGL, etc)
    -   Migrating the Scaleform Project to the new Stingray entity-based UI solution.
    
-   Content Contributions: Contributions made to add to and improve existing content, including assets, models, textures, etc.
    -   Addition of new locations
    -   Improvements of current content (City geometry, textures, characters, trees, water, etc)


## Stay in touch!

Your feedback and contribution is essential in making this project a success! 
