ViATc
=====
ViATc - Vim mode at Total Commander.  
This software works on Windows and only as an addidion to "Total Commander" - the greatest file manager (keyboard friendly, two panels, advanced search, comparator, multirename, FTP, plugins) get it from www.ghisler.com  
ViATc tries to resemble the workflow of Vim and web browser plugins like Vimium or better yet SurfingKeys.

What ViATc does to Total Commander (called later TC):
- it's only a separate addition, easily disabled, it doesn't modify TC
- adds more functionality - supports all that AutoHotkey does, not just TC
- adds more shortcuts, user can add and configure shortcuts, in addition to Vim style, Emacs or any style can also be programmed-in



Installation
============
- You can download a compiled executable from https://magicstep.github.io/viatc/  
  A compiled executable most likely will be older than the current script version. 
- You can run the script if you have Autohotkey installed. Download and install Autohotkey, it is powerful for many purposes. https://autohotkey.com  
  To get the script download zip file from https://github.com/magicstep/ViATc-English/archive/master.zip, extract and you wil see the ahk script. To run it double-click viatc-0.5.4en.ahk
- Look for a new icon in the tray, right-click on it and choose Help.

Settings
========
Put the ini file into your Total Commander directory "c:\Program Files\totalcmd" or "c:\Program Files (x86)\totalcmd" 
Reload ViATc after any changes made in the ini file to take effect.
You can add and remove shortcuts directly in the ini file or via ViATc Settings window. After changes you must click Save before clicking OK.
In the ini file lines that begin with a semicolon ; are ignored. It's a standard comment in ini files.  
If you have mapped CapsLock as Escape in other AHK script you need to map it again in viatc.ini like this <CapsLock>=<Esc>


Usage
=====
A small subset of commands:

j  = down
k  = up
t  = open tab, same as ctrl+t
x  = close tab, same as ctrl+w
d  = directory hotlist, same as ctrl+d
u  = go up in directory, same as backspace
lk = go up in directory
lj = enter
aj = enter


Author
======
- Author of the original Chinese version is linxinhong https://github.com/linxinhong
- Translator and maintainer of the English version is magicstep https://github.com/magicstep  
  Alternatively you can contact me with the same nickname @gmail.com I know nothing about Chinese, I've used Google translate initially and then rephrased and modified this software. I'm just a junior in AHK.

This version is not perfected yet, any help appreciated.
