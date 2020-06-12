ViATc
=====
ViATc - Vim mode at Total Commander.  
This software works on Windows and only as an addidion to "Total Commander" - the greatest file manager (keyboard friendly, two panels, advanced search, comparator, multirename, FTP, plugins) get it from www.ghisler.com  
ViATc tries to resemble the workflow of Vim and web browser plugins like Vimium or better yet SurfingKeys.

What ViATc does to Total Commander (called later TC):
- it's only a separate addition, easily disabled, it doesn't modify TC
- adds more functionality - supports all that AutoHotkey does, not just TC
- adds more shortcuts, user can add and configure shortcuts, in addition to Vim style, Emacs or any style can also be programmed-in



Usage:
=====
- The project website is https://magicstep.github.io/viatc/  
  You can download compiled executable from there. Compiled executable might be older than the current script version. 
- You can run the script if you have Autohotkey installed. Download and install Autohotkey, it is powerful for many purposes. https://autohotkey.com
  Download ViATc script from https://github.com/magicstep/ViATc-English/archive/master.zip, extract, go into "viatc-0.5.4" folder and double-click viatc-0.5.4en.ahk
- Look for a new icon in the tray, right-click on it and choose Help.

Settings
========
Put the ini file into your Total Commander directory "c:\Program Files\totalcmd" or "c:\Program Files (x86)\totalcmd" 
Reload ViATc after any changes in the ini file to take effect.
You can add and remove shortcuts directly in the ini file or via ViATc Settings window (you must click Save before clicking Ok).
In the ini file lines that begin with a semicolon ; are ignored. It's a standard comment in ini files.  
If you have mapped CapsLock as Escape in other AHK script you need to map it again in viatc.ini like below
<CapsLock>=<Esc>


Author
======
- Author of the original Chinese version is linxinhong https://github.com/linxinhong
- Translator and maintainer of the English version is magicstep https://github.com/magicstep  
  Alternatively you can contact me with the same nickname @gmail.com I know nothing about Chinese, I've used Google translate initially and then rephrased and modified this software. I'm just a junior in AHK.

This version is not perfected yet, any help appreciated.
