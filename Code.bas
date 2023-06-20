$regfile = "M8def.dat"
$crystal = 11059200
'*****************************
Open "comb.5:9600,8,n,1" For Output As #1
Enable Interrupts
'*****************************
Config Watchdog = 2048
Start Watchdog
'*****************************
Config Adc = Single , Prescaler = Auto , Reference = Avcc
Start Adc
'*****************************
Config Timer1 = Pwm , Prescale = 8 , Pwm = 8 , Compare A Pwm = Clear Down , Compare B Pwm = Clear Down
Enable Timer1
Enable Interrupts
Start Timer1

Config Timer2 = Pwm , Prescale = 8 , Pwm = On , Compare Pwm = Clear Up
Enable Timer2
Start Timer2

Ocr1a = 0
Ocr1b = 0
Ocr2 = 0
'*****************************
_in Alias Pind.7
Key_learn Alias Pind.4
Led_power Alias Portd.2
Led_learn Alias Portd.1
Voltage_trigger Alias Pind.3

Config _in = Input
Config Key_learn = Input
Config Led_power = Output
Config Led_learn = Output
Config Voltage_trigger = Input
'*****************************
Dim I As Word
Dim Ii As Word
Dim Pwmm As Word
Dim Flag As Byte
Dim Adcc As Word

Dim Time_count As Word
Dim Rf_data(50) As Word
Dim Remote_id As String * 30
Dim Remote_data As String * 30

Dim Save_id As String * 30
Dim Eram_save_id As Eram String * 30
Dim Eram_pwmm As Eram Word
Dim Eram_flag As Eram Byte

Save_id = Eram_save_id

Const Key_debounce = 300
Dim Data_save(301) As Word
'*****************************
Print #1 , "Save ID is :" ; Save_id
Flag = Eram_flag
Pwmm = Eram_pwmm
If Flag = 1 Then Ocr1a = Pwmm

Led_power = 1
For I = 1 To 10
   Toggle Led_learn
   Toggle Led_power
   Waitms 50
   Reset Watchdog
Next I
Led_power = 1
Led_learn = 0

Do
   Gosub Read_rf
   Reset Watchdog
   Adcc = Getadc(1)
   If Adcc < 450 Then
      Led_power = 0
      Eram_flag = Flag
      Eram_pwmm = Pwmm
      Print #1 , "Save Data"
      Waitms 500
      Do
         Reset Watchdog
         Waitms 100
         Adcc = Getadc(1)
         Toggle Led_learn
      Loop Until Adcc > 500
   End If

Loop
'*****************************
Read_rf:
   Remote_data = ""
   Remote_id = ""
   If _in = 1 Then
      Do : Loop Until _in = 0

      Time_count = 0
      Do : Incr Time_count : Waitus 5 : Loop Until _in = 1


      If Time_count > 1550 And Time_count < 2100 Then       '1550   1950
         Led_learn = 1
         Remote_id = ""
         I = 1
         Do
            If _in = 1 Then
               Time_count = 0
               Do : Incr Time_count : Waitus 5 : Loop Until _in = 0
               Rf_data(i) = Time_count
               Incr I
            End If
            Reset Watchdog
         Loop Until I > 24

         For I = 1 To 24
            If Rf_data(i) > 45 And Rf_data(i) < 95 Then
               Rf_data(i) = 0
               Remote_id = Remote_id + "0"
            Else
               If Rf_data(i) > 140 And Rf_data(i) < 220 Then
                  Rf_data(i) = 1
                  Remote_id = Remote_id + "1"
               Else
                  'Print #1 , I ; ")" ; Rf_data(i)
                  Remote_id = ""
                  Remote_data = ""
                  Return
               End If
            End If
         Next I

         Remote_data = Right(remote_id , 8)
         Remote_id = Left(remote_id , 16)
         'Print #1 , "ID=" ; Remote_id ; "  Data=" ; Remote_data ; "   " ; Key_learn


         If Key_learn = 1 Then                              'Save new Remote
            Save_id = Remote_id
            Eram_save_id = Remote_id
            Waitms 10

            Print #1 , "Saved"
            Print #1 , "ID=" ; Remote_id ; "  Data=" ; Remote_data
            Led_learn = 1
            Waitms 100
            Do
               Reset Watchdog
               Waitms 10
            Loop Until Key_learn = 0
         End If

         If Save_id = Remote_id Then
            If Remote_data = "00000011" Then Flag = 1
            If Remote_data = "00001100" Then Flag = 0

            If Remote_data = "00001111" Then Pwmm = 25
            If Remote_data = "00110000" Then Pwmm = 51
            If Remote_data = "00110011" Then Pwmm = 76
            If Remote_data = "00111100" Then Pwmm = 102
            If Remote_data = "00111111" Then Pwmm = 127
            If Remote_data = "11000000" Then Pwmm = 153
            If Remote_data = "11000011" Then Pwmm = 178
            If Remote_data = "11001100" Then Pwmm = 204
            If Remote_data = "11001111" Then Pwmm = 229
            If Remote_data = "11110000" Then Pwmm = 255

            If Flag = 1 Then Ocr1a = Pwmm Else Ocr1a = 0
         End If

      End If

   End If
      Led_learn = 0
Return
'*****************************