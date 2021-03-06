PROCEDURE CorStruct
 IF MESSAGEBOX('�� ������ �������� '+CHR(13)+CHR(10)+;
               '������������� ��������� ��?!'+CHR(13)+CHR(10)+;
               '',4+48,'') != 6
  RETURN 
 ENDIF 

 IF MESSAGEBOX('�� ��������� ������� � ����� ���������?',4+48,'') != 6
  RETURN 
 ENDIF 

 ppriod = STR(tYear,4)+PADL(tMonth,2,'0')
 spriod = PADL(tMonth,2,'0')+RIGHT(STR(tYear,4),1)

 ppdir  = pbase+'\'+ppriod
 IF !fso.FolderExists(ppdir)
  MESSAGEBOX('����������� ���������� '+ppdir,0+16,'')  
  RETURN
 ENDIF 
 
 aisfile = ppdir+'\AisOms'
 IF !fso.FileExists(aisfile+'.dbf')
  MESSAGEBOX('����������� ���� '+aisfile,0+16,'')  
  RETURN
 ENDIF 
 
 IF OpenFile(aisfile, 'AisOms', 'shared', 'mcod')>0
  RETURN 
 ENDIF 
 IF OpenFile(pbase+'\'+gcperiod+'\nsi\UsrLpu', "UsrLpu", "shar", "mcod") > 0
  USE IN aisoms
  RETURN
 ENDIF 
 IF OpenFile(pbase+'\'+gcperiod+'\nsi\tarifn', "tarif", "shar", "cod") > 0
  IF USED('tarif')
   USE IN tarif
  ENDIF 
  USE IN aisoms
  RETURN
 ENDIF 
 IF OpenFile(pbase+'\'+gcperiod+'\nsi\profus', "profus", "shar", "cod") > 0
  IF USED('profus')
   USE IN profus
  ENDIF 
  USE IN tarif
  USE IN aisoms
  RETURN
 ENDIF 

 SELECT AisOms
 SCAN
  m.mcod = mcod
  m.IsVed   = IIF(LEFT(m.mcod,1) == '0', .F., .T.)
  m.lpuid = STR(lpuid,4)
  m.nvfile = 'nv'+m.lpuid

  WAIT m.mcod WINDOW NOWAIT 

  IF !fso.FolderExists(ppdir+'\'+m.mcod)
   LOOP 
  ENDIF 
  IF !fso.FileExists(ppdir+'\'+m.mcod+'\people.dbf')
   LOOP 
  ENDIF 
  IF !fso.FileExists(ppdir+'\'+m.mcod+'\talon.dbf')
   LOOP 
  ENDIF 
  IF OpenFile(ppdir+'\'+m.mcod+'\people', 'people', 'excl')>0
   LOOP 
  ENDIF 
  IF OpenFile(ppdir+'\'+m.mcod+'\talon', 'talon', 'excl')>0
   USE IN People
   LOOP 
  ENDIF 
  IF OpenFile(ppdir+'\'+m.mcod+'\m'+m.mcod, 'merror', 'excl')>0
   USE IN People
   LOOP 
  ENDIF 
  
  SELECT merror
  IF FIELD('subet')!='SUBET'
   ALTER TABLE merror ADD COLUMN SubEt n(1)
  ENDIF 
  
  SELECT talon 
  IF FIELD('Vz')!='VZ'
   ALTER TABLE Talon ADD COLUMN Vz L
  ENDIF 
  IF FIELD('lpu_ord')!='LPU_ORD'
   ALTER TABLE talon ADD COLUMN lpu_ord n(6)
  ENDIF 
  IF FIELD('date_ord')!='DATE_ORD'
   ALTER TABLE talon ADD COLUMN date_ord d
  ENDIF 
  IF FIELD('n_kd')!='N_KD'
   WAIT "���������� N_KD..." WINDOW NOWAIT 
   ALTER TABLE talon ADD COLUMN n_kd n(3)
   SCAN 
    m.tip = tip 
    IF EMPTY(m.tip)
     LOOP 
    ENDIF 
    m.cod = cod 
    IF !SEEK(m.cod, 'tarif')
     LOOP 
    ENDIF 
    m.n_kd = tarif.n_kd
    REPLACE n_kd WITH m.n_kd
   ENDSCAN 
   WAIT CLEAR 
  ENDIF 
  IF FIELD('mp')!='MP'
   WAIT "���������� MP..." WINDOW NOWAIT 
   ALTER TABLE talon ADD COLUMN mp c(1)
   WAIT CLEAR 
  ENDIF 
  
  IF m.qcod='S2'
  WAIT "�������� �������..." WINDOW NOWAIT 
  SCAN 
   m.cod = cod 
   m.profil = profil
   IF EMPTY(m.profil)
    m.profil = IIF(SEEK(m.cod, 'profus'), ALLTRIM(profus.profil), '')
    REPLACE profil WITH m.profil
   ELSE 
    EXIT 
   ENDIF 
  ENDSCAN 
  WAIT CLEAR 
  ENDIF 
  
  SELECT people
  IF FIELD('IsPr')!='ISPR'
   ALTER TABLE People ADD COLUMN IsPr L
  ENDIF 
  IF FIELD('s_all')!='S_ALL'
   ALTER TABLE People ADD COLUMN s_all n(11,2)
  ENDIF 
  IF FIELD('fil_id')!='FIL_ID'
   ALTER TABLE People ADD COLUMN fil_id n(6)
  ENDIF 
  IF FIELD('prmcod')!='PRMCOD'
   ALTER TABLE People ADD COLUMN prmcod c(7)
  ENDIF 
  IF FIELD('tipp')!='TIPP'
   ALTER TABLE People ADD COLUMN tipp c(1)
   SCAN 
    DO CASE 
     CASE IsEnp(sn_pol)
      REPLACE tipp WITH '�'
     CASE IsKms(sn_pol)
      REPLACE tipp WITH '�'
     CASE IsVs(sn_pol)
      REPLACE tipp WITH '�'
     OTHERWISE 
      REPLACE tipp WITH '�'
    ENDCASE 
   ENDSCAN 
  ENDIF 
*  USE 

  IF !fso.FileExists(ppdir+'\'+m.mcod+'\'+m.nvfile+'.dbf')
   IF fso.FileExists(ppdir+'\'+m.mcod+'\'+m.nvfile+'.'+spriod)
    fso.CopyFile(ppdir+'\'+m.mcod+'\'+m.nvfile+'.'+spriod, ppdir+'\'+m.mcod+'\'+m.nvfile+'.dbf')
    oSettings.CodePage(ppdir+'\'+m.mcod+'\'+m.nvfile+'.dbf', 866, .t.)
    IF OpenFile(ppdir+'\'+m.mcod+'\'+nvfile, 'nvfile', 'excl') == 0
     SELECT nvfile 
     INDEX ON pcod TAG pcod 
     USE 
    ENDIF 
   ENDIF 
  ELSE 
*   fso.DeleteFile(ppdir+'\'+m.mcod+'\'+m.nvfile+'.dbf')
*   fso.DeleteFile(ppdir+'\'+m.mcod+'\'+m.nvfile+'.cdx')
  ENDIF 

  IF USED('people')
   USE IN people
  ENDIF 
  IF USED('talon')
   USE IN talon 
  ENDIF 
  IF USED('merror')
   USE IN merror
  ENDIF 

  SELECT aisoms

 ENDSCAN 

 IF USED('aisoms')
  USE IN aisoms
 ENDIF 
 IF USED('usrlpu')
  USE IN UsrLpu
 ENDIF 
 IF USED('tarif')
  USE IN tarif
 ENDIF 
 IF USED('profus')
  USE IN profus
 ENDIF 
 
 WAIT CLEAR 

 MESSAGEBOX('OK!', 0+64, '')

RETURN 