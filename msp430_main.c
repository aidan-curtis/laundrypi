//******************************************************************************
//   MSP430G2xx3 - USCI_B0, SPI 3-Wire Slave
//
//   Description: SPI slave talks to SPI master using 3-wire mode. USCI RX ISR
//   is used to handle communication,
//   CPU normally in LPM4.
//   ACLK = n/a, MCLK = SMCLK = DCO ~1.2MHz
//
//   Use with SPI Master Incremented Data code example.  If
//   breakpoints are set in slave RX ISR, master must stopped also to avoid
//   overrunning slave RXBUF.
//
//                MSP430G2xx3
//             -----------------
//         /|\|              XIN|-
//          | |                 |
//          | |             XOUT|-
//            |              |
//            |             P1.7|<- Data Out (UCB0SIMO)
//            |                 |
//            |             P1.6|-> Data In (UCB0SOMI)
//            |                 |
//            |             P1.5|<- Serial Clock In (UCB0CLK)
//
//   D. Dang
//   Texas Instruments Inc.
//   February 2011
//   Built with CCS Version 4.2.0 and IAR Embedded Workbench Version: 5.10
//******************************************************************************
#include "msp430g2553.h"
#include <string.h>

char cmdbuf[20];
char cmd_index=0;
char tx[] = {0xB7};
int sensor_result = 0;
static int total_val = 0;
static unsigned int total_read = 0;
static unsigned int sensor_total = 0;
static int baseline = 0;
static int first = 1;
static int num_iter = 0;
static int machine_on = 0;
void setup_adc(void);

void main(void)

{
                          // ACLK = VLO
  WDTCTL = WDT_ADLY_1_9;                       // WDT 16ms, ACLK, interval timer
  IE1 |= WDTIE;                               // Enable WDT interrupt

  while (P1IN & BIT5);                   // If clock sig from mstr stays low,
                                            // it is not yet in SPI mode

  P1SEL |= BIT5 + BIT6 + BIT7;
  P1SEL2 |= BIT5 + BIT6 + BIT7;
  UCB0CTL1 |= UCSWRST;                       // **Put state machine in reset**
  UCB0CTL0 |= UCMSB + UCSYNC + UCCKPH;               // 3-pin, 8-bit SPI slave
  UCB0CTL1 &= ~UCSWRST;                     // **Initialize USCI state machine**
  IE2 |= UCB0RXIE;                          // Enable USCI0 RX interrupt


  setup_adc();
  int volatile sensor_reading = 0;
  int i;
  int ss = 0;

  __bis_SR_register(GIE);
  while(1){
      if((P2IN & BIT5) && (ss == 0)){
          UCB0CTL1 |= UCSWRST;
          //IE2 &= ~UCB0RXIE;
          ss = 1;
      }
      else if(!(P2IN & BIT5) && ss){
          UCB0CTL0 |= UCMSB + UCSYNC + UCCKPH;               // 3-pin, 8-bit SPI slave
          UCB0CTL1 &= ~UCSWRST;                     // **Initialize USCI state machine**
          IE2 |= UCB0RXIE;                          // Enable USCI0 RX interrupt
          ss = 0;
      }
      __bis_SR_register(LPM3_bits + GIE);     // Enters LMP3 again


          ADC10CTL0 |= ENC+ADC10SC;         // Enable and start conversion
          __bis_SR_register(GIE);     // Wait for conversion to end
          total_val+=abs(ADC10MEM-baseline);
//          total_val+=abs(ADC10MEM - 475);
//          total_val+=abs(ADC10MEM - 475);

          total_read++;
          if(total_read > 20){
              sensor_total = total_val/total_read;
              total_read = 0;
              total_val = 0;

              if(first == 1 && sensor_total != -1){
                  first = 0;
                  baseline = sensor_total;
              } else {
                //  __delay_cycles(100);
                  if(sensor_total > 300) {
//                  if(sensor_total > 200) {
                        machine_on = 0xFF;
//                        machine_on = 0xBB;
                  } else {
                      machine_on = 0x00;
                  }
              }
          }
      __bis_SR_register(LPM3_bits + GIE);     // Enters LMP3 again
  }

}


void setup_adc(void){
  /***********************************************************************************************
  Sets up the ADC10 module to receive data from P1.0 (external TMP20 temperature sensor).

  Vref+ = 2.5V, Vref- = Vss     (chosen to be consistent with battery providing 3V)
  Sample-hold-time = 64 ADC10CLK cycles = 51.2us
  Interrupt generated when conversion complete to conserve power
  Clock sourced from OSC, divided by 4
  ************************************************************************************************/
    ADC10CTL0 = SREF_1 + ADC10SHT_3 + ADC10ON + ADC10IE + REFON + REF2_5V;
    ADC10CTL1 = INCH_0 + SHS_0 + + ADC10DIV_3 + ADC10SSEL_0;
    return;
}

// ADC10 interrupt service routine
#pragma vector=ADC10_VECTOR
__interrupt void ADC10_ISR(void)
{
  __bic_SR_register_on_exit(LPM3_bits + GIE);   // Exit LPM3
}


// Watchdog Timer interrupt service routine
#if defined(__TI_COMPILER_VERSION__) || defined(__IAR_SYSTEMS_ICC__)
#pragma vector=WDT_VECTOR
__interrupt void watchdog_timer(void)
#elif defined(__GNUC__)
void __attribute__ ((interrupt(WDT_VECTOR))) watchdog_timer (void)
#else
#error Compiler not supported!
#endif
{
    __bic_SR_register_on_exit(LPM3_bits + GIE);  // Exit LPM3
}

// USCI Receiver ISR
#if defined(__TI_COMPILER_VERSION__) || defined(__IAR_SYSTEMS_ICC__)
#pragma vector=USCIAB0RX_VECTOR
__interrupt void USCI0RX_ISR (void)
#elif defined(__GNUC__)
void __attribute__ ((interrupt(USCIAB0RX_VECTOR))) USCI0RX_ISR (void)
#else
#error Compiler not supported!
#endif
{

    UCB0TXBUF = machine_on;
    char value = UCB0RXBUF;


//
//  if (value == '\n') {
//
//    cmd_index = 0;
//  } else {
//    cmdbuf[cmd_index] = value;
//    cmd_index++;
//  }

}
