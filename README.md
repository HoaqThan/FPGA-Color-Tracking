# FPGA-Color-Tracking

## Picture Converter
Step 1: Put .png/jpg in `input`.  
Step 2: Open `cmd` in Picture Converter, then run the command python `image_process.py` for `image_rgb.txt`. 
<img width="1135" height="244" alt="image" src="https://github.com/user-attachments/assets/d0af1e02-cea1-48f2-99a3-d6c9635caf74" />
Step 3: Open Modelsim -> compile -> run tb... for `threshold_out.txt`.  
<img width="1291" height="211" alt="image" src="https://github.com/user-attachments/assets/0efed919-9a1c-4aac-b4f1-fe5aa7d20049" />
<img width="704" height="299" alt="image" src="https://github.com/user-attachments/assets/bd85455a-7a7e-4140-a012-5ab4d64159ff" />
Step 4: Open `cmd` in Picture Converter, then run the command python `restore_image.py` for Black White Picture.  
<img width="1308" height="301" alt="image" src="https://github.com/user-attachments/assets/a457bb44-5a7f-435b-bb5e-46fd246890e9" />
<img width="487" height="186" alt="image" src="https://github.com/user-attachments/assets/0c0b7633-6d89-4b49-a3f7-78c3791fcbe6" />

Compare:
Origin:
<img width="474" height="355" alt="sunrise" src="https://github.com/user-attachments/assets/09a31c9c-4738-4cfb-a0a7-ead0315a89e6" />

Convert:
<img width="640" height="480" alt="result" src="https://github.com/user-attachments/assets/3661fc34-ac6d-46f6-ba82-fbc32f6f5694" />

## Simulation
Step 1: Use `image_rgb.txt` for testing.  
Step 2: Open Modelsim -> compile all -> run tb... for Tracking Center.  

## Hardware
Hardware: OV7670 and Tang Nano 9k  
