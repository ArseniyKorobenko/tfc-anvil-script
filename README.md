# tfc-anvil-script
An AutoHotkey script to automate anvil usage

## How to install
1. Click the green `<> Code` button
2. Click "Download ZIP"
3. Unpack the ZIP file

## How to use
1. Run the `anvil.exe` file
2. Press a key combination that you will activate the script with
3. Select your GUI scale
4. Click "Apply"
5. Open Minecraft **in windowed mode**
6. Select the recipe that you want to forge
7. Press the key combination that you inputted earlier

If your GUI scale is set to 1 or 2, enable the `Enter required strikes manually` checkbox  
With manual entry enabled, you will need to type in the names of the required strikes manually.  
Instead of full names, you can type in only their initials (without spaces)


## Troubleshooting
- Try setting a higher GUI scale. GUI scales 1 and 2 are buggy due to image compression
- Take screenshots of the required last hits by pressing `Win + Shift + S`, trim them in Paint,  
and replace the respective `order hit-name GUI-scale.png` file in the `img_files` folder
- If the `anvil.exe` file doesn't run, install AutoHotkey and run the `anvil.ahk` file instead
