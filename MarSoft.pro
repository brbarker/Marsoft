pro Marsoft

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Welcome to MarSoft. The GDL library created for Ursinus College Physics Department.
; 
; Useful abbreviations to know:
;       - RA = Right Ascension
;       - RAh = Right Ascension Hour(s)
;       - RAm = Right Ascension Minute(s)
;       - RAs = Right Ascension Second(s)
;
;       - Dec = Declination
;       - DecD = Declination Degrees
;       - DecM = Declination Minutes
;       - DecS = Declination Seconds
;
; It contains a search feature with two options:
;       - Search a .CSV file
;               - The .CSV file columns must have the following format to be read properly:
;                       - Source Name, RAh, RAm, RAs, DecD, DecM, DecS
;       - Searching with Observation Time and Date
;
; It contains a calculation feature with four options:
;       - Calculate Day of the Year, also known as Day of the Julian Calendar
;       - Calculate Declination of the Mean Sun using either:
;               - Day of the Julian Calendar
;               - Days since Vernal Equinox
;       - Calculate Right Ascension of the Mean Sun using either:
;               - Day of the Julian Calendar
;               - Days since Vernal Equinox
;       - Telescope Calculations
;               - Calculate Angular Magnification
;               - Calculate Angular Resolution
;               - Calculate Focal Ratio
;               - Calculate Snell's Law For Angle Of Refraction
;
; Latest Update Date: 02-22-2022
; Latest Update Contributor: Brian Barker
; Update Version: 1.1.0
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



; Close any previously opened file

close, /all


; This begins and repeats the entire procedure until the user wants to stop
    repeat begin                                                                                            

    ; Give the user options for what they want to do
    ; Repeats until the user picks an available option

        repeat begin
            print,""
            print,"Home Menu:"
            read,choice,prompt="|1 - Search Options|  |2 - Calculations| "
        endrep until (choice ge 1) && (choice le 2)

    ; If Home Menu option 1 is picked do this

        if choice eq 1 then begin
            print,"...Accessing Searches..."

        ; Repeats until the user picks an available option

            repeat begin
                print,""
                print,"How Would You Like To Search?"
                read,search_option,prompt="|1 - From A .CSV File|  |2 - Using Observation Time And Date| "
                print,""
            endrep until (search_option ge 1) && (search_option le 2)

        ; If Search Menu option 1 is picked do this

            if search_option eq 1 then begin
                print,"Please Pick The .CSV File That You Would Like To Search"
                print,""

                ; Declarations of variables for the manipulations during the search

                    RAh = 0.0
                    RAm = 0.0
                    RAs = 0.0
                    DecD = 0.0
                    DecM = 0.0
                    DecS = 0.0

                ; Open a file for the search history

                    openw,2,'GDLSearch.txt'

                ; Use dialog_pickfile to locate the file to be used and assign it a name
                ; The name is "user_file" and the filter can be changed to different file types or taken out. "/read" changes the title of the dialog box

                    user_file = dialog_pickfile(FILTER='*.csv',/read)

                ; Read the file in and assign it to the Source_Data variable, assign the header information to variables

                    Source_Data = read_csv(user_file, COUNT=count, HEADER=SourceHead, N_TABLE_HEADER=0)   

                ; Take the columns (FIELDS) of the csv and assign them variables for later use
                    
                    Names = Source_Data.FIELD1
                    RAHs = Source_Data.FIELD2
                    RAMs = Source_Data.FIELD3
                    RASs = Source_Data.FIELD4
                    DECDs = Source_Data.FIELD5
                    DECMs = Source_Data.FIELD6
                    DECSs = Source_Data.FIELD7


                ; Put all the columns from the csv into one list

                    DataList = list(Names,RAHs,RAMs,RASs,DECDs,DECMs,DECSs)

                ; This begins the search process. It repeats the whole process until the user decides to stop

                    repeat begin

                        ; Ask user if they want to search by Source Name, RAh, or DecD
                        ; Repeats until the user picks an available option

                        repeat begin
                            print,""
                            print,"How Would You Like To Search The File? "
                            read,mode,prompt="|1 - Source Name| |2 - Right Ascension Hours| |3 - Declination Degrees| "
                            print,""
                        endrep until (mode ge 1) && (mode le 3)

                    ; Mode 1 Selected ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                        ;If Search Mode option 1 is picked do this
                        
                            if mode eq 1 then begin 

                            ; Print the list of sources with selector numbers so the user can pick which one they want
                            ; This section will repeat if the user chooses to

                                repeat begin
                                    for i=0,N_ELEMENTS(Names)-1 do begin
                                        print,i+1," --- ",Names[i]
                                    endfor

                            ; User selects source from the list
                                    print,""
                                    read,source_selector,prompt="Which Source Would You Like Information For? "

                            ; This question repeats until the user enters a number that is on the list.
                            ; If a number NOT on the list is picked, GDL will produce an error and stop the procedure. This prevents that.

                                    repeat begin	
                                        if source_selector gt N_ELEMENTS(Names) then begin
                                            read,source_selector,prompt="Which Source Would You Like Information For? "
                                        endif
                                    endrep until source_selector le N_ELEMENTS(Names)

                            ; Assign the most recent selected source's data to variables for display and calling

                                    RAh = RAHs[source_selector-1]
                                    RAm = RAMs[source_selector-1]
                                    RAs = RASs[source_selector-1]
                                    DecD = DECDs[source_selector-1]
                                    DecM = DECMs[source_selector-1]
                                    DecS = DECSs[source_selector-1]

                            ; Display the source information chosen by user

                                    print,""
                                    print,Names[source_selector-1],":"
                                    print,""
                                    print,"RA Hr: ",RAh
                                    print,"RA Min: ",RAm
                                    print,"RA Sec: ",RAs
                                    print,"Dec Deg: ",DecD
                                    print,"Dec Min: ",DecM
                                    print,"Dec Sec: ",DecS
                                    print,""

                            ; Identify if the chosen source is a star or constellation
                            ; Constellations are not point sources, so their location information is more general without minutes or seconds
                            ; This tests if the minutes and seconds are 0 in BOTH Dec and RA

                                if (RAm eq 0) && (RAs eq 0) && (DecM eq 0) && (DecS eq 0) then begin
                                    print,"This Source Is A Constellation!"
                                    print,""
                                endif else begin
                                    print,"This Source Is A Star!"
                                    print,""
                                endelse

                            ; Allow the user to pick another source until they are satisfied
                            ; Repeat this question until either 1 or 0 is chosen

                                    repeat begin	
                                        print,"Would You Like to Pick Another Source From The List? "
                                        read,cont,prompt="|1 - Yes| |0 - No| "
                                        print,""
                                    endrep until (cont le 1) && (cont ge 0)

                                endrep until cont eq 0              ; End to the repeat loop at the beginning of Mode 1

                            ; Print the selected source and its info to the GDLSearch file. This is not printed to screen.		

                                printf,2,systime()
                                printf,2,Names[source_selector-1],":"
                                printf,2,"RAh: ",RAh
                                printf,2,"RAm: ",RAm
                                printf,2,"RAs: ",RAs
                                printf,2,"DecD: ",DecD
                                printf,2,"DecM: ",DecM
                                printf,2,"DecS: ",DecS
                                
                            endif          ; End if to initialize Mode 1

                    ; Mode 2 Selected ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                        ; If Search Mode 2 is picked do this

                            if mode eq 2 then begin

                            ; Ask the user what RA they want

                                read,user_RAh,prompt="What Right Ascension Hour Are You Searching For? "
                                print,""

                            ; Ask for a search range input and then indicate searching has begun

                                read,user_range,prompt="Please Enter A Plus Or Minus Value For The Search Range. Entering 0 Means Only Exact Matches Will Be Shown. "
                                print,""
                                print,"...Searching for RA Hours With Your Value..."
                                print,""

                            ; Create some lists and arrays to be able to manipulate the master file

                                RALS = list()
                                RAA = []
                                RAAS = list()
                                NAA = list()
                                CC = list()

                            ; Print titles for the displayed info

                                print," Name ------- RAh ------- RAm ------- RAs ------- DecD ------- DecM ------- DecS "

                            ; If a range is entered do this
                            
                                if user_range gt 0 then begin
                                    search_floor = (user_RAh - user_range)

                                ; Go through DataList and search for RAH minus user_range
                                ; Only happens if the user picks a range above 0
                                ; Goes through the list of RAHs and if the source is a match, it adds it to a main list for display

                                    for i=0,N_ELEMENTS(RAHs)-1 do begin
                                        if RAHs[i] eq search_floor then begin
                                            RAA = [RAHs[i],RAMs[i],RASs[i],DECDs[i],DECMs[i],DECSs[i]]                  ; Take only the number columns and add them to a temporary list
                                            RAAS.add,RAA																; Add them
                                            NAA.add,Names[i]
                                            CC.add,Names[i]															; Take all the names that match that data and add them to another temporary list
                                            RALS = list(Names[i],RAA,/EXTRACT)											; Combine the lists to show user's search results and provide a count
                                            print,Names[i],RAHs[i],RAMs[i],RASs[i],DECDs[i],DECMs[i],DECSs[i]			; Print user's search results
                                        endif
                                    endfor
                                
                                    for i=0,N_ELEMENTS(RAHs)-1 do begin
                                        if (RAHs[i] gt search_floor) && (RAHs[i] lt user_RAh) then begin
                                            RAA = [RAHs[i],RAMs[i],RASs[i],DECDs[i],DECMs[i],DECSs[i]]                  ; Take only the number columns and add them to a temporary list
                                            RAAS.add,RAA																; Add them
                                            NAA.add,Names[i]															; Take all the names that match that data and add them to another temporary list
                                            CC.add,Names[i]	
                                            RALS = list(Names[i],RAA,/EXTRACT)											; Combine the lists to show user's search results and provide a count
                                            print,Names[i],RAHs[i],RAMs[i],RASs[i],DECDs[i],DECMs[i],DECSs[i]			; Print user's search results
                                        endif
                                    endfor
                                endif

                            ; Go through DataList and search for matching RAHs
                            ; Goes through the list of RAHs and if the source is a match, it adds it to a main list for display

                                for i=0,N_ELEMENTS(RAHs)-1 do begin
                                    if RAHs[i] eq user_RAh then begin
                                        RAA = [RAHs[i],RAMs[i],RASs[i],DECDs[i],DECMs[i],DECSs[i]]                  ; Take only the number columns and add them to a temporary list
                                        RAAS.add,RAA																; Add them
                                        NAA.add,Names[i]															; Take all the names that match that data and add them to another temporary list
                                        CC.add,Names[i]	
                                        RALS = list(Names[i],RAA,/EXTRACT)											; Combine the lists to show user's search results and provide a count
                                        print,Names[i],RAHs[i],RAMs[i],RASs[i],DECDs[i],DECMs[i],DECSs[i]			; Print user's search results
                                    endif
                                endfor

                            ; Go through DataList and search for RAH plus user_range
                            ; Goes through the list of RAHs and if the source is a match, it adds it to a main list for display
                            ; Only happens if the user picks a range above 0

                                if user_range gt 0 then begin 
                                    search_ceiling = (user_RAh + user_range)

                                    for i=0,N_ELEMENTS(RAHs)-1 do begin
                                        if (RAHs[i] gt user_RAh) && (RAHs[i] lt search_ceiling) then begin
                                            RAA = [RAHs[i],RAMs[i],RASs[i],DECDs[i],DECMs[i],DECSs[i]]                  ; Take only the number columns and add them to a temporary list
                                            RAAS.add,RAA																; Add them
                                            NAA.add,Names[i]															; Take all the names that match that data and add them to another temporary list
                                            CC.add,Names[i]	
                                            RALS = list(Names[i],RAA,/EXTRACT)											; Combine the lists to show user's search results and provide a count
                                            print,Names[i],RAHs[i],RAMs[i],RASs[i],DECDs[i],DECMs[i],DECSs[i]			; Print user's search results
                                        endif
                                    endfor

                                    for i=0,N_ELEMENTS(RAHs)-1 do begin
                                        if RAHs[i] eq search_ceiling then begin
                                            RAA = [RAHs[i],RAMs[i],RASs[i],DECDs[i],DECMs[i],DECSs[i]]                  ; Take only the number columns and add them to a temporary list
                                            RAAS.add,RAA																; Add them
                                            NAA.add,Names[i]															; Take all the names that match that data and add them to another temporary list
                                            CC.add,Names[i]	
                                            RALS = list(Names[i],RAA,/EXTRACT)											; Combine the lists to show user's search results and provide a count
                                            print,Names[i],RAHs[i],RAMs[i],RASs[i],DECDs[i],DECMs[i],DECSs[i]			; Print user's search results
                                        endif
                                    endfor
                                endif

                            ; Counts the temporary lists to make sure they have stuff in them and prints communications

                                RC = RALS.count()
                                Counter = CC.count()

                            ; If there are no matches do this

                                if RC lt 1 then begin
                                    print,"Sorry. No Matches."
                                    print,""
                                endif

                            ; If the user entered a number that can not be an RAH do this

                                if user_RAh gt 23 then begin						; If the user enters a number bigger than 23.99, explain why that isn't allowed
                                    print,"Right Ascension Hours Go From 1 - 23.99"
                                    print,""
                                endif

                            ; If there are matches, ask the user to pick one to proceed with

                                if	RC ge 1 then begin								
                                    print,""
                                
                                ; Repeats until the user has picked a line number on the list

                                    repeat begin
                                        read,line_selector,prompt="Which Line Number Would You Like to Proceed With? "
                                        print,""
                                    endrep until line_selector le Counter

                                ; Assign the most recent selected source's data to variables for display and calling

                                    RAh = RAAS[line_selector - 1,0]
                                    RAm = RAAS[line_selector - 1,1]
                                    RAs = RAAS[line_selector - 1,2]
                                    DecD = RAAS[line_selector - 1,3]
                                    DecM = RAAS[line_selector - 1,4]
                                    DecS = RAAS[line_selector - 1,5]

                                ; Print the final choice from user and indicate the next step is being started

                                    print,""
                                    print,"Proceeding with: "
                                    print,NAA[line_selector - 1]
                                    print,""
                                    print,"RA Hr: ",RAh
                                    print,"RA Min: ",RAm
                                    print,"RA Sec: ",RAs
                                    print,"Dec Deg: ",DecD
                                    print,"Dec Min: ",DecM
                                    print,"Dec Sec: ",DecS
                                    print,""

                                ; Identify if the chosen source is a star or constellation
                                ; Constellations are not point sources, so their location information is more general without minutes or seconds
                                ; This tests if the minutes and seconds are 0 in BOTH Dec and RA

                                    if (RAm eq 0) && (RAs eq 0) && (DecM eq 0) && (DecS eq 0) then begin
                                        print,"This Source Is A Constellation!"
                                        print,""
                                    endif else begin
                                        print,"This Source Is A Star!"
                                        print,""
                                    endelse

                                ; Print the selected source and its info to the GDLSearch file	

                                    printf,2,systime()
                                    printf,2,NAA[line_selector - 1],":"
                                    printf,2,"RAh: ",RAh
                                    printf,2,"RAm: ",RAm
                                    printf,2,"RAs: ",RAs
                                    printf,2,"DecD: ",DecD
                                    printf,2,"DecM: ",DecM
                                    printf,2,"DecS: ",DecS

                                endif           ; End if for when there are matches to display

                            endif			; End if mode 2 is selected

                    ; Mode 3 Selected ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                        ; If Search Mode 3 is selected do this

                            if mode eq 3 then begin

                            ; Ask the user what Dec Degrees they want

                                read,user_DecD,prompt="What Declination Degrees Are You Searching For? "
                                print,""

                            ; Ask for a search range input and then indicate searching

                                read,user_range,prompt="Please Enter A Plus Or Minus Value For The Search Range. Entering 0 Means Only Exact Matches Will Be Shown. "
                                print,""
                                print,"Searching for Dec Degrees With Your Value..."
                                print,""

                            ; Create some lists and arrays to be able to manipulate the master file
                                DecDL = list()
                                RALS = list()
                                DLL = []
                                DLLS = list()
                                NAAS = list()
                                CC = list()


                            ; Print titles for display

                                print," Name ------- RAh ------- RAm ------- RAs ------- DecD ------- DecM ------- DecS "

                            ; If a range is entered do this

                                if user_range gt 0 then begin
                                    search_floor = (user_DecD - user_range)

                                ; Go through DataList and search for DecD minus user_range
                                ; Only happens if the user picks a range above 0
                                ; Goes through the list of DecDs and if the source is a match, it adds it to a main list for display

                                    for i=0,N_ELEMENTS(DECDs)-1 do begin
                                        if DECDs[i] eq search_floor then begin
                                            DLL = [RAHs[i],RAMs[i],RASs[i],DECDs[i],DECMs[i],DECSs[i]]				; Take only the numbers from the list and arrange them to be checked and displayed
                                            DLLS.add,DLL															; Add them to a temporary list
                                            NAAS.add,Names[i]														; Add the names to a temporary list
                                            CC.add,Names[i]
                                            DecDL = list(Names[i],DLL,/EXTRACT)										; Combine the temporary lists
                                            print,Names[i],RAHs[i],RAMs[i],RASs[i],DECDs[i],DECMs[i],DECSs[i]		; Print the matches for the users search
                                        endif
                                    endfor

                                    for i=0,N_ELEMENTS(DECDs)-1 do begin
                                        if (DECDs[i] gt search_floor) && (DECDs[i] lt user_DecD) then begin
                                            DLL = [RAHs[i],RAMs[i],RASs[i],DECDs[i],DECMs[i],DECSs[i]]				; Take only the numbers from the list and arrange them to be checked and displayed
                                            DLLS.add,DLL															; Add them to a temporary list
                                            NAAS.add,Names[i]														; Add the names to a temporary list
                                            CC.add,Names[i]
                                            DecDL = list(Names[i],DLL,/EXTRACT)										; Combine the temporary lists
                                            print,Names[i],RAHs[i],RAMs[i],RASs[i],DECDs[i],DECMs[i],DECSs[i]		; Print the matches for the users search
                                        endif
                                    endfor

                                endif

                            ; Go through DataList and search for DECDs that match the users search
                            ; Goes through the list of DecDs and if the source is a match, it adds it to a main list for display

                                    for i=0,N_ELEMENTS(DECDs)-1 do begin
                                        if DECDs[i] eq user_DecD then begin
                                            DLL = [RAHs[i],RAMs[i],RASs[i],DECDs[i],DECMs[i],DECSs[i]]				; Take only the numbers from the list and arrange them to be checked and displayed
                                            DLLS.add,DLL															; Add them to a temporary list
                                            NAAS.add,Names[i]														; Add the names to a temporary list
                                            CC.add,Names[i]
                                            DecDL = list(Names[i],DLL,/EXTRACT)										; Combine the temporary lists
                                            print,Names[i],RAHs[i],RAMs[i],RASs[i],DECDs[i],DECMs[i],DECSs[i]		; Print the matches for the users search
                                        endif
                                    endfor

                            ; Go through DataList and search for DecD minus user_range
                            ; Only happens if the user picks a range above 0
                            ; Goes through the list of DecDs and if the source is a match, it adds it to a main list for display

                                if user_range gt 0 then begin
                                    search_ceiling = (user_DecD + user_range)

                                    for i=0,N_ELEMENTS(DECDs)-1 do begin
                                        if (DECDs[i] gt user_DecD) && (DECDs[i] lt search_ceiling) then begin
                                            DLL = [RAHs[i],RAMs[i],RASs[i],DECDs[i],DECMs[i],DECSs[i]]				; Take only the numbers from the list and arrange them to be checked and displayed
                                            DLLS.add,DLL															; Add them to a temporary list
                                            NAAS.add,Names[i]														; Add the names to a temporary list
                                            CC.add,Names[i]
                                            DecDL = list(Names[i],DLL,/EXTRACT)										; Combine the temporary lists
                                            print,Names[i],RAHs[i],RAMs[i],RASs[i],DECDs[i],DECMs[i],DECSs[i]		; Print the matches for the users search
                                        endif
                                    endfor

                                    for i=0,N_ELEMENTS(DECDs)-1 do begin
                                        if DECDs[i] eq search_ceiling then begin
                                            DLL = [RAHs[i],RAMs[i],RASs[i],DECDs[i],DECMs[i],DECSs[i]]				; Take only the numbers from the list and arrange them to be checked and displayed
                                            DLLS.add,DLL															; Add them to a temporary list
                                            NAAS.add,Names[i]														; Add the names to a temporary list
                                            CC.add,Names[i]
                                            DecDL = list(Names[i],DLL,/EXTRACT)										; Combine the temporary lists
                                            print,Names[i],RAHs[i],RAMs[i],RASs[i],DECDs[i],DECMs[i],DECSs[i]		; Print the matches for the users search
                                        endif
                                    endfor

                                endif
                            
                            ; Test to make sure there are matches to the users search

                                DL = DecDL.count()
                                Counter = CC.count()

                            ; If there are no matches do this

                                if DL lt 1 then begin
                                    print,"Sorry. No Matches."
                                    print,""
                                endif

                            ; If there are matches, ask the user to pick one to proceed with

                                if	DL ge 1 then begin								
                                    print,""

                                ; Repeats until the user picks a line that is displayed

                                    repeat begin
                                        read,line_selector,prompt="Which Line Would You Like to Proceed With? "
                                        print,""
                                    endrep until line_selector le Counter

                                ; Assign the most recent selected source's data to variables for display and calling

                                    RAh = DLLS[line_selector - 1,0]
                                    RAm = DLLS[line_selector - 1,1]
                                    RAs = DLLS[line_selector - 1,2]
                                    DecD = DLLS[line_selector - 1,3]
                                    DecM = DLLS[line_selector - 1,4]
                                    DecS = DLLS[line_selector - 1,5]

                                ; Print the final choice from user and indicate the next step is being started

                                    print,""
                                    print,"Proceeding with: "
                                    print,""
                                    print,NAAS[line_selector - 1]
                                    print,""
                                    print,"RA Hr: ",RAh
                                    print,"RA Min: ",RAm
                                    print,"RA Sec: ",RAs
                                    print,"Dec Deg: ",DecD
                                    print,"Dec Min: ",DecM
                                    print,"Dec Sec: ",DecS
                                    print,""

                                ; Identify if the chosen source is a star or constellation
                                ; Constellations are not point sources, so their location information is more general without minutes or seconds
                                ; This tests if the minutes and seconds are 0 in BOTH Dec and RA

                                    if (RAm eq 0) && (RAs eq 0) && (DecM eq 0) && (DecS eq 0) then begin
                                        print,"This Source Is A Constellation!"
                                        print,""
                                    endif else begin
                                        print,"This Source Is A Star!"
                                        print,""
                                    endelse

                                ; Print the selected source and its info to the GDLSearch file

                                    printf,2,systime()
                                    printf,2,NAAS[line_selector - 1],':'
                                    printf,2,"RAh: ",RAh
                                    printf,2,"RAm: ",RAm
                                    printf,2,"RAs: ",RAs
                                    printf,2,"DecD: ",DecD
                                    printf,2,"DecM: ",DecM
                                    printf,2,"DecS: ",DecS

                                endif
            
                            endif   ; End if mode 3 is selected

                ; Ask the user if they want to start over and search again

                        repeat begin
                            print,"Would You Like To Start The Search Over Again?"
                            read,end_Ref4,prompt="|1 - Yes| |0 - No| "
                        endrep until (end_Ref4 le 1) && (end_Ref4 ge 0)

                    endrep until end_Ref4 eq 0				; End repeat from very beginning if user chooses not to start over

                ; Makes sure the user knows where to find the files that log what happened in their session
                ; Warn them that they will be overwritten with every new session

                    print,""
                    print,"***"
                    print,"Please Make Sure To Find 'GDLSearch.txt' As Well As 'GDLsearchJournal.txt' In The Directory Where This Program Is Saved."
                    print,"'GDLSearch.txt' Provides A Log of The Stars That Were Selected. 'GDLsearchJournal' Provides A Detailed Log Of Everything Printed To Screen."
                    print,"Both Files Are Overwritten With Every New Call Of The Program. Once It Is Started Again, This Session Will Be Lost."
                    print,"***"
                    print,""

                ; End the search
                    print,"End Search."
                    print,""

            endif                           ; End if for .csv search option

        ; If Search Option 2 is picked do this

            if search_option eq 2 then begin

            ; Repeats this question until one of the options is picked

                repeat begin
                    print,""
                    print,"Is The Observation Date During Daylight Savings Time? "
                    read,time_mode,prompt="|1 - Yes| |0 - No| "
                    print,""
                endrep until (time_mode le 1) && (time_mode ge 0)

                ; If Time Mode is 0 do this

                    if time_mode eq 0 then begin

                    ; Ask for the hour of observation to calculate HA of the Mean Sun

                        read,MST,prompt="What Is The Time Of Observation In 24-hr Format? (Example: 10:30 pm should be entered as 22.5) "
                        print,""

                        HAms = MST - 12
                        
                    ; Find RAms for this observation date

                        repeat begin                            ; Repeats the RA calculation section until the user wants to stop

                        ; Repeats this question until the user picks one of the options

                            repeat begin
                                print,"How Would You Like To Calculate Right Ascension Of The Mean Sun?"
                                read,search_mode,prompt="|1 - Using Day Of The Julian Calendar| |2 - Using Days Since Vernal Equinox| "
                                print,""
                            endrep until search_mode le 2 && search_mode ge 1


                            ; If search_mode 1 is picked do this

                                if search_mode eq 1 then begin 

                                ; User inputs for calculation

                                    read,t,prompt="What Day Of The Julian Calendar Would You Like To Use? "
                                    print,""
                                    RA = 18.62 + (.0657 * t)

                                ; If the RA is bigger than 24, it has gone around the entire CE and must have 24 subtracted from it. Do this

                                    if RA gt 24 then begin
                                        new_RA = RA - 24
                                        print,"Right Ascension Of The Mean Sun On This Day Is: ", (new_RA)
                                        print,""
                                        RAms = new_RA
                                    endif

                                ; Prints the RA if it is less than 24

                                    if RA le 24 then begin
                                    print,"Right Ascension Of The Mean Sun On This Day Is: ", RA
                                        print,""
                                        RAms = RA
                                    endif

                                endif           ; End if for Search Mode 1
                                
                            ; If search_mode 2 is picked, do this

                                if search_mode eq 2 then begin

                                ; User inputs for calculation

                                    read,tv,prompt="How Many Days Since The Vernal Equinox? "
                                    print,""
                                    RA = 0.0 + (24.0/365.0) * tv

                                ; If the RA is bigger than 24, it has gone around the entire CE and must have 24 subtracted from it. Do this

                                    if RA gt 24 then begin
                                        new_RA = RA - 24
                                        print,"Right Ascension Of The Mean Sun On This Day Is: ", (new_RA)
                                        print,""
                                        RAms = new_RA
                                    endif

                                ; Prints the RA if it is less than 24

                                    if RA le 24 then begin
                                    print,"Right Ascension Of The Mean Sun On This Day Is: ", RA
                                        print,""
                                        RAms = RA
                                    endif

                                endif               ; End if for Search Mode 1

                            ; Repeats question until one of the choices is picked

                                repeat begin
                                    print,"Would You Like To Calculate A New RA?"
                                    read,end_RASun,prompt="|1 - Yes| |0 - No| "
                                    print,""
                                endrep until end_RASun le 1

                        endrep until end_RASun eq 0             ; End RASun calculation

                        ; Calculates the Local Sidereal Time for the observation date and time

                            LST = RAms + HAms

                        ; Displays the information calculated
                            
                            if LST gt 24 then begin
                                new_LST = LST - 24
                            endif else begin
                                new_LST = LST
                            endelse

                            print,"The Local Sidereal Time Is: ",new_LST
                            print,""

                        ; Adds and subtracts 6 hours to the RA hour.
                        ; The calculated RA will be transiting the meridian so adding and subtracting 6 will give the RA values on the horizon to the east and west

                            RA_w = new_LST - 6
                            RA_e = new_LST + 6

                        ; Shows the RA hours on the horizon

                            print,"Looking South At This Time, Sources With An RA Hour Between The Following Two Values Will Be Visible. "
                            print,""

                            if RA_e lt 0 then begin
                                new_RA_e = 24 + RA_e
                                RA_e = new_RA_e
                            endif 

                            if RA_e gt 24 then begin
                                new_RA_e = RA_e - 24
                                RA_e = new_RA_e
                            endif 

                            print,"RA To The East ",RA_e


                            if RA_w lt 0 then begin
                                new_RA_w = 24 + RA_w
                                RA_w = new_RA_w
                            endif 

                            if RA_w gt 24 then begin
                                new_RA_w = RA_w - 24
                                RA_w = new_RA_w
                            endif

                            print,"RA To The West ",RA_w
                    
                            print,""

                    endif               ; Ends if Time Mode is 0

                ; If Time Mode 1 is picked do this

                    if time_mode eq 1 then begin

                    ; User inputs for calculation

                        read,MST,prompt="What Is The Time Of Observation In 24-hr Format? (Example: 10:30 pm should be entered as 22.5) "
                        print,""

                    ; If Daylight Saving Time is being observed, the time is one hour ahead of MST and a conversion is needed

                        DST = MST + 1
                        HAms = DST - 13
                        

                    ; Calculate RA of the Mean Sun and repeat until the user doesn't want to calculate a new one

                        repeat begin

                        ; Repeats the question until one of the choices is picked

                            repeat begin
                                print,"How Would You Like To Calculate Right Ascension Of The Mean Sun?"
                                read,search_mode,prompt="|1 - Using Day Of The Julian Calendar| |2 - Using Days Since Vernal Equinox| "
                                print,""
                            endrep until search_mode le 2 && search_mode ge 1

                            ; If search_mode 1 is picked do this

                                if search_mode eq 1 then begin 
                                
                                ; User inputs for calculation

                                    read,t,prompt="What Day Of The Julian Calendar Would You Like To Use? "
                                    print,""
                                    RA = 18.62 + (.0657 * t)

                                ; If the RA is bigger than 24, it has gone around the entire CE and must have 24 subtracted from it. Do this

                                    if RA gt 24 then begin
                                        new_RA = RA - 24
                                        print,"Right Ascension Of The Mean Sun On This Day Is: ", (new_RA)
                                        print,""
                                        RAms = new_RA
                                    endif

                                ; Prints the RA if it is less than 24

                                    if RA le 24 then begin
                                        print,"Right Ascension Of The Mean Sun On This Day Is: ", RA
                                        print,""
                                        RAms = RA
                                    endif

                                endif               ; End if Search Mode 1 is picked
                                

                                ; If search_mode 2 is picked, do this

                                    if search_mode eq 2 then begin

                                    ; User inputs for calculation

                                        read,tv,prompt="How Many Days Since The Vernal Equinox? "
                                        print,""
                                        RA = 0.0 + (24.0/365.0) * tv

                                ; If the RA is bigger than 24, it has gone around the entire CE and must have 24 subtracted from it. Do this

                                        if RA gt 24 then begin
                                            new_RA = RA - 24
                                            print,"Right Ascension Of The Mean Sun On This Day Is: ", (new_RA)
                                            print,""
                                            RAms = new_RA
                                        endif

                                ; Prints the RA if it is less than 24

                                        if RA le 24 then begin
                                            print,"Right Ascension Of The Mean Sun On This Day Is: ", RA
                                            print,""
                                            RAms = RA
                                        endif

                                    endif               ; End if Search Mode 2 is picked

                        ; Repeats this question until the user picks a choice that is available
                            repeat begin
                                print,"Would You Like To Calculate A New RA?"
                                read,end_RASun,prompt="|1 - Yes| |0 - No| "
                                print,""
                            endrep until end_RASun le 1

                        endrep until end_RASun eq 0         ; Ends the RASun calculation

                        ; Calculates Local Sidereal Time for observation date and time

                            LST = RAms + HAms

                        ; Displays the information calculated

                            if LST gt 24 then begin
                                new_LST = LST - 24
                            endif else begin
                                new_LST = LST
                            endelse

                            print,"The Local Sidereal Time Is: ",new_LST
                            print,""

                        ; Adds and subtracts 6 hours to the RA hour.
                        ; The calculated RA will be transiting the meridian so adding and subtracting 6 will give the RA values on the horizon to the east and west

                            RA_w = new_LST - 6
                            RA_e = new_LST + 6

                        ; Shows the RA hours on the horizon

                            print,"Looking South At This Time, Sources With An RA Hour Between The Following Two Values Will Be Visible. "
                            print,""

                            if RA_e lt 0 then begin
                                new_RA_e = 24 + RA_e
                                RA_e = new_RA_e
                            endif 

                            if RA_e gt 24 then begin
                                new_RA_e = RA_e - 24
                                RA_e = new_RA_e
                            endif 

                            print,"RA To The East ",RA_e


                            if RA_w lt 0 then begin
                                new_RA_w = 24 + RA_w
                                RA_w = new_RA_w
                            endif 

                            if RA_w gt 24 then begin
                                new_RA_w = RA_w - 24
                                RA_w = new_RA_w
                            endif

                            print,"RA To The West ",RA_w
                    
                            print,""

                    endif               ; End if Time Mode 1 is picked

            endif                       ; End if Search Option 2 is picked

        repeat begin
            print,"Would You Like To Return To The Home Menu?"
            read,over,prompt="|1 - Yes| |0 - No| "
        endrep until over le 1

        endif           ; End if for Home Menu option 1

    ; If Home Menu option 2 is picked do this

        if choice eq 2 then begin

        ; Prints something to make the user experience a bit better

            print,""
            print,"...Accessing Calculations..."                  ; User experience
            print,""

        ; Show options for what the user can calculate
        ; Repeats until one of the options is picked

            repeat begin
                print,"What Would You Like To Calculate?"
                print,"|1 - Day Of Year|  |2 - Declination Of The Mean Sun|  |3 - Right Ascension Of The Mean Sun|  |4 - Telescope Calculations| "
                read,mode,prompt="|5 - Solar System Distance Conversion| "
                print,""
            endrep until (mode ge 1) && (mode le 5)

        ; If Calculation Mode 1 is picked do this

            if mode eq 1 then begin
                
            ; Repeats mode 1 until the user wants to stop

                repeat begin

                ; Input Month
                ; Repeats until the user enters a number that corresponds to a month

                    repeat begin
                        read,Mon,prompt="Enter Month in MM Format: "
                        print,""
                    endrep until (Mon gt 0) && (Mon le 12)

                ; Input Date
                ; Repeats until the user enters a number that corresponds to a date

                    repeat begin
                        read,Date,prompt="Enter Date in DD Format: "
                        print,""
                    endrep until (Date gt 0) && (Date le 31)

                ; Determine the day of the year from the date

                    DoY=0
                
                ; Creates an array that contains the day numbers of the firsts of each month to calculate the day of the year
                
                    DoMon=[0,31,59,90,120,151,181,212,243,273,304,334]

                ; Calculates the day of the year

                    DoY=DoMon[Mon-1] + Date

                ; display the calculated day of the year 

                    print,"The Day Of The Year is: ",DoY
                    print,""

                ; Repeats the question until the user picks one of the options

                    repeat begin
                        print,"Would You Like To Calculate Again?"
                        read,end_DOY,prompt="|1 - Yes| |0 - No| "
                        print,""
                    endrep until end_DOY le 1

                endrep until end_DOY eq 0               ; End DOY calculation


            endif                   ; End if Calculation Mode 1 is picked
            
        ; If Calculation Mode 2 is picked do this

            if mode eq 2 then begin
            
            ; Repeats the beginning question until one of the choices is picked

                repeat begin

                ; Repeats the calculation until the user wants to stop

                    repeat begin

                    ; Offer choices for how to calculate Dec of the Mean Sun

                        repeat begin
                            print,"How Would You Like To Calculate Declination Of The Mean Sun?"
                            read,mode,prompt="|1 - Using Day Of The Julian Calendar| |2 - Using Days Since Vernal Equinox| "
                            print,""
                        endrep until (mode le 2) && (mode ge 1)

                    ; If mode 1 is picked then do this

                        if mode eq 1 then begin

                        ; user inputs for calculation

                            repeat begin
                                read,t,prompt="What Day Of The Julian Calendar Would You Like To Use? "
                                print,""
                            endrep until (t ge 1) && (t le 365)
                        
                        ; Calculate Dec of the Mean Sun and display

                            Dec = 23.5*sin((2*!pi/365)*(t-79))
                            print,"Declination Of The Mean Sun On This Day Is: ", Dec
                            print,""

                        endif               ; End if mode 1 is picked

                    ; If mode 2 is picked then do this

                        if mode eq 2 then begin

                        ; User inputs for calculation

                            read,tv,prompt="How Many Days Since The Vernal Equinox? "
                            print,""

                        ; Calculate Dec of the Mean Sun and display

                            Dec = 23.5*sin((2*!pi/365)*tv)
                            print,"Declination Of The Mean Sun On This Day Is: ", Dec
                            print,""

                        endif               ; End if mode 2 is picked

                    ; Repeats the question until the user picks an available option

                        repeat begin
                            print,"Would You Like To Calculate Again?"
                            read,end_DecSun,prompt="|1 - Yes| |0 - No| "
                            print,""
                        endrep until end_DecSun le 1

                    endrep until end_DecSun eq 0            ; End repeat for DecSun calculation
                
                endrep until mode le 2 && mode ge 1             ; End repeat to make sure user picks an available option


            endif                   ; End if mode 2 is picked

        ; If Calculation Mode 3 is picked do this

            if mode eq 3 then begin
            
            ; Repeats until one of the available options is picked

                repeat begin

                ; Repeats until the calculation until the user wants to stop

                    repeat begin

                    ; Offer options for how to calculate RA of the Mean Sun

                        repeat begin
                            print,"How Would You Like To Calculate Right Ascension Of The Mean Sun?"
                            read,mode,prompt="|1 - Using Day Of The Julian Calendar| |2 - Using Days Since Vernal Equinox| "
                            print,""
                        endrep until (mode ge 1) && (mode le 2)

                        ; If mode 1 is picked do this

                            if mode eq 1 then begin 
                            
                            ; User inputs for calculation

                                repeat begin
                                    read,t,prompt="What Day Of The Julian Calendar Would You Like To Use? "
                                    print,""
                                endrep until (t ge 1) && (t le 365)

                            ; Calculate RA of the Mean Sun
                                RA = 18.62 + (.0657 * t)

                            ; If the RA is bigger than 24, it has gone around the entire CE and must have 24 subtracted from it. Do this

                                if RA gt 24 then begin
                                    new_RA = RA - 24
                                    print,"Right Ascension Of The Mean Sun On This Day Is: ", (new_RA)
                                    print,""
                                    RAms = new_RA
                                endif

                            ; Prints the RA if it is less than 24

                                if RA le 24 then begin
                                print,"Right Ascension Of The Mean Sun On This Day Is: ", RA
                                    print,""
                                    RAms = RA
                                endif

                            endif           ; End if for mode 1 
                            

                        ; If mode 2 is picked, do this

                            if mode eq 2 then begin

                            ; User inputs for calculation

                                read,tv,prompt="How Many Days Since The Vernal Equinox? "
                                print,""

                            ; Calculate RA of the Mean Sun

                                RA = 0.0 + (24.0/365.0) * tv

                            ; If the RA is bigger than 24, it has gone around the entire CE and must have 24 subtracted from it. Do this

                                if RA gt 24 then begin
                                    new_RA = RA - 24
                                    print,"Right Ascension Of The Mean Sun On This Day Is: ", (new_RA)
                                    print,""
                                    RAms = new_RA
                                endif

                            ; Prints the RA if it is less than 24

                                if RA le 24 then begin
                                print,"Right Ascension Of The Mean Sun On This Day Is: ", RA
                                    print,""
                                    RAms = RA
                                endif

                            endif           ; End if mode 2 is picked

                        repeat begin
                            print,"Would You Like To Calculate Again?"
                            read,end_RASun,prompt="|1 - Yes| |0 - No| "
                            print,""
                        endrep until end_RASun le 1

                    endrep until end_RASun eq 0             ; End repeat for RASun calculation

                endrep until mode le 2 && mode ge 1         ; End repeat for the beginning question

            endif                           ; End if mode 3 is picked

         ; If calculation mode 4 is picked do this

             if mode eq 4 then begin

             ; Repeats the choice until the user picks one on the menu

                 repeat begin
                     print,"What Would You Like To Calculate? "
                     read,tele_choice,prompt="|1 - Angular Magnification| |2 - Angular Resolution|  |3 - Focal Ratio|  |4 - Snell's Law Solver For Angle Of Refraction| "
                     print,""
                 endrep until (tele_choice ge 1) && (tele_choice le 4)

             ; If tele_choice is 1 do this
                 if tele_choice eq 1 then begin
                     read,f_obj,prompt="What Is The Focal Length Of The Objective Mirror or Lens? "
                     print,""
                     read,f_eye,prompt="What Is The Focal Length Of The Eyepiece Being Used? "
                     print,""
                     m = f_obj / f_eye
                     print,"The Angular Magnification For Your Combination Of Focal Lengths Is: "
                     print,m
                     print,""
                 endif           ; End if tele_choice is 1

             ; If tele_choice is 2 do this

                 if tele_choice eq 2 then begin
                     read,L,prompt="What Is The Minimum Separation Between Objects That Can Be Resolved? "
                     print,""
                     read,distance,prompt="What Is The Distance Between The Observer And The Source? "
                     print,""
                     ang_res = L / distance
                     print,"The Angular Resolution Of The Telescope Is: "
                     print,ang_res
                     print,""
                 endif           ; End if tele_choice is 2

             ; If tele_choice is 3 do this

                 if tele_choice eq 3 then begin
                     read,f_length,prompt="What Is The Focal Length Of The Objective Mirror Or Lens? "
                     print,""
                     read,diameter,prompt="What Is The Diameter Of The Telescope Aperture? "
                     F = f_length / diameter
                     print,"The Focal Ratio Of The Telescope Is: "
                     print,F
                     print,""
                 endif           ; End if tele_choice is 3

             ; If tele_choice is 4 do this

                 if tele_choice eq 4 then begin
                     ;theta_1 = 0.0
                     read,n_1,prompt="What Is The Index Of Refraction For The Material Where The Light Originates? "
                     print,""
                     read,theta_1,prompt="What Is The Degree Angle Of Incidence Of Light Rays In The Original Material? "
                     theta_1_rad = theta_1 * (!pi/180)
                     print,""
                     read,n_2,prompt="What Is The Index Of Refraction For The Material Where The Light Refracts? "
                     print,""
                     theta_2_rad = asin((n_1 * sin(theta_1_rad)) / n_2)
                     theta_2 = theta_2_rad * (180/!pi)
                     print,"The Angle Of Refraction For This Material In Degrees Is: "
                     print,theta_2
                     print,"The Angle Of Refraction For This Material In Radians Is: "
                     print,theta_2_rad
                     print,""
                     
                 endif           ; End if tele_choice is 4

             endif               ; End if mode 4 is picked
             
             if mode eq 5 then begin
               
               read,user_dis,prompt="What Is The Total Distance Of The Space You Have (m)? "
               
               planets = list("Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune")
               dis = [57.9e9, 108.2e9, 149.6e9,227.9e9,778.6e9,1.4335e12,2.8725e12,4.4951e12]
               
               con_fact = user_dis / dis[7]
               
               new_dis = dis * con_fact                  
               
               planet_dict = dictionary(planets,new_dis)
               

               
               print, ""
               print,"Here Are The Distances For Your Model In Meters "
               print, planet_dict
               print,""
               
               
             endif                 ; End if mode 5 is picked

        ; Ask the user if they want to start over
        ; Repeats until the user picks an available option

            repeat begin
                print,"Would You Like To Return To The Home Menu?"
                read,over,prompt="|1 - Yes| |0 - No| "
            endrep until (over le 1) && (over ge 0)

        endif                       ; End if for Home Menu choice 2

    endrep until over eq 0          ; End repeat for the entire procedure

    ; Confirming end

    print,""
    print,"Thank You For Using Marsoft, The Ursinus Observatory Software Library! This Is An Open Source Project And Contributions Are Welcome! "
    print,"To Contribute Code Please Contact Ursinus College, Department of Physics and Astronomy To Ask How!"
    print,""
    print,"End Procedure."

end