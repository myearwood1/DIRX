# DIRX
Extended version of DIRECTORY command, rather than ADIR because cursors are better than arrays.
ADIR was offered long ago, but having the files and folders dumped into a cursor was not. The DIRECTORY command writes to a file, but not a cursor. I used Christian Ehlscheid ADIREX to create DIRX which can build a cursor of 1 million files, when adir cannot.
DirX also supports a VFPPATH keyword to search all folders listed in the SET PATH.
It seems to be as fast as ADIR, but since a cursor is created, using that cursor in LOCATE/SQL SELECT is much faster than DO WHILE / FOR NEXT constructs.

Drop DIRX.PRG and the included files into your program directory. There is no point in adding any of it into a procedure library. As long as the files are within the SET PATH, you can run DIRX immediately, without set procedure to. That is natural.

To use it to produce a cursor of all files (recursively) in your VFP Set Path. 
DirX('c_TheFiles','VFPPATH*.*','',.T.)
With that, you can do operations on sets of files without looping. Here's how to find all .prg files that contain REPORT FORM. This is 5 times faster than GoFish.
IF DirX('c_TheFiles','VFPPATH*.*','',.T.) > 0

	*Which files contain "REPORT FORM"?
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
