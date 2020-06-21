# HotStringManager
An AHK based applet, that enables you to activate/create/maintain hotstrings on the fly in any text input situation.  
  
General notes: 
--------------  
The current design of the code is to run in "script mode" and not in a standalone ".exe" mode for the sake of flexibility.  
(Creating a standalone version might need some tweaking/testing)  
As I was developing it for private use originally, I will need to allocate time to create proper documentation of how it works,  
but if you understand AHK language, you can easily find the asnwers for yourself. (if not, feel free to ask me)  
The app is currently in Hungarian language, but this does not affect usability much. (I will create a translation soon)  

Files:  
-----  
The app consists of two files:  
  HotStringManager.AHK (script)  
  GeneralHotStrings.txt (database) 
  
Usage:  
----- 
Use it while being in a text input field either browser/office/etc.  
Any hotstrings from its database are fired globally, but there is a toggle hotkey to turn them off temporarily.  
You can either add new entries automatically or via a sophisticated popup.  
Either of them should be evoked after typing the new expression you would like to add.  
Hotkeys:  
Ctrl+Shift+- : Opens an intuitive menu for adding/managing new hotsrting abbreviations, based on the last word you were typing.  
Ctrl+- :Automatically adds a hotstring to the database, without opening the popup menu. (The abbreviation will be based on a predefined logic)  
Ctrl+Insert::Reload (this I recommend changing to something else, I will do so in a future version)  
Alt+CapsLock:: Toggle hotstring firing

----------------  
Adam Bukovinszki
---------------- 

