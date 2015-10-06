:default ::= action => [name,values]
lexeme default = latm => 1

Script ::= 
    Definition 
    |Script Definition 

Definition ::= ExpDef | ParamDef |  RulDef | MapDef | DatDef | ScopeDef

MapDef ::= 
    'MAP' Term '->' cdec          action => add_map
    |'MAP' Term '->' cdec 'GROUP'   action => add_map


ScopeDef ::= 'SCP' edec action => add_scope 
 
RulDef ::= 
     rdec step ':' 'WHEN' Term 'THEN' InfoVar action => add_rule_step
    |rdec step ':' 'ELSE' Term action => add_last_rule_step

ExpDef ::= edec ':' ComExp action => add_exp
ParamDef ::= pdec ':'  Value1 ',' Value2 action => add_param

DatDef ::= 
    dsdec ':' DataSet action => add_dataset
    |DatDef cdec ':' ColumnName action => add_col

ComExp ::= 
    Term Operator Term action => found_Exp 
    |ComExp Operator Term action => found_Exp

Term ::= InfoVar action => found_Term 
        | Function '[' InfoVar ']' action => found_funcTerm
        | Function '[' InfoVar ',' Params ']' action => found_funcTerm
        | '(' Exp ')' action => found_SubTerm

Exp ::= 
    InfoVar Operator InfoVar action => found_Exp
    |Exp Operator InfoVar action => found_Exp
   
InfoVar ::= pdec        action => found_InfoVar
        | pdec'.'Value  action => found_InfoVar
        | pdec'.'List   action => found_InfoVar
        | cdec          action => found_InfoVar
        | edec          action => found_InfoVar 
        | rdec          action => found_InfoVar
        | dsdec         action => found_InfoVar

rdec ~ 'Rul' num
pdec ~ 'Par' num 
cdec ~ 'Col' num 
edec ~ 'Exp' num 
step ~ '.s' num
dsdec ~ 'Dat' num 

num ~ [\d]+

Operator ~ MathOp | LogOp
MathOp ~ [\+\*\-\/]
LogOp ~ 'AND' | 'OR' | '<' | '>' | '=' | 'IN' | '<=' | '>=' | '<>'

Value ~ 'Value1' | 'Value2'
List ~ 'List1' | 'List2'

Value1 ~ Numeric | Anum | q Anum q
Value2 ~ Numeric | Anum | q Anum q
ColumnName ~ Anum
DataSet ~ Anum
Function ~ Anum
Params ~ csv

csv ~ Anum | csv ',' Anum
Anum ~ [\w]+
q ~ [\']

Num ~ [0-9]+
Float ~  Num '.' Num | '-'Float
Int ~ Num | '-'Num
Numeric ~ Float | Int


:discard ~ whitespace
whitespace ~ [\s]+

:discard ~ <hash comment>
<hash comment> ~ <terminated hash comment> | <unterminated
final hash comment>
<terminated hash comment> ~ '#' <hash comment body> <vertical space char>
<unterminated final hash comment> ~ '#' <hash comment body>
<hash comment body> ~ <hash comment char>*
<vertical space char> ~ [\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}]
<hash comment char> ~ [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}]


