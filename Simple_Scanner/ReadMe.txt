我有做的Advanced Features
(我沒有多加function,是在程式碼裡加了很多判斷)

1.Discard C and C++ type comment ��
  加了comment line的RE,然後做判斷
  EX: //123456//656565    ---->這樣我只算一個,因為//是整行都是註解,包括後面的//
  EX: /*123456//656565*/  ---->這樣我只算一個,因為/*和*/之中都是註解,包括後面的//
2.Count the comment lines
  去找註解裡的\n,然後+1
3.Syntax error check: a.Redefined variables  b.Undeclared variables
  Redefined variables: var x int    我後面的x會先輸出 x int TYPE VAR,才再輸出x is redefined,再輸出 = assign 5 digit,
      		       var x int =5
       		       前面輸出x int TYPE VAR沒什麼問題,因為要先讀到x才知道他redefined,不過後面我又輸出= assign 5 digit,
      		       看起來很奇怪,可是我覺得既然都已經得到x redefined,那compile當然不會過,那後面輸出哪些就不是問題
  Undeclared variables:跟Redefined variables例子很像,x=5,x會先被讀到undeclared,可是後面又輸出= assign 5 digit,不過也沒關係


I also have readme here: https://hackmd.io/s/ryAuuBRnz