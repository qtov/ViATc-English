; All programs are generic
<MSWord>:
    CustomActions ("<Wordleft>","Move [Count] times to the left")
    CustomActions ("<WordRight>","Move [Count] times to the right")
    CustomActions ("<WordUp>","Move up [Count] times")
    CustomActions ("<WordDown>","Move down [Count] times")
return
<WordAdd>:
	oWord := ComObjCreate("Word.Application")
	oWord.Documents.Add
	oWord.Selection.TypeText("Line1`n")
	oWord.Selection.TypeText("Line2`n")
	oWord.Selection.TypeText("Line3`n")
	oWord.Visible := True
return
<WordLeft>:
	oWord.Selection.Previous(1,1).Select
return
<WordRight>:
	oWord.Selection.Next(1,1).Select
return
<WordUp>:
	oWord.Selection.MoveUp(5,1)
return
<WordDown>:
	oWord.Selection.MoveDown(5,1)
return
