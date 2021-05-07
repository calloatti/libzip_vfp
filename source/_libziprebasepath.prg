*!* _libziprebasepath

*!* REMOVES THE BASE PATH FROM A PATH

*!* EXAMPLE

*!* _libziprebasepath("C:\Windows\System32\somefile.dll", "C:\Windows")

*!* RETURNS "System32\somefile.dll"

lparameters psfilepath, pbasepath

return ltrim(strextract(m.psfilepath, m.pbasepath, '', 1, 1), 0, '\')