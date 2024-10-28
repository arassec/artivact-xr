# <img src="https://github.com/arassec/artivact-xr/blob/main/artivactxr-logo-white-text.png" width="256">

## About

"Artivact XR" is an application to bring virtual artifacts into the metaverse. 

It uses the Exports created by [Artivact](https://github.com/arassec/artivact) to display 3D models of previously scanned items, and presents them in virtual reality headsets like Meta Quest or Pico.

## Status

"Artivact XR" is currently in development and in a very early stage.

It has to be built and installed on headsets manually at the moment.


## Building

The app is developed using the free and open-source [Godot](https://godotengine.org/) game engine. 

<img alt="godot-logo" src="https://github.com/arassec/artivact-xr/blob/main/godot-logo-watercolor-text.jpg" width="512">

In order to build and Export it, the following steps are required:

* Checkout the Project from Github
* Open the Godot editor and Import the Project
* Follow the [setup instructions](https://docs.godotengine.org/en/stable/tutorials/xr/index.html#basic-tutorial) for XR projects
* Install the [Godot XR Tools for Godot 4](https://godotengine.org/asset-library/asset/1698) plugin from the asset library  
* Update the configuration file `android/build/gradle.properties` and add the path to the JDK at the bottom, e.g. `org.gradle.java.home=C:\\Users\\arassec\\.jdks\\temurin-17.0.9`

## License

This project is licensed under the [MIT License](https://github.com/arassec/artivact-xr/blob/main/LICENSE).