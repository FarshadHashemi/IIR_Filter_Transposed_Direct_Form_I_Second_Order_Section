Library IEEE ;
Use IEEE.STD_Logic_1164.All ;
Use IEEE.Numeric_STD.All ;

Entity IIR_Filter_Transposed_Direct_Form_I_Second_Order_Section Is
	
    Generic(
        Length_Of_Input_Words            : Integer := 8 ;
        Length_Of_Input_Fractions        : Integer := 7 ;
		
        Length_Of_Output_Words           : Integer := 9 ;
        Length_Of_Output_Fractions       : Integer := 7 ;
		
        Length_Of_Coefficients_Words     : Integer := 10 ;
        Length_Of_Coefficients_Fractions : Integer := 7 ;
		
        Gain                             : Integer := 31 ;
        Feed_Forward_Coefficient_1       : Integer := 255 ;
        Feed_Back_Coefficient_1          : Integer := -24 ;
        Feed_Back_Coefficient_2          : Integer := 23
    ) ;
	
    Port(
        Clock              : In  STD_Logic ;
        Synchronous_Reset  : In  STD_Logic ;
        Clock_Enable       : In  STD_Logic ;
        Input              : In  Signed(Length_Of_Input_Words-1 Downto 0) ;
        Output             : Out Signed(Length_Of_Output_Words-1 Downto 0)
    ) ;
    
End IIR_Filter_Transposed_Direct_Form_I_Second_Order_Section;

Architecture Behavioral of IIR_Filter_Transposed_Direct_Form_I_Second_Order_Section Is

    Signal Synchronous_Reset_Register        : STD_Logic                                                              := '0' ;
    Signal Clock_Enable_Register             : STD_Logic                                                              := '0' ;
    Signal Input_Register                    : Signed(Length_Of_Input_Words-1 Downto 0)                               := To_Signed(0,Length_Of_Input_Words) ;
    
    Signal Input_Signal                      : Signed(Length_Of_Input_Words-1 Downto 0)                               := To_Signed(0,Length_Of_Input_Words) ;
    Signal Input_Signal_1_Delay              : Signed(Length_Of_Input_Words-1 Downto 0)                               := To_Signed(0,Length_Of_Input_Words) ;
    
    Signal Input_Gain                        : Signed(Length_Of_Input_Words+Length_Of_Coefficients_Words-1 Downto 0)  := To_Signed(0,Length_Of_Input_Words+Length_Of_Coefficients_Words) ;
    Alias  Input_Gaine_Quantize              : Signed(Length_Of_Output_Words-1 Downto 0) Is Input_Gain(Length_Of_Output_Words+Length_Of_Input_Fractions+Length_Of_Coefficients_Fractions-Length_Of_Output_Fractions-1 Downto Length_Of_Input_Fractions+Length_Of_Coefficients_Fractions-Length_Of_Output_Fractions) ;
    
    Signal Signal_Denumerator_0_1_Delay      : Signed(Length_Of_Output_Words-1 Downto 0)                              := To_Signed(0,Length_Of_Output_Words) ;
    Signal Signal_Denumerator_0_2_Delay      : Signed(Length_Of_Output_Words-1 Downto 0)                              := To_Signed(0,Length_Of_Output_Words) ;
    Signal Signal_Denumerator_1_1_Delay      : Signed(Length_Of_Output_Words-1 Downto 0)                              := To_Signed(0,Length_Of_Output_Words) ;
    Signal Signal_Denumerator_1_2_Delay      : Signed(Length_Of_Output_Words-1 Downto 0)                              := To_Signed(0,Length_Of_Output_Words) ;
    Signal Signal_Denumerator_2_1_Delay      : Signed(Length_Of_Output_Words-1 Downto 0)                              := To_Signed(0,Length_Of_Output_Words) ;
    Signal Signal_Denumerator_2_2_Delay      : Signed(Length_Of_Output_Words-1 Downto 0)                              := To_Signed(0,Length_Of_Output_Words) ;
    
    Signal Adder_Denumerator_0               : Signed(Length_Of_Output_Words-1 Downto 0)                              := To_Signed(0,Length_Of_Output_Words) ;
    Signal Adder_Denumerator_1               : Signed(Length_Of_Output_Words+Length_Of_Coefficients_Words-1 Downto 0) := To_Signed(0,Length_Of_Output_Words+Length_Of_Coefficients_Words) ;
    Alias  Adder_Denumerator_1_Quantize      : Signed(Length_Of_Output_Words-1 Downto 0) Is Adder_Denumerator_1(Length_Of_Output_Words+Length_Of_Coefficients_Fractions-1 Downto Length_Of_Coefficients_Fractions) ;
    Signal Adder_Denumerator_2               : Signed(Length_Of_Output_Words+Length_Of_Coefficients_Words-1 Downto 0) := To_Signed(0,Length_Of_Output_Words+Length_Of_Coefficients_Words) ;
    
    Signal Adder_Denumerator_0_1_Delay       : Signed(Length_Of_Output_Words-1 Downto 0)                              := To_Signed(0,Length_Of_Output_Words) ;
    Signal Adder_Denumerator_0_2_Delay       : Signed(Length_Of_Output_Words-1 Downto 0)                              := To_Signed(0,Length_Of_Output_Words) ;
    Signal Adder_Denumerator_0_3_Delay       : Signed(Length_Of_Output_Words-1 Downto 0)                              := To_Signed(0,Length_Of_Output_Words) ;
    Signal Adder_Denumerator_0_4_Delay       : Signed(Length_Of_Output_Words-1 Downto 0)                              := To_Signed(0,Length_Of_Output_Words) ;
    
    Signal Multiplier_Numerator_0            : Signed(Length_Of_Output_Words-1 Downto 0)                              := To_Signed(0,Length_Of_Output_Words) ;
    Signal Multiplier_Numerator_1            : Signed(Length_Of_Output_Words+Length_Of_Coefficients_Words-1 Downto 0) := To_Signed(0,Length_Of_Output_Words+Length_Of_Coefficients_Words) ;
    Alias  Multiplier_Numerator_1_Quantize   : Signed(Length_Of_Output_Words-1 Downto 0) Is Multiplier_Numerator_1(Length_Of_Output_Words+Length_Of_Coefficients_Fractions-1 Downto Length_Of_Coefficients_Fractions) ;
    Signal Multiplier_Numerator_2            : Signed(Length_Of_Output_Words-1 Downto 0)                              := To_Signed(0,Length_Of_Output_Words) ;
    
    Signal Adder_Numerator_0                 : Signed(Length_Of_Output_Words-1 Downto 0)                              := To_Signed(0,Length_Of_Output_Words) ;
    Signal Adder_Numerator_1                 : Signed(Length_Of_Output_Words-1 Downto 0)                              := To_Signed(0,Length_Of_Output_Words) ;
    Signal Adder_Numerator_2                 : Signed(Length_Of_Output_Words-1 Downto 0)                              := To_Signed(0,Length_Of_Output_Words) ;
    
Begin

    Process(Clock)
    Begin
       
        If Rising_Edge(Clock) Then
       
        --  Registering Input Ports
           Synchronous_Reset_Register <= Synchronous_Reset ;
           Clock_Enable_Register      <= Clock_Enable ;
           Input_Register             <= Input ;
        --  %%%%%%%%%%%%%%%%%%%%%%%
        
        --  Reset Internal Registers
           If Synchronous_Reset_Register='1' Then
               
                Input_Signal                 <= To_Signed(0,Length_Of_Input_Words) ;
                Input_Signal_1_Delay         <= To_Signed(0,Length_Of_Input_Words) ;
                
                Input_Gain                   <= To_Signed(0,Length_Of_Input_Words+Length_Of_Coefficients_Words) ;

                Signal_Denumerator_0_1_Delay <= To_Signed(0,Length_Of_Output_Words) ;
                Signal_Denumerator_0_2_Delay <= To_Signed(0,Length_Of_Output_Words) ;
                Signal_Denumerator_1_1_Delay <= To_Signed(0,Length_Of_Output_Words) ;
                Signal_Denumerator_1_2_Delay <= To_Signed(0,Length_Of_Output_Words) ;
                Signal_Denumerator_2_1_Delay <= To_Signed(0,Length_Of_Output_Words) ;
                Signal_Denumerator_2_2_Delay <= To_Signed(0,Length_Of_Output_Words) ;
                
                Adder_Denumerator_0          <= To_Signed(0,Length_Of_Output_Words) ;
                Adder_Denumerator_1          <= To_Signed(0,Length_Of_Output_Words+Length_Of_Coefficients_Words) ;
                Adder_Denumerator_2          <= To_Signed(0,Length_Of_Output_Words+Length_Of_Coefficients_Words) ;
                
                Adder_Denumerator_0_1_Delay  <= To_Signed(0,Length_Of_Output_Words) ;
                Adder_Denumerator_0_2_Delay  <= To_Signed(0,Length_Of_Output_Words) ;
                Adder_Denumerator_0_3_Delay  <= To_Signed(0,Length_Of_Output_Words) ;
                Adder_Denumerator_0_4_Delay  <= To_Signed(0,Length_Of_Output_Words) ;
                
                Multiplier_Numerator_0       <= To_Signed(0,Length_Of_Output_Words) ;
                Multiplier_Numerator_1       <= To_Signed(0,Length_Of_Output_Words+Length_Of_Coefficients_Words) ;
                Multiplier_Numerator_2       <= To_Signed(0,Length_Of_Output_Words) ;
                
                Adder_Numerator_0            <= To_Signed(0,Length_Of_Output_Words) ;
                Adder_Numerator_1            <= To_Signed(0,Length_Of_Output_Words) ;
                Adder_Numerator_2            <= To_Signed(0,Length_Of_Output_Words) ;
        --  %%%%%
        
            Elsif Clock_Enable_Register='1' Then
                
                Input_Signal                 <= Input_Register ;
                Input_Signal_1_Delay         <= Input_Signal ;
                
                Input_Gain                   <= Input_Signal_1_Delay * To_Signed(Gain,Length_Of_Coefficients_Words) ;
                
                Signal_Denumerator_0_1_Delay <= Input_Gaine_Quantize ;
                Signal_Denumerator_0_2_Delay <= Signal_Denumerator_0_1_Delay ;
                Signal_Denumerator_1_1_Delay <= Input_Gaine_Quantize ;
                Signal_Denumerator_1_2_Delay <= Signal_Denumerator_1_1_Delay ;
                Signal_Denumerator_2_1_Delay <= Input_Gaine_Quantize ;
                Signal_Denumerator_2_2_Delay <= Signal_Denumerator_2_1_Delay ;
                
                Adder_Denumerator_0          <= Adder_Denumerator_1_Quantize + Signal_Denumerator_0_2_Delay ;
                Adder_Denumerator_1          <= ((Adder_Denumerator_1_Quantize + Signal_Denumerator_1_2_Delay) * To_Signed(((-1)*Feed_Back_Coefficient_1),Length_Of_Coefficients_Words)) + Adder_Denumerator_2 ;
                Adder_Denumerator_2          <= ((Adder_Denumerator_1_Quantize + Signal_Denumerator_2_2_Delay) * To_Signed(((-1)*Feed_Back_Coefficient_2),Length_Of_Coefficients_Words)) ;
                
                Adder_Denumerator_0_1_Delay  <= Adder_Denumerator_0 ;
                Adder_Denumerator_0_2_Delay  <= Adder_Denumerator_0_1_Delay ;
                Adder_Denumerator_0_3_Delay  <= Adder_Denumerator_0_2_Delay ;
                Adder_Denumerator_0_4_Delay  <= Adder_Denumerator_0_3_Delay ;
                                
                Multiplier_Numerator_0       <= Adder_Denumerator_0 ;
                Multiplier_Numerator_1       <= Adder_Denumerator_0_2_Delay * To_Signed(Feed_Forward_Coefficient_1,Length_Of_Coefficients_Words) ;
                Multiplier_Numerator_2       <= Adder_Denumerator_0_4_Delay ;
                
                Adder_Numerator_0            <= Multiplier_Numerator_0 ;
                Adder_Numerator_1            <= Multiplier_Numerator_1_Quantize + Adder_Numerator_0 ;
                Adder_Numerator_2            <= Multiplier_Numerator_2 + Adder_Numerator_1 ;
                
            End If ;
           
        End If ;
       
    End Process ;
    
--  Registering Output Ports 
    Output                   <= Adder_Numerator_2 ;
--  %%%%%%%%%%%%%%%%%%%%%%%
    
End Behavioral ;