Fix bug of "Error lParam &lParam"
---

Convert `lParam` or/and `wParam` - when it is an input string - from type *string* to *pointer* which point to the string.

**New way** : `Param && (_MsgWithInputStringParam[msg] & 0x1) && !isObject(Param)`.
　`_MsgWithInputStringParam` is a static object, which key is `msg` (Scintilla functions, such as `SCI_ADDTEXT`), and value is a state of combination about `lParam` and `wParam`.
　The 0x1 (01 bin) indicate `wParam` is an input string which need to convert from type *string* to *pointer*, and so does 0x2 (10 bin) which indicate `lParam`.
　The set of key-value pairs in `_MsgWithInputStringParam` is filtered from `const char *` in **Scintilla Documentation** (1 May 2014 NH) with *SciLexer.dll* (3.4.3.0). And, convert from `SCI_ADDTEXT` to `addtext`.

Replace/Remove the **old way** - `Param && !(Param+0) && !isObject(Param)` - which get error when Param is a string of numerical value.

---

See [Fix bug of "Error lParam &lParam"](https://github.com/RaptorX/scintilla-wrapper/pull/3)
