# Slides and code for the TechQuest 2024 in Lisbon



## Slides

The slides are written in Markdown.
The presentation file is `presentation.md` (there are other longer files but not actually used for that presentation as they contian too much infomartion for the time allotted)


From the Mardown file, you can get other files

* in HTML for presentaion
* in PDF for presentation
* in PDF for preparation with Table Of Content

To generate those files from the main Markdonw file, you can run:

```
make
```

Note that you will need marp and pandoc.


marp is written in nodejs
https://github.com/marp-team/marp-cli?tab=readme-ov-file#standalone-binary

and can be installed with binaries
https://github.com/marp-team/marp-cli/releases


pandoc is written in Haskell.


# to open links with eveince

you will have to follow:

https://askubuntu.com/questions/1379631/document-viewer-evince-fails-to-open-hyperlinks-in-a-pdf-document


```
sudo ln -s /etc/apparmor.d/usr.bin.evince /etc/apparmor.d/disable/ 
sudo apparmor_parser -R /etc/apparmor.d/disable/usr.bin.evince
```
