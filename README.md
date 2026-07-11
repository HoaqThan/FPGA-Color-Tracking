# FPGA-Color-Tracking

## Picture Convertor
Step 1: Put .png/jpg in `input`.  
Step 2: Open `cmd` in Picture Convertor then command python `image_process.py` for `image_rgb.txt`.  
Step 3: Open modelsim -> compile -> run tb... for `threshold_out.txt`.  
Step 4: Open `cmd` in Picture Convertor then command python `restore_image.py` for Black White Picture.  

## Simulation
Step 1: Use `image_rgb.txt` for test.  
Step 2: Open modelsim -> compile all -> run tb... for Tracking Center.  

## Hardware
Hardware: OV7670 and Tang Nano 9k  
