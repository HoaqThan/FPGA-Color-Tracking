# FPGA Color Tracking

> Consolidated README generated from the previously drafted sections.

## 1. Project Description

### 1.1 Introduction

This project implements a real-time FPGA-based color tracking system
using the OV7670 camera and Tang Nano 9K FPGA development board. The
system captures RGB565 image data, processes it through an HSV-based
color detection pipeline, tracks the detected object, and generates
tracking information.

The repository includes RTL modules, simulation projects, and Python
utilities for image conversion and restoration.

### 1.2 Objective

-   Implement FPGA-based real-time color tracking.
-   Process RGB565 image data using HSV thresholding.
-   Detect and track colored objects.
-   Verify RTL modules through simulation.
-   Support preprocessing and postprocessing with Python.

------------------------------------------------------------------------

## 2. Features

-   Real-time FPGA color tracking
-   RGB565 image processing
-   HSV threshold detection
-   Object center calculation
-   Bounding box generation
-   Safe-zone detection
-   VGA display output
-   Python image conversion utilities
-   RTL simulation projects

------------------------------------------------------------------------

## 3. System Overview

The design is organized as a streaming image-processing pipeline:

``` text
OV7670 Camera
      │
      ▼
Camera Configuration
      │
      ▼
RGB565 Input
      │
      ▼
Clock Synchronization
      │
      ▼
HSV Threshold
      │
      ▼
Object Tracking
 ┌────┴────┐
 ▼         ▼
Center   Bounding Box
      │
      ▼
 Safe Zone
      │
      ▼
VGA Output
```

------------------------------------------------------------------------

## 4. Repository Structure

``` text
FPGA-Color-Tracking/
├── Picture Convertor/
├── Simulation/
└── README.md
```

------------------------------------------------------------------------

## 5. Design Architecture

The project is divided into:

-   Camera Interface
-   Camera Configuration
-   Clock Generation
-   Clock Synchronization
-   Image Processing
-   Object Tracking
-   VGA Display
-   System Integration

------------------------------------------------------------------------

## 6. Module Index

  Module                    Description
  ------------------------- ---------------------------
  system_top                Top-level integration
  tracking_top              Tracking pipeline
  rgb565_to_hsv_threshold   HSV threshold processing
  bounding_box              Bounding box generation
  center_calc               Object center calculation
  safe_zone                 Safe-zone detection
  VGA_Controller            VGA output
  ov7670_configurator       Camera initialization
  ov7670_sccb_master        SCCB communication
  ov7670_init_rom           Camera register ROM

------------------------------------------------------------------------

## 7. Interface Specifications

Populate from each Verilog module when finalizing documentation to
ensure port names and widths exactly match the RTL source.

------------------------------------------------------------------------

## 8. System Workflow

1.  Camera initialization.
2.  RGB565 image acquisition.
3.  Clock-domain synchronization.
4.  HSV threshold processing.
5.  Object tracking.
6.  Bounding box and center calculation.
7.  Safe-zone evaluation.
8.  VGA display output.

------------------------------------------------------------------------

## 9. Simulation

The repository contains simulation projects for:

-   Color Tracking HSV
-   Configurator
-   Pulse Clock
-   Sync Clock
-   Tracking Center
-   Completed Simulation

------------------------------------------------------------------------

## 10. Verification Flow

``` text
Input Image
     │
Python Conversion
     │
RTL Simulation
     │
Simulation Output
     │
Image Restoration
```

------------------------------------------------------------------------

## 11. Image Processing Pipeline

``` text
Camera
  │
RGB565
  │
HSV Threshold
  │
Tracking
 ├── Center
 └── Bounding Box
      │
 Safe Zone
      │
 VGA
```

------------------------------------------------------------------------

## 12. Project Organization

-   Python utilities
-   Camera modules
-   Processing modules
-   Tracking modules
-   Display modules
-   Simulation projects

------------------------------------------------------------------------

## 13. Design Summary

A modular FPGA architecture implementing real-time color tracking using
independent RTL modules.

------------------------------------------------------------------------

## 14. Current Implementation

-   Camera configuration
-   Clock synchronization
-   HSV processing
-   Tracking
-   VGA output
-   Python utilities
-   RTL simulations

------------------------------------------------------------------------

## 15. Limitations

Interface tables and timing/resource reports should be completed
directly from the RTL implementation and synthesis reports.

------------------------------------------------------------------------

## 16. Future Work

-   Complete interface documentation.
-   Add synthesis/timing reports.
-   Add waveform illustrations.
-   Add hardware validation results.

------------------------------------------------------------------------

## 17. Author

FPGA Color Tracking Project
