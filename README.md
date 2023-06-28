# **AI CAMERA**

This app detects the object from the list of specified objects and auto-zooms to fit them to the screen-size. The demo below will provide a better understanding of its functionalities and features.

# Demo 
 Since github does not allow any GIF of size greater than 5MB to be displayed in README.md. The video quality in demo below is reduced because of compression of GIF.
 
![Demo Gif](https://s12.gifyu.com/images/SQV4p.gif)

# My Implementation

* Selection of an object from the home page from a list based on the “labels” file of the tensorflow lite model.
* The camera image stream provides the data to the tensorflow lite model which gives output in the form of recognitions.
* The selected object is filtered out from all the recognized ones.
* Then the zoom value is calculated based on the aspect ratio and dimensions of object and device.
* Finally a smoothing function is used which converts the discrete zoomLevels of the image stream to the steady value using medians and standard deviations.
* Moreover an object detection box is stacked over the object to elaborate its detection and confidence level.
* Image capture and image save (The captured image will have the zoom factors and everything else but the object detection box on top of it (one with the orange color) will be filtered out as it is only meant to assist the user while taking image).
* Added a floating action button in the home screen to view the gallery of the app.
* Latest captured image preview beside the image click button in the camera screen which opens the gallery.

