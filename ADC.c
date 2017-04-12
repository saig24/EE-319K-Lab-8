// ADC.c
// Runs on LM4F120/TM4C123
// Provide functions that initialize ADC0
// Last Modified: 3/6/2015 
// Student names: John Sigmon
// Last modification date:

#include <stdint.h>
#include "tm4c123gh6pm.h"



// ADC initialization function 
// Input: none
// Output: none
void ADC_Init(void){ 
	int delay;
	
	SYSCTL_RCGC2_R |= 0x10;			//enable port E clock
	while((SYSCTL_PRGPIO_R&0x10) == 0){};
	GPIO_PORTE_DIR_R &= 0xFB;		//Port E pin 2 is set to input
	GPIO_PORTE_AMSEL_R |= 0x04;				//
	GPIO_PORTE_DEN_R &= 0xFB;		//clear bits to enable analog
	
	SYSCTL_RCGCADC_R |= 0x01;		//enable ADC clock
	delay = SYSCTL_RCGCADC_R;       // extra time to stabilize
  delay = SYSCTL_RCGCADC_R;       // extra time to stabilize
  delay = SYSCTL_RCGCADC_R;       // extra time to stabilize
  delay = SYSCTL_RCGCADC_R;

	ADC0_PC_R |= 0x01;						//Set ADC conversion speed to 125kHz
	ADC0_SSPRI_R = 0x0123;			//set sequencer priority
	ADC0_ACTSS_R &= (~0x123);				//zero bit 3 to disable selected sequence
	ADC0_EMUX_R &= ~0xF000;		//set software start trigger event
	ADC0_SSMUX3_R |= 0x01;			//since we are using PE2 (channel 1) write 1 to [3:0]
	ADC0_SSCTL3_R = 0x0006;				//this line sets [3:0] to "0110"
	ADC0_IM_R &= (~0x0008);					//clear bit 3 to disable interrupts
	ADC0_ACTSS_R  |= 0x0008;			//set bit 3 to enable selected sequencer 3
	ADC0_SAC_R = 0x04;  // 16) enable hardware oversampling; A N means 2^N (16 here) samples are averaged; 0<=N<=6
	

}

//------------ADC_In------------
// Busy-wait Analog to digital conversion
// Input: none
// Output: 12-bit result of ADC conversion
uint32_t ADC_In(void){  
	//initiate capture
	//RIS (SAR)
	//read captured value from fifo buffer
	//clear ris flag using icr reg
	//return
	//******check this function output- data should be 12 bits.
uint32_t local_data;
	
	ADC0_PSSI_R = 0x0008;
	
	while ((ADC0_RIS_R & 0x08) == 0) {
	};																								//wait for conversion
	
	local_data = (ADC0_SSFIFO3_R & 0xFFF);						//retrieve data from fifo buffer
	ADC0_ISC_R = 0x0008; 
	
	return (local_data);
		
}



