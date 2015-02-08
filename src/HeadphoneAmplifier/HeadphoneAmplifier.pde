// ---------------------------------------------------------------------------
// This software is in the public domain, furnished "as is", without technical
// support, and with no warranty, express or implied, as to its usefulness for
// any purpose.
//
// HeadphoneAmplifer.pde
//    This Arduino sketch will turn the Audio Codec Shield into a Head Phone
//    Amplifier for personal use.
//    (http://www.openmusiclabs.com/projects/codec-shield/)
// 
// NOTE:
//    This code was tested with
//    - Arduino UNO R3 + LeafLabs Maple R5
//    - Open Music Labs Audio Codec Shield
//    - Dell ST2420L Monitor Line Out Audio Output
//    - Shure SRH840 Headphone Monitors
//
// Author: 
//    5 Nov 2015 - Johnny Dong @ Spudmash Media
//                 (www.spudmash.com)
//
// ---------------------------------------------------------------------------

//
// Define Sample Rate + No. of ADCS used
//
////////////////////////////////////////////////

#define SAMPLE_RATE 44 // 44.1Khz
#define ADCS 2

#include <Wire.h>
#include <SPI.h>
#include <AudioCodec.h>


//
// Initialize global variables analogue I/O
//
////////////////////////////////////////////////
int left_in = 0; // in from codec (LINE_IN)
int right_in = 0;
int left_out = 0; // out to codec (HP_OUT)
int right_out = 0;


//
// Create variables for ADC VarResister
// (see board, for names MOD0 & MOD1)
// NOTE: 
// VarResisters have unsigned positive values
//
////////////////////////////////////////////////
unsigned int mod0_value = 0;
unsigned int mod1_value = 0;


//
// Initialization
//
////////////////////////////////////////////////
void setup() {
  AudioCodec_init(); // setup codec registers
  // call this last if setting up other parts
}


//
// Main Program Loop
//
////////////////////////////////////////////////
void loop() {
  while (1); // reduces clock jitter
}


//
// Main Interrupt Routine
//
////////////////////////////////////////////////
ISR(TIMER1_COMPA_vect, ISR_NAKED) { 

  
  //
  // NOTE: data_in variables are referenced
  //
  ////////////////////////////////////////////////
  AudioCodec_data(&left_in, &right_in, left_out, right_out);
  
  
  //
  // NOTE: If you don't want any processing,
  // i.e. Left/Right channel pass data through
  // witout volume control, uncomment the following
  // and return control immediately (reti()).
  //
  ////////////////////////////////////////////////
  //left_out = left_in;
  //right_out = right_in;
  //reti();
  
  
  //
  // Setup temporary buffers to process incoming
  // audio
  //
  ////////////////////////////////////////////////
  int temp1 = left_in;
  int temp2 = right_in;
  
  
  //
  // MOD0 VarResister: 
  // Line In Volume Control
  //
  ////////////////////////////////////////////////
  MultiSU16X16toH16(temp1, left_in, mod0_value);      // Left Channelinput
  MultiSU16X16toH16(temp2, right_in, mod0_value);     // Right Channel input
  
  
  //
  // MOD1 VarResister: 
  // Headphone Amp Volume Control
  //
  ////////////////////////////////////////////////
  //MultiSU16X16toH16(temp1, left_in, mod1_value);    // Left Channel Amp Output
  //MultiSU16X16toH16(temp2, right_in, mod1_value);   // Right Channel Amp Output
  
  
  //
  // Route Resultant waveforms to ADC
  //
  ////////////////////////////////////////////////
  left_out = temp1;
  right_out = temp2;
  AudioCodec_ADC(&mod0_value, &mod1_value);
  

  //
  // Return control from interrupt
  //
  ////////////////////////////////////////////////
  reti();
}
