// ADC.c
// Runs on LM4F120/TM4C123
// Provide functions that initialize ADC0
// Last Modified: 3/6/2015 
// Student names: John Sigmon
// Last modification date:

#include <stdint.h>
#include "tm4c123gh6pm.h"

extern uint32_t Data;


// ADC initialization function 
// Input: none
// Output: none
void ADC_Init(void){ 
	int delay;
	SYSCTL_RCGCADC_R |= 0x01;		//enable ADC clock
	SYSCTL_RCGC2_R |= 0x10;			//enable port E clock
	delay = SYSCTL_RCGCADC_R;
	GPIO_PORTE_DIR_R &= 0xFB;		//Port E pin 2 is set to input
	GPIO_PORTE_AMSEL_R |= 0x04;				// is this right?**********
	GPIO_PORTE_DEN_R &= 0xFB;		//clear bits to enable analog
	
	ADC0_PC_R = 0x01;					//Set ADC conversion speed to 125kHz
	ADC0_SSPRI_R = 0x0123;			//set sequencer priority
	ADC0_ACTSS_R &= 0xF7;				//zero bit 3 to disable selected sequence
	ADC0_EMUX_R &=0xFFFF0FFF;		//set software start trigger event
	ADC0_SSMUX3_R |= 0x01;			//since we are using PE2 (channel 1) write 1 to [3:0]
	ADC0_SSCTL3_R = 0x06;			//these two lines set [3:0] to "0110"
	ADC0_IM_R &= 0xF7;					//clear bit 3 to disable interrupts
	ADC0_ACTSS_R  |= 0x08;			//set bit 3 to enable selected sequencer 3
	

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
	
	ADC0_PSSI_R = 0x0008;
	while ((ADC0_RIS_R & 0x08) == 0) {};			//wait for conversion
		Data = ADC0_SSFIFO3_R & 0xFFF;					//retrieve data from fifo buffer
		ADC0_ISC_R = 0x0008; 
		return (Data);
		
}



