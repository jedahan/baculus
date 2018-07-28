## Baculus Build Log

### Software

This is a log on how to setup a raspberry pi with everything you need to create your own baculus node. 

### Preparation

To build a node, we gathered the following materials:

* computer running macOS (linux is also supported)
* raspberry pi 3 model b+ (model b also supported)
* microSD card + SD adapter
* wireless access point connected to the internet
* [PiBakery application](https://github.com/baculus-buoy/pibakery/releases)
* baculus buoy [pibakery-recipe](https://github.com/baculus-buoy/baculus/blob/master/pibakery-recipe.xml)

### PiBakery

We will be using our own version of PiBakery to burn the initial SD card, as it is cross-platform and allows easy customization of build images. First, download the latest version from our [releases page](https://github.com/baculus-buoy/pibakery/releases). We used v0.3.10, which is available as a direct download for [macOS](https://github.com/baculus-buoy/pibakery/releases/download/v0.3.10/PiBakery-darwin-x64.zip) and [linux (64-bit)](https://github.com/baculus-buoy/pibakery/releases/download/v0.3.10/PiBakery-linux-x64.zip) as well as other architectures.

![permissions](images/1_permissions.png)

When you first open PiBakery, it will ask for administrator permissions, this is to access your sd card to write later.![2. blank](images/2_blank.png)

Once that is out of the way, you are greeted with a blank screen. We have created a recipe that needs to be edited a bit to work on your network. Make sure to downloaded the latest [pibakery-recipe.xml](https://raw.githubusercontent.com/baculus-buoy/baculus/master/pibakery-recipe.xml), then click import, and choose it.

![import](images/3_import.png)Once imported, you should see the blocks of what exactly will run on the pi on first boot, and on every boot.![4. imported](images/4_imported.png)

Now, edit NUMBER_HERE, YOUR NETWORK HERE, and YOUR PASSWORD HERE. This is a one-time requirement to get all the necessary software on first boot. 

![configured](images/5_configured.png)

Next, click Write in the top right corner, and you will be greeted with a SD card and Operating System chooser. If this is a blank SD card, your Operating System should prompt you to format it. Make sure to give a memorable name (we use '**boot**'), and select **Raspbian Lite**.

![sd](images/6_sd.png)

Click Start Write, and make sure the same exact name is in the popup.

![confirmation](images/7_confirmation.png)

Once it is done written, pop it into the pi. If you have a screen attached you should be able to watch the entire process, otherwise just wait a few minutes (ours took 15 minutes) until you see a 'baculus' wifi network up.

![wifi](images/8_wifi.png)

You can connect to this network and start chatting!