// SysTick.c
// written by: John Sigmon
// written 4/8/17

#include <stdint.h>
#include "tm4c123gh6pm.h"
#include "ADC.h"

volatile int32_t ADCMail = 0, ADCStatus = 0;
	
extern int32_t Data;


// The delay parameter is in units of the 80 MHz core clock. (12.5 ns)
//input sample_rate is the frequency of sampling in Hz

void SysTick_Init(void){
	NVIC_ST_CTRL_R = 0;											//disables systick during setup
	NVIC_ST_RELOAD_R = (2000000);				//reload register = samplerate*f(bus)
	NVIC_ST_CURRENT_R = 0;									//clear current
	NVIC_SYS_PRI3_R &= 0x00FFFFFF;			
	NVIC_SYS_PRI3_R |= 0x30000000;					//set priority to 3
	NVIC_ST_CTRL_R = 0x07;									//set bits 0, 1, 2
}


/*This should be an ISR to sample the ADC
	It should:
	1.) toggle heartbeat LED (PF0)
	2.) toggle heartbeat LED again (PF0)
	3.) sample the ADC
	4.) save the 12 bit ADC sample into the mailbox ADCMail
	5.) set mailbox flag ADCStatus to signify new data
	6.) toggle heartbeat LED (PF0)
	7.) return from interrupt		*/
	
void SysTick_Handler(void){
	GPIO_PORTF_DATA_R |= 0x01;
	GPIO_PORTF_DATA_R &= 0x00;
	ADCMail = ADC_In();
	ADCStatus |= 1;
	GPIO_PORTF_DATA_R |= 0x01;
}



