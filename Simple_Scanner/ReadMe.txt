§Ú¦³°µªºAdvanced Features
(§Ú¨S¦³¦h¥[function,¬O¦bµ{¦¡½X¸Ì¥[¤F«Ü¦h§PÂ_)

1.Discard C and C++ type comment ƒÜ
  ¥[¤Fcomment lineªºRE,µM«á°µ§PÂ_
  EX: //123456//656565    ---->³o¼Ë§Ú¥uºâ¤@­Ó,¦]¬°//¬O¾ã¦æ³£¬Oµù¸Ñ,¥]¬A«á­±ªº//
  EX: /*123456//656565*/  ---->³o¼Ë§Ú¥uºâ¤@­Ó,¦]¬°/*©M*/¤§¤¤³£¬Oµù¸Ñ,¥]¬A«á­±ªº//
2.Count the comment lines
  ¥h§äµù¸Ñ¸Ìªº\n,µM«á+1
3.Syntax error check: a.Redefined variables  b.Undeclared variables
  Redefined variables: var x int    §Ú«á­±ªºx·|¥ý¿é¥X x int TYPE VAR,¤~¦A¿é¥Xx is redefined,¦A¿é¥X = assign 5 digit,
      		       var x int =5
       		       «e­±¿é¥Xx int TYPE VAR¨S¤°»ò°ÝÃD,¦]¬°­n¥ýÅª¨ìx¤~ª¾¹D¥Lredefined,¤£¹L«á­±§Ú¤S¿é¥X= assign 5 digit,
      		       ¬Ý°_¨Ó«Ü©_©Ç,¥i¬O§ÚÄ±±o¬JµM³£¤w¸g±o¨ìx redefined,¨ºcompile·íµM¤£·|¹L,¨º«á­±¿é¥X­þ¨Ç´N¤£¬O°ÝÃD
  Undeclared variables:¸òRedefined variables¨Ò¤l«Ü¹³,x=5,x·|¥ý³QÅª¨ìundeclared,¥i¬O«á­±¤S¿é¥X= assign 5 digit,¤£¹L¤]¨SÃö«Y


I also have readme here: https://hackmd.io/s/ryAuuBRnz