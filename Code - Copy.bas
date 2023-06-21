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
_in Alias Pind.5
Key_learn Alias Pinc.0
Led_learn Alias Portd.6

Config _in = Input
Config Key_learn = Input
Config Led_learn = Output
'*****************************
Dim I As Word
Dim Ii As Word
Dim Flag As Byte

Dim Time_count As Word
Dim Rf_data(50) As Word
Dim Remote_id As String * 30
Dim Remote_data As String * 30

Dim Save_id As String * 30
Dim Eram_save_id As Eram String * 30

Save_id = Eram_save_id


'*****************************


Dim Rf_data1(350) As Word
Do
   If Key_learn = 1 Then
      I = 0
      Do
         If _in = 1 Then
            Time_count = 0
            Do : Incr Time_count : Waitus 5 : Loop Until _in = 0
            Rf_data1(i) = Time_count
            Incr I
         End If
         Reset Watchdog
      Loop Until I > 150

      For I = 1 To 150
         Print #1 , I ; ") " ; Rf_data1(i)
         Reset Watchdog
      Next I
   End If


   Waitms 300
   Reset Watchdog
   Toggle Led_learn
Loop




Print #1 , "Save ID is :" ; Save_id

If Key_learn = 1 Then Print #1 , "key learn on"

For I = 1 To 10
   Toggle Led_learn
   Waitms 50
   Reset Watchdog
Next I
Led_learn = 0

Do

   If Flag = 1 Then
      Flag = 0
      'Print #1 , "Code=" ; Remote_data
      Waitms 100
   End If


   Gosub Read_rf
   Reset Watchdog
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
            If Rf_data(i) > 30 And Rf_data(i) < 95 Then
               Rf_data(i) = 0
               Remote_id = Remote_id + "0"
            Else
               If Rf_data(i) > 120 And Rf_data(i) < 220 Then
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

         Remote_data = Right(remote_id , 4)
         Remote_id = Left(remote_id , 20)
         Print #1 , "ID=" ; Remote_id ; "  Data=" ; Remote_data ; "   " ; Key_learn


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

         If Save_id = Remote_id Then Flag = 1

      End If

   End If
      Led_learn = 0
Return
'*****************************

'(
'Check remote data
Do
   If Key_learn = 1 Then
      I = 0
      Do
         If _in = 1 Then
            Time_count = 0
            Do : Incr Time_count : Waitus 5 : Loop Until _in = 0
            Rf_data1(i) = Time_count
            Incr I
         End If
         Reset Watchdog
      Loop Until I > 150

      For I = 1 To 150
         Print #1 , I ; ") " ; Rf_data1(i)
         Reset Watchdog
      Next I
   End If


   Waitms 300
   Reset Watchdog
   Toggle Led_learn
Loop
')