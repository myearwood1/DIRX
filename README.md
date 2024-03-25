# DIRX
Extended version of DIRECTORY command, rather than ADIR because cursors are better than arrays.
ADIR was offered long ago, but having the files and folders dumped into a cursor was not. The DIRECTORY command writes to a file, but not a cursor. I used Christian Ehlscheid's ADIREX to create DIRX which can build a cursor of 1 million files, when adir cannot.
DirX also supports a VFPPATH keyword to search all folders listed in the SET PATH.
It seems to be as fast as ADIR, but since a cursor is created, using that cursor in LOCATE/SQL SELECT is much faster than DO WHILE / FOR NEXT constructs.

Drop DIRX.PRG and the included files into any folder in your vfp search path. There is no point in adding any of it into a procedure library as the purpose of these libraries is replaced by the OS long filenames. As long as the files are within the SET PATH, or simply part of your EXE, you can run DIRX immediately, without set procedure to. That is as natural as ?DATE().

To produce a cursor of all files (recursively) in your VFP Set Path. 
DirX('c_TheFiles','VFPPATH*.*','',.T.)
With that, you can do operations on sets of files without looping. Here's how to find all .prg files that contain REPORT FORM. This is 5 times faster than GoFish.

*Which files contain "REPORT FORM"?
IF DirX('c_TheFiles','VFPPATH*.*','',.T.) > 0
	select ;
		occurs('REPORT FORM',upper(filetostr(alltrim(fullname)))) as nHowMany,*  ;
	from ;
		c_TheFiles ;
	where ;
		upper(filename) # 'MYSEARCH.PRG' ;
		and fileext in ('PRG')  ;
	having ;
		nHowMany > 0 ;
	order by ;
		fileext ;
	INTO CURSOR ;
		JUSTTHESE ;
	NOFILTER
 ENDIF
