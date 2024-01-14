# Godot Core
Godot Core is a set of useful generic tools to use in Godot. It handles utilities essential for many games like showing menus/loading screens, changing scenes, playing audio and more.
This implementation is based on [UnityCore](https://github.com/coderDarren/UnityCore), the original implementation was designed to be used with Unity Engine, but I've adapted it for Godot 4.1.1, mainly for personal use, but I'm making this public in case someone wants to use it.
#### Notes:
- Feel free to use this as a starting point in your project and expand upon it.
- Some parts of the implementation might not be optimal.
- C# Version: [GodotCore](https://github.com/xaqui/GodotCore)

## Requirements
- Godot 4.1
 
There are 5 categories of tooling in this package:
```
1. Menu Management
2. Audio Management
3. Scene Management
4. Data Management
5. Session Management
```
Let me give you a brief overview explanation of each system. If you need a more detailed explanation of the implementation, I highly recommend watching the video tutorials by the original authors of UnityCore. I will include links to the videos below.

### Menu Management
Let's you switch between a set of user defined Pages with the option to add fade in/out animations. 

 Tutorial: https://youtu.be/qkKuGmGRF2k

### Audio Management
Play, Stop or Restart sounds. 
I encourage you to check out the example scene set up in the project and/or take a look at the video tutorial below with the original implementation to learn more about the design.

Tutorial: https://youtu.be/3hsBFxrIgQI

### Scene Management

The Scene Controller allows to switch between scenes and susbscribe to scene load events. You can choose to add menu management by specifying a PageType.
For adding a new scene to the possible scenes to load, the user must manually define its Scene Type and hardcode the path in the SceneController.

Tutorial: https://youtu.be/4oTluGCOgOM

### Data Management

In this case, the Data Management system was not based on the original UnityCore implementation, instead it was based on another implementation which does the same and also provides the feature to store data on a local file, serializing the data to JSON. I learned about this system from Trever Mock on his video tutorial. If you want a detailed explanation or learn more about this design, I'd recommend watching it.
* This data management system supports optional encryptation of the saved file's contents. Make sure you're not trying to read from an encrypted file when you have encryptation disabled and vice versa or you'll get an exception.

Tutorial: https://youtu.be/aUi9aijvpgs

### Session Management

System to help you keep track of data useful during current session. Things like session start time, current fps... Expand this system with any session data specific to your project.

Tutorial: https://youtu.be/M6xy272-axM


