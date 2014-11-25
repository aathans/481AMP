AMP
======
Ara's Musical Playground, or AMP, is a project created for a 5-year old named Ara.  Ara has Autism Spectrum Disorder (ASD) 
and as result has trouble grading movement and keeping her attention on one activity for long periods of time.  The goal of
AMP is to help improve these skills while maintaining a fun and relaxing environment.  The central tube of the structure can 
be pulled in different directions and different degrees, which in turn trigger different events.  This allows Ara to recognize
the differences between pulling light vs. pulling hard.  These events are blocked after a set time interval and can only be
reenabled by pulling the tube in the direction of the light that turns red.  This will keep Ara involved and her attention
focuesed on the sytem.

SETUP:
1. Plug Philips HUE hub into a router.
2. On the computer running the application, connect to this router.
3. Plug in Intel Galileo via USB to your computer.
4. Put the Standard Firmata sketch onto the board.
5. In AMPControlLightsViewController.m, set the NUM_LIGHTS constant to the number of HUE light bulbs you have and
TIME_INTERVAL to the number of seconds you want Ara to have to reactivate the music by pulling the tube.
6. Optional: Set the default properties of the lights in AMPControlLightsViewController.m and default brightness in 
AMPDataManager.m
DEFAULT_HUE: 0-65535
DEFAULT_SATURATION: 0-255
DEFAULT_BRIGHTNESS: 0-255 (must be the same in both files)
7. Run the application and when prompted connect your HUB and Galileo.
8. Enjoy!

Created By: Alex Athan, Justine Chen, Brandon Mazzara
