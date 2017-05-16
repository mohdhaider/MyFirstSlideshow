# MyFirstSlideshow

For people who browse random repositories (hello by the way), this is just a technical exercise and reflects how projects are developed in a lot of companies. Someone write some code based on some specifications, someone else review the code then it get merged when everyone is happy. Then the specifications changes and an issue is created and someone needs to fix that.

Please read this document entirely before continuing the exercise.  
Failure to comply to these rules will result in the forfeit your application.

- Don’t fork the project
- Don’t submit a Pull Request on the repo
- Don’t comment on any of the issues or Pull Existing Requests

This "app" is a rather simple one.
It only one screen divided into two areas. The app should display images an array of 4 elements
``` 
["https://c1.staticflickr.com/6/5615/15570202337_0e64f5046e_k.jpg",
 "https://c1.staticflickr.com/4/3169/2846544061_cb7c04b46f_b.jpg",
 "https://i.redd.it/d8q1wkgu1awy.jpg",
 "http://www.kapstadt.de/webcam.jpg"]
 
  // Images under Creative Commons 
  // Images attributed to (in order) https://www.flickr.com/photos/_torne/
  // https://www.flickr.com/photos/chrisyarzab/
  // https://www.reddit.com/user/lalien42/
  // http://www.kapstadt.de/
```
(PS. the last one is temporary as we will create new service which will help this exercise)

The two areas will work the same way. Each of them will have a button to cycle to the next image, an index indicator and a zone to display the image. 

The branch "slideshow" is currently respecting the above "specifications" but with some caveats.
